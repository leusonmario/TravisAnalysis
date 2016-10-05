#!/usr/bin/env ruby

require 'csv'
require 'fileutils'
require 'find'
require './Repository/GitProject.rb'
require './Repository/ProjectInfo.rb'
require './Travis/BuildTravis.rb'

class MainAnalysisProjects

	def initialize(pathAnalysis)
		@pathAnalysis = pathAnalysis
		@pathAllResults = ""
		@pathResultByProject = ""
		@pathConflicstAnalysis = ""
		@pathMergeScenariosAnalysis = ""
		@pathConflictsAnalysis = ""
		@pathErroredCases = ""
		@pathFailedCases = ""
		creatingResultsDirectories()
		@projectsInfo = ProjectInfo.new(pathAnalysis)
		travisAnalysis()
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

	def travisAnalysis()
		puts "*************************************"
		puts "########## TRAVIS ANALYSIS ##########"
		puts "-------------------------------------"
		puts "RootPath: #{@pathAnalysis}"
		puts "-------------------------------------"
		puts "-------------------------------------"

	end

	def creatingResultsDirectories()
		FileUtils::mkdir_p 'ResultsAll/ResultsByProject'
		FileUtils::mkdir_p 'ResultsAll/ConflictsAnalysis'
		FileUtils::mkdir_p 'ResultsAll/MergeScenariosAnalysis'
		FileUtils::mkdir_p 'ResultsAll/ConflictsCauses'
		FileUtils::mkdir_p 'ResultsAll/ErroredCases'
		FileUtils::mkdir_p 'ResultsAll/FailedCases'
		Dir.chdir "ResultsAll"
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
		
	end

	def runAnalysis()
		Dir.chdir getPathAllResults
		CSV.open("resultsAllFinal.csv", "wb") do |csv|
			csv << ["Project", "TotalBuildPush", "TotalPushPassed", "TotalPushErrored", "TotalPushFailed", "TotalPushCanceled", 
				"TotalBuildPull", "TotalPullPassed", "TotalPullErrored", "TotalPullFailed", "TotalPullCanceled"]
		end

		Dir.chdir getPathMergeScenariosAnalysis
		CSV.open("TotalMergeScenariosFinal.csv", "wb") do |csv|
			csv << ["Project", "TotalMS", "TotalMSBuilded", "AllBuilds", "TotalRepeatedMSB", "TotalMSPassed", "TotalMSErrored", "TotalMSFailed", "TotalMSCanceled"]
		end

		Dir.chdir getPathConflictsCauses
		CSV.open("CausesBuildConflicts.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "NO FOUND SYMBOL", "GIT PROBLEM", "REMOTE ERROR", "COMPILER ERROR", "PERMISSION", "ANOTHER ERROR"]
		end

		CSV.open("CausesTestConflicts.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "FAILED", "GIT PROBLEM", "REMOTE ERROR", "PERMISSION", "ANOTHER ERROR"]
		end

		Dir.chdir getPathConflicstAnalysis
		CSV.open("ConflictsAnalysisFinal.csv", "w") do |csv|
 			csv << ["ProjectName", "MergeScenarios", "PushesNotBuilt", "TotalRepeat", "MSNoParent","TotalBuiltPushes","PushesPassed", "PassedTravis", "PassedTravisConf", "PassedConfig", 
 				"PassedConfigConf", "PassedSource", "PassedSourceConf", "PassedAll", "PassedAllConf", "PushesErrored", "ErroredTravis", "ErroredTravisConf", "ErroredConfig", "ErroredConfigConf", "ErroredSource", "ErroredSourceConf", 
 				"ErroredAll", "ErroredAllConf", "PushesFailed", "FailedTravis", "FailedTravisConf", "FailedConfig", "FailedConfigConf","FailedSource", "FailedSourceConf", "FailedAll", "FailedAllConf", "PushesCanceled", "CanceledTravis", "CanceledTravisConf", "CanceledConfig", 
 				"CanceledConfigConf", "CanceledSource", "CanceledSourceConf", "CanceledAll", "CanceledAllConf"]
 		end
		
		index = 0
		@projectsInfo.getPathProjects().each do |pathProject|
			gitProject = GitProject.new(pathProject)
			projectName = gitProject.getProjectName()
			puts "Project [#{index+1}]: #{projectName}"
			buildTravis = BuildTravis.new(projectName, pathProject)
			projectAnalysis = buildTravis.getStatusBuildsProject(projectName, getPathResultByProject, getPathConflicstAnalysis, getPathMergeScenariosAnalysis, 
				getPathConflictsCauses, getPathErroredCases, getPathFailedCases)
			Dir.chdir getPathAllResults
			CSV.open("resultsAllFinal.csv", "a+") do |csv|
				csv << [projectAnalysis[0], projectAnalysis[1], projectAnalysis[2], projectAnalysis[3], projectAnalysis[4], projectAnalysis[5], 
				projectAnalysis[6], projectAnalysis[7], projectAnalysis[8], projectAnalysis[9], projectAnalysis[10]]
			end
			index += 1
		end
		puts "************* FINISH :) *************"
	end
end

parameters = []
File.open("properties", "r") do |text|
	indexLine = 0
	text.each_line do |line|
		parameters[indexLine] = line[/\<(.*?)\>/, 1]
		indexLine += 1
	end
end

actualPath = Dir.pwd
project = MainAnalysisProjects.new(parameters[0])
project.runAnalysis()

Dir.chdir actualPath
Dir.chdir "R"
%x(Rscript r-analysis.r)
