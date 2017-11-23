require 'require_all'
require_all './MiningRepositories'
require_all './Out'
require_all './CausesExtractor'
require_all './R'

class MainAnalysisProjects

	def initialize(loginUser, passwordUser, travisToken, pathGumTree, projectsList)
		@loginUser = loginUser
		@passwordUser = passwordUser
		@pathGumTree = pathGumTree
		@token = travisToken
		@localClone = Dir.pwd
		delete = %x(rm -rf FinalResults)
		FileUtils::mkdir_p 'FinalResults/AllErroredBuilds'
		FileUtils::mkdir_p 'FinalResults/MergeScenarios/BuiltMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/MergeScenarios/AllMergeScenarios'
		FileUtils::mkdir_p 'FinalResults/MergeScenarios/IntervalMergeScenarios'
		Dir.chdir "FinalResults/MergeScenarios/BuiltMergeScenarios"
		@writeCSVWithForksBuiltMerge = WriteCSVWithForks.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/MergeScenarios/AllMergeScenarios"
		@writeCSVWithForksAllMerge = WriteCSVs.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/MergeScenarios/IntervalMergeScenarios"
		@writeCSVWithForksIntervalMerge = WriteCSVs.new(Dir.pwd)
		Dir.chdir getLocalCLone
		Dir.chdir "FinalResults/AllErroredBuilds"
		@writeCSVAllErroredBuilds = WriteCSVAllErrored.new(Dir.pwd)
		Dir.chdir getLocalCLone
		@projectsList = projectsList
	end

	def getTravisToken()
		@token
	end

	def getLocalCLone()
		@localClone
	end

	def getLoginUser()
		@loginUser
	end

	def getPasswordUser()
		@passwordUser
	end

	def getPathGumTree()
		@pathGumTree
	end

	def getWriteCSVForkBuilt()
		@writeCSVWithForksBuiltMerge
	end

	def getWriteCSVForkAll()
		@writeCSVWithForksAllMerge
	end

	def getWriteCSVForkInterval()
		@writeCSVWithForksIntervalMerge
	end

	def getWriteCSVAllErroredBuilds()
		@writeCSVAllErroredBuilds
	end

	def getProjectsList()
		@projectsList
	end

	def printStartAnalysis()
		puts "*************************************"
		puts "-------------------------------------"
		puts "####### START TRAVIS ANALYSIS #######"
		puts "-------------------------------------"
		puts "*************************************"
	end

	def printProjectInformation (index, project)
		puts "Project [#{index}]: #{project}"
	end

	def printFinishAnalysis()
		puts "*************************************"
		puts "-------------------------------------"
		puts "####### FINISH TRAVIS ANALYSIS #######"
		puts "-------------------------------------"
		puts "*************************************"
	end

	def runAnalysis()
		printStartAnalysis()
		index = 1
		
		@projectsList.each do |project|
			printProjectInformation(index, project)
			begin
			mainGitProject = GitProject.new(project, getLocalCLone(), getLoginUser(), getPasswordUser())
			cloneProject = BadlyMergeScenarioExtractor.new(project, "", getLocalCLone())
			extractorCLI = ExtractorCLI.new(getLoginUser(), getPasswordUser(), getTravisToken(), "travis", getLocalCLone(), project)
			rescue
				print "\nPROJECT NOT FOUND\n"
			end
			if(mainGitProject.getProjectAvailable() and mainGitProject.getCloneProject().checkPomFile)
				projectName = mainGitProject.getProjectName()
				buildTravis = BuildTravis.new(projectName, mainGitProject, getLocalCLone())
				mainProjectAnalysisBuilt = buildTravis.runAllAnalysisBuilt(projectName, getWriteCSVAllErroredBuilds(), getWriteCSVForkBuilt(), getWriteCSVForkAll(), getWriteCSVForkInterval(), getPathGumTree(), true, cloneProject, extractorCLI)
				mainGitProject.getCloneProject().deleteProject()
				cloneProject.getCloneProject().deleteProject()
				extractorCLI.deleteProject()

				if (mainProjectAnalysisBuilt != nil)
					getWriteCSVForkBuilt().writeResultsAll(mainProjectAnalysisBuilt)
				end
			else
				begin
					mainGitProject.getCloneProject().deleteProject()
					cloneProject.getCloneProject().deleteProject()
					extractorCLI.deleteProject()
					print "PROJECT DOES NOT HAVE POM AVAILABLE"
				rescue
					print "NOT POSSIBLE TO DELETE FILES \n"
				end
			end
			index += 1
		end
		printFinishAnalysis()
	end

end

parameters = []
File.open("properties", "r") do |text|
	indexLine = 0
	text.each_line do |line|
		parameters[indexLine] = line[/\<(.*?)\>/, 1]
		indexLine += 1
	end
end

projectsList = []
File.open("projectsList", "r") do |text|
	indexLine = 0
	text.each_line do |line|
		projectsList[indexLine] = line[/\"(.*?)\"/, 1]
		indexLine += 1
	end
end

actualPath = Dir.pwd
project = MainAnalysisProjects.new(parameters[0], parameters[1], parameters[2], parameters[3], projectsList)
project.runAnalysis()

Dir.chdir actualPath
Dir.chdir "R"
%x(Rscript r-analysis.r)
Dir.chdir actualPath
bcTypesCount = BCTypesCount.new()
bcTypesCount.runTypesCount()
Dir.chdir actualPath
