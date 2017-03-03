require 'require_all'
require 'travis'
require_rel 'MergeScenariosAnalysis'

class BuiltMergeScenariosAnalysis < MergeScenariosAnalysis

	def getStatusBuildsProject(projectName, writeCSVAllBuilds, writeCSVBuilt, writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks)
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

		fileErrored = ""
		fileFailed = ""
		
		passedConflicts = ConflictAnalysis.new()
		erroredConflicts = ConflictAnalysis.new()
		failedConflicts = ConflictAnalysis.new()
		canceledConflicts = ConflictAnalysis.new()
		
		confBuild = ConflictBuild.new(@pathProject)
		confAllErrored = ConflictCategoryErroredAll.new()
		confAllErroredPull = ConflictCategoryErroredAll.new()
		confErroredForkBuilt = ConflictCategoryErrored.new()
		confForkIntervalErrored = ConflictCategoryErrored.new()
		confForkAllErrored = ConflictCategoryErrored.new()
		confFailedBuilt = ConflictCategoryFailed.new()
		confFailedAllErrored = ConflictCategoryFailed.new()
		confFailedAll = ConflictCategoryFailed.new()
		confFailedInterval = ConflictCategoryFailed.new()

		projectNameFile = projectName.gsub('/','-')
		
		@repositoryTravisProject = getGitProject.getRepositoryTravisByProject()

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
							writeCSVAllBuilds.printErroredBuildPull(projectName.split("/").last, build, confAllErroredPull.findConflictCause(build, getPathProject())[0])
							buildPullErrored += 1
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
							writeCSVAllBuilds.printErroredBuild(projectName.split("/").last, build, confAllErrored.findConflictCause(build, getPathProject())[0])
							buildPushErrored += 1
						elsif (status == "failed")
							#writeCSVAllBuilds.printFailedBuild(projectName.split("/").last, build, confFailedAllErrored.findConflictCause(build))
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
								builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
								
								mergeCommit = mergeScenariosAnalysis(build)
								result = @gitProject.conflictScenario(mergeCommit, allBuilds, build)
								if (result[0] != nil)
									if (result[0])
										totalPushes += 1
									elsif (!result[0])
										totalParentsNoPassed += 1				
									end
									#Independente dos parents de um merge tenham uma build associada no travis, 
									#o codigo abaixo classifica a distribuiçao de cenarios de merge em passed, errored, failed e canceled status
									type = confBuild.typeConflict(build)
									commitsBuildsCloser = []
									commitsBuildsCloser[0] = getGitProject().getCommitCloserToBuild(allBuilds, mergeCommit[0])
									commitsBuildsCloser[1] = getGitProject().getCommitCloserToBuild(allBuilds, mergeCommit[1])
									resultCommitsCloser = @gitProject.conflictScenario(commitsBuildsCloser, allBuilds, build)
									
									if (status == "passed")
										totalMSPassed += 1
										confBuild.conflictAnalysisCategories(passedConflicts, type, result[0])
									elsif (status == "errored")
										totalMSErrored += 1
										isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
										writeCSVForkAll.printConflictBuild(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confForkAllErrored.findConflictCause(build, getPathProject(), pathGumTree, type, true), projectNameFile)
										
										if (commitsBuildsCloser[0] != nil and commitsBuildsCloser[1] != nil and resultCommitsCloser[0] == true and isConflict == true)
											writeCSVForkInterval.printConflictBuild(build, commitsBuildsCloser[0], commitsBuildsCloser[1], confForkIntervalErrored.findConflictCause(build, getPathProject(), pathGumTree, type, true), projectNameFile)
										end
										
										if (isConflict and result[0] == true) 
											writeCSVBuilt.printConflictBuild(build, result[1][0], result[2][0], confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true), projectNameFile)
										end
									elsif (status == "failed")
										totalMSFailed += 1
										isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, result[0])
										writeCSVForkAll.printConflictTest(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confFailedAll.findConflictCause(build), projectNameFile)

										if (commitsBuildsCloser[0] != nil and commitsBuildsCloser[1] != nil and resultCommitsCloser[0] == true)
											if (isConflict)
												writeCSVForkInterval.printConflictTest(build, commitsBuildsCloser[0], commitsBuildsCloser[1], confFailedAll.findConflictCause(build), projectNameFile)
											end
										end

										if (isConflict and result[0] == true) 
											writeCSVBuilt.printConflictTest(build, result[1][0], result[2][0], confFailedBuilt.findConflictCause(build), projectNameFile)
										end
									else
										totalMSCanceled += 1
										confBuild.conflictAnalysisCategories(canceledConflicts, type, result[0])
									end
								else
									totalPushesNoBuilt+=1
								end
							end
						end
					end
					writeCSVBuilt.writeResultByProject(projectName.gsub('/','-'), typeBuild, build)
				end
			end
			
		 	writeCSVBuilt.writeMergeScenariosFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size-builtMergeScenarios.size, totalPushes, totalParentsNoPassed, totalPushesNoBuilt, totalRepeatedBuilds, totalBuilds, totalPushes+totalParentsNoPassed, totalMSPassed, totalMSErrored, 
					totalMSFailed, totalMSCanceled)
			
			writeCSVBuilt.writeBuildConflicts(projectName, confErroredForkBuilt.getTotal(), confErroredForkBuilt.getunavailableSymbol(), confErroredForkBuilt.getMalformedExp(), 
				confErroredForkBuilt.getMethodUpdate(), confErroredForkBuilt.getDuplicateStatement(), confErroredForkBuilt.getDependencyProblem(), confErroredForkBuilt.getUnimplementedMethod(), 
				confErroredForkBuilt.getGitProblem(), confErroredForkBuilt.getRemoteError(), confErroredForkBuilt.getCompilerError(), confErroredForkBuilt.getOtherError())

			writeCSVBuilt.writeTestConflicts(projectName, confFailedBuilt.getTotal(), confFailedBuilt.getFailed(), confFailedBuilt.getGitProblem(), confFailedBuilt.getRemoteError(), confFailedBuilt.getPermission(), 
				confFailedBuilt.getOtherError())

			#Add chamada aqui para criacao dos arquivos de conflictAnalysis de all and interval filters
			# Para tanto instanciar objetos de ConflictsAnalysis para tais filtros
			writeCSVBuilt.writeConflictsAnalysisFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size - builtMergeScenarios.size, totalRepeatedBuilds, totalPushesNoBuilt, totalPushes, 
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
