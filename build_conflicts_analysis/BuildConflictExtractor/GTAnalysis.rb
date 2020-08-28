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

	def getGumTreeAnalysis(pathProject, sha, conflictCauses, cloneProject, superiorParentStatus, extractorCLI, result, gitProject, leftSha, rightSha)
		parents = @mergeCommit.getParentsMergeIfTrue(pathProject, sha)
		actualPath = Dir.pwd

		pathCopies = @copyDirectories.createCopyProject(sha, parents, pathProject)

		#  		   					result 		  left 			right 			MergeCommit 	parent1 		parent2 	problemas
		out = gumTreeDiffByBranch(sha, pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4], conflictCauses, pathProject, parents, cloneProject, superiorParentStatus, extractorCLI, result, gitProject, leftSha, rightSha)
		@copyDirectories.deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
		return out
	end

	def getGumTreeTCAnalysis(pathProject, sha, cloneProject)
		actualPath = Dir.pwd
		parents = @mergeCommit.getParentsMergeIfTrue(pathProject, sha)

		pathCopies = @copyDirectories.createCopyProject(sha, parents, pathProject)

		#  		   					result 		  left 			right 			MergeCommit 	parent1 		parent2 	problemas
		out = gumTreeDiffTCByBranch(sha, pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4], pathProject, parents, cloneProject)
		Dir.chdir actualPath
		return out, pathCopies
	end

	def deleteCopies(pathCopies)
		@copyDirectories.deleteProjectCopies(pathCopies)
	end

	def gumTreeDiffByBranch(mergeCommit, result, left, right, base, conflictCauses, pathProject, parents, cloneProject, superiorParentStatus, extractorCLI, resultParents, gitProject, leftSha, rightSha)
		print conflictCauses
		statusModified = cloneProject.verifyBadlyMergeScenario(parents[0], parents[1], mergeCommit)
		conflictingContributions = []

		baseLeft = @parentMSDiff.runAllDiff(base, left)
		baseRight = @parentMSDiff.runAllDiff(base, right)
		leftResult = @parentMSDiff.runAllDiff(left, result)
		rightResult = @parentMSDiff.runAllDiff(right, result)
		# passar como parametro o caminho dos diretorios (base, left, right, result). Por enquanto apenas o left e right
		return verifyModificationStatus(mergeCommit, baseLeft, leftResult, baseRight, rightResult, conflictCauses, base, left, right, pathProject, parents, cloneProject, statusModified, superiorParentStatus, extractorCLI, resultParents, gitProject, leftSha, rightSha)
	end

	def gumTreeDiffTCByBranch(mergeCommit, result, left, right, base, pathProject, parents, cloneProject)
		statusModified = cloneProject.verifyBadlyMergeScenario(parents[0], parents[1], mergeCommit)
		conflictingContributions = nil
		if (statusModified == true)
			conflictingContributions = true
		end

		baseLeft = @parentMSDiff.runAllDiff(base, left)
		baseRight = @parentMSDiff.runAllDiff(base, right)
		leftResult = @parentMSDiff.runAllDiff(left, result)
		rightResult = @parentMSDiff.runAllDiff(right, result)
		# passar como parametro o caminho dos diretorios (base, left, right, result). Por enquanto apenas o left e right
		#return verifyModificationStatus(mergeCommit, baseLeft, leftResult, baseRight, rightResult, conflictCauses, left, right, pathProject, parents, cloneProject)

		statusModified = verifyModifiedFile(baseLeft[0], leftResult[0], baseRight[0], rightResult[0])
		statusAdded = verifyAddedDeletedFile(baseLeft[1], leftResult[1], baseRight[1], rightResult[1])
		statusDeleted = verifyAddedDeletedFile(baseLeft[2], leftResult[2], baseRight[2], rightResult[2])

		allIntegratedContributions = true
		if (!statusModified or !statusAdded or !statusDeleted)
			allIntegratedContributions = false
		end

		return baseLeft, leftResult, baseRight, rightResult, conflictingContributions, allIntegratedContributions
	end

	def deleteProjectCopies(pathCopies)
		index = 0
		while(index < pathCopies.size)
			delete = %x(rm -rf #{pathCopies[index]})
			index += 1
		end
	end

	def verifyModificationStatus(mergeCommit, baseLeft, leftResult, baseRight, rightResult, conflictCauses, basePath, leftPath, rightPath, pathProject, parents, cloneProject, contributionsState, superiorParentStatus, extractorCLI, result, gitProject, leftSha, rightSha)
		checkEuristic = true
		conflictingContributions = []
		allIntegratedContributions = true
		bcDependency = []
		parentEuristicTrue = false
		changesAfterMerge = superiorParentStatus
		superiorParentStatus = result[0]
		if (!contributionsState)
			statusModified = verifyModifiedFile(baseLeft[0], leftResult[0], baseRight[0], rightResult[0])
			statusAdded = verifyAddedDeletedFile(baseLeft[1], leftResult[1], baseRight[1], rightResult[1])
			statusDeleted = verifyAddedDeletedFile(baseLeft[2], leftResult[2], baseRight[2], rightResult[2])

			if (!statusModified or !statusAdded or !statusDeleted)
				allIntegratedContributions = false
			end
		end

		brokenBuild = true
		indexValue = 0
		conflictCauses.getFilesConflict().each do |conflictCause|
			if(conflictCause[0] == "unimplementedMethod" || conflictCause[0] == "unimplementedMethodSuperType")
				bcDependency[indexValue] = false
				#if (allIntegratedContributions)
				#	conflictingContributions[indexValue] = true
				#else
				bcUnimplementedMethod = BCUnimplementedMethod.new()
				if (bcUnimplementedMethod.verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, conflictCause) == false)
					conflictingContributions[indexValue] = false
					bcDependency[indexValue] = false
				else
					conflictingContributions[indexValue] = true
					bcDependency[indexValue] = false
				end
				#end
			elsif (conflictCause[0] == "unavailableSymbolFileSpecialCase")
				conflictingContributions[indexValue] = false
				bcDependency[indexValue] = false
			elsif (conflictCause[0] == "unavailableSymbolMethod" || conflictCause[0] == "unavailableSymbolVariable" || conflictCause[0] == "unavailableSymbolFile")
				bcUnavailableSymbol = BCUnavailableSymbol.new()
				bcMethodUpdate = BCMethodUpdate.new(getGumTreePath())
				if (bcUnavailableSymbol.verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, conflictCause, basePath, leftPath, rightPath, superiorParentStatus) == false)
					if (conflictCause[0] == "unavailableSymbolFile" and bcUnavailableSymbol.verifyBCDependency(leftPath, rightPath, conflictCause, baseLeft[0], baseRight[0], leftResult[0], rightResult[0], superiorParentStatus))
						conflictingContributions[indexValue] = true
						bcDependency[indexValue] = true
					elsif (conflictCause[0] == "unavailableSymbolMethod" and bcUnavailableSymbol.verifyBCDependencyMethod(leftPath, rightPath, conflictCause, bcMethodUpdate))
						conflictingContributions[indexValue] = true
						bcDependency[indexValue] = true
					else
						conflictingContributions[indexValue] = false
						bcDependency[indexValue] = false
					end
				else
					conflictingContributions[indexValue] = true
					bcDependency[indexValue] = true
				end
=begin					elsif (conflictCause[0] == "unavailableSymbolMethod" and bcUnavailableSymbol.verifyBCDependencyMethod(leftPath, rightPath, conflictCause, bcMethodUpdate))
						conflictingContributions[indexValue] = true
						bcDependency[indexValue] = true
					else
						conflictingContributions[indexValue] = false
						bcDependency[indexValue] = false
					end
#=end
					conflictingContributions[indexValue] = false
					bcDependency[indexValue] = false
=end
				#				else
				#					conflictingContributions[indexValue] = true
				#					bcDependency[indexValue] = false
				#end
				#conflictingContributions[indexValue] = true
				#bcDependency[indexValue] = true
				#end

			elsif (conflictCause[0] == "statementDuplication")
				bcDependency[indexValue] = false
				#if (allIntegratedContributions)
				#	conflictingContributions[indexValue] = true
				#else
				bcStatementDuplication = BCStatementDuplication.new()
				if (bcStatementDuplication.verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, conflictCause) == false)
					conflictingContributions[indexValue] = false
				else
					conflictingContributions[indexValue] = true
				end
				#end
			elsif (conflictCause[0] == "methodParameterListSize")
				bcMethodUpdate = BCMethodUpdate.new(getGumTreePath())
				if (bcMethodUpdate.verifyBuildConflict(basePath, leftPath, rightPath, conflictCause, baseLeft, baseRight) == false)
					# if (bcMethodUpdate.verifyBCDependency(leftPath, rightPath, conflictCause) == false)
						conflictingContributions[indexValue] = false
						bcDependency[indexValue] = false
					#else
					#	conflictingContributions[indexValue] = true
					#	bcDependency[indexValue] = true
					#end
				else
					conflictingContributions[indexValue] = true
					bcDependency[indexValue] = false
				end
			elsif (conflictCause[0] == "dependencyProblem")
				bcDependencyAnalisis = BCDependency.new()
				if (bcDependencyAnalisis.verifyBuildConflict(baseLeft[0], leftResult[0], baseRight[0], rightResult[0], conflictCause) == true)
					conflictingContributions[indexValue] = false
					bcDependency[indexValue] = false
				else
					conflictingContributions[indexValue] = true
					bcDependency[indexValue] = true
				end
			elsif (conflictCause[0] == "alternativeStatment")
				bcDependency[indexValue] = false
				#if (allIntegratedContributions)
				#	conflictingContributions[indexValue] = true
				#else
				bcAlternative = BCAlternativeStatement.new()
				if (bcAlternative.verifyBuildConflict(baseLeft[0], leftResult[0], baseRight[0], rightResult[0], conflictCause) == false)
					conflictingContributions[indexValue] = false
				else
					conflictingContributions[indexValue] = true
				end
				#end
			elsif (conflictCause[0] == "malformedExpression")
				bcDependency[indexValue] = false
				if (allIntegratedContributions)
					conflictingContributions = true
				else
					conflictingContributions[indexValue] = false
				end
			elsif (conflictCause[0] == "incompatibleTypes")
				#bcDependency[indexValue] = false
				#if (allIntegratedContributions)
				#	conflictingContributions[indexValue] = true
				#else
				conflictingContributions[indexValue] = false
				brokenBuild = false
				#end
			else
				bcDependency[indexValue] = false
				conflictingContributions[indexValue] = false
			end

			if (!checkEuristic and !conflictingContributions[indexValue])
				print "#{statusModified} #{changesAfterMerge} : #{result} : #{mergeCommit}\n\n"
				if ((result[3] == ["passed"] or (result[3] == ["failed"])) and (result[4] == ["passed"] or (result[4] == ["failed"])) and !changesAfterMerge)
					print "FOIFOIFOIFOIFOFIFOIF"
					sleep (20)
					parentEuristicTrue =	evaluateSuperiorParentEuristic(extractorCLI, leftSha, rightSha, gitProject)
				end
				checkEuristic = true
			end
			if (parentEuristicTrue)
				print "CABARE AQUI\n"
				bcDependency[indexValue] = true
				conflictingContributions[indexValue] = true
			else

			end
			indexValue += 1
		end

		return conflictingContributions, allIntegratedContributions, brokenBuild, bcDependency

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
		begin
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
		rescue
			return false
		end
	end


	def evaluateSuperiorParentEuristic(extractorCLI, left, right, gitProject)
		if (!extractorCLI.getProjectActive)
			extractorCLI.activeForkProject()
		end
		count = 0
		resultLeftParent = Array.new
		resultRightParent = Array.new
		while (count < 5)
			resultLeftParent.push(verifyBuildCurrentState(extractorCLI, left, nil, gitProject))
			resultRightParent.push(verifyBuildCurrentState(extractorCLI, right, nil, gitProject))
			count += 1
		end

		passedLeft = 0
		passedRight = 0
		resultLeftParent.each do |oneResult|
			begin
				if (oneResult[0] == "passed" or oneResult[0] == "[passed]" or oneResult[0] == "failed" or oneResult[0] == "[failed]")
					passedLeft += 1
				end
			rescue
				print "NO INFORMATION AVAILABLE"
			end
		end

		resultRightParent.each do |oneResult|
			begin
				if (oneResult[0] == "passed" or oneResult[0] == "[passed]" or oneResult[0] == "failed" or oneResult[0] == "[failed]")
					passedRight += 1
				end
			rescue
				print "NO INFORMATION AVAILABLE"
			end
		end

		if (passedLeft > 2 and passedRight > 2)
			return true
		else
			return false
		end
	end

	def verifyBuildCurrentState(extractorCLI, sha, mergeScenarios, gitProject)
		indexCount = 0
		idLastBuild = extractorCLI.checkIdLastBuild()
		state = false
		if (mergeScenarios == nil)
			state = extractorCLI.replayBuildOnTravis(sha, gitProject.getMainProjectBranch())
		end
		if (state)
			while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
				sleep(10)
				indexCount += 1
				if (indexCount == 5)
					return nil
				end
			end

			status = extractorCLI.checkStatusBuild()
			while (status == "started" and indexCount < 5)
				sleep(20)
				print "Merge Scenario Parents not built yet\n"
				status = extractorCLI.checkStatusBuild()
			end

			return extractorCLI.getInfoLastBuild()
		end
		return nil
	end

end