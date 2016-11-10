#!/usr/bin/env ruby

require 'fileutils'
require 'find'
require 'csv'
require './Repository/GitProject.rb'
require './Repository/ProjectInfo.rb'
require './Travis/BuildTravis.rb'
require './Out/WriteCSVs.rb'

class MainAnalysisProjects

	def initialize(pathAnalysis, loginUser, passwordUser, pathGumTree)
		@pathAnalysis = pathAnalysis
		@loginUser = loginUser
		@passwordUser = passwordUser
		@pathGumTree = pathGumTree
		@writeCSVs = WriteCSVs.new(Dir.pwd)
		@projectsInfo = ProjectInfo.new(pathAnalysis)
	end

	def getPathAnalysis()
		@pathAnalysis
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

	def getProjectsInfo()
		@projectsInfo
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
		
		@projectsInfo.getPathProjects().each do |pathProject|
			gitProject = GitProject.new(pathProject)
			projectName = gitProject.getProjectName()
			printProjectInformation(index, projectName)
			buildTravis = BuildTravis.new(projectName, pathProject)
			projectAnalysis = buildTravis.getStatusBuildsProject(projectName, getWriteCSVs(), getPathGumTree())
			getWriteCSVs().writeResultsAll(projectAnalysis)
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

actualPath = Dir.pwd
project = MainAnalysisProjects.new(parameters[0], parameters[1], parameters[2], parameters[3])
project.runAnalysis()

Dir.chdir actualPath
Dir.chdir "R"
%x(Rscript r-analysis.r)