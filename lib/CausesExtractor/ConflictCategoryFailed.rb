require 'require_all'
require_rel 'ConflictCategories'
require_all '././BuildConflictExtractor'
require_all '././TestConflictsExtractor'

class ConflictCategoryFailed
	include ConflictCategories

	def initialize(pathGumTree, projectName, localClone)
		@projectName = projectName
		@pathGumTree = pathGumTree
		@localClone = localClone
		@gitProblem = 0
		@remoteError = 0
		@otherError = 0
		@permission = 0
		@failed = 0
		@gtAnalysis = GTAnalysis.new(@pathGumTree, @projectName, @localClone)
	end

	def getProjectName()
		@projectName
	end

	def getPathGumTree()
		@pathGumTree
	end

	def getLocalClone()
		@localClone
	end

	def getGitProblem()
		@gitProblem
	end

	def getRemoteError()
		@remoteError
	end

	def getOtherError()
		@otherError
	end

	def getPermission()
		@permission
	end

	def getFailed()
		@failed
	end

	def getTotal()
		return getGitProblem() + getRemoteError() + getFailed() + getOtherError() + getPermission()
	end

	def findConflictCauseFork(logs, mergeScenario, localClone)
		result = []
		logs.each do |log|
			result.push(getCauseByJob(log))
		end
		return adjustValueReturn(result), result[2], getFinalStatus(result, mergeScenario, localClone)
	end

	def findConflictCause(build, pathLocalClone)
		result = []
		indexJob = 0
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "failed")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |part|
						causesInfo = getCauseByJob(part)
						result.push(causesInfo)
					end
				end
			end
			indexJob += 1
		end
		return adjustValueReturn(result), result[2], getFinalStatus(result, build.commit.sha, pathLocalClone)
	end

	def adjustValueReturn(result)
		arrayFrequency = []
		arrayStatus = []
		result.each do |individualResult|
			arrayFrequency.push(individualResult[1])
			arrayStatus.push(individualResult[0])
		end
		return arrayStatus, arrayFrequency
	end

	def getFinalStatus(resultByJobs, sha, localClone)
		diffsMergeScenario = @gtAnalysis.getGumTreeTCAnalysis(localClone, sha, @localClone)
		testConflictsExtractor = TestConflictInfo.new()
		resultTC = []
		resultByJobs.each do |filesInfo|
			resultTC.push(testConflictsExtractor.getInfoTestConflicts(diffsMergeScenario, filesInfo))
		end
		return adjustInfoTestConflict(resultTC)
	end

	def adjustInfoTestConflict(resultTC)
		newTestFileArray = []
		newTestCaseArray = []
		resultTC.each do |result|
			newTestFileArray.push(result[0])
			newTestCaseArray.push(result[1])
		end
		return newTestFileArray, newTestCaseArray
	end

	def getCauseByJob(log)
		stringBuildFail = "FAILURE"
		stringNoOutput = "No output has been received"
		stringTerminated = "The build has been terminated"
		stringTheCommand = "The command "
		result = ""
		numberFailures = 0
		filesInfo = []
		if (log[/Errors: [0-9]*/])
			@failed += 1
			result = "failed"
		elsif (log[/#{stringBuildFail}\s*([^\n\r]*)\s*([^\n\r]*)\s*([^\n\r]*)failed/] || part[/#{stringTheCommand}("mvn|"\.\/mvnw)+(.*)failed(.*)/])
			@failed += 1
			result = "failed"
		elsif (log[/#{stringTheCommand}("git clone |"git checkout)(.*?)failed(.*)[\n]*/])
			@gitProblem += 1
			result = "gitProblem"
		elsif (log[/#{stringNoOutput}(.*)wrong(.*)[\n]*#{stringTerminated}/])
			@remoteError += 1
			result = "remoteError"
		elsif (log[/#{stringTheCommand}("cd|"sudo|"echo|"eval)+ (.*)failed(.*)/])
			@permission += 1
			result = "permission"
		else
			@otherError += 1
			result = "otherError"
		end

		if (log[/Failed tests: (\n)*[\s\S\:\)\(]*\nTests run: [\s\S\:\,\-\.0-9\n ]* Failures: 1[\s\S\n]* BUILD FAILURE/])
			numberFailures = log.to_s.match(/Failed tests: (\n)*[\s\S\:\)\(]*\nTests run: [\s\S\:\,\-\.0-9\n ]* Failures: 1[\s\S\n]* BUILD FAILURE/).to_s.match(/Failed tests: (\n)*[\s\S]*(\n)*Skipped:/).to_s.match(/Failures: [0-9]*/).to_s.split("Failures: ")[1].to_i
		end
		if (log[/Failures: 1[0-9]*[\s\S]* <<< FAILURE!/])
			numberOccurences = log.to_enum(:scan, /Failures: 1[0-9]*[\s\S]* <<< FAILURE!/).map { Regexp.last_match }
			numberOccurences.each do |occurence|
				generalInfo = occurence.to_s.match(/FAILURE![\s\S]*\([\s\S]*\)/).to_s.split("\(")
				methodName = generalInfo[0].to_s.gsub("FAILURE!","").to_s.gsub("\n","").to_s.gsub("\r","")
				file = generalInfo[1].split(".").last.to_s.gsub("\)","")
				filesInfo.push([file, methodName])
			end
		end
		return result, numberFailures, filesInfo
	end
end