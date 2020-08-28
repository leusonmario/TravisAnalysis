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

  def checkPomFile()
		actualPath = Dir.pwd
		Dir.chdir @localClone
		checkPom = %x(find -name 'pom.xml')
		checkPom += %x(find -name 'pom.xml.in')
		sleep 3
		checkGradle = %x(find -name 'build.gradle')
		Dir.chdir actualPath
		if (checkPom != "" and checkGradle == "")
			return true
		else
			return false
		end
	end

end