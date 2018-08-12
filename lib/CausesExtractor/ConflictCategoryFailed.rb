require 'require_all'
require 'travis'
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
		@staticAnalysis = 0
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

	def getStaticAnalysis()
		@staticAnalysis
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
		result = verificationOfTrueTestFiles(result, localClone, mergeScenario)
		return adjustValueReturn(result), result[2], getFinalStatus(result, mergeScenario, localClone)
	end

	def findConflictCause(build, sha, pathLocalClone, buildNumberParentOne, buildNumerParentTwo)
		print build.id
		failedTestFromParent = brokenLogsOfBuild(build)
		if (buildNumberParentOne != nil)
			failedTestFromParentOne = findFailedTestForFailedParent(buildNumberParentOne)
		end
		if (buildNumerParentTwo != nil)
			failedTestFromParentTwo = findFailedTestForFailedParent(buildNumerParentTwo)
		end

		removePreviousFailedTests(failedTestFromParent, failedTestFromParentOne)
		removePreviousFailedTests(failedTestFromParent, failedTestFromParentTwo)
		verificationOfTrueTestFiles(failedTestFromParent, pathLocalClone, sha)
		print failedTestFromParent
		begin
			return adjustValueReturn(failedTestFromParent), failedTestFromParent[0][2], getFinalStatus(failedTestFromParent, build.commit.sha, pathLocalClone)
		rescue
			return adjustValueReturn(failedTestFromParent), nil, getFinalStatus(failedTestFromParent, build.commit.sha, pathLocalClone)
		end
	end

	# receber os ids
	# verificar se os status sao falhos
	# em caso positivo, pegar a lista de quebras
	# remover essa lista já falha do resultado final
	#
	def findFailedTestForFailedParent(buildNumerParent)
		result = []
		begin
			projectTravis = Travis::Repository.find(@projectName)
			build = projectTravis.build(buildNumerParent)
			result = brokenLogsOfBuild(build)
		rescue
			print "GET BUILD FROM BUILD NUMBER DID NOT WORK \n"
		end
		return result
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
		diffsMergeScenario = @gtAnalysis.getGumTreeTCAnalysis(@localClone.getCloneProject().getLocalClone(), sha, @localClone)
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
		validCase = false
		begin
			resultToPrint = Array.new
			resultByJobs.each do |failedCauseJob|
				if (failedCauseJob[0] == "CoverageError")
					resultToPrint.push([["",""], ["", "", "", [[""],[""],[""]]], ["", "", "", [[""],[""],[""]]], ["","",""]])
					newTestFileArray.push("NO APLICABLE")
					newTestCaseArray.push("NO APLICABLE")
					updateTestArray.push("NO APLICABLE")
					changesSameMethod.push("NO APLICABLE")
					dependentChangesParentOne.push("NO APLICABLE")
					dependentChangesParentTwo.push("NO APLICABLE")
					buildStatus.push("NO APLICABLE")
					buildIDs.push("NO APLICABLE")
					validCase = true
				end
			end
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
					validCase = true
					resultCoverageAnalysis = @tcAnalyzer.runTCAnalysis(coverageAnalysis[0], addModFilesLeftResult, addModFilesRightResult)
					resultToPrint.push([filesInfo, coverageAnalysis, resultCoverageAnalysis, resultTC])
					changesSameMethod.push(resultCoverageAnalysis[0])
					dependentChangesParentOne.push(resultCoverageAnalysis[1])
					dependentChangesParentTwo.push(resultCoverageAnalysis[2])
				else
					resultToPrint.push([filesInfo, coverageAnalysis, ["", "", "", [[""],[""],[""]]], resultTC])
					changesSameMethod.push("NO APLICABLE")
					dependentChangesParentOne.push("NO APLICABLE")
					dependentChangesParentTwo.push("NO APLICABLE")
					#resultCoverageAnalysis = @tcAnalyzer.runTCAnalysisErrorCases(addModFilesLeftResult, addModFilesRightResult)
				end
			end
			#ainda tenho o caminho em diffMergeScenario[1]
			@gtAnalysis.deleteProjectCopies(diffsMergeScenario[1])
			#return newTestFileArray, newTestCaseArray, updateTestArray, changesSameMethod, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, validCase, diffsMergeScenario[0][5], buildStatus
			return resultToPrint, diffsMergeScenario[0][5], validCase, buildStatus, buildIDs
		rescue
			@gtAnalysis.deleteProjectCopies(diffsMergeScenario[1])
			#return newTestFileArray, newTestCaseArray, updateTestArray, changesSameMethod, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, validCase, diffsMergeScenario[0][5], buildStatus
			return resultToPrint, diffsMergeScenario[0][5], validCase, buildStatus, buildIDs
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
			elsif (log[/Build failed to meet Clover coverage targets: The following coverage targets for null were not met/])
				@staticAnalysis += 1
				result = "CoverageError"
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
			if (log[/(Failed tests:)(\n)*[\s\S\:\)\(]*[\n]*Tests run:/])
				result = "errored"
				numberOccurences = log.to_s.to_enum(:scan, /Failed tests: (\n)*[\s\S\:\)\(]*\nTests run:/).map { Regexp.last_match }
				numberOccurences[0].to_s.each_line do |occurrenceLine|
					if (!occurrenceLine.to_s.match('Tests in error|Failed tests|there were zero|not invoked|();') and occurrenceLine != "\n")
						methodName = ""
						file = ""
						if (occurrenceLine.match('\('))
							generalInfo = occurrenceLine.match('[a-zA-Z0-9\(\_]*\.[a-zA-Z0-9\.\_]*')
							methodName = generalInfo.to_s.split("\(")[0].to_s
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
					if (!occurrenceLine.to_s.match('Timeout|Tests in error|Tests run|Run|there were zero|not invoked|();') and occurrenceLine != "\n")
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
						elsif (occurrenceLine.match('->[a-zA-Z0-9\(\_]*\.[a-zA-Z0-9\.\_]*'))
							generalInfo = occurrenceLine.match('->[a-zA-Z0-9\(\_]*\.[a-zA-Z0-9\.\_]*')
							methodName = generalInfo.to_s.split(".").last
							file = generalInfo.to_s.split(".")[0].to_s.gsub("->","")
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

	private

	def removePreviousFailedTests(mergeCommitInfo, parentInfo)
		removeCase = []
		begin
			if (mergeCommitInfo.size > 0 and mergeCommitInfo[2] != nil and parentInfo.size > 0 and parentInfo[2] != nil)
				mergeCommitInfo[0][2].each do |failedTestInfoMergeCommit|
					parentInfo[0][2].each do |failedTestInfoParent|
						if (failedTestInfoMergeCommit[0] == failedTestInfoParent[0] and failedTestInfoMergeCommit[1] == failedTestInfoParent[1])
							removeCase.push(failedTestInfoMergeCommit)
						end
					end
				end
				removeCase.each do |removeOne|
					mergeCommitInfo[2].delete(removeOne)
				end
			end
		rescue

		end
	end

	def verificationOfTrueTestFiles(mergeCommitInfo, pathLocalClone, sha)
		actualPath = Dir.pwd
		removeCases = Array.new
		Dir.chdir @localClone.getCloneProject().getLocalClone()
		checkout = %x(git checkout #{sha})
		begin
			mergeCommitInfo[0][2].each do |fileWithTestCase|
				fileLocalPath = %x(find -name #{fileWithTestCase[0]}.java)
				if (fileLocalPath != "")
					file = File.open(fileLocalPath.to_s.gsub("./","").to_s.gsub("\n",""))
					contents = file.read
					file.close
					if (!contents.to_s.include? fileWithTestCase[1].to_s.gsub("\n",""))
						removeCases.push(fileWithTestCase)
					end
				else
					removeCases.push(fileWithTestCase)
				end
			end
			if (removeCases.size > 0)
				removeCases.each do |oneCase|
					mergeCommitInfo[0][2].delete(oneCase)
				end
			end
		rescue
			print "NOT WORKED VERIFICATION OF TRULLY TESTS"
		end
		Dir.chdir actualPath
		return mergeCommitInfo
	end

	def brokenLogsOfBuild(build)
		result = []
		indexJob = 0
		begin
			while (indexJob < build.job_ids.size)
				if (build.jobs[indexJob].state == "failed")
					if (build.jobs[indexJob].log != nil and !build.jobs[indexJob].log.to_s[/The forked VM terminated without saying properly goodbye. VM crash or System.exit called/])
						build.jobs[indexJob].log.body do |part|
							causesInfo = getCauseByJob(part)
							if (causesInfo[1] > 0)
								result.push(causesInfo)
							end
						end
					end
				end
				indexJob += 1
			end
		rescue
			print "CAUSES FROM FAILED TEST DID NOT WORK\n"
			return [[],[],[]]
		end
		return result
	end
end