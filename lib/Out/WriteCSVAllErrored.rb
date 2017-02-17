require 'fileutils'
require 'csv'
require 'require_all'
require_all './Travis'

class WriteCSVAllErrored

	def initialize(actualPath)
		@pathErroredCauses = ""
		@pathErroredCases = ""
		@pathFailedCases = ""
		creatingResultsDirectories(actualPath)
	end

	def getPathErroredCases()
		@pathErroredCases
	end

	def getPathFailedCases()
		@pathFailedCases
	end

	def getPathErroredCauses()
		@pathErroredCauses
	end
	
	def creatingResultsDirectories(actualPath)
		Dir.chdir actualPath
		FileUtils::mkdir_p 'ErroredCauses'
		FileUtils::mkdir_p 'ErroredCases'
		FileUtils::mkdir_p 'FailedCases'
		
		Dir.chdir "ErroredCauses"
		@pathErroredCauses = Dir.pwd
		Dir.chdir actualPath
		Dir.chdir "ErroredCases"
		@pathErroredCases = Dir.pwd
		Dir.chdir actualPath
		Dir.chdir "FailedCases"
		@pathFailedCases = Dir.pwd
		createCSV()
	end

	def createCSV()
		createErroredCausesFile()
 	end

 	def createErroredCausesFile()
 		Dir.chdir getPathErroredCauses
		CSV.open("BuildConflictsCauses.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "NO FOUND SYMBOL", "MALFORMED EXPRESSION", "METHOD UPDATE", "DUPLICATE STATEMENT", "DEPENDENCY", "UNIMPLEMENTED METHOD", 
					"GIT PROBLEM", "REMOTE ERROR", "COMPILER ERROR", "ANOTHER ERROR"]
		end

 		CSV.open("TestConflictsCauses.csv", "wb") do |csv|
			csv << ["ProjectName",	"Total", "FAILED", "GIT PROBLEM", "REMOTE ERROR", "ANOTHER ERROR"]
		end
 	end

 	def printErroredBuild(projectName, build, cause)
		Dir.chdir getPathErroredCases()
		if (File.exists?("Errored"+projectName+".csv"))
			CSV.open("Errored"+projectName+".csv", "a+") do |csv|
				csv << [build.id, cause]
			end
		else
			CSV.open("Errored"+projectName+".csv", "w") do |csv|
				csv << ["BuildID", "Message"]
				csv << [build.id, cause]
			end			
		end
	end

	def printFailedBuild(projectName, build, cause)
		Dir.chdir getPathFailedCases()
		if (File.exists?("Failed"+projectName+".csv"))
			CSV.open("Failed"+projectName+".csv", "a+") do |csv|
				csv << [build.id, cause]
			end
		else
			CSV.open("Failed"+projectName+".csv", "w") do |csv|
				csv << ["BuildID", "Message"]
				csv << [build.id, cause]
			end			
		end
	end
end