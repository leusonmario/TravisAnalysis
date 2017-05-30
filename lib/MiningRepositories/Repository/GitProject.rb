require 'octokit'
require 'active_support/core_ext/numeric/time'
require 'date'
require_rel './CloneProjectGit'

class GitProject

	def initialize(project, localClone, login, password)
		@projectAvailable = isProjectAvailable(project, login, password)
		if(getProjectAvailable())
			@cloneProject = CloneProjectGit.new(localClone, project, "mainProjectClone")
			@projetcName = project
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

	def getCloneProject()
		@cloneProject
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
		Dir.chdir @cloneProject.getLocalClone()
		@mergeScenarios = Array.new
		commitTravisInput = getDateFirstBuild()
		if (commitTravisInput != nil)
			merges = %x(git log --pretty=format:'%H' --merges --since="#{commitTravisInput}")
			merges.each_line do |mergeScenario|
				@mergeScenarios.push(mergeScenario.gsub("\n",""))
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
		@forksListNames.clear
		result = []
		Dir.chdir @cloneProject.getLocalClone()
		Octokit.auto_paginate = true

		client = Octokit::Client.new \
	  		:login    => getLogin(),
	  		:password => getPassword()
		
		forksProject = client.forks(getProjectName())
		forksProject.each do |fork|
			begin  
				noTravisProject = 0
				buildProjeto = Travis::Repository.find(fork.html_url.gsub('https://github.com/','')) 
				newName = fork.html_url.partition('github.com/').last
				if (buildProjeto != nil)
					@forksListNames.push(newName)
				end
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

	def conflictScenario(parentsMerge, projectBuilds)		
		parentOne = nil
		buildOne = nil
		parentTwo = nil
		buildTwo = nil
		
		if (projectBuilds[parentsMerge[0]] != nil and projectBuilds[parentsMerge[1]] != nil)
			if (projectBuilds[parentsMerge[0]][0]==["passed"] or projectBuilds[parentsMerge[0]][0]==["failed"])
				parentOne = true
				buildOne = projectBuilds[parentsMerge[0]][1]
			else
				buildOne = projectBuilds[parentsMerge[0]][2]
			end
			
			if (projectBuilds[parentsMerge[1]][0]==["passed"] or projectBuilds[parentsMerge[1]][0]==["failed"])
				parentTwo = true
				buildTwo = projectBuilds[parentsMerge[1]][1]
			else
				buildTwo = projectBuilds[parentsMerge[1]][2]
			end
			
			if (parentOne==true and parentTwo==true)
				return true, buildOne, buildTwo
			end
		end
		return false, buildOne, buildTwo
	end

	def conflictScenarioFailed(parentsMerge, projectBuilds)
		parentOne = nil
		buildOne = nil
		parentTwo = nil
		buildTwo = nil

		if (projectBuilds[parentsMerge[0]] != nil and projectBuilds[parentsMerge[1]] != nil)
			if (projectBuilds[parentsMerge[0]][0]==["passed"])
				parentOne = true
				buildOne = projectBuilds[parentsMerge[0]][1]
			else
				buildOne = projectBuilds[parentsMerge[0]][2]
			end

			if (projectBuilds[parentsMerge[1]][0]==["passed"])
				parentTwo = true
				buildTwo = projectBuilds[parentsMerge[1]][1]
			else
				buildTwo = projectBuilds[parentsMerge[1]][2]
			end

			if (parentOne==true and parentTwo==true)
				return true, buildOne, buildTwo
			end
		end
		return false, buildOne, buildTwo
	end

	def conflictScenarioAll(parentsMerge, projectBuilds, projectBuildsFork)		
		parentOne = nil
		buildOne = nil
		parentTwo = nil
		buildTwo = nil
		
		begin
			if (projectBuilds[parentsMerge[0]] != nil)
				if (projectBuilds[parentsMerge[0]][0]==["passed"] or projectBuilds[parentsMerge[0]][0]==["failed"])
					parentOne = true
					buildOne = projectBuilds[parentsMerge[0]][1]
				end
			end
		rescue

		end

		begin
			if (projectBuildsFork[parentsMerge[0]] != nil)
				if (projectBuildsFork[parentsMerge[0]][0]== "passed" or projectBuildsFork[parentsMerge[0]][0]== "failed")
					parentOne = true
					buildOne = projectBuildsFork[parentsMerge[0]][2]
				end
			end
		rescue

		end
			
		begin
			if (projectBuilds[parentsMerge[1]] != nil)
				if ((projectBuilds[parentsMerge[1]][0]==["passed"] or projectBuilds[parentsMerge[1]][0]==["failed"]))
					parentTwo = true
					buildTwo = projectBuilds[parentsMerge[1]][1]
				end
			end
		rescue

		end

		begin
			if (projectBuildsFork[parentsMerge[1]] != nil)
				if (projectBuildsFork[parentsMerge[1]][0]== "passed" or projectBuildsFork[parentsMerge[1]][0]== "failed")
					parentTwo = true
					buildTwo = projectBuildsFork[parentsMerge[1]][2]
				end
			end
		rescue

		end
		
		if (parentOne==true and parentTwo==true)
			return true, buildOne, buildTwo
		end

		return false, buildOne, buildTwo
	end

	def getCommitCloserToBuild(allbuilds, commit)
		Dir.chdir @cloneProject.getLocalClone()
		begin
			aux = %x(git checkout #{commit})
			#antes estava %ci
			date = %x(git show -s --format=%cd #{commit})
			dateUntil = DateTime.parse(date)
			dateSince = dateUntil - 15.days
			log = %x(git log --pretty=format:'%H' --since=#{dateSince.strftime} --until=#{dateUntil.strftime})
			log.each_line do |item|
				if (allbuilds[item.gsub("\n", "")] != nil)
					return item.gsub("\n", "")
				end
			end
		rescue
			return nil
		end
	end
end