require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'require_all'
require 'net/http'
require 'json'
require 'uri'
require_all '././MiningRepositories/Repository'
require_rel 'BadlyMergeScenarioExtractor'
require_rel 'CopyProjectDirectories'
require_rel 'ParentsMSDiff'
require_rel 'BCTypes/'

class GTAnalysis
	def initialize(gumTreePath, projectName, localClone)
		@mergeCommit = MergeCommit.new()
		@parentMSDiff = ParentsMSDiff.new(gumTreePath)
		@copyDirectories = CopyProjectDirectories.new()
		@projectName = projectName
		@pathLocalClone = localClone
		@gumTreePath = gumTreePath
	end

	def getProjectName()
		@projectName
	end

	def getPathLocalClone()
		@pathLocalClone
	end

	def getGumTreePath()
		@gumTreePath
	end

	def getParentsMFDiff()
		@parentMSDiff
	end

	def getCopyProjectDirectories()
		@copyProjectDirectories
	end

	def getGumTreeAnalysis(pathProject, build, conflictCauses)
		parents = @mergeCommit.getParentsMergeIfTrue(pathProject, build.commit.sha)
		actualPath = Dir.pwd
		
		pathCopies = @copyDirectories.createCopyProject(build.commit.sha, parents, pathProject)

		#  		   					result 		  left 			right 			MergeCommit 	parent1 		parent2 	problemas
		out = gumTreeDiffByBranch(build.commit.sha, pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4], conflictCauses, pathProject, parents)
		@copyDirectories.deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
		return out
	end

	def gumTreeDiffByBranch(mergeCommit, result, left, right, base, conflictCauses, pathProject, parents)
		baseLeft = @parentMSDiff.runAllDiff(base, left)
		baseRight = @parentMSDiff.runAllDiff(base, right)
		leftResult = @parentMSDiff.runAllDiff(left, result)
		rightResult = @parentMSDiff.runAllDiff(right, result)
		# passar como parametro o caminho dos diretorios (base, left, right, result). Por enquanto apenas o left e right
		return verifyModificationStatus(mergeCommit, baseLeft, leftResult, baseRight, rightResult, conflictCauses, left, right, pathProject, parents)
	end

	def deleteProjectCopies(pathCopies)
		index = 0
		while(index < pathCopies.size)
			delete = %x(rm -rf #{pathCopies[index]})	
			index += 1
		end
	end

	def verifyModificationStatus(mergeCommit, baseLeft, leftResult, baseRight, rightResult, conflictCauses, leftPath, rightPath, pathProject, parents)
		badlyMergeScenariosExtractor = BadlyMergeScenarioExtractor.new(getProjectName(), pathProject, getPathLocalClone())
		statusModified = badlyMergeScenariosExtractor.verifyBadlyMergeScenario(parents[0], parents[1], mergeCommit)
		if (statusModified == false)
			statusModified = verifyModifiedFile(baseLeft[0], leftResult[0], baseRight[0], rightResult[0])
		end
		statusAdded = verifyAddedDeletedFile(baseLeft[1], leftResult[1], baseRight[1], rightResult[1])
		statusDeleted = verifyAddedDeletedFile(baseLeft[2], leftResult[2], baseRight[2], rightResult[2])
		
		conflictingContributions = []
		allIntegratedContributions = false
		indexValue = 0
		conflictCauses.getCausesConflict().each do |conflictCause|
			if(conflictCause == "unimplementedMethod")
				bcUnimplementedMethod = BCUnimplementedMethod.new()
				if (bcUnimplementedMethod.verifyBuildConflict(baseLeft[0], leftResult[0], baseRight[0], rightResult[0], conflictCauses.getFilesConflict()[indexValue]) == false)
					conflictingContributions[indexValue] = false
				end
			elsif (conflictCause == "unavailableSymbolMethod" || conflictCause == "unavailableSymbolVariable" || conflictCause == "unavailableSymbolFile")
				bcUnavailableSymbol = BCUnavailableSymbol.new()
				if (bcUnavailableSymbol.verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, conflictCauses.getFilesConflict()[indexValue], leftPath, rightPath) == false)
					conflictingContributions[indexValue] = false
				end
			elsif (conflictCause == "statementDuplication")
				bcStatementDuplication = BCStatementDuplication.new()
				if (bcStatementDuplication.verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, conflictCauses.getFilesConflict()[indexValue]) == false)
					conflictingContributions[indexValue] = false
				end
			elsif (conflictCause == "methodParameterListSize")
				bcMethodUpdate = BCMethodUpdate.new(getGumTreePath())
				if (bcMethodUpdate.verifyBuildConflict(leftPath, rightPath, conflictCauses.getFilesConflict()[indexValue]) == false)
					conflictingContributions[indexValue] = false
				end
			elsif (conflictCause == "dependencyProblem")
				bcDependency = BCDependency.new()
				if (bcDependency.verifyBuildConflict(baseLeft[0], leftResult[0], baseRight[0], rightResult[0], conflictCauses.getFilesConflict()[indexValue]) == true)
					conflictingContributions[indexValue] = false
				end
			end
			conflictingContributions[indexValue] = true
			indexValue += 1
		end
		
		if (statusModified and statusAdded and statusDeleted)
			return conflictingContributions, true
		else
			return conflictingContributions, false
		end
	end

	def verifyAddedDeletedFile(baseLeftInitial, leftResultFinal, baseRightInitial, rightResultFinal)
		if(baseLeftInitial.size > 0) 
			baseLeftInitial.each do |fileLeft|
				if (!rightResultFinal.include?(fileLeft))
					return false
				end
			end
		end
		if (baseRightInitial.size > 0)
			baseRightInitial.each do |fileLeft|
				if (!leftResultFinal.include?(fileLeft))
					return false
				end
			end
		end
		return true
	end

	def verifyModifiedFile(baseLeftInitial, leftResultFinal, baseRightInitial, rightResultFinal)
		if(baseLeftInitial.size > 0)
			baseLeftInitial.each do |keyFile, fileLeft|
				fileRight = rightResultFinal[keyFile]
				if (fileRight == nil or fileLeft != fileRight)
					return false
				end
			end
		end
		if(baseRightInitial.size > 0) 
			baseRightInitial.each do |keyFile, fileRight|
				fileLeft = leftResultFinal[keyFile]
				if (fileLeft == nil or fileRight != fileLeft)
					return false
				end
			end
		end
		return true
	end

end