require 'require_all'
require 'travis'
require_rel '../ConflictCategoryErrored'
require_rel '../ConflictCategoryFailed'
require_rel '../ConflictBuild'
require_all '././MiningRepositories/Repository'
require_all '././MiningRepositories/Data'
require_all '././BuildConflictExtractor/BCTypes'

class MergeScenariosAnalysis
	def initialize(projectName, gitProject, localClone)
		@projectName = projectName
		@pathProject = gitProject.getCloneProject().getLocalClone()
		@gitProject = gitProject
		@projectMergeScenarios = @gitProject.getMergeScenarios()
		@repositoryTravisProject = nil
		@pathLocalClone = localClone
		@projectCommits = Hash.new
	end

	def getProjectName()
		@projectName
	end

	def getPathLocalClone()
		@pathLocalClone
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

	def mergeScenariosAnalysisCommit(sha)
		mergeCommit = MergeCommit.new()
		resultMergeCommit = mergeCommit.getParentsMergeIfTrue(@pathProject, sha)
		return resultMergeCommit
	end

	def loadAllBuilds(projectBuild, travisProjectClone, confBuild, withWithoutForks)
		allBuilds = Hash.new()
		loadAllBuildsProject(projectBuild, confBuild, allBuilds)
		loadAllBuildsProject(travisProjectClone, confBuild, allBuilds)
		
		if (withWithoutForks)
			getGitProject().getForksList().each do |newFork|
				loadAllBuildsProject(newFork, confBuild, allBuilds)
			end
		end
		return allBuilds
	end

	def loadAllBuildsProject(projectBuild, confBuild, allBuilds)
		if (projectBuild != nil)
			projectBuild.each_build do |build|
				if (!build.pull_request)
					if(allBuilds[build.commit.sha] == nil)
						allBuilds[build.commit.sha] = [[confBuild.getBuildStatus(build)], [build.id], [build.number]]
					elsif (allBuilds[build.commit.sha][0] != [confBuild.getBuildStatus(build)])
						if (allBuilds[build.commit.sha][0] == ["canceled"] or confBuild.getBuildStatus(build) == "canceled")
							allBuilds.delete(build.commit.sha)
							allBuilds[build.commit.sha] = [["canceled"], [build.id], [build.number]]
						elsif (allBuilds[build.commit.sha][0] == ["passed"])
							allBuilds.delete(build.commit.sha)
							allBuilds[build.commit.sha] = [[confBuild.getBuildStatus(build)], [build.id], [build.number]]
						elsif (allBuilds[build.commit.sha][0] == ["errored"] or confBuild.getBuildStatus(build) == "errored")
							allBuilds.delete(build.commit.sha)
							allBuilds[build.commit.sha] = [["errored"], [build.id], [build.number]]
						else
							allBuilds.delete(build.commit.sha)
							allBuilds[build.commit.sha] == [["failed"], [build.id], [build.number]]
						end
					end
				end
			end
		else
			print "NULO"
		end
	end

end