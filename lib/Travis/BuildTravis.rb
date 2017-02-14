#!/usr/bin/env ruby

require 'travis'
require './Repository/MergeCommit.rb'
require './Travis/ConflictCategoryErrored.rb'
require './Travis/ConflictCategoryFailed.rb'
require './Data/ConflictAnalysis.rb'
require_relative 'ConflictBuild.rb'
require_relative 'BuiltMergeScenariosAnalysis.rb'
require_relative 'MergeScenariosAnalysis.rb'
require_relative 'AllMergeScenariosAnalysis.rb'
require_relative 'IntervalMergeScenariosAnalysis.rb'

class BuildTravis

	def initialize(projectName, gitProject)
		@builtMergeScenariosAnalysis = BuiltMergeScenariosAnalysis.new(projectName, gitProject)
		@allMergeScenariosAnalysis = AllMergeScenariosAnalysis.new(projectName, gitProject)
		@intervalMergeScenariosAnalysis = IntervalMergeScenariosAnalysis.new(projectName, gitProject)
	end

	def getBuiltMergeScenariosAnalysis()
		@builtMergeScenariosAnalysis
	end

	def getAllMergeScenariosAnalysis()
		@allMergeScenariosAnalysis
	end

	def getIntervalMergeScenariosAnalysis()
		@intervalMergeScenariosAnalysis
	end

	def runAllAnalysisBuilt(projectName, writeCSVAllBuilds, writeCSVBuilt,  writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks)
		return getBuiltMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVAllBuilds, writeCSVBuilt, writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks)
	end

	def runAllAnalysisAll(projectName, writeCSVs, pathGumTree, withWithoutForks)
		return getAllMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVs, pathGumTree, withWithoutForks)
	end
	
	def runAllAnalysisInterval(projectName, writeCSVs, pathGumTree, withWithoutForks)
		return getIntervalMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVs, pathGumTree, withWithoutForks)
	end

	def runAllAnalysis(projectName, gitProject, writeCSVs, writeCSVAllBuildssk, pathGumTree, withWithoutForks)
		buildTotalPush = 0
		buildTotalPull = 0
		buildPushPassed = 0
		buildPushErrored = 0
		buildPushFailed = 0
		buildPushCanceled = 0
		buildPullPassed = 0
		buildPullErrored = 0
		buildPullFailed = 0
		buildPullCanceled = 0
		typeBuild = ""
		
		builtMergeScenarios = Array.new
		totalPushesNoBuilt = 0
		totalParentsNoPassed = 0
		totalPushes = 0
		totalPushesNormalScenarios = 0
		totalPushesMergeScenarios = 0
		totalRepeatedBuilds = 0
		totalMS = 0
		totalBuilds = 0
		totalMSPassed = 0
		totalMSErrored = 0
		totalMSFailed = 0
		totalMSCanceled = 0
		
		passedConflicts = ConflictAnalysis.new()
		erroredConflicts = ConflictAnalysis.new()
		failedConflicts = ConflictAnalysis.new()
		canceledConflicts = ConflictAnalysis.new()
		
		confBuild = ConflictBuild.new(@pathProject)
		confErrored = ConflictCategoryErrored.new()
		confFailed = ConflictCategoryFailed.new()

		projectNameFile = projectName.gsub('/','-')
		
		# nao precisa disso... Uma chamada apena e valida
		@repositoryTravisProject = gitProject.getRepositoryTravisByProject()

		if (getRepositoryTravisProject() != nil)
			allBuilds = loadAllBuilds(getRepositoryTravisProject(), confBuild, withWithoutForks)
			getRepositoryTravisProject().each_build do |build|

				if (build != nil)
					status = confBuild.getBuildStatus(build)
					if build.pull_request
						buildTotalPull += 1
						typeBuild = "pull"
						if (status == "passed")
							buildPullPassed += 1
						elsif (status == "errored")
							buildPullErrored += 1
							#lembrando que para casos de cenarios de merge sera necessario informar se ocorreu conflito de build ou nao, por meio do uso do gumtree
							writeCSVAllBuilds.printConflictBuild(build, confErrored.findErroredCause(build, getPathProject(), pathGumTree, confBuild.typeConflict(build))[0])
						elsif (status == "failed")
							buildPullFailed += 1
						else
							buildPullCanceled += 1
						end
					else
						buildTotalPush += 1
						typeBuild = "push"
						if (status == "passed")
							buildPushPassed += 1
						elsif (status == "errored")
							buildPushErrored += 1
						elsif (status == "failed")
							buildPushFailed += 1
						else
							buildPushCanceled += 1
						end

						if (@projectMergeScenarios.include? build.commit.sha+"\n" or @projectMergeScenarios.include? build.commit.sha)					
							totalBuilds += 1

							if(builtMergeScenarios.include? build.commit.sha+"\n" or builtMergeScenarios.include? build.commit.sha)
								totalRepeatedBuilds += 1
							else
								totalPushesMergeScenarios += 1
								builtMergeScenarios.push(build.commit.sha.gsub("\n",""))
								
								mergeCommit = mergeScenariosAnalysis(build)
								if (mergeCommit.size > 1)
									type = confBuild.typeConflict(build)
									if (status == "passed")
										totalMSPassed += 1
										confBuild.conflictAnalysisCategories(passedConflicts, type, true)
									elsif (status == "errored")
										totalMSErrored += 1
										isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, true)
										writeCSVs.printConflictBuild(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confErrored.findConflictCause(build, getPathProject(), pathGumTree, type), projectNameFile)
									elsif (status == "failed")
										totalMSFailed += 1
										isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, true)
										writeCSVs.printConflictTest(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confFailed.findConflictCause(build), projectNameFile)
									else
										totalMSCanceled += 1
										confBuild.conflictAnalysisCategories(canceledConflicts, type, true)
									end
								end
							end
						end
					end
					writeCSVs.writeResultByProject(projectName.gsub('/','-'), typeBuild, build)
				end
			end
			
		 	writeCSVs.writeMergeScenariosFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size-builtMergeScenarios.size, totalPushes, totalParentsNoPassed, totalPushesNoBuilt, totalRepeatedBuilds, totalBuilds, totalPushes+totalParentsNoPassed, totalMSPassed, totalMSErrored, 
					totalMSFailed, totalMSCanceled)
			
			writeCSVs.writeBuildConflicts(projectName, confErrored.getTotal(), confErrored.getunavailableSymbol(), confErrored.getMalformedExp(), 
				confErrored.getUpdateModifier(), confErrored.getDuplicateStatement(), confErrored.getDependencyProblem(), confErrored.getUnimplementedMethod(), 
				confErrored.getGitProblem(), confErrored.getRemoteError(), confErrored.getCompilerError(), confErrored.getOtherError())

			writeCSVs.writeTestConflicts(projectName, confFailed.getTotal(), confFailed.getFailed(), confFailed.getGitProblem(), confFailed.getRemoteError(), confFailed.getPermission(), 
				confFailed.getOtherError())

			writeCSVs.writeConflictsAnalysisFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size - builtMergeScenarios.size, totalRepeatedBuilds, totalPushesNoBuilt, totalPushes, 
							passedConflicts.getTotalPushes, passedConflicts.getTotalTravis, passedConflicts.getTotalTravisConf, passedConflicts.getTotalConfig, 
							passedConflicts.getTotalConfigConf, passedConflicts.getTotalSource, passedConflicts.getTotalSourceConf, passedConflicts.getTotalAll, 
							passedConflicts.getTotalAllConf, erroredConflicts.getTotalPushes, erroredConflicts.getTotalTravis, erroredConflicts.getTotalTravisConf, 
							erroredConflicts.getTotalConfig, erroredConflicts.getTotalConfigConf, erroredConflicts.getTotalSource, erroredConflicts.getTotalSourceConf, 
							erroredConflicts.getTotalAll, erroredConflicts.getTotalAllConf, failedConflicts.getTotalPushes, failedConflicts.getTotalTravis, 
							failedConflicts.getTotalTravisConf, failedConflicts.getTotalConfig, failedConflicts.getTotalConfigConf, failedConflicts.getTotalSource, 
							failedConflicts.getTotalSourceConf,failedConflicts.getTotalAll, failedConflicts.getTotalAllConf, canceledConflicts.getTotalPushes, 
							canceledConflicts.getTotalTravis,canceledConflicts.getTotalTravisConf, canceledConflicts.getTotalConfig, canceledConflicts.getTotalConfigConf, 
							canceledConflicts.getTotalSource, canceledConflicts.getTotalSourceConf,canceledConflicts.getTotalAll, canceledConflicts.getTotalAllConf)

			return projectName, buildTotalPush, buildPushPassed, buildPushErrored, buildPushFailed, buildPushCanceled, buildTotalPull, buildPullPassed, buildPullErrored, buildPullFailed, buildPullCanceled
		else
			return nil
		end
	end	
end
