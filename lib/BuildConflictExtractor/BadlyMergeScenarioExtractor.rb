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

	def verifyBadlyMergeScenario(leftParent, rightParent)
		simulateMergeScenario(leftParent, rightParent)
		result = %x(diff --brief -r #{@cloneProject.getLocalClone()} #{getPathMainProject()})
		@cloneProject.deleteMergeScenarioProject()
		if (result == nil)
			return true
		else
			return false
		end
	end

	def simulateMergeScenario(leftParent, rightParent)
		Dir.chdir @cloneProject.getLocalClone()
		%x(git reset --hard #{leftParent})
		%x(git clean -f)
		%x(git checkout -b otherParent #{rightParent})
		%x(git merge otherParent)
	end

end