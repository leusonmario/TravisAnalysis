require 'require_all'
require 'travis'
require_rel 'MergeScenariosAnalysis'

class BuiltMergeScenariosAnalysis < MergeScenariosAnalysis

	def getStatusBuildsProject(projectName, writeCSVAllBuilds, writeCSVBuilt, writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks, cloneProject, extractorCLI)
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
		
		notBuiltParents = Array.new
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
		confBuildFork = ConflictBuild.new(extractorCLI.getPathProject())
		confAllErrored = ConflictCategoryErroredAll.new()
		confAllErroredPull = ConflictCategoryErroredAll.new()
		confErroredForkBuilt = ConflictCategoryErrored.new(projectName, getPathLocalClone())
		confForkIntervalErrored = ConflictCategoryErrored.new(projectName, getPathLocalClone())
		confForkAllErrored = ConflictCategoryErrored.new(projectName, getPathLocalClone())
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
							#writeCSVAllBuilds.printErroredBuildPull(projectName.split("/").last, build, confAllErroredPull.findConflictCause(build, getPathProject())[0])
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
							#writeCSVAllBuilds.printErroredBuild(projectName.split("/").last, build, confAllErrored.findConflictCause(build, getPathProject())[0])
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
								result = @gitProject.conflictScenario(mergeCommit, allBuilds)
								if (result[0] == true)
									if (result[0])
										totalPushes += 1
									elsif (!result[0])
										totalParentsNoPassed += 1				
									end

									type = confBuild.typeConflict(build)
									if (status == "passed")
										totalMSPassed += 1
										confBuild.conflictAnalysisCategories(passedConflicts, type, result[0])
									elsif (status == "errored")
										if (result[1] == nil)
											notBuiltParents.push(mergeCommit[0])
										end
										if (result[2] == nil)
											notBuiltParents.push(mergeCommit[1])
										end
										totalPushesNoBuilt+=1
									elsif (status == "failed")
										totalMSFailed += 1
										isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, result[0])
										#writeCSVForkAll.printConflictTest(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confFailedAll.findConflictCause(build), projectNameFile)

										if (isConflict and result[0] == true) 
											#writeCSVBuilt.printConflictTest(build, result[1][0], result[2][0], confFailedBuilt.findConflictCause(build), projectNameFile)
										end
									else
										totalMSCanceled += 1
										confBuild.conflictAnalysisCategories(canceledConflicts, type, result[0])
									end
								end
							end
						end
					end
					writeCSVBuilt.writeResultByProject(projectName.gsub('/','-'), typeBuild, build)
				end
			end

			notBuiltParents.each do |notBuiltParent|
				idLastBuild = extractorCLI.checkIdLastBuild()
				state = extractorCLI.replayBuildOnTravis(notBuiltParent, "master")
				while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
					sleep(20)
				end
				
				status = extractorCLI.checkStatusBuild()
				while (status == "started\n")
					sleep(20)
					status = extractorCLI.checkStatusBuild()
				end
			end

			extractorCLI.gitPull()
			validScenarioProject = 0
			@projectMergeScenarios.each do |mergeScenario|
				if (!builtMergeScenarios.include? mergeScenario)
					idLastBuild = extractorCLI.checkIdLastBuild()
					state = extractorCLI.replayBuildOnTravis(mergeScenario, "master")
					if (state == true)
						while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
							sleep(20)
						end
						status = extractorCLI.checkStatusBuild()
						while (status == "started\n")
							sleep(20)
							status = extractorCLI.checkStatusBuild()
						end
						#all not built merge scenarios should be built.
						#Depending on its build process result, the parents commits should also be built
						if (status == "errored\n")
							totalMSCanceled += 1
							mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
							result = @gitProject.conflictScenario(mergeCommit, allBuilds)
							firstParentStatus = ""
							if (result[1] == nil)
								idLastBuild = extractorCLI.checkIdLastBuild()
								state = extractorCLI.replayBuildOnTravis(mergeCommit[0], "master")
								while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
									sleep(20)
								end	
								status = extractorCLI.checkStatusBuild()
								while (status == "started\n")
									sleep(30)
									status = extractorCLI.checkStatusBuild()
								end
								firstParentStatus = extractorCLI.checkStatusBuild()
							end
							if (result[2] == nil and (firstParentStatus == "passed\n" or firstParentStatus == "failed\n"))
								idLastBuild = extractorCLI.checkIdLastBuild()
								state = extractorCLI.replayBuildOnTravis(mergeCommit[1], "master")
								while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
									sleep(20)
								end
								status = extractorCLI.checkStatusBuild()
								while (status == "started\n")
									sleep(30)
									status = extractorCLI.checkStatusBuild()
								end
								secondParentStatus = extractorCLI.checkStatusBuild()
								if (secondParentStatus == "passed\n" or secondParentStatus == "failed\n")
									validScenarioProject += 1
								end
							end
						elsif (status == "passed\n")
							totalMSPassed += 1
						elsif (status == "failed\n")
							totalMSFailed += 1
						elsif (status == "canceled\n")
							totalMSCanceled += 1
						end
					end
				end
				if (validScenarioProject > 2)
					break
				end
			end

			repositoryTravisProjectFork = Travis::Repository.find(extractorCLI.getUsername()+"/"+extractorCLI.getName())
		 	allBuildsFork = loadAllBuilds(repositoryTravisProjectFork, confBuildFork, withWithoutForks)
		 	
		 	getRepositoryTravisProject().each_build do |build|
				if (build != nil)
					status = confBuild.getBuildStatus(build)
					if (!build.pull_request)
						if (@projectMergeScenarios.include? build.commit.sha+"\n" or @projectMergeScenarios.include? build.commit.sha)
							mergeCommit = mergeScenariosAnalysis(build)
							if (allBuildsFork.size > 0)
								result = @gitProject.conflictScenarioAll(mergeCommit, allBuilds, allBuildsFork)
							else
								result = @gitProject.conflictScenario(mergeCommit, allBuilds)
							end
							if (result[0] == true)
								type = confBuild.typeConflict(build)
								if (status == "errored")
									totalMSErrored += 1
									isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
									if (isConflict and result[0] == true)
										writeCSVBuilt.printConflictBuild(build, result[1][0], result[2][0], confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject), projectNameFile)
									end
								end
							end
						end
					end
				end
			end

		 	writeCSVBuilt.writeMergeScenariosFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size-builtMergeScenarios.size, 
		 		totalPushes, totalParentsNoPassed, totalPushesNoBuilt, totalRepeatedBuilds, totalBuilds, totalPushes+totalParentsNoPassed, 
		 		totalMSPassed, totalMSErrored, totalMSFailed, totalMSCanceled)
			
			writeCSVBuilt.writeBuildConflicts(projectName, confErroredForkBuilt.getTotal(), confErroredForkBuilt.getCausesErroredBuild.getUnavailableVariable(), 
				confErroredForkBuilt.getCausesErroredBuild.getExpectedSymbol(), confErroredForkBuilt.getCausesErroredBuild.getMethodParameterListSize(), 
				confErroredForkBuilt.getCausesErroredBuild.getStatementDuplication(), confErroredForkBuilt.getCausesErroredBuild.getDependencyProblem(), 
				confErroredForkBuilt.getCausesErroredBuild.getUnimplementedMethod(), confErroredForkBuilt.getCausesErroredBuild.getGitProblem(), 
				confErroredForkBuilt.getCausesErroredBuild.getRemoteError(), confErroredForkBuilt.getCausesErroredBuild.getCompilerError(), 
				confErroredForkBuilt.getCausesErroredBuild.getOtherError())

			writeCSVBuilt.writeTestConflicts(projectName, confFailedBuilt.getTotal(), confFailedBuilt.getFailed(), confFailedBuilt.getGitProblem(), 
				confFailedBuilt.getRemoteError(), confFailedBuilt.getPermission(), confFailedBuilt.getOtherError())

			writeCSVBuilt.writeConflictsAnalysisFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size - builtMergeScenarios.size, 
							totalRepeatedBuilds, totalPushesNoBuilt, totalPushes, 
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