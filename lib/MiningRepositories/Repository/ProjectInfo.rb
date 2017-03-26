require 'require_all'
require_rel 'GitProject'

class ProjectInfo

	def initialize(pathAnalysis)
		@pathAnalysis = pathAnalysis
		@pathProjects = Array.new
		findPathProjects() 
	end

	def getPathAnalysis()
		@pathAnalysis
	end

	def getPathProjects()
		@pathProjects
	end

	def getProjectNames()
		@projectNames
	end

	def findPathProjects()
		Find.find(@pathAnalysis) do |path|
	  		@pathProjects << path if path =~ /.*\.travis.yml$/
		end
		@pathProjects.sort_by!{ |e| e.downcase }

	end

end