require 'require_all'
require_rel 'ConflictCategories'
require_all '././BuildConflictExtractor'
require_all '././TestConflictsExtractor'

class ConflictCategoryFailed
	include ConflictCategories

	def initialize(pathGumTree, projectName, localClone, extractorCLI)
		@projectName = projectName
		@pathGumTree = pathGumTree
		@localClone = localClone
		@gitProblem = 0
		@remoteError = 0
		@otherError = 0
		@permission = 0
		@failed = 0
		@gtAnalysis = GTAnalysis.new(@pathGumTree, @projectName, @localClone)
		@testCaseCoverge = TestCaseCoverage.new(@localClone.getCloneProject().getLocalClone(), extractorCLI)
		@tcAnalyzer = TestConflictsAnalyzer.new()
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
		newTestFileArray = []
		newTestCaseArray = []
		updateTestArray = []
		changesSameMethod = []
		dependentChanges = []
		buildIDs = []
		coverageAnalysis = nil
		begin
			resultByJobs[0][2].each do |filesInfo|
				resultTC = testConflictsExtractor.getInfoTestConflicts(diffsMergeScenario[0], diffsMergeScenario[1], filesInfo, getPathGumTree())
				newTestFileArray.push(resultTC[0])
				newTestCaseArray.push(resultTC[1])
				updateTestArray.push(resultTC[2])
				#add uma classe responsável por fazer a análise
				#esta iria receber apenas as iformações relacionadas
				#Já tenho essa informação em diffMergeScenario : [1]LeftResult e [3]RightResult
				addModFilesLeftResult = @gtAnalysis.getParentsMFDiff.runOnlyModifiedAddFiles(diffsMergeScenario[0][1][0], diffsMergeScenario[1][2], diffsMergeScenario[1][1])
				addModFilesRightResult = @gtAnalysis.getParentsMFDiff.runOnlyModifiedAddFiles(diffsMergeScenario[0][3][0], diffsMergeScenario[1][3], diffsMergeScenario[1][1])
				coverageAnalysis = @testCaseCoverge.runTestCase(filesInfo[0], filesInfo[1], sha)
				resultCoverageAnalysis = @tcAnalyzer.runTCAnalysis(coverageAnalysis[0], addModFilesLeftResult, addModFilesRightResult)
				changesSameMethod.push(resultCoverageAnalysis[0])
				dependentChanges.push(resultCoverageAnalysis[1])
				buildIDs.push(coverageAnalysis[1])
			end
			#ainda tenho o caminho em diffMergeScenario[1]
			@gtAnalysis.deleteProjectCopies(diffsMergeScenario[1])
			return newTestFileArray, newTestCaseArray, updateTestArray, changesSameMethod, dependentChanges, buildIDs, coverageAnalysis[0]
		rescue
			return newTestFileArray, newTestCaseArray, updateTestArray, changesSameMethod, dependentChanges, buildIDs, nil
		end
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
		elsif (log[/#{stringBuildFail}\s*([^\n\r]*)\s*([^\n\r]*)\s*([^\n\r]*)failed/] || log[/#{stringTheCommand}("mvn|"\.\/mvnw)+(.*)failed(.*)/] || log[/There are test failures/])
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

		if (log[/Failed tests: (\n)*[\s\S\:\)\(]*\nTests run: [\s\S\:\,\-\.0-9\n ]* Failures: [1-9][0-9]*[\s\S\n]* BUILD FAILURE/])
			numberFailures = log.to_s.match(/Failed tests: (\n)*[\s\S\:\)\(]*\nTests run: [\s\S\:\,\-\.0-9\n ]* Failures: [1-9][0-9]*[\s\S\n]* BUILD FAILURE/).to_s.match(/Failed tests: (\n)*[\s\S]*(\n)*Skipped:/).to_s.match(/Failures: [0-9]*/).to_s.split("Failures: ")[1].to_i
		end
		if (log[/Failures: [1-9][0-9]*[\s\S]* <<< FAILURE!/])
			numberOccurences = log.to_enum(:scan, /[a-zA-Z0-9]*\([a-zA-Z.0-9]*\)  Time elapsed: [0-9.]* sec  <<< FAILURE!/).map { Regexp.last_match }
			numberOccurences.each do |occurence|
				generalInfo = occurence.to_s.split("\(")
				methodName = generalInfo[0]
				file = generalInfo[1].split("\)")[0].to_s.split("\.").last
				filesInfo.push([file, methodName])
			end
		end
		if(log[/There are test failures/])
			numberOccurences = log.to_s.to_enum(:scan, /Tests in error:[\s\S]*Tests run/).map { Regexp.last_match }
			numberOccurences.each do |occurence|
				numberFailures += 1
				generalInfo = occurence.to_s.match(/[a-zA-Z0-9]+\.[a-zA-Z0-9]+/)
				methodName = generalInfo.to_s.split("\.").last
				file = generalInfo.to_s.split("\.")[0]
				filesInfo.push([file, methodName])
			end
		end
		return result, numberFailures, filesInfo
	end
end