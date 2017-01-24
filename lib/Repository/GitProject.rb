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
			@forksListNames = []
			@login = login
			@password = password
			@firstBuild = nil
			@numberProjectForks = 0
		end
	end

	def getFirstBuild()
		@firstBuild
	end

	def getLogin()
		@login
	end

	def getPassword()
		@password
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

	def getProjectName()
		@projetcName
	end

	def getMergeScenarios()
		@mergeScenarios
	end

	def getNumberProjectForks()
		@numberProjectForks
	end

	def isRepositoryAvailable()
		if (@projectAvailable==true and @firstBuild != nil)
			return true
		else
			return false
		end
	end

	def getForksListNames()
		@forksListNames
	end

	def cloneProjectLocally(project, localClone)
		Dir.chdir localClone
		clone = %x(git clone https://github.com/#{project} localProject)
		Dir.chdir "localProject"
		return Dir.pwd
	end

	def deleteProject()
		Dir.chdir getLocalClone()
		delete = %x(rm -rf localProject)
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
		Dir.chdir getPath()
		@mergeScenarios = Array.new
		#commitTravisInput = %x(git log --format=%aD .travis.yml | tail -1)
		commitTravisInput = getDateFirstBuild()
		if (commitTravisInput != nil)
			merges = %x(git log --pretty=format:'%H' --merges --since="#{commitTravisInput}")
			merges.each_line do |mergeScenario|
				@mergeScenarios.push(mergeScenario.gsub('\\n',''))
			end
		end
	end

	def getDateFirstBuild()
		begin
			@firstBuild = Travis::Repository.find(getProjectName()).build(1)
			return @firstBuild.started_at
		rescue
			puts "NO ACTIVE TRAVIS REPOSITORY"
			return nil
		end
	end

	def getNumberMergeScenarios()
		return @mergeScenarios.length
	end

	def getForksList()
		result = []
		Dir.chdir @path
		Octokit.auto_paginate = true

		client = Octokit::Client.new \
	  		:login    => getLogin(),
	  		:password => getPassword()
		
		forksProject = client.forks(getProjectName())
		forksProject.each do |fork|
			begin  
				#puts fork.html_url
				noTravisProject = 0
				buildProjeto = Travis::Repository.find(fork.html_url.gsub('https://github.com/','')) 
				newName = fork.html_url.partition('github.com/').last
				if (buildProjeto != nil)
					@forksListNames.push(newName)
				end
				#clone = %x(git clone #{fork.html_url} #{newName})
				result.push(buildProjeto)
				rescue Exception => e  
				 	noTravisProject += 1
			end
		end
		@numberProjectForks = forksProject.size
		return result
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

	def getRepositoryTravisByProject()
		projectBuild = nil
		begin
			projectBuild = Travis::Repository.find(getProjectName())
			return projectBuild
		rescue Exception => e  
			return nil
		end
	end
	
	def getNumberForks()
		return @forksList.length
	end

	def updateProject()
		Dir.chdir @path
		update = %x(git pull origin)
	end

	def conflictScenario(parentsMerge, projectBuilds, build)		
		parentOne = ""
		buildOne = ""
		parentTwo = ""
		buildTwo = ""
		
		if (projectBuilds[parentsMerge[0]] != nil and projectBuilds[parentsMerge[1]] != nil)
			if (projectBuilds[parentsMerge[0]][0]==["passed"])
					parentOne = true
					buildOne = projectBuilds[parentsMerge[0]][1]
			else
				return false, nil, nil
			end
			
			if (projectBuilds[parentsMerge[1]][0]==["passed"])
					parentTwo = true
					buildTwo = projectBuilds[parentsMerge[1]][1]
			else
				return false, nil, nil
			end
			
			if (parentOne==true and parentTwo==true)
				return true, buildOne, buildTwo
			end
		end
		return nil, nil, nil
	end
end