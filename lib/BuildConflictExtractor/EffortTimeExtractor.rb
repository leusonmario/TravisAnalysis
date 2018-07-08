require 'require_all'
require 'travis'
require 'active_support/core_ext/numeric/time'
require 'date'
require 'time'
require_rel 'ResolutionPatterns/'

class EffortTimeExtractor
	@projectBuildsMap = Hash.new()
	@projectPath = ""

	def initialize(projectBuilds, path)
		@projectBuildsMap = projectBuilds
		@projectPath = path
	end

	def checkFixedBuild(brokenCommit, mergeCommit, pathProject, pathGumTree, causesConflicts)
		numberBuilsTillFix = 0
		localBrokenCommit = brokenCommit
		buildId = ""
		@projectBuildsMap.each do |key, value|
			if (checkFailedCommitAsParent(localBrokenCommit, key))
				numberBuilsTillFix += 1
				buildId = value[1][0]
				if (value[0][0] == "passed" or value[0][0] == "failed")
					result = checkTimeEffort(brokenCommit, mergeCommit, key)

					fixCommit = CopyFixCommit.new(pathProject, brokenCommit, key)
					resultRunDiff = fixCommit.runAllDiff(pathGumTree)
					fixCommit.deleteProjectCopies()
					index = 0
					fixPatterns = []
					if causesConflicts != nil
						causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
							if (conflictsCauses[0] == "statementDuplication")
								fixStatementDuplication = FixStatementDuplication.new
								fixPatterns[index] = fixStatementDuplication.verfyFixPattern(conflicts, resultRunDiff)
							elsif (conflictsCauses[0] == "unavailableSymbol" or conflictsCauses[0] == "unavailableSymbolFile" or conflictsCauses[0] == "unavailableSymbolMethod" or conflictsCauses[0] =="unavailableSymbolVariable")
								fixUnavailableSymbol = FixUnavailableSymbol.new
								fixPatterns[index] = fixUnavailableSymbol.verfyFixPattern(value, resultRunDiff)
							elsif (conflictsCauses[0] == "unimplementedMethod")
								fixUnimplementedMethod = FixUnimplementedMethod.new
								fixPatterns[index] = fixUnimplementedMethod.verfyFixPattern(value, resultRunDiff)
							elsif (conflictsCauses[0] == "methodParameterListSize")
								fixMethodUpdate = FixMethodUpdate.new
								fixPatterns[index] = fixMethodUpdate.verifyFixPattern(value, resultRunDiff)
							end
							index += 1
						end

						return value[1][0], value[0][0], result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
					end
				else
					localBrokenCommit = key
				end
			end
		end
		result = checkFixedBuildCommitCloser(brokenCommit, mergeCommit)
		if (result.size > 2)
			return result
		else
			return result[1], "NO-FIX", "NO-FIX", numberBuilsTillFix+result[0], "NO-FIX", "NO-FIX", false
		end
	end

	def checkFixCommitChangesTestCase(diff, failedTestInfo)
		testCaseUpdate = false
		testFileUpdate = false
		begin
			if (diff[0][failedTestInfo[0]] != nil)
				testFileUpdate = true
				if (diff[0][failedTestInfo[0]].to_s.match(/on Method #{failedTestInfo[1]}/))
					testCaseUpdate = true
				end
			end
			return testFileUpdate, testCaseUpdate
		rescue
			print "\nDiff changes was null\n"
		end
		return testFileUpdate, testCaseUpdate
	end

=begin
	def checkFixCommitAllCHanges(diff, changedMethods)
		updateFiles = Hash.new
		changedMethods.each do |setChangedFiles|
			setChangedFiles.each do |key, value|
				if(diff[0][key] != nil)
					methods = Array.new
					methods.push("")
					value.each do |method|
						if (diff[0][failedTestInfo[0]].to_s.match(/on Method #{method}/))
							methods.push(method)
						end
					end
					updateFiles[key] = methods
				end
			end
		end

		return updateFiles
	end
=end
	def checkFixCommitAllCHanges(diff, changedMethods)
		updateFiles = Hash.new
		begin
			changedMethods.each do |key, value|
				if(diff[0][key] != nil)
					methods = Array.new
					methods.push("")
					value.each do |method|
						if (diff[0][failedTestInfo[0]].to_s.match(/on Method #{method}/))
							methods.push(method)
						end
					end
					updateFiles[key] = methods
				end
			end

			return updateFiles
		rescue
			print "\nDiff changes was null\n"
		end
		return updateFiles
	end

	def checkFixedBuildFailed(brokenCommit, mergeCommit, pathProject, failedTestInformation, changedMethods)
		numberBuilsTillFix = 0
		buildId = ""
		@projectBuildsMap.each do |key, value|
			if (checkFailedCommitAsParent(brokenCommit, key))
				numberBuilsTillFix += 1
				buildId = value[1][0]
				if (value[0][0] == "passed")
					result = checkTimeEffort(brokenCommit, mergeCommit, key)
					fixCommit = CopyFixCommit.new(pathProject, brokenCommit, key)
					resultRunDiff = fixCommit.runAllDiff(pathProject)
					updateTestInfo = checkFixCommitChangesTestCase(resultRunDiff, failedTestInformation)
					sameMethods = checkFixCommitAllCHanges(resultRunDiff, changedMethods[0])
					dependentParentOne = checkFixCommitAllCHanges(resultRunDiff, changedMethods[1])
					dependentParentTwo = checkFixCommitAllCHanges(resultRunDiff, changedMethods[2])
					return value[1][0], value[0][0], result[0], numberBuilsTillFix, result[1], result[2], true, updateTestInfo[0], updateTestInfo[1], sameMethods, dependentParentOne, dependentParentTwo
				else
					brokenCommit = key
				end
			end
		end

		return "NO APPLICABLE", "NO-FIX", "NO-FIX", "NO APPLICABLE", "NO-FIX", "NO-FIX", false, "NO APPLICABLE", "NO APPLICABLE", "NO APPLICABLE", "NO APPLICABLE", "NO APPLICABLE"
	end

	def checkFailedCommitAsParent(brokenCommit, fixedCommit)
		Dir.chdir @projectPath

		commitInfo = %x(git cat-file -p #{fixedCommit})
		commitInfo.each_line do |line|
			if(line.include?('author'))
				break
			end
			if(line.include?('parent'))
				commitSHA = line.partition('parent ').last.to_s.gsub("\n","").gsub(' ','').gsub('\r','')
				if (commitSHA == brokenCommit)
					return true
				end
			end
		end
		return false
	end

	def checkTimeEffort (brokenCommit, mergeCommit, fixedCommit)
		firstParentInfo = getFixedProcessCommit(mergeCommit[0])
		secondParentInfo = getFixedProcessCommit(mergeCommit[1])
		brokenCommitInfo = getFixedProcessCommit(brokenCommit)
		fixedCommitInfo = getFixedProcessCommit(fixedCommit)
		sameAuthors = false
		sameCommiter = false
		intervalTime = ((DateTime.parse(fixedCommitInfo[2]) - DateTime.parse(brokenCommitInfo[2]))*24*60).to_i

		if (firstParentInfo[0] == fixedCommitInfo[0] or secondParentInfo[0] == fixedCommitInfo[0])
			sameAuthors = true
		end

		if (firstParentInfo[1] == fixedCommitInfo[1] or secondParentInfo[1] == fixedCommitInfo[1])
			sameCommiter = true
		end
		return intervalTime, sameAuthors, sameCommiter
	end

	def getFixedProcessCommit(commit)
		Dir.chdir @projectPath

		author = ""
		committer = ""
		date = %x(git show -s --format=%cd #{commit})
		commitInfo = %x(git cat-file -p #{commit})

		commitInfo.each_line do |line|
			if (line.include?('author'))
				author = line.partition('author ').last.to_s.scan(/[a-zA-Z ]*/)
			end
			if (line.include?('committer'))
				committer = line.partition('committer ').last.to_s.scan(/[a-zA-Z ]*/)
			end
		end

		return author, committer, date
	end

	def checkFixedBuildCommitCloser(brokenCommit, mergeCommit)
		numberBuilsTillFix = 0
		buildID = ""
		@projectBuildsMap.each do |key, value|
			if (getRevList(mergeCommit, key, brokenCommit) == true)
				numberBuilsTillFix += 1
				buildId = value[1][0]
				if (value[0][0] == "passed" or value[0][0] == "failed")
					result = checkTimeEffort(brokenCommit, mergeCommit,key)
					return value[1][0], value[0][0], result[0], numberBuilsTillFix, result[1], result[2], false
				else
					brokenCommit = key
				end
			end
		end
		return numberBuilsTillFix, buildID
	end

	def getRevList(mergeCommit, commit, commitFailed)
		Dir.chdir @projectPath
		base = %x(git merge-base --all #{mergeCommit[0]} #{mergeCommit[1]})
		revList = %x(git rev-list #{base} #{commit})
		if (revList.include? commitFailed)
			return true
		else
			return false
		end
	end

end