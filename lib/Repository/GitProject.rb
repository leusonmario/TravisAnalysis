#!/usr/bin/env ruby
#file: gitProject.rb

require 'octokit'

class GitProject

	def initialize(project, localClone, login, password)
		@projectAvailable = isProjectAvailable(project, login, password)
		if(getProjectAvailable())
			@projetcName = project
			@localClone = localClone
			@path = cloneProjectLocally(project, localClone)
			@mergeScenarios = Array.new
			getMergesScenariosByProject()
			@forksList = []
		end
	end

	def getPath()
		@path
	end

	def getProjectAvailable()
		@projectAvailable
	end

	def getLocalClone()
		@localClone
	end

	def getLocalName()
		@localName
	end

	def getProjectName()
		@projetcName
	end

	def getMergeScenarios()
		@mergeScenarios
	end

	def getForksList()
		@forksList
	end

	def cloneProjectLocally(project, localClone)
		Dir.chdir localClone
		@localName = project.gsub('/','')
		clone = %x(git clone https://github.com/#{project} #{getLocalName()})
		Dir.chdir getLocalName()
		return Dir.pwd
	end

	def deleteProject()
		Dir.chdir getLocalClone()
		delete = %x(rm -rf #{getLocalName()})
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
		Dir.chdir getPath().gsub('.travis.yml','')
		@mergeScenarios = Array.new
		commitTravisInput = %x(git log --format=%aD .travis.yml | tail -1)
		merges = %x(git log --pretty=format:'%H' --merges --since="#{commitTravisInput}")
		merges.each_line do |mergeScenario|
			@mergeScenarios.push(mergeScenario.gsub('\\n',''))
		end
	end

	def getNumberMergeScenarios()
		getMergesScenariosByProject()
		return @mergeScenarios.length
	end

	def getForksList()
		Dir.chdir @path
		Octokit.auto_paginate = true

		client = Octokit::Client.new \
	  		:login    => 'leusonmario',
	  		:password => '<password>'
		
		forksProject = client.forks(project)
		forksProject.each do |fork|
			begin  
				puts fork.html_url
				buildProjeto = Travis::Repository.find(fork.html_url.gsub('https://github.com/','')) 
				newName = fork.html_url.partition('github.com/').last.gsub('/','-')
				clone = %x(git clone #{fork.html_url} #{newName})
				puts clone
				rescue Exception => e  
				 	puts "NO TRAVIS PROJECT"
			end
		end
	end

	def isProjectAvailable(projectName, login, password)
		Octokit.auto_paginate = true
		client = Octokit::Client.new \
	  		:login    => login,
	  		:password => password
		begin
			contentsProject = client.contents(projectName)
			return true
		rescue Exception => e  
			puts "PROJECT NOT FOUND"
		end
		return false
	end
	
	def getNumberForks()
		getForksList()
		return @forksList.length
	end

	def updateProject()
		Dir.chdir @path
		update = %x(git pull origin)
	end

	def conflictScenario(parentsMerge, projectBuilds, build)		
		parentOne = false
		parentTwo = false
		
		projectBuilds.each_build do |mergeBuild|
			if(parentsMerge[0].include?(mergeBuild.commit.sha) and mergeBuild.state=='passed')
				parentOne = true
			elsif (parentsMerge[1].include?(mergeBuild.commit.sha) and mergeBuild.state=='passed')
				parentTwo = true
			end

			if (parentOne and parentTwo)
				return true
			end
		end	
		
		return false
	end

end