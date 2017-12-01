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
		@errored = 0
		@cmpProblem = 0
		@gtAnalysis = GTAnalysis.new(@pathGumTree, @projectName, @localClone)
		@testCaseCoverge = TestCaseCoverage.new(@localClone.getCloneProject().getLocalClone(), extractorCLI)
		@tcAnalyzer = TestConflictsAnalyzer.new()
	end

	def getProjectName()
		@projectName
	end

	def getCmpProblem()
		@cmpProblem
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

	def getErrored()
		@errored
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
				if (build.jobs[indexJob].log != nil and !build.jobs[indexJob].log.to_s[/The forked VM terminated without saying properly goodbye. VM crash or System.exit called/])
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
		dependentChangesParentOne = []
		dependentChangesParentTwo = []
		buildIDs = []
		buildStatus = []
		coverageAnalysis = nil
		begin
			resultByJobs[0][2].each do |filesInfo|
				resultTC = testConflictsExtractor.getInfoTestConflictsByParent(diffsMergeScenario[0], diffsMergeScenario[1], filesInfo, getPathGumTree())
				newTestFileArray.push(resultTC[0])
				newTestCaseArray.push(resultTC[1])
				updateTestArray.push(resultTC[2])
				#add uma classe responsável por fazer a análise
				#esta iria receber apenas as iformações relacionadas
				#Já tenho essa informação em diffMergeScenario : [1]LeftResult e [3]RightResult
				addModFilesLeftResult = @gtAnalysis.getParentsMFDiff.runOnlyModifiedAddFiles(diffsMergeScenario[0][1][0], diffsMergeScenario[1][2], diffsMergeScenario[1][1])
				addModFilesRightResult = @gtAnalysis.getParentsMFDiff.runOnlyModifiedAddFiles(diffsMergeScenario[0][3][0], diffsMergeScenario[1][3], diffsMergeScenario[1][1])
				coverageAnalysis = @testCaseCoverge.runTestCase(filesInfo[0], filesInfo[1], sha)
				resultCoverageAnalysis = []
				buildStatus.push(coverageAnalysis[2])
				buildIDs.push(coverageAnalysis[1])
				if (coverageAnalysis[0] != nil)
					resultCoverageAnalysis = @tcAnalyzer.runTCAnalysis(coverageAnalysis[0], addModFilesLeftResult, addModFilesRightResult)
					changesSameMethod.push(resultCoverageAnalysis[0])
					dependentChangesParentOne.push(resultCoverageAnalysis[1])
					dependentChangesParentTwo.push(resultCoverageAnalysis[2])
				else
					resultCoverageAnalysis = @tcAnalyzer.runTCAnalysisErrorCases(addModFilesLeftResult, addModFilesRightResult)
				end
			end
			#ainda tenho o caminho em diffMergeScenario[1]
			@gtAnalysis.deleteProjectCopies(diffsMergeScenario[1])
			return newTestFileArray, newTestCaseArray, updateTestArray, changesSameMethod, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, coverageAnalysis[0], diffsMergeScenario[0][5], buildStatus
		rescue
			@gtAnalysis.deleteProjectCopies(diffsMergeScenario[1])
			return newTestFileArray, newTestCaseArray, updateTestArray, changesSameMethod, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, nil, diffsMergeScenario[0][5], buildStatus
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
		if (log != nil)
			if (log[/Errors: [1-9][0-9]*/])
				@failed += 1
				result = "failed"
			elsif (log[/#{stringBuildFail}\s*([^\n\r]*)\s*([^\n\r]*)\s*([^\n\r]*)failed/] || log[/#{stringTheCommand}("mvn|"\.\/mvnw)+(.*)failed(.*)/])
				@failed += 1
				result = "failed"
			elsif (log[/There are test failures/])
				@errored += 1
				result = "errored"
			elsif (log[/#{stringTheCommand}("git clone |"git checkout)(.*?)failed(.*)[\n]*/])
				@gitProblem += 1
				result = "gitProblem"
			elsif (log[/#{stringNoOutput}(.*)wrong(.*)[\n]*#{stringTerminated}/] || log[/404 Not Found/])
				@remoteError += 1
				result = "CompilationProblem"
			elsif (log[/#{stringTheCommand}("cd|"sudo|"echo|"eval)+ (.*)failed(.*)/])
				@permission += 1
				result = "permission"
			elsif (log[/reason: actual and formal argument lists differ in length|cannot find symbol/] || log[/is already defined in/]|| log[/illegal start of type/])
				@cmpProblem += 1
				result = "CompilationProblem"
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
					if (methodName != "" and file != "" and methodName != nil and file != nil)
						filesInfo.push([file, methodName])
						numberFailures += 1
					end
				end
			end
			if (log[/Failed tests: (\n)*[\s\S\:\)\(]*\nTests run:/])
				result = "errored"
				numberOccurences = log.to_s.to_enum(:scan, /Failed tests: (\n)*[\s\S\:\)\(]*\nTests run:/).map { Regexp.last_match }
				numberOccurences[0].to_s.each_line do |occurrenceLine|
					if (!occurrenceLine.to_s.match('Tests in error|Failed tests|there were zero|not invoked|();') and occurrenceLine != "\n")
						methodName = ""
						file = ""
						if (occurrenceLine.match('\('))
							generalInfo = occurrenceLine.match('[a-zA-Z0-9\(\_]*\.[a-zA-Z0-9\.\_]*')
							methodName = generalInfo.to_s.split("\(")[0]
							if (methodName.match('.'))
								methodName = methodName.to_s.split(".").last
								file = generalInfo.to_s.split("#{methodName}")[0].to_s.split(".").last.to_s.gsub(".","")
							else
								file = generalInfo.to_s.split("\.").last
							end
						else
							generalInfo = occurrenceLine.match('[a-zA-Z0-9]*\.[a-zA-Z0-9\_\.]*')
							file = generalInfo.to_s.split("\.")[0]
							methodName = generalInfo.to_s.split("\.").last
						end
						if (methodName != "" and file != "" and methodName != nil and file != nil)
							filesInfo.push([file, methodName])
							numberFailures += 1
						end
					end
				end
			elsif(log[/There (are|was) test failures/])
				result = "errored"
				numberOccurences = log.to_s.to_enum(:scan, /Tests in error:[\s\S]*Tests run/).map { Regexp.last_match }
				numberOccurences[0].to_s.each_line do |occurrenceLine|
					#numberOccurences.each do |occurrenceLine|
					if (!occurrenceLine.to_s.match('Tests in error|Tests run|Run|there were zero|->|not invoked|();') and occurrenceLine != "\n")
						#if (occurrenceLine != "\n")
						#methodName = occurrenceLine.to_s.match('Tests in error:[a-zA-Z0-9 \\n\.]*').to_s.split("\.").last
						methodName = ""
						file = ""
						if (occurrenceLine.match('\('))
							generalInfo = occurrenceLine.match('[a-zA-Z0-9\(\_]*\.[a-zA-Z0-9\.\_]*')
							methodName = generalInfo.to_s.split("\(")[0]
							if (methodName != nil and methodName.match('\.'))
								methodName = methodName.to_s.split(".").last
								file = generalInfo.to_s.split("#{methodName}")[0].to_s.split(".").last.to_s.gsub(".","")
							else
								file = generalInfo.to_s.split("\.").last
							end
						else
							#talvez seja melhor usar generalInfo[0]
							generalInfo = occurrenceLine.match('[a-zA-Z0-9]*\.[a-zA-Z0-9\_\.]*')
							file = generalInfo.to_s.split("\.")[0]
							methodName = generalInfo.to_s.split("\.").last
						end
						#file = occurrenceLine.to_s.match('Tests in error:[a-zA-Z0-9 \\n\.\[\]\=\(]*').to_s.split("\.").last
						if (methodName != "" and file != "" and methodName != nil and file != nil)
							filesInfo.push([file, methodName])
							numberFailures += 1
						end
					end
				end
			end
		end

		return result, numberFailures, filesInfo
	end
end