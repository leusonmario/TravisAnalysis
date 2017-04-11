require 'require_all'
require_rel '../MiningRepositories/Repository/CloneProjectGit'

class BadlyMergeScenarioExtractor 

	def initialize(projectName, pathLocalProject, localClone)
		@pathMainProject = pathLocalProject
		@actualPath = localClone
		@cloneProject = CloneProjectGit.new(localClone, projectName, "mergeScenarioClone")
	end

	def getActualPath()
		@actualPath
	end

	def getPathMainProject()
		@pathMainProject
	end

	def verifyBadlyMergeScenario(leftParent, rightParent, mergeCommit)
		result = simulateMergeScenario(leftParent, rightParent, mergeCommit)
		@cloneProject.deleteProject()
		if (result == "")
			return true
		else
			return false
		end
	end

	def simulateMergeScenario(leftParent, rightParent, mergeCommit)
		Dir.chdir @cloneProject.getLocalClone()
		mainBranch =  %x(git remote show origin).match(/HEAD branch: [\s\S]*  Remote branches/).to_s.match(/HEAD branch: [\s\S]*(\n)/).to_s.gsub("HEAD branch: ","").gsub("\n","")
		%x(git pull)
		%x(git reset --hard #{leftParent})
		%x(git clean -f)
		%x(git checkout -b rightParent #{rightParent})
		%x(git checkout #{mainBranch})
		%x(git merge rightParent -m #{leftParent})
		%x(git checkout -b mergeCommit #{mergeCommit})
		diff = %x(git diff #{mainBranch})
		%x(git checkout #{mainBranch})
		%x(git branch -D rightParent)
		%x(git branch -D mergeCommit)
		%x(git pull)
		return diff
	end

end