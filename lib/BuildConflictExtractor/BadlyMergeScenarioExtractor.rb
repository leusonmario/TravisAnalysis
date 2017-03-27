class BadlyMergeScenarioExtractor 

	def initialize(projectName, pathLocalProject, localClone)
		@projectName = projectName
		@actualPath = localClone
		@pathMergeScenario = cloneProjectLocally(localClone)
		@pathLocalProject = pathLocalProject
	end

	def getProjectName()
		@projectName
	end

	def getActualPath()
		@actualPath
	end

	def getPathMergeScenario()
		@pathMergeScenario
	end

	def getPathLocalProject()
		@pathLocalProject
	end

	def cloneProjectLocally(localClone)
		Dir.chdir localClone
		clone = %x(git clone https://github.com/#{getProjectName} mergeScenarioClone)
		Dir.chdir "mergeScenarioClone"
		return Dir.pwd
	end

	def simulateMergeScenario(leftParent, rightParent)
		Dir.chdir getPathMergeScenario
		%x(git reset --hard #{leftParent})
		%x(git clean -f)
		%x(git checkout -b otherParent #{rightParent})
		%x(git merge otherParent)
	end

	def deleteMergeScenarioProject()
		Dir.chdir getActualPath()
		%x(rm -rf mergeScenarioClone)
	end

	def verifyBadlyMergeScenario(leftParent, rightParent)
		simulateMergeScenario(leftParent, rightParent)
		result = %x(diff --brief -r #{getPathMergeScenario} #{getPathLocalProject})
		deleteMergeScenarioProject()
		if (result == nil)
			return true
		else
			return false
		end
	end
end

#HEAD branch: [\s\S]*\\n
#aux = %x(git remote show origin).match(/HEAD branch: [\s\S]*  Remote branches/).gsub(': ', '')

#remoteOrigin = %x(git remote show origin)
#aux = remoteOringin.match(/HEAD branch: [\s\S]*\\n  Remote branches/)
#branch = aux.gsub(': ', '')
#%x(git checkout -f #{branch})