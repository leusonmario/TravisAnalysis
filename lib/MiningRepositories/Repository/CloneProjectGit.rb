class CloneProjectGit

	def initialize(localClone, projectName, nameFolder)
		@mainLocalClonePath = localClone
		@nameFolder = nameFolder
		@localClone = cloneProjectLocally(projectName, nameFolder)
	end

	def getMainLocalClonePath()
		@mainLocalClonePath
	end

	def getLocalClone()
		@localClone
	end

	def cloneProjectLocally(projectName, nameFolder)
		Dir.chdir @mainLocalClonePath
		clone = %x(git clone https://github.com/#{projectName} #{nameFolder})
		Dir.chdir nameFolder
		return Dir.pwd
	end

	def deleteProject()
		Dir.chdir @mainLocalClonePath
		%x(rm -rf #{@nameFolder})
	end

end