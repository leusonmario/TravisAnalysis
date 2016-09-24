#!/usr/bin/env ruby

require 'travis'
require 'csv'
require 'fileutils'
require 'find'
require './Repository/GitProject.rb'
require './Travis/BuildTravis.rb'

class MainAnalysisProjects

	def initialize(pathAnalysis)
		@pathAnalysis = pathAnalysis
		@pathProjects = Array.new 
		getPathProjects()
		result = creatingResultsDirectories()
		@projectNames = Array.new 
		findProjectNames()
		@pathAllResults = result[0]
		@pathResultByProject = result[1]
	end

	def getPathAnalysis()
		@pathAnalysis
	end

	def getPathProjects()
		@pathProjects
	end

	def getPathAllResults()
		@pathAllResults
	end

	def getPathResultByProject()
		@pathResultByProject
	end

	def getProjectNames()
		@projectNames
	end

	def findProjectNames()
		@pathProjects.each do |path|
			gitProject = GitProject.new(path)
			@projectNames.push(gitProject.getProjectName)
		end
		@projectNames.sort_by!{ |e| e.downcase }

	end

	def getPathProjects()
		Find.find(@pathAnalysis) do |path|
	  		@pathProjects << path if path =~ /.*\.travis.yml$/
		end
		@pathProjects.sort_by!{ |e| e.downcase }
	end

	def creatingResultsDirectories()
		FileUtils::mkdir_p 'ResultsAll/ResultsByProject'
		Dir.chdir "ResultsAll"
		pathAll = Dir.pwd
		Dir.chdir "ResultsByProject"
		pathResultBy = Dir.pwd
		return pathAll, pathResultBy
	end

	def runAnalysis()
		Dir.chdir getPathAllResults
		CSV.open("resultsAllFinalTest.csv", "wb") do |csv|
			csv << ["Project", "TotalBuildPush", "TotalPushPassed", "TotalPushErrored", "TotalPushFailed", "TotalPushCanceled", 
				"TotalBuildPull", "TotalPullPassed", "TotalPullErrored", "TotalPullFailed", "TotalPullCanceled"]
		end
		
		@projectNames.each do |projectName|
			buildTravis = BuildTravis.new()
			projectAnalysis = buildTravis.getStatusBuildsProject(projectName, @pathResultByProject)
			Dir.chdir getPathAllResults
			CSV.open("resultsAllFinalTest.csv", "a+") do |csv|
				csv << [projectAnalysis[0], projectAnalysis[1], projectAnalysis[2], projectAnalysis[3], projectAnalysis[4], projectAnalysis[5], 
				projectAnalysis[6], projectAnalysis[7], projectAnalysis[8], projectAnalysis[9], projectAnalysis[10]]
			end
		end
	end

end

project = MainAnalysisProjects.new("/home/leuson/TesteFork")
project.runAnalysis()