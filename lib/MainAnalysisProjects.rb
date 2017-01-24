#!/usr/bin/env ruby

require 'fileutils'
require 'find'
require 'csv'
require './Repository/GitProject.rb'
require './Repository/ProjectInfo.rb'
require './Travis/BuildTravis.rb'
require './Out/WriteCSVs.rb'
require './Out/WriteCSVWithForks.rb'

class MainAnalysisProjects

	def initialize(loginUser, passwordUser, pathGumTree, projectsList)
		@loginUser = loginUser
		@passwordUser = passwordUser
		@pathGumTree = pathGumTree
		@localClone = Dir.pwd
		delete = %x(rm -rf FinalResults)
		FileUtils::mkdir_p 'FinalResults/ProjectWithoutForks'
		FileUtils::mkdir_p 'FinalResults/ProjectWithForks'
		Dir.chdir "FinalResults/ProjectWithForks"
		@writeCSVProjectWithForks = WriteCSVWithForks.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/ProjectWithoutForks"
		@writeCSVProjectWithoutForks = WriteCSVs.new(Dir.pwd)
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

	def getWriteCSVs()
		@writeCSVProjectWithForks
	end

	def getWriteCSVWithoutForks()
		@writeCSVProjectWithoutForks
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
				mainProjectAnalysis = buildTravis.runAllAnalysis(projectName, getWriteCSVs(), getPathGumTree(), true)
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
						projectName = gitProject.getProjectName()
						buildTravis = BuildTravis.new(projectName, gitProject)
						projectAnalysis = buildTravis.runAllAnalysis(projectName, getWriteCSVWithoutForks(), getPathGumTree(), false)
						if (projectAnalysis != nil)
							getWriteCSVWithoutForks().writeResultsAll(projectAnalysis)
						end
						gitProject.getDateFirstBuild()
						if (gitProject.isRepositoryAvailable())
							numberForksWithTravisActive += 1
						end
						gitProject.deleteProject()
					end
					otherIndex += 1
				end

				#passar o projectAnalysis do primeiro for
				if (mainProjectAnalysis != nil)
					getWriteCSVs().writeResultsAll(mainProjectAnalysis)
					getWriteCSVs().writeTravisAnalysis(mainGitProject.getProjectName(), mainGitProject.getNumberProjectForks(), mainGitProject.getForksListNames().size, numberForksWithTravisActive)
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