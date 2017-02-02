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

 	def writeResultByProject(projectName, typeBuild, build)
		Dir.chdir getPathResultByProject()
		if (File.exists?(projectName+"Final.csv"))
			CSV.open(projectName+"Final.csv", "a+") do |csv|
				csv << [build.state, typeBuild, build.commit.sha, build.id]
			end
		else
			CSV.open(projectName+"Final.csv", "w") do |csv|
	 			csv << ["Status", "Type", "Commit", "ID"]
	 			csv << [build.state, typeBuild, build.commit.sha, build.id]
	 		end			
		end
	end

end