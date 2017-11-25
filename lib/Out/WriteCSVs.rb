require 'fileutils'
require 'csv'
require 'require_all'
require_all './CausesExtractor'

class WriteCSVs

	def initialize(actualPath)
		@pathConflicstAnalysis = ""
		@pathErroredCases = ""
		@pathFailedCases = ""
		creatingResultsDirectories(actualPath)
	end

	def getPathErroredCases()
		@pathErroredCases
	end

	def getPathFailedCases()
		@pathFailedCases
	end

	def getPathConflicstAnalysis()
		@pathConflicstAnalysis
	end

	def getPathConflictsCauses()
		@pathConflictsCauses
	end

	def creatingResultsDirectories(actualPath)
		Dir.chdir actualPath
		delete = %x(rm -rf FinalResults)
		FileUtils::mkdir_p 'ConflictsAnalysis'
		FileUtils::mkdir_p 'ConflictsCauses'
		FileUtils::mkdir_p 'ErroredCases'
		FileUtils::mkdir_p 'FailedCases'
		Dir.chdir actualPath
		Dir.chdir "ConflictsAnalysis"
		@pathConflicstAnalysis = Dir.pwd
		Dir.chdir actualPath
		Dir.chdir "ConflictsCauses"
		@pathConflictsCauses = Dir.pwd
		Dir.chdir actualPath
		Dir.chdir "ErroredCases"
		@pathErroredCases = Dir.pwd
		Dir.chdir actualPath
		Dir.chdir "FailedCases"
		@pathFailedCases = Dir.pwd
		createCSV()
	end

	def createDirectoryByProject(projectName)
		Dir.chdir getPathResultByProject
		FileUtils::mkdir_p projectName
		Dir.chdir projectName
		setPathResultByProjectDirectory(Dir.pwd)
	end

	def createCSV()
		createBuildConflictCausesFile()
		createTestConflictsCausesFiles()
		createConflicAnalysisFile()
 	end

 	def createBuildConflictCausesFile()
 		Dir.chdir getPathConflictsCauses()
		CSV.open("BuildConflictsCauses.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "UNAVAILABLE VARIABLE", "UNAVAILABLE METHOD", "UNAVAILABLE FILE", "MALFORMED EXPRESSION", 
				"METHOD UPDATE", "DUPLICATE STATEMENT", "DEPENDENCY", "UNIMPLEMENTED METHOD", "GIT PROBLEM", "REMOTE ERROR", "COMPILER ERROR",
				"ANOTHER ERROR"]
		end
 	end

 	def createTestConflictsCausesFiles()
 		Dir.chdir getPathConflictsCauses()
 		CSV.open("TestConflictsCauses.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "FAILED", "GIT PROBLEM", "REMOTE ERROR", "ANOTHER ERROR"]
		end
 	end

	def createConflicAnalysisFile
		Dir.chdir getPathConflicstAnalysis
		CSV.open("ConflictsAnalysisFinal.csv", "w") do |csv|
 			csv << ["ProjectName", "MergeScenarios", "PushesNotBuilt", "TotalRepeat", "MSNoParent","TotalBuiltPushes","PushesPassed", 
 				"PassedTravis", "PassedTravisConf", "PassedConfig", "PassedConfigConf", "PassedSource", "PassedSourceConf", "PassedAll", 
 				"PassedAllConf", "PushesErrored", "ErroredTravis", "ErroredTravisConf", "ErroredConfig", "ErroredConfigConf", "ErroredSource", 
 				"ErroredSourceConf", "ErroredAll", "ErroredAllConf", "PushesFailed", "FailedTravis", "FailedTravisConf", "FailedConfig", 
 				"FailedConfigConf","FailedSource", "FailedSourceConf", "FailedAll", "FailedAllConf", "PushesCanceled", "CanceledTravis", 
 				"CanceledTravisConf", "CanceledConfig", "CanceledConfigConf", "CanceledSource", "CanceledSourceConf", "CanceledAll", 
 				"CanceledAllConf"]
 		end
	end

	def writeBuildConflicts(projectName, confErroredTotal, confErroredunavailableSymbol, confErroredMalformedExp, confErroredMethodUpdate, 
							confErroredDuplicate, confErroredDependency, confErroredMethod, confErroredGitProblem, confErroredRemoteError, 
							confErroredCompilerError, confErroredOtherError)
		Dir.chdir getPathConflictsCauses()
		CSV.open("BuildConflictsCauses.csv", "a+") do |csv|
			csv << [projectName, confErroredTotal, confErroredunavailableSymbol, confErroredMalformedExp, confErroredMethodUpdate, 
					confErroredDuplicate, confErroredDependency, confErroredMethod, confErroredGitProblem, confErroredRemoteError, 
					confErroredCompilerError, confErroredOtherError]
		end
	end

	def writeTestConflicts(projectName, confFailedTotal, confFailedFailed, confFailedGitProblem, confFailedRemoteError, confFailedPermission, 
							confFailedOtherError)
		Dir.chdir getPathConflictsCauses()
		CSV.open("TestConflictsCauses.csv", "a+") do |csv|
			csv << [projectName, confFailedTotal, confFailedFailed, confFailedRemoteError, confFailedPermission, confFailedOtherError]
		end
	end

	def writeConflictsAnalysisFinal(projectName, projectMergeScenariosSize, projectMergeScenariosBuilt, totalRepeatedBuilds, 
					totalPushesNoBuilt, totalPushes, passedConflictsTotalPushes, passedConflictsTotalTravis, passedConflictsTotalTravisConf, 
					passedConflictsTotalConfig, passedConflictsTotalConfigConf, passedConflictsTotalSource, passedConflictsTotalSourceConf, 
					passedConflictsTotalAll, passedConflictsTotalAllConf, erroredConflictsTotalPushes, erroredConflictsTotalTravis, 
					erroredConflictsTotalTravisConf, erroredConflictsTotalConfig, erroredConflictsTotalConfigConf, erroredConflictsTotalSource, 
					erroredConflictsTotalSourceConf, erroredConflictsTotalAll, erroredConflictsTotalAllConf, failedConflictsTotalPushes, 
					failedConflictsTotalTravis, failedConflictsTotalTravisConf, failedConflictsTotalConfig, failedConflictsTotalConfigConf, 
					failedConflictsTotalSource, failedConflictsTotalSourceConf,failedConflictsTotalAll, failedConflictsTotalAllConf, 
					canceledConflictsTotalPushes, canceledConflictsTotalTravis,canceledConflictsTotalTravisConf, canceledConflictsTotalConfig, 
					canceledConflictsTotalConfigConf, canceledConflictsTotalSource, canceledConflictsTotalSourceConf,canceledConflictsTotalAll, 
					canceledConflictsTotalAllConf)
		Dir.chdir getPathConflicstAnalysis()
		CSV.open("ConflictsAnalysisFinal.csv", "a+") do |csv|
			csv << [projectName, projectMergeScenariosSize, projectMergeScenariosBuilt, totalRepeatedBuilds, totalPushesNoBuilt, totalPushes, 
					passedConflictsTotalPushes, passedConflictsTotalTravis, passedConflictsTotalTravisConf, passedConflictsTotalConfig, 
					passedConflictsTotalConfigConf, passedConflictsTotalSource, passedConflictsTotalSourceConf, passedConflictsTotalAll, 
					passedConflictsTotalAllConf, erroredConflictsTotalPushes, erroredConflictsTotalTravis, erroredConflictsTotalTravisConf, 
					erroredConflictsTotalConfig, erroredConflictsTotalConfigConf, erroredConflictsTotalSource, erroredConflictsTotalSourceConf, 
					erroredConflictsTotalAll, erroredConflictsTotalAllConf, failedConflictsTotalPushes, failedConflictsTotalTravis, 
					failedConflictsTotalTravisConf, failedConflictsTotalConfig, failedConflictsTotalConfigConf, failedConflictsTotalSource, 
					failedConflictsTotalSourceConf,failedConflictsTotalAll, failedConflictsTotalAllConf, canceledConflictsTotalPushes, 
					canceledConflictsTotalTravis,canceledConflictsTotalTravisConf, canceledConflictsTotalConfig, canceledConflictsTotalConfigConf, 
					canceledConflictsTotalSource, canceledConflictsTotalSourceConf,canceledConflictsTotalAll, canceledConflictsTotalAllConf]
		end
	end

	def printConflictBuild(build, buildOne, buildTwo, state, projectName, effort)
		Dir.chdir getPathErroredCases()
		if (File.exists?("Errored"+projectName+".csv"))
			CSV.open("Errored"+projectName+".csv", "a+") do |csv|
				if (effort != nil)
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], effort[0], effort[1], effort[2], effort[3], effort[4], effort[5], effort[6], effort[7]]
				else
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], "", "", "", "", "", "", "", ""]
				end

			end
		else
			CSV.open("Errored"+projectName+".csv", "ab") do |csv|
				csv << ["BuildID", "BuildParentOne", "BuildParentTwo", "MessageState", "NumberOccurrences", "ConflictingContributions", "AllColaborationsIntgrated", "BrokenBuild", "Dependency", "FixBuildID", "FixStatus", "Effort", "NumberBuildsPerformed", "SameAuthor", "SameCommiter", "BestCase", "FIxPattern"]
				if (effort != nil)
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], effort[0], effort[1], effort[2], effort[3], effort[4], effort[5], effort[6], effort[7]]
				else
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], "", "", "", "", "", "", "", ""]
				end
			end			
		end
	end

	def printConflictBuildFromFailedBuils(build, buildOne, buildTwo, state, projectName, effort)
		Dir.chdir getPathErroredCases()
		if (File.exists?("BCFromFailed"+projectName+".csv"))
			CSV.open("BCFromFailed"+projectName+".csv", "a+") do |csv|
				if (effort != nil)
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], effort[0], effort[1], effort[2], effort[3], effort[4], effort[5], effort[6], effort[7]]
				else
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], "", "", "", "", "", "", "", ""]
				end

			end
		else
			CSV.open("BCFromFailed"+projectName+".csv", "ab") do |csv|
				csv << ["BuildID", "BuildParentOne", "BuildParentTwo", "MessageState", "NumberOccurrences", "ConflictingContributions", "AllColaborationsIntgrated", "BrokenBuild", "Dependency", "FixBuildID", "FixStatus", "Effort", "NumberBuildsPerformed", "SameAuthor", "SameCommiter", "BestCase", "FIxPattern"]
				if (effort != nil)
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], effort[0], effort[1], effort[2], effort[3], effort[4], effort[5], effort[6], effort[7]]
				else
					csv << [build, buildOne, buildTwo, state[0], state[2], state[1][0], state[1][1], state[1][2], state[1][3], "", "", "", "", "", "", "", ""]
				end
			end
		end
	end

	def printConflictTest(build, buildOne, buildTwo, status, projectName, effort, frequency, infoNewTestFile, infoNewTestCase, updateTestCase, changesSameMethods, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, allContributionsIntegrated)
		Dir.chdir getPathFailedCases()
		if (File.exists?("Failed"+projectName+".csv"))
			CSV.open("Failed"+projectName+".csv", "a+") do |csv|
				if (effort != nil)
					csv << [build, buildOne, buildTwo, status, frequency, effort[0], effort[1], effort[2], effort[3], effort[4], effort[5], effort[6], infoNewTestFile, infoNewTestCase, updateTestCase, changesSameMethods, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, allContributionsIntegrated]
				else
					csv << [build, buildOne, buildTwo, status, frequency, "", "", "", "", "", "", "", infoNewTestFile, infoNewTestCase, updateTestCase, changesSameMethods, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, allContributionsIntegrated]
				end
			end
		else
			CSV.open("Failed"+projectName+".csv", "ab") do |csv|
				csv << ["BuildID", "BuildParentOne", "BuildParentTwo", "MessageState", "Frequency", "FixBuildID", "FixStatus", "Effort", "NumberBuildsPerformed", "SameAuthor", "SameCommiter", "BestCase", "NewTestFile", "NewTestCase", "UpdateTestCase", "ChangesSameMethod", "DependentChangesParentOne", "DependentChangesParentTwo", "BuildIDs", "AllContributionsIntegrated"]
				if (effort != nil)
					csv << [build, buildOne, buildTwo, status, frequency, effort[0], effort[1], effort[2], effort[3], effort[4], effort[5], effort[6], infoNewTestFile, infoNewTestCase, updateTestCase, changesSameMethods, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, allContributionsIntegrated]
				else
					csv << [build, buildOne, buildTwo, status, frequency, "", "", "", "", "", "", "", infoNewTestFile, infoNewTestCase, updateTestCase, changesSameMethods, dependentChangesParentOne, dependentChangesParentTwo, buildIDs, allContributionsIntegrated]
				end
			end			
		end
	end

	def printAllConflictTest(build, buildOne, buildTwo, projectName)
		Dir.chdir getPathFailedCases()
		if (File.exists?("AllFailed"+projectName+".csv"))
			CSV.open("AllFailed"+projectName+".csv", "a+") do |csv|
				csv << [build, buildOne, buildTwo]
			end
		else
			CSV.open("AllFailed"+projectName+".csv", "ab") do |csv|
				csv << ["BuildID", "BuildParentOne", "BuildParentTwo"]
				csv << [build, buildOne, buildTwo]
			end
		end
	end

end