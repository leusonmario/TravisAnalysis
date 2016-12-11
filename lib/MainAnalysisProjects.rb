#!/usr/bin/env ruby

require 'fileutils'
require 'find'
require 'csv'
require './Repository/GitProject.rb'
require './Repository/ProjectInfo.rb'
require './Travis/BuildTravis.rb'
require './Out/WriteCSVs.rb'

class MainAnalysisProjects

	def initialize(loginUser, passwordUser, pathGumTree, projectsList)
		@loginUser = loginUser
		@passwordUser = passwordUser
		@pathGumTree = pathGumTree
		@localClone = Dir.pwd
		@writeCSVs = WriteCSVs.new(Dir.pwd)
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
		@writeCSVs
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
			gitProject = GitProject.new(project, getLocalCLone(), getLoginUser(), getPasswordUser())
			if(gitProject.getProjectAvailable())
				projectName = gitProject.getProjectName()
				buildTravis = BuildTravis.new(projectName, gitProject)
				projectAnalysis = buildTravis.getStatusBuildsProject(projectName, getWriteCSVs(), getPathGumTree())
				if (projectAnalysis != nil)
					getWriteCSVs().writeResultsAll(projectAnalysis)
				else
					gitProject.deleteProject()
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