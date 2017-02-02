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
		FileUtils::mkdir_p 'FinalResults/ProjectWithoutForks/BuiltMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/ProjectWithoutForks/AllMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/ProjectWithoutForks/IntervalMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/ProjectWithForks/BuiltMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/ProjectWithForks/AllMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/ProjectWithForks/IntervalMergeScenarios'
		Dir.chdir "FinalResults/ProjectWithForks/BuiltMergeScenarios"
		@writeCSVWithForksBuiltMerge = WriteCSVWithForks.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/ProjectWithForks/AllMergeScenarios"
		@writeCSVWithForksAllMerge = WriteCSVWithForks.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/ProjectWithForks/IntervalMergeScenarios"
		@writeCSVWithForksIntervalMerge = WriteCSVWithForks.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/ProjectWithoutForks/BuiltMergeScenarios"
		@writeCSVWithoutForksBuiltMerge = WriteCSVs.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/ProjectWithoutForks/AllMergeScenarios"
		@writeCSVWithoutForksAllMerge = WriteCSVs.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/ProjectWithoutForks/IntervalMergeScenarios"
		@writeCSVWithoutForksIntervalMerge = WriteCSVs.new(Dir.pwd)
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

	def getWriteCSVWithoutForksBuilt()
		@writeCSVWithoutForksBuiltMerge
	end

	def getWriteCSVForkAll()
		@writeCSVWithForksAllMerge
	end

	def getWriteCSVWithoutForksAll()
		@writeCSVWithoutForksAllMerge
	end

	def getWriteCSVForkInterval()
		@writeCSVWithForksIntervalMerge
	end

	def getWriteCSVWithoutForksInterval()
		@writeCSVWithoutForksIntervalMerge
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
				mainProjectAnalysisBuilt = buildTravis.runAllAnalysisBuilt(projectName, getWriteCSVForkBuilt(), getPathGumTree(), true)
				mainProjectAnalysisAll = buildTravis.runAllAnalysisAll(projectName, getWriteCSVForkAll(), getPathGumTree(), true)
				mainProjectAnalysisInterval = buildTravis.runAllAnalysisInterval(projectName, getWriteCSVForkInterval(), getPathGumTree(), true)
				mainGitProject.deleteProject()

				projectWithoutForks = []
				projectWithoutForks.push(project)
				projectWithoutForks += mainGitProject.getForksListNames()
				
				otherIndex = 0
				numberForksWithTravisActive = -1
				projectWithoutForks.each do |projectWithoutFork|
					printProjectInformation(otherIndex, projectWithoutFork)
					gitProject = GitProject.new(projectWithoutFork, getLocalCLone(), getLoginUser(), getPasswordUser())
					if(gitProject.getProjectAvailable())
						getWriteCSVWithoutForksBuilt().createDirectoryByProject(project.split('/').last)
						getWriteCSVWithoutForksAll().createDirectoryByProject(project.split('/').last)
						getWriteCSVWithoutForksInterval().createDirectoryByProject(project.split('/').last)
						projectName = gitProject.getProjectName()
						buildTravis = BuildTravis.new(projectName, gitProject)
						projectAnalysisBuilt = buildTravis.runAllAnalysisBuilt(projectName, getWriteCSVWithoutForksBuilt(), getPathGumTree(), false)
						projectAnalysisAll = buildTravis.runAllAnalysisAll(projectName, getWriteCSVWithoutForksAll(), getPathGumTree(), false)
						projectAnalysisInterval = buildTravis.runAllAnalysisInterval(projectName, getWriteCSVWithoutForksInterval(), getPathGumTree(), false)
						if (projectAnalysisBuilt != nil)
							getWriteCSVWithoutForksBuilt().writeResultsAll(projectAnalysisBuilt)
						end
						if (projectAnalysisAll != nil)
							getWriteCSVWithoutForksAll().writeResultsAll(projectAnalysisAll)
						end
						gitProject.getDateFirstBuild()
						if (gitProject.isRepositoryAvailable())
							numberForksWithTravisActive += 1
						end
						gitProject.deleteProject()
					end
					otherIndex += 1
				end

				if (mainProjectAnalysisBuilt != nil)
					getWriteCSVForkBuilt().writeResultsAll(mainProjectAnalysisBuilt)
					getWriteCSVForkBuilt().writeTravisAnalysis(mainGitProject.getProjectName(), mainGitProject.getNumberProjectForks(), mainGitProject.getForksListNames().size, numberForksWithTravisActive)
				end

				if (mainProjectAnalysisAll != nil)
					getWriteCSVForkAll().writeResultsAll(mainProjectAnalysisAll)
					getWriteCSVForkAll().writeTravisAnalysis(mainGitProject.getProjectName(), mainGitProject.getNumberProjectForks(), mainGitProject.getForksListNames().size, numberForksWithTravisActive)
				end

				if (mainProjectAnalysisInterval != nil)
					getWriteCSVForkInterval().writeResultsAll(mainProjectAnalysisInterval)
					getWriteCSVForkInterval().writeTravisAnalysis(mainGitProject.getProjectName(), mainGitProject.getNumberProjectForks(), mainGitProject.getForksListNames().size, numberForksWithTravisActive)
				end
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