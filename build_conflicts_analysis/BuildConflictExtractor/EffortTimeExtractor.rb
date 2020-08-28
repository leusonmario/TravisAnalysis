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

  def findFixCommitWithSuperiorStatus(projectCommits, fixCommitHash)
    projectCommits.each do |key, commitInfo|
      if (key == fixCommitHash and isFixCommitStatusSuperior(commitInfo.getLocalBuild().getBuildStatus))
        return true
      else
        return false
      end
     end
  end

	def checkFixedBuildForLocalBuilds(brokenCommit, mergeCommit, pathProject, pathGumTree, causesConflicts, gitProject, projectCommits)
		numberBuilsTillFix = 0
		localBrokenCommit = brokenCommit
		allPossibleParents = []

		fixCommitHash = identifyFixCommit(gitProject, localBrokenCommit)
    while(fixCommitHash != "NO-COMMIT")
      allPossibleParents.push(fixCommitHash)
      localBrokenCommit = fixCommitHash
      fixCommitHash = identifyFixCommit(gitProject, localBrokenCommit)
    end

    allPossibleParents.each do |onePossibleParent|
      if (findFixCommitWithSuperiorStatus(projectCommits, onePossibleParent))
        result = checkTimeEffort(brokenCommit, mergeCommit, onePossibleParent)

        fixCommitInfo = CopyFixCommit.new(pathProject, brokenCommit, onePossibleParent)
        resultRunDiff = []
        if (!fixCommitInfo.getAllDiff)
          resultRunDiff = fixCommitInfo.runAllDiff(pathGumTree)
        end
        fixCommitInfo.deleteProjectCopies()
        fixPatterns = []
        if causesConflicts != nil
          causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
            fixPatterns.push(fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff))
          end

          return onePossibleParent, commitInfo.getLocalBuild().getBuildStatus, result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
        end
      end
      numberBuilsTillFix += 1
    end

=begin
		projectCommits.each do |key, commitInfo|
			if (findFixCommitWithSuperiorStatus(projectCommits, fixCommitHash))
        result = checkTimeEffort(localBrokenCommit, mergeCommit, key)

        fixCommitInfo = CopyFixCommit.new(pathProject, localBrokenCommit, key)
        resultRunDiff = []
        if (!fixCommitInfo.getAllDiff)
          resultRunDiff = fixCommitInfo.runAllDiff(pathGumTree)
        end
        fixCommitInfo.deleteProjectCopies()
        fixPatterns = []
        if causesConflicts != nil
          causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
            fixPatterns.push(fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff))
          end

          return fixCommitHash, commitInfo.getLocalBuild().getBuildStatus, result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
        end
      else
        localBrokenCommit = key
      end
    end
=end
    numberBuilsTillFix = 0
    allPossibleParents.each do |onePossibleParent|
      localBuild = LocalBuild.new(onePossibleParent, pathProject)
      if isFixCommitStatusSuperior(localBuild.getBuildStatus())
        result = checkTimeEffort(brokenCommit, mergeCommit, onePossibleParent)

        fixCommitInfo = CopyFixCommit.new(pathProject, brokenCommit, onePossibleParent)
        resultRunDiff = []
        if (!fixCommitInfo.getAllDiff)
          resultRunDiff = fixCommitInfo.runAllDiff(pathGumTree)
        end
        fixCommitInfo.deleteProjectCopies()
        fixPatterns = []
        if causesConflicts != nil
          causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
            fixPatterns.push(fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff))
          end

          return onePossibleParent, localBuild.getBuildStatus(), result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
        end
      end
      numberBuilsTillFix += 1
    end

=begin
		localBuild = LocalBuild.new(fixCommitHash, pathProject)
		if isFixCommitStatusSuperior(localBuild.getLocalBuild().getBuildStatus)
			result = checkTimeEffort(brokenCommit, mergeCommit, fixCommitHash)

			fixCommitInfo = CopyFixCommit.new(pathProject, brokenCommit, fixCommitHash)
			resultRunDiff = []
			if (!fixCommitInfo.getAllDiff)
				resultRunDiff = fixCommitInfo.runAllDiff(pathGumTree)
			end
			fixCommitInfo.deleteProjectCopies()
			fixPatterns = []
			if causesConflicts != nil
				causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
					fixPatterns.push(fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff))
				end

				return fixCommitHash, localBuild.getLocalBuild().getBuildStatus, result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
			end
		end
=end
			return "NO-FIX", "NO-FIX", "NO-FIX", "NO-FIX", "NO-FIX", "NO-FIX", false, ["NO-FIX"]
	end

	def isFixCommitStatusSuperior(status)
		if (status == "failed" or status == "passed")
			return true
		end
		return false
	end

	def identifyFixCommit(gitProject, brokenCommit)
		gitProject.getAllCommits.each do |oneCommit|
			if (checkFailedCommitAsParent(brokenCommit, oneCommit))
				return oneCommit
			end
    end
    return "NO-COMMIT"
	end

	def checkFixedBuild(brokenCommit, mergeCommit, pathProject, pathGumTree, causesConflicts, extractorCLI, gitProject)
		numberBuilsTillFix = 0
		localBrokenCommit = brokenCommit
		allPossibleParents = []
		buildId = ""

		@projectBuildsMap.each do |key, value|
			if (checkFailedCommitAsParent(localBrokenCommit, key))
				numberBuilsTillFix += 1
				buildId = value[1][0]
				if (value[0][0] == "passed" or value[0][0] == "failed")
					result = checkTimeEffort(brokenCommit, mergeCommit, key)

					fixCommit = CopyFixCommit.new(pathProject, brokenCommit, key)
					resultRunDiff = []
					if (!fixCommit.getAllDiff)
						resultRunDiff = fixCommit.runAllDiff(pathGumTree)
					end
					fixCommit.deleteProjectCopies()
					fixPatterns = []
					if causesConflicts != nil
						causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
							fixPatterns.push(fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff))
						end

						return value[1][0], value[0][0], result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
					end
				else
					localBrokenCommit = key
					if (!allPossibleParents.include? key)
						allPossibleParents.push(key)
					end
				end
			end
		end
#=begin
		if (!extractorCLI.getProjectActive)
			extractorCLI.activeForkProject()
		end
		attemptBuildFix = extractorCLI.buildFixConflicts(brokenCommit, gitProject, @projectBuildsMap)
#=begin
		if (attemptBuildFix != nil)
			fixPatterns = []
			result = ""
			if causesConflicts != nil
				causesConflicts.getCausesFilesInfoConflicts().each do |conflictsCauses|
					if (conflictsCauses[0] != "compilerError" and conflictsCauses[0] != "remoteError" and conflictsCauses[0] != "githubError")
					result = checkTimeEffort(brokenCommit, mergeCommit, attemptBuildFix[0])
					resultRunDiff = []
					fixCommit = CopyFixCommit.new(pathProject, brokenCommit, attemptBuildFix[0])
					if (!fixCommit.getAllDiff)
						resultRunDiff = fixCommit.runAllDiff(pathGumTree)
          end
          fixCommit.deleteProjectCopies()
					#resultRunDiff = fixCommit.runAllDiff(pathGumTree)
					fixPatterns.push(fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff))
				end

				return attemptBuildFix[1][2], attemptBuildFix[1][0], result[0], numberBuilsTillFix, result[1], result[2], true, fixPatterns
				end
			end
		else
#=end
			result = checkFixedBuildCommitCloser(brokenCommit, mergeCommit)
			if (result.size > 2)
				return result
			else
				return result[1], "NO-FIX", "NO-FIX", numberBuilsTillFix+result[0], "NO-FIX", "NO-FIX", false
			end
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

	private

	def fixPatternBasedOnConflictType(conflictsCauses, resultRunDiff)
		if (conflictsCauses[0] == "statementDuplication")
			fixStatementDuplication = FixStatementDuplication.new
			return fixStatementDuplication.verfyFixPattern(conflictsCauses, resultRunDiff)
		elsif (conflictsCauses[0] == "unavailableSymbol" or conflictsCauses[0] == "unavailableSymbolFile" or conflictsCauses[0] == "unavailableSymbolMethod" or conflictsCauses[0] == "unavailableSymbolVariable")
			fixUnavailableSymbol = FixUnavailableSymbol.new
			return fixUnavailableSymbol.verfyFixPattern(conflictsCauses, resultRunDiff)
		elsif (conflictsCauses[0] == "unimplementedMethod")
			fixUnimplementedMethod = FixUnimplementedMethod.new
			return fixUnimplementedMethod.verfyFixPattern(conflictsCauses, resultRunDiff)
		elsif (conflictsCauses[0] == "methodParameterListSize")
			fixMethodUpdate = FixMethodUpdate.new
			return fixMethodUpdate.verifyFixPattern(conflictsCauses, resultRunDiff)
		end
	end

end