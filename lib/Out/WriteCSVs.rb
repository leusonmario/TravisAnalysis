#!/usr/bin/env ruby

require 'fileutils'
require 'csv'
require './Travis/BuildTravis.rb'

class WriteCSVs

	def initialize(actualPath)
		@pathAllResults = ""
		@pathResultByProject = ""
		@pathConflicstAnalysis = ""
		@pathMergeScenariosAnalysis = ""
		@pathConflictsAnalysis = ""
		@pathErroredCases = ""
		@pathFailedCases = ""
		creatingResultsDirectories(actualPath)
	end

	def getDbConnection()
		@dbConnection
	end

	def getPathAnalysis()
		@pathAnalysis
	end

	def getPathErroredCases()
		@pathErroredCases
	end

	def getPathFailedCases()
		@pathFailedCases
	end

	def getPathAllResults()
		@pathAllResults
	end

	def getPathResultByProject()
		@pathResultByProject
	end

	def getPathConflicstAnalysis()
		@pathConflicstAnalysis
	end

	def getPathMergeScenariosAnalysis()
		@pathMergeScenariosAnalysis
	end

	def getPathConflictsCauses()
		@pathConflictsCauses
	end

	def creatingResultsDirectories(actualPath)
		Dir.chdir actualPath
		FileUtils::mkdir_p 'FinalResults/ResultsByProject'
		FileUtils::mkdir_p 'FinalResults/ConflictsAnalysis'
		FileUtils::mkdir_p 'FinalResults/MergeScenariosAnalysis'
		FileUtils::mkdir_p 'FinalResults/ConflictsCauses'
		FileUtils::mkdir_p 'FinalResults/ErroredCases'
		FileUtils::mkdir_p 'FinalResults/FailedCases'
		Dir.chdir "FinalResults"
		@pathAllResults = Dir.pwd
		Dir.chdir "ResultsByProject"
		@pathResultByProject = Dir.pwd
		Dir.chdir @pathAllResults
		Dir.chdir "ConflictsAnalysis"
		@pathConflicstAnalysis = Dir.pwd
		Dir.chdir @pathAllResults
		Dir.chdir "MergeScenariosAnalysis"
		@pathMergeScenariosAnalysis = Dir.pwd
		Dir.chdir @pathAllResults
		Dir.chdir "ConflictsCauses"
		@pathConflictsCauses = Dir.pwd
		Dir.chdir @pathAllResults
		Dir.chdir "ErroredCases"
		@pathErroredCases = Dir.pwd
		Dir.chdir @pathAllResults
		Dir.chdir "FailedCases"
		@pathFailedCases = Dir.pwd
		createCSV()
	end

	def createCSV()

		Dir.chdir getPathAllResults
		CSV.open("AllProjectsResult.csv", "wb") do |csv|
			csv << ["Project", "TotalBuildPush", "TotalPushPassed", "TotalPushErrored", "TotalPushFailed", "TotalPushCanceled", 
				"TotalBuildPull", "TotalPullPassed", "TotalPullErrored", "TotalPullFailed", "TotalPullCanceled"]
		end
		
		Dir.chdir getPathMergeScenariosAnalysis
		CSV.open("MergeScenariosProjects.csv", "wb") do |csv|
			csv << ["Project", "TotalMS", "TotalMSBuilt", "AllBuilds", "TotalRepeatedMSB", "TotalMSPassed", "TotalMSErrored", "TotalMSFailed", "TotalMSCanceled"]
		end
		
		Dir.chdir getPathConflictsCauses
		CSV.open("BuildConflictsCauses.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "NO FOUND SYMBOL", "GIT PROBLEM", "REMOTE ERROR", "COMPILER ERROR", "ANOTHER ERROR"]
		end

		CSV.open("TestConflictsCauses.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "FAILED", "GIT PROBLEM", "REMOTE ERROR", "ANOTHER ERROR"]
		end

		Dir.chdir getPathConflicstAnalysis
		CSV.open("ConflictsAnalysisFinal.csv", "w") do |csv|
 			csv << ["ProjectName", "MergeScenarios", "PushesNotBuilt", "TotalRepeat", "MSNoParent","TotalBuiltPushes","PushesPassed", "PassedTravis", "PassedTravisConf", "PassedConfig", 
 				"PassedConfigConf", "PassedSource", "PassedSourceConf", "PassedAll", "PassedAllConf", "PushesErrored", "ErroredTravis", "ErroredTravisConf", "ErroredConfig", "ErroredConfigConf", "ErroredSource", "ErroredSourceConf", 
 				"ErroredAll", "ErroredAllConf", "PushesFailed", "FailedTravis", "FailedTravisConf", "FailedConfig", "FailedConfigConf","FailedSource", "FailedSourceConf", "FailedAll", "FailedAllConf", "PushesCanceled", "CanceledTravis", "CanceledTravisConf", "CanceledConfig", 
 				"CanceledConfigConf", "CanceledSource", "CanceledSourceConf", "CanceledAll", "CanceledAllConf"]
 		end
 	end

 	def createResultByProjectFiles(projectName)
		Dir.chdir getPathResultByProject()
		CSV.open(projectName+"Final.csv", "w") do |csv|
 			csv << ["Status", "Type", "Commit", "ID"]
 		end
	end

 	def writeResultsAll(projectInfo)
 		Dir.chdir getPathAllResults
	 	CSV.open("AllProjectsResult.csv", "a+") do |csv|
 			csv << [projectInfo[0], projectInfo[1], projectInfo[2], projectInfo[3], projectInfo[4], projectInfo[5], projectInfo[6], projectInfo[7], projectInfo[8], 
			projectInfo[9], projectInfo[10]]
		end
	end

	def writeResultByProject(projectName, typeBuild, build)
		Dir.chdir getPathResultByProject()
		CSV.open(projectName+"Final.csv", "a+") do |csv|
			csv << [build.state, typeBuild, build.commit.sha, build.id]
		end
	end

	def writeMergeScenariosFinal(projectName, projectMergeScenariosSize, builtMergeScenariosSize, totalBuilds, totalRepeatedBuilds, totalMSPassed, totalMSErrored, totalMSFailed, totalMSCanceled)
		Dir.chdir getPathMergeScenariosAnalysis()
		CSV.open("MergeScenariosProjects.csv", "a+") do |csv|
			csv << [projectName, projectMergeScenariosSize, builtMergeScenariosSize, totalBuilds, totalRepeatedBuilds, totalMSPassed, totalMSErrored, totalMSFailed, totalMSCanceled]
		end
	end

	def writeBuildConflicts(projectName, confErroredTotal, confErroredUnvailableSymbol, confErroredGitProblem, confErroredRemoteError, confErroredCompilerError, confErroredOtherError)
		Dir.chdir getPathConflictsCauses()
		CSV.open("BuildConflictsCauses.csv", "a+") do |csv|
			csv << [projectName, confErroredTotal, confErroredUnvailableSymbol, confErroredGitProblem, confErroredRemoteError, confErroredCompilerError, confErroredOtherError]
		end
	end

	def writeTestConflicts(projectName, confFailedTotal, confFailedFailed, confFailedGitProblem, confFailedRemoteError, confFailedPermission, confFailedOtherError)
		Dir.chdir getPathConflictsCauses()
		CSV.open("TestConflictsCauses.csv", "a+") do |csv|
			csv << [projectName, confFailedTotal, confFailedFailed, confFailedRemoteError, confFailedPermission, confFailedOtherError]
		end
	end

	def writeConflictsAnalysisFinal(projectName, projectMergeScenariosSize, projectMergeScenariosBuilt, totalRepeatedBuilds, totalPushesNoBuilt, totalPushes, 
					passedConflictsTotalPushes, passedConflictsTotalTravis, passedConflictsTotalTravisConf, passedConflictsTotalConfig, 
					passedConflictsTotalConfigConf, passedConflictsTotalSource, passedConflictsTotalSourceConf, passedConflictsTotalAll, 
					passedConflictsTotalAllConf, erroredConflictsTotalPushes, erroredConflictsTotalTravis, erroredConflictsTotalTravisConf, 
					erroredConflictsTotalConfig, erroredConflictsTotalConfigConf, erroredConflictsTotalSource, erroredConflictsTotalSourceConf, 
					erroredConflictsTotalAll, erroredConflictsTotalAllConf, failedConflictsTotalPushes, failedConflictsTotalTravis, 
					failedConflictsTotalTravisConf, failedConflictsTotalConfig, failedConflictsTotalConfigConf, failedConflictsTotalSource, 
					failedConflictsTotalSourceConf,failedConflictsTotalAll, failedConflictsTotalAllConf, canceledConflictsTotalPushes, 
					canceledConflictsTotalTravis,canceledConflictsTotalTravisConf, canceledConflictsTotalConfig, canceledConflictsTotalConfigConf, 
					canceledConflictsTotalSource, canceledConflictsTotalSourceConf,canceledConflictsTotalAll, canceledConflictsTotalAllConf)
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

	def printConflictBuild(build, buildOne, buildTwo, state, projectName)
		Dir.chdir getPathErroredCases()
		if (File.exists?("Errored"+projectName+".csv"))
			CSV.open("Errored"+projectName+".csv", "a+") do |csv|
				csv << [build.id, buildOne.id, buildTwo.id, state]
			end
		else
			CSV.open("Errored"+projectName+".csv", "w") do |csv|
				csv << ["BuildID", "BuildParentOne", "BuildParentTwo", "MessageState"]
				csv << [build.id, buildOne.id, buildTwo.id, state]
			end			
		end
	end

	def printConflictTest(build, buildOne, buildTwo, state, projectName)
		Dir.chdir getPathFailedCases()
		if (File.exists?("Failed"+projectName+".csv"))
			CSV.open("Failed"+projectName+".csv", "a+") do |csv|
				csv << [build.id, buildOne.id, buildTwo.id, state]
			end
		else
			CSV.open("Failed"+projectName+".csv", "w") do |csv|
				csv << ["BuildID", "BuildParentOne", "BuildParentTwo", "MessageState"]
				csv << [build.id, buildOne.id, buildTwo.id, state]
			end			
		end
	end

end