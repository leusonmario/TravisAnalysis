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

	def getCloneProject()
		@cloneProject
	end

	def getPathMainProject()
		@pathMainProject
	end

	def verifyBadlyMergeScenario(leftParent, rightParent, mergeCommit)
		result = simulateMergeScenario(leftParent, rightParent, mergeCommit)
		if (result == "")
			return true
		else
			return false
		end
	end

	def simulateMergeScenario(leftParent, rightParent, mergeCommit)
		Dir.chdir @cloneProject.getLocalClone()
		mainBranch =  %x(git remote show origin).match(/HEAD branch: [\s\S]*  Remote branches/).to_s.match(/HEAD branch: [\s\S]*(\n)/).to_s.gsub("HEAD branch: ","").gsub("\n","")
		%x(git checkout #{mainBranch})
		%x(git clean -f)
		%x(git checkout -b leftParent #{leftParent})
		%x(git reset --hard origin)
		%x(git checkout #{mainBranch})
		%x(git checkout -b rightParent #{rightParent})
		merge = %x(git merge leftParent --no-edit)
		%x(git reset --hard origin)
		%x(git checkout -f #{mainBranch})
		%x(git checkout -b mergeCommit #{mergeCommit})
		diff = %x(git diff rightParent)
		%x(git reset --merge)
		%x(git reset --hard origin)
		%x(git checkout -f #{mainBranch})
		%x(git branch -D rightParent)
		%x(git branch -D leftParent)
		%x(git branch -D mergeCommit)
		return diff
	end

end