#!/usr/bin/env ruby

require 'travis'
require './Repository/MergeCommit.rb'
require './Travis/ConflictCategoryErrored.rb'
require './Travis/ConflictCategoryFailed.rb'
require './Data/ConflictAnalysis.rb'
require_relative 'ConflictBuild.rb'

class MergeScenariosAnalysis
	def initialize(projectName, gitProject)
		@projectName = projectName
		@pathProject = gitProject.getPath()
		@gitProject = gitProject
		@projectMergeScenarios = @gitProject.getMergeScenarios()
		@repositoryTravisProject = nil
	end

	def getProjectName()
		@projectName
	end

	def getPathProject()
		@pathProject
	end

	def getMergeScenarios()
		@projectMergeScenarios
	end

	def getGitProject()
		@gitProject
	end

	def getRepositoryTravisProject()
		@repositoryTravisProject
	end

	def mergeScenariosAnalysis(build)
		mergeCommit = MergeCommit.new()
		resultMergeCommit = mergeCommit.getParentsMergeIfTrue(@pathProject, build.commit.sha)
		return resultMergeCommit
	end

	def loadAllBuilds(projectBuild, confBuild, withWithoutForks)
		allBuilds = Hash.new()
		loadAllBuildsProject(projectBuild, confBuild, allBuilds)
		
		if (withWithoutForks)
			getGitProject().getForksList().each do |newFork|
				loadAllBuildsProject(newFork, confBuild, allBuilds)
			end
		end
		return allBuilds
	end

	def loadAllBuildsProject(projectBuild, confBuild, allBuilds)
		projectBuild.each_build do |build|
			if (!build.pull_request)
				if(allBuilds[build.commit.sha] == nil)
					allBuilds[build.commit.sha] = [[confBuild.getBuildStatus(build)], [build.id]]
				elsif (allBuilds[build.commit.sha][0] != [confBuild.getBuildStatus(build)])
					if (allBuilds[build.commit.sha][0] == ["canceled"] or confBuild.getBuildStatus(build) == "canceled")
						allBuilds.delete(build.commit.sha)
						allBuilds[build.commit.sha] = [["canceled"], [build.id]]
					elsif (allBuilds[build.commit.sha][0] == ["passed"])
						allBuilds.delete(build.commit.sha)
						allBuilds[build.commit.sha] = [[confBuild.getBuildStatus(build)], [build.id]]
					elsif (allBuilds[build.commit.sha][0] == ["errored"] or confBuild.getBuildStatus(build) == "errored")
						allBuilds.delete(build.commit.sha)
						allBuilds[build.commit.sha] = [["errored"], [build.id]]
					else 
						allBuilds.delete(build.commit.sha)
						allBuilds[build.commit.sha] == [["failed"], [build.id]]
					end
				end
			end
		end
	end
end