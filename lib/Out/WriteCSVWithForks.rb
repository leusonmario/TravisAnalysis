require 'fileutils'
require 'csv'
require 'require_all'
require_rel 'WriteCSVs'

class WriteCSVWithForks < WriteCSVs
	
	def createCSV()
		super()
		createTravisAnalysisFile()
 	end

	def writeTravisAnalysis(projectName, numberForks, numberForksWithTravis, numberForksWithTravisActive)
		Dir.chdir getPathAllResults
		CSV.open("RepositoryTravisAnalysis.csv", "a+") do |csv|
 			csv << [projectName, numberForks, numberForksWithTravis, numberForksWithTravisActive]
		end
	end

 	def createTravisAnalysisFile()
 		Dir.chdir getPathAllResults
 		CSV.open("RepositoryTravisAnalysis.csv", "wb") do |csv|
			csv << ["Project", "NumberForks", "NumberForksWithTravis", "NumberForksWithTravisActive"]
		end
 	end

end