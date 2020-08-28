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

		if (result)
			return true
		else
			return false
		end
	end

	def simulateMergeScenario(leftParent, rightParent, mergeCommit)
		Dir.chdir @cloneProject.getLocalClone()

		mainBranch =  %x(git remote show origin).match(/HEAD branch: [\s\S]*  Remote branch(es)?/).to_s.match(/HEAD branch: [\s\S]*(\n)/).to_s.gsub("HEAD branch: ","").gsub("\n","")
		%x(git checkout #{mainBranch})
		%x(git checkout -b mergeCommit #{mergeCommit})
		%x(git checkout #{mainBranch})
		%x(git reset --hard #{leftParent})
		%x(git clean -f)
		%x(git checkout -b new #{rightParent})
		%x(git checkout #{mainBranch})
		%x(git merge new)

		logReply = %x(git diff)
		logReplyMerge = %x(git diff mergeCommit)

		%x(git branch -D new)
		%x(git branch -D mergeCommit)
		%x(git checkout #{mainBranch})

		modificationsAfterMerge = false

		if (logReply != logReplyMerge) # conflict
			modificationsAfterMerge = true
		end
		return modificationsAfterMerge
	end

end