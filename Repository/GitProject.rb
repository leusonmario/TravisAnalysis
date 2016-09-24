#!/usr/bin/env ruby
#file: gitProject.rb

require 'travis'
require 'csv'
require 'rubygems'
require 'fileutils'
require 'find'
require 'octokit'
require 'github_api'
require 'json'
require 'find'
require 'fileutils'

class GitProject

	def initialize(pathProject)
		@path = pathProject
		@projetcName = findProjectName()
		@mergeScenarios = []
		@forksList = []
	end

	def getPath()
		@path
	end

	def getProjectName()
		@projectName
	end

	def getMergeScenarios()
		@mergeScenarios
	end

	def getForksList()
		@forksList
	end

	def findProjectName()
		Dir.chdir getPath().gsub('.travis.yml','')
		
		config = %x(git remote show origin)
		config.each_line do |conf|
			if (conf.start_with?('  Fetch'))
				indexOne = conf.index('github.com/')
				@projectName = conf[indexOne+11..conf.length-2]
			end
		end
	end

	def getMergesScenariosByProject()
		mergeScenarios = %x(git log --pretty=format:'%H' --merges)
		mergeScenarios.each_line do |mergeScenario|
			@mergeScenarios.push(mergeScenario.gsub('commit ',''))
		end
	end

	def getNumberMergeScenarios()
		getMergesScenariosByProject()
		return @mergeScenarios.length
	end

	def getForksList()
		Dir.chdir @path
		Octokit.auto_paginate = true
		client = Octokit::Client.new :access_token => ENV["05a950d0fdd651dc724c636ebf668fd18d1ef31b"]
		forksProject = client.forks(@projectName)
		forksProject.each do |fork|
			begin  
				raise buildProjeto = Travis::Repository.find(fork.html_url)
					newName = fork.html_url.partition('github.com/').last.gsub('/','')
					clone = %x(git clone #{fork.html_url} #{newName})
					puts clone
				rescue Exception => e  
				  	puts "NO TRAVIS PROJECT"
			end
		end
	end
	
	def getNumberForks()
		getForksList()
		return @forksList.length
	end

	def updateProject()
		Dir.chdir @path
		update = %x(git pull origin)
	end
end