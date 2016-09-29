#!/usr/bin/env ruby
#file: projectInfo.rb

require 'travis'
require 'csv'
require 'fileutils'
require 'find'
require_relative 'GitProject.rb'

class ProjectInfo

	def initialize(pathAnalysis)
		@pathAnalysis = pathAnalysis
		@pathProjects = Array.new
		getPathProjects() 
		@projectNames = Array.new
		findProjectNames()
	end

	def getPathAnalysis()
		@pathAnalysis
	end

	def getPathProjects()
		@pathProjects
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

end