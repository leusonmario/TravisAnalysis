#!/usr/bin/env ruby

require 'require_all'
require_all './Repository'
require_all './Out'
require_all './Travis'

class MainAnalysisProjects

	def initialize(loginUser, passwordUser, pathGumTree, projectsList)
		@loginUser = loginUser
		@passwordUser = passwordUser
		@pathGumTree = pathGumTree
		@localClone = Dir.pwd
		delete = %x(rm -rf FinalResults)
		FileUtils::mkdir_p 'FinalResults/AllErroredBuilds'
		FileUtils::mkdir_p 'FinalResults/MergeScenarios/BuiltMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/MergeScenarios/AllMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/MergeScenarios/IntervalMergeScenarios'
		Dir.chdir "FinalResults/MergeScenarios/BuiltMergeScenarios"
		@writeCSVWithForksBuiltMerge = WriteCSVWithForks.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/MergeScenarios/AllMergeScenarios"
		@writeCSVWithForksAllMerge = WriteCSVs.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/MergeScenarios/IntervalMergeScenarios"
		@writeCSVWithForksIntervalMerge = WriteCSVs.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/AllErroredBuilds"
		@writeCSVAllErroredBuilds = WriteCSVAllErrored.new(Dir.pwd)
		Dir.chdir getLocalCLone
		@projectsList = projectsList
	end

	def getLocalCLone()
		@localClone
	end

	def getLoginUser()
		@loginUser
	end

	def getPasswordUser()
		@passwordUser
	end

	def getPathGumTree()
		@pathGumTree
	end

	def getWriteCSVForkBuilt()
		@writeCSVWithForksBuiltMerge
	end

	def getWriteCSVForkAll()
		@writeCSVWithForksAllMerge
	end

	def getWriteCSVForkInterval()
		@writeCSVWithForksIntervalMerge
	end

	def getWriteCSVAllErroredBuilds()
		@writeCSVAllErroredBuilds
	end

	def getProjectsList()
		@projectsList
	end

	def printStartAnalysis()
		puts "*************************************"
		puts "-------------------------------------"
		puts "####### START TRAVIS ANALYSIS #######"
		puts "-------------------------------------"
		puts "*************************************"
	end

	def printProjectInformation (index, project)
		puts "Project [#{index}]: #{project}"
	end

	def printFinishAnalysis()
		puts "*************************************"
		puts "-------------------------------------"
		puts "####### FINISH TRAVIS ANALYSIS #######"
		puts "-------------------------------------"
		puts "*************************************"
	end

	def runAnalysis()
		printStartAnalysis()
		index = 1
		
		@projectsList.each do |project|
			printProjectInformation(index, project)
			mainGitProject = GitProject.new(project, getLocalCLone(), getLoginUser(), getPasswordUser())
			if(mainGitProject.getProjectAvailable())
				projectName = mainGitProject.getProjectName()
				buildTravis = BuildTravis.new(projectName, mainGitProject)
				#mainProjectAnalysisBuilt = buildTravis.runAllAnalysis(projectName, getWriteCSVForkBuilt(), getWriteCSVAllErroredBuilds(),getPathGumTree(), true)
				mainProjectAnalysisBuilt = buildTravis.runAllAnalysisBuilt(projectName, getWriteCSVAllErroredBuilds(), getWriteCSVForkBuilt(), getWriteCSVForkAll(), getWriteCSVForkInterval(), getPathGumTree(), true)
				#mainProjectAnalysisAll = buildTravis.runAllAnalysisAll(projectName, getWriteCSVForkAll(), getPathGumTree(), true)
				#mainProjectAnalysisInterval = buildTravis.runAllAnalysisInterval(projectName, getWriteCSVForkInterval(), getPathGumTree(), true)
				mainGitProject.deleteProject()

				if (mainProjectAnalysisBuilt != nil)
					getWriteCSVForkBuilt().writeResultsAll(mainProjectAnalysisBuilt)
				end

				#if (mainProjectAnalysisAll != nil)
				#	getWriteCSVForkAll().writeResultsAll(mainProjectAnalysisAll)
				#end

				#if (mainProjectAnalysisInterval != nil)
				#	getWriteCSVForkInterval().writeResultsAll(mainProjectAnalysisInterval)
				#end
			end
			index += 1
		end
		printFinishAnalysis()
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

projectsList = []
File.open("projectsList", "r") do |text|
	indexLine = 0
	text.each_line do |line|
		projectsList[indexLine] = line[/\"(.*?)\"/, 1]
		indexLine += 1
	end
end

actualPath = Dir.pwd
project = MainAnalysisProjects.new(parameters[0], parameters[1], parameters[2], projectsList)
project.runAnalysis()

Dir.chdir actualPath
Dir.chdir "R"
%x(Rscript r-analysis.r)