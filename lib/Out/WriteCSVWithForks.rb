require 'fileutils'
require 'csv'
require 'require_all'
require_rel 'WriteCSVs'

class WriteCSVWithForks < WriteCSVs
	
	def initialize(actualPath)
		@pathAllResults = ""
		@pathResultsByProject = ""
		@pathMergeScenariosAnalysis = ""
		super(actualPath)
	end

	def getPathMergeScenariosAnalysis()
		@pathMergeScenariosAnalysis
	end

	def getPathAllResults()
		@pathAllResults
	end

	def getPathResultByProject ()
		@pathResultsByProject
	end

	def creatingResultsDirectories(actualPath)
		Dir.chdir actualPath
		FileUtils::mkdir_p 'ResultsByProject'
		FileUtils::mkdir_p 'MergeScenariosAnalysis'
		Dir.chdir actualPath
		Dir.chdir "ResultsByProject"
		@pathResultsByProject = Dir.pwd
		Dir.chdir actualPath
		Dir.chdir "MergeScenariosAnalysis"
		@pathMergeScenariosAnalysis = Dir.pwd
		Dir.chdir actualPath
		@pathAllResults = Dir.pwd
		super(actualPath)
		createCSV()
	end

	def createCSV()
		createAllResultsFile()
		createMergeScenariosAnalysisFile()
		super()
 	end

 	def createAllResultsFile()
 		Dir.chdir getPathAllResults
		CSV.open("AllProjectsResult.csv", "wb") do |csv|
			csv << ["Project", "TotalBuildPush", "TotalPushPassed", "TotalPushErrored", "TotalPushFailed", "TotalPushCanceled", 
				"TotalBuildPull", "TotalPullPassed", "TotalPullErrored", "TotalPullFailed", "TotalPullCanceled"]
		end
 	end

 	def createMergeScenariosAnalysisFile
 		Dir.chdir getPathMergeScenariosAnalysis()
		CSV.open("MergeScenariosProjects.csv", "wb") do |csv|
			csv << ["Project", "TotalMS", "TotalMSNoBuilt","TotalMSParentPassed", "TotalMSParentsNoPassed", "TotalParentNoBuilt", "TotalRepeatedMSB", "AllBuilds", "ValidBuilds", "TotalMSPassed", "TotalMSErrored", "TotalMSFailed", "TotalMSCanceled"]
		end
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

 	def writeMergeScenariosFinal(projectName, allMergeScenariosProject, noBuiltMergeScenario, builtPassedParentMergeScenarios, noBuiltPassedParentMergeScenarios, noParentBuilt, totalRepeatedBuilds, totalBuilds, validBuilds, totalMSPassed, totalMSErrored, 
								totalMSFailed, totalMSCanceled)
		Dir.chdir getPathMergeScenariosAnalysis()
		CSV.open("MergeScenariosProjects.csv", "a+") do |csv|
			csv << [projectName, allMergeScenariosProject, noBuiltMergeScenario, builtPassedParentMergeScenarios, noBuiltPassedParentMergeScenarios, noParentBuilt, totalRepeatedBuilds, totalBuilds, validBuilds, totalMSPassed, totalMSErrored, totalMSFailed, 
					totalMSCanceled]
		end
	end

	def writeResultsAll(projectInfo)
 		Dir.chdir getPathAllResults
	 	CSV.open("AllProjectsResult.csv", "a+") do |csv|
 			csv << [projectInfo[0], projectInfo[1], projectInfo[2], projectInfo[3], projectInfo[4], projectInfo[5], projectInfo[6], projectInfo[7], projectInfo[8], 
			projectInfo[9], projectInfo[10]]
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