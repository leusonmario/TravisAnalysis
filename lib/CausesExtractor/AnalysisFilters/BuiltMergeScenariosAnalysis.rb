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
		rebuiltMergeScenarios = Array.new
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
		validScenarioProject = 0
		validScenarioProjectFailed = 0
		validScenarioProjectList = Array.new

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
		#confFailedBuilt = ConflictCategoryFailed.new(pathGumTree, projectName, cloneProject)

		projectBuildsMap = Hash.new()

		projectNameFile = projectName.gsub('/','-')	
		@repositoryTravisProject = getGitProject.getRepositoryTravisByProject()
		validMergeScenario = Array.new
		lastScenarioDate = nil
		lastScenarioDateFailed = nil
		countIntervalCommits = 0
		travisProjectClone = getTravisRepository(getGitProject.getLogin(), getGitProject.getProjectName)

		if (getRepositoryTravisProject() != nil)
			allBuilds = loadAllBuilds(getRepositoryTravisProject(), travisProjectClone, confBuild, withWithoutForks)
			effortTimeExtractor = EffortTimeExtractor.new(allBuilds, @pathProject)

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
								mergeCommit = mergeScenariosAnalysis(build)
								statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], build.commit.sha)
								if (statusModified)
									builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
								else
									rebuiltMergeScenarios.push(build.commit.sha.gsub('\\n',''))
								end

								result = @gitProject.conflictScenario(mergeCommit, allBuilds)
								if (result[0] == true)
									totalPushes += 1

									type = confBuild.typeConflict(build)
									if (status == "passed")
										totalMSPassed += 1
										confBuild.conflictAnalysisCategories(passedConflicts, type, result[0])
									elsif (status == "errored")
										validMergeScenario.push(build.commit.sha)
										totalMSErrored += 1
										if (verifyDateDifference(lastScenarioDate, getDataMergeScenario(build.commit.sha)))
											if (!verifyEmptyBuildLogs(build))
												if (validScenarioProject < 100)
													isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
													#writeCSVForkAll.printConflictBuild(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confForkAllErrored.findConflictCause(build, getPathProject(), pathGumTree, type, true), projectNameFile)

													if (isConflict and result[0] == true)
														stateBC = confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject)
														effort = nil
														if (stateBC.size > 2)
															effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3])
														end
														writeCSVBuilt.printConflictBuild(build.id, result[1][0], result[2][0], stateBC, projectNameFile, effort)
														validScenarioProject += 1
														lastScenarioDate = getDataMergeScenario(build.commit.sha)
													else
														if !result[0]
															causesBroken = confAllErrored.findConflictCause(build, getPathProject())
															buildAgain = false
															causesBroken.each do |cause|
																if (cause == "methodUpdate" or cause == "unavailableSymbol" or cause == "unimplementedMethod" or cause == "statementDuplication")
																	buildAgain = true
																end
															end
															if buildAgain
																causesParentOne = confAllErrored.findConflictCauseLocalID(result[1], getPathProject())
																causesParentOne.each do |cause|
																	if (cause == "dependencyProblem" or cause == "compilerError" or cause == "gitProblem" or cause ==  "remoteError")
																		notBuiltParents.push(mergeCommit[0])
																		break
																	end
																end

																causesParentTwo = confAllErrored.findConflictCauseLocalID(result[2], getPathProject())
																causesParentTwo.each do |cause|
																	if (cause == "dependencyProblem" or cause == "compilerError" or cause == "gitProblem" or cause ==  "remoteError")
																		notBuiltParents.push(mergeCommit[1])
																		break
																	end
																end
															end
														end
														if (result[1] == nil)
															notBuiltParents.push(mergeCommit[0])
														end
														if (result[2] == nil)
															notBuiltParents.push(mergeCommit[1])
														end
														totalPushesNoBuilt+=1
													end
												end
											else
												builtMergeScenarios.delete(build.commit.sha)
											end
										end
=begin									elsif (status == "failed")
										validMergeScenario.push(build.commit.sha)
										totalMSFailed += 1
										if (verifyDateDifference(lastScenarioDateFailed, getDataMergeScenario(build.commit.sha)) and validScenarioProjectFailed < 100)
											resultFailed = result = @gitProject.conflictScenarioFailed(mergeCommit, allBuilds)
											isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, resultFailed[0])

											if (isConflict and result[0] and verifyDateDifference(lastScenarioDateFailed, getDataMergeScenario(build.commit.sha)))
												effort = effortTimeExtractor.checkFixedBuildFailed(build.commit.sha, mergeCommit)
												resultFailedBuild = confFailedBuilt.findConflictCause(build, getPathProject())
												writeCSVBuilt.printConflictTest(build, result[1][0], result[2][0], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], resultFailedBuild[2][0], resultFailedBuild[2][1], resultFailedBuild[2][2], resultFailedBuild[2][3], resultFailedBuild[2][4], resultFailedBuild[2][5])
												validScenarioProjectFailed += 1
												lastScenarioDateFailed = getDataMergeScenario(build.commit.sha)
											end
										end
=end
									else
										totalMSCanceled += 1
										confBuild.conflictAnalysisCategories(canceledConflicts, type, result[0])
									end
								else
									totalParentsNoPassed += 1
								end
							end
						end
					end
					writeCSVBuilt.writeResultByProject(projectName.gsub('/','-'), typeBuild, build)
				end
			end

			lastScenarioDate = nil
			if (travisProjectClone != nil)
				travisProjectClone.each_build do |build|
					if (build != nil)
						status = confBuild.getBuildStatus(build)
						if !build.pull_request
							if (@projectMergeScenarios.include? build.commit.sha+"\n" or @projectMergeScenarios.include? build.commit.sha)
								totalBuilds += 1

								if(builtMergeScenarios.include? build.commit.sha+"\n" or builtMergeScenarios.include? build.commit.sha)
									totalRepeatedBuilds += 1
								else
									print "Merge já buildado \n"
									totalPushesMergeScenarios += 1
									mergeCommit = mergeScenariosAnalysis(build)
									statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], build.commit.sha)
									if (statusModified)
										builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
									else
										rebuiltMergeScenarios.push(build.commit.sha.gsub('\\n',''))
									end

									result = @gitProject.conflictScenario(mergeCommit, allBuilds)
									if (result[0] == true)
										totalPushes += 1

										type = confBuild.typeConflict(build)
										if (status == "passed")
											totalMSPassed += 1
											confBuild.conflictAnalysisCategories(passedConflicts, type, result[0])
										elsif (status == "errored")
											print build.commit.sha
											print "\n"
											validMergeScenario.push(build.commit.sha)
											totalMSErrored += 1
											if (verifyDateDifference(lastScenarioDate, getDataMergeScenario(build.commit.sha)))
												if (!verifyEmptyBuildLogs(build))
													if (validScenarioProject < 100)
														isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
														#writeCSVForkAll.printConflictBuild(build, mergeCommit[0].to_s, mergeCommit[1].to_s, confForkAllErrored.findConflictCause(build, getPathProject(), pathGumTree, type, true), projectNameFile)

														if (isConflict and result[0] == true)
															stateBC = confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject)
															effort = nil
															if (stateBC.size > 2)
																effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3])
															end
															writeCSVBuilt.printConflictBuild(build.id, result[1][0], result[2][0], stateBC, projectNameFile, effort)
															validScenarioProject += 1
															lastScenarioDate = getDataMergeScenario(build.commit.sha)
														else
															if !result[0]
																causesBroken = confAllErrored.findConflictCause(build, getPathProject())
																buildAgain = false
																causesBroken.each do |cause|
																	if (cause == "methodUpdate" or cause == "unavailableSymbol" or cause == "unimplementedMethod" or cause == "statementDuplication")
																		buildAgain = true
																	end
																end
																if buildAgain
																	causesParentOne = confAllErrored.findConflictCauseLocalID(result[1], getPathProject())
																	causesParentOne.each do |cause|
																		if (cause == "dependencyProblem" or cause == "compilerError" or cause == "gitProblem" or cause ==  "remoteError")
																			notBuiltParents.push(mergeCommit[0])
																			break
																		end
																	end

																	causesParentTwo = confAllErrored.findConflictCauseLocalID(result[2], getPathProject())
																	causesParentTwo.each do |cause|
																		if (cause == "dependencyProblem" or cause == "compilerError" or cause == "gitProblem" or cause ==  "remoteError")
																			notBuiltParents.push(mergeCommit[1])
																			break
																		end
																	end
																end
															end
															if (result[1] == nil)
																notBuiltParents.push(mergeCommit[0])
															end
															if (result[2] == nil)
																notBuiltParents.push(mergeCommit[1])
															end
															totalPushesNoBuilt+=1
														end
													end
												else
													builtMergeScenarios.delete(build.commit.sha)
												end
											end
=begin
										elsif (status == "failed")
											totalMSFailed += 1
											if (verifyDateDifference(lastScenarioDateFailed, getDataMergeScenario(build.commit.sha)) and validScenarioProjectFailed < 100)
												resultFailed = result = @gitProject.conflictScenarioFailed(mergeCommit, allBuilds)
												isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, resultFailed[0])

												if (isConflict and result[0])
													effort = effortTimeExtractor.checkFixedBuildFailed(build.commit.sha, mergeCommit)
													resultFailedBuild = confFailedBuilt.findConflictCause(build, getPathProject())
													writeCSVBuilt.printConflictTest(build, result[1][0], result[2][0], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], resultFailedBuild[2][0], resultFailedBuild[2][1], resultFailedBuild[2][2], resultFailedBuild[2][3], resultFailedBuild[2][4], resultFailedBuild[2][5])
													lastScenarioDateFailed = getDataMergeScenario(build.commit.sha)
													validScenarioProjectFailed += 1
												end
											end
=end
										else
											totalMSCanceled += 1
											confBuild.conflictAnalysisCategories(canceledConflicts, type, result[0])
										end
									else
										totalParentsNoPassed += 1
									end
								end
							end
						end
						writeCSVBuilt.writeResultByProject(projectName.gsub('/','-'), typeBuild, build)
					end
				end
			end

			if (validScenarioProject < 100)
				extractorCLI.activeForkProject()
				forkAllBuilds = Hash.new()
				notBuiltParents.each do |notBuiltParent|
					mergeScenarios = nil
					if (rebuiltMergeScenarios.include? notBuiltParent)
						mergeScenarios = mergeScenariosAnalysisCommit(notBuiltParent)
					end
					resultBuildProcess = verifyBuildCurrentState(extractorCLI, notBuiltParent, mergeScenarios)
					if (resultBuildProcess != nil)
						forkAllBuilds[notBuiltParent] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
					else
						break
					end
				end

				#extractorCLI.gitPull()
				countIntervalCommits = 0
				@projectMergeScenarios.each do |mergeScenario|
					if (!builtMergeScenarios.include? mergeScenario)
						mergeScenarioDate = getDataMergeScenario(mergeScenario)
						if (verifyDateDifference(lastScenarioDate,mergeScenarioDate))
							lastScenarioDate = mergeScenarioDate
							mergeScenarios = nil
							if (rebuiltMergeScenarios.include? mergeScenario)
								mergeScenarios = mergeScenariosAnalysisCommit(mergeScenario)
							end
							resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeScenario, mergeScenarios)
							if (resultBuildProcess != nil)
								forkAllBuilds[mergeScenario] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
							#else
								#break
								if (extractorCLI.checkStatusBuild() == "errored")
									totalMSCanceled += 1
									mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
									result = @gitProject.conflictScenario(mergeCommit, allBuilds)
									firstParentStatus = ""
									secondParentStatus = ""
									if (result[1] != nil and result[2] != nil)
										validScenarioProject += 1
										validScenarioProjectList.push(mergeScenario)
									else
										if (result[1] == nil)
											resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
											if (resultBuildProcess != nil)
												forkAllBuilds[mergeCommit[0]] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
											else
												break
											end
											firstParentStatus = extractorCLI.checkStatusBuild()
										end
										if (result[2] == nil and (firstParentStatus == "passed" or firstParentStatus == "failed"))
											resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
											if (resultBuildProcess != nil)
												forkAllBuilds[mergeCommit[1]] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
											else
												break
											end
											secondParentStatus = extractorCLI.checkStatusBuild()
										end
										if ((result[1] != nil or firstParentStatus == "passed" or firstParentStatus == "failed") and (result[2] != nil or secondParentStatus == "passed" or secondParentStatus == "failed"))
											validScenarioProject += 1
											validScenarioProjectList.push(mergeScenario)
										end
									end
								elsif (extractorCLI.checkStatusBuild() == "passed")
									totalMSPassed += 1
=begin							elsif (extractorCLI.checkStatusBuild() == "failed")
								totalMSFailed += 1
								mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
								result = @gitProject.conflictScenario(mergeCommit, allBuilds)
								firstParentStatus = ""
								secondParentStatus = ""
								if (result[1] != nil and result[2] != nil)
									validScenarioProject += 1
									validScenarioProjectList.push(mergeScenario)
								else
									if (result[1] == nil)
										resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeCommit[0])
										if (resultBuildProcess != nil)
											forkAllBuilds[mergeCommit[0]] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
										else
											break
										end
										firstParentStatus = extractorCLI.checkStatusBuild()
									end
									if (result[2] == nil and firstParentStatus == "passed")
										resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeCommit[1])
										if (resultBuildProcess != nil)
											forkAllBuilds[mergeCommit[1]] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
										else
											break
										end
										secondParentStatus = extractorCLI.checkStatusBuild()
									end
									if ((result[1] != nil or firstParentStatus == "passed") and (result[2] != nil or secondParentStatus == "passed"))
										validScenarioProject += 1
										validScenarioProjectList.push(mergeScenario)
									end
								end
=end
								elsif (extractorCLI.checkStatusBuild() == "canceled")
									totalMSCanceled += 1
								end
							end
						end
					end
					if (validScenarioProject > 99 and validScenarioProjectFailed > 99)
						break
					end
				end

				getRepositoryTravisProject().each_build do |build|
					if (build != nil and !(validMergeScenario.include? build.commit.sha+"\n" or validMergeScenario.include? build.commit.sha))
						status = confBuild.getBuildStatus(build)
						if (!build.pull_request)
							if (@projectMergeScenarios.include? build.commit.sha+"\n" or @projectMergeScenarios.include? build.commit.sha)
								mergeCommit = mergeScenariosAnalysis(build)
								result = @gitProject.conflictScenarioAll(mergeCommit, allBuilds, forkAllBuilds)
								if (result[0] == true)
									type = confBuild.typeConflict(build)
									if (status == "errored")
										totalMSErrored += 1
										isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
										if (isConflict and result[0] == true)
											stateBC = confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject)
											effort = nil
											if (stateBC.size > 2)
												effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3])
											end
											writeCSVBuilt.printConflictBuild(build.id, result[1][0], result[2][0], stateBC, projectNameFile, effort)
											validScenarioProject += 1
											lastScenarioDate = getDataMergeScenario(build.commit.sha)
										end
=begin									elsif (status == "failed")
										totalMSFailed += 1
										isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, result[0])
										if (isConflict and result[0] == true)
											effort = effortTimeExtractor.checkFixedBuildFailed(build.commit.sha, mergeCommit)
											resultFailedBuild = confFailedBuilt.findConflictCause(build, getPathProject())
											writeCSVBuilt.printConflictTest(build, result[1][0], result[2][0], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], resultFailedBuild[2][0], resultFailedBuild[2][1], resultFailedBuild[2][2], resultFailedBuild[2][3], resultFailedBuild[2][4], resultFailedBuild[2][5])
										end
=end
									end
								end
							end
						end
					end
				end

				validScenarioProjectList.each do |mergeScenario|
					if (@projectMergeScenarios.include? mergeScenario+"\n" or @projectMergeScenarios.include? mergeScenario)
						mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
						result = @gitProject.conflictScenarioAll(mergeCommit, allBuilds, forkAllBuilds)
						if (result[0] == true)
							type = confBuild.typeConflict(mergeScenario)
							infoValidScenario = forkAllBuilds[mergeScenario]
							if (infoValidScenario[0] == 'errored')
								totalMSErrored += 1
								isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
								if (isConflict and result[0] == true)
									stateBC = confErroredForkBuilt.findConflictCauseFork(infoValidScenario[1], mergeScenario, getPathProject(), pathGumTree, type, true, cloneProject)
									effort = nil
									if (stateBC.size > 1)
										effort = effortTimeExtractor.checkFixedBuild(mergeScenario, mergeCommit, getPathProject(), pathGumTree, stateBC[3])
									end
									writeCSVBuilt.printConflictBuild(@gitProject.getBuildID(mergeScenario, allBuilds, forkAllBuilds), result[1], result[2], stateBC, projectNameFile, effort)
								end
=begin							elsif (infoValidScenario[0] == "failed")
								totalMSFailed += 1
								if (verifyDateDifference(lastScenarioDateFailed, getDataMergeScenario(mergeCommit)) and validScenarioProjectFailed < 100)
									resultFailed = result = @gitProject.conflictScenarioFailed(mergeCommit, allBuilds)
									isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, resultFailed[0])
									if (isConflict and result[0])
										effort = effortTimeExtractor.checkFixedBuildFailed(mergeScenario, mergeCommit)
										resultFailedBuild = confFailedBuilt.findConflictCauseFork(infoValidScenario[1], mergeScenario, getPathProject())
										writeCSVBuilt.printConflictTest(build, result[1][0], result[2][0], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], resultFailedBuild[2][0], resultFailedBuild[2][1], resultFailedBuild[2][2], resultFailedBuild[2][3], resultFailedBuild[2][4], resultFailedBuild[2][5])
										lastScenarioDateFailed = getDataMergeScenario(mergeScenario)
										validScenarioProjectFailed += 1
									end
								end
=end
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

#			writeCSVBuilt.writeTestConflicts(projectName, confFailedBuilt.getTotal(), confFailedBuilt.getFailed(), confFailedBuilt.getGitProblem(),
#				confFailedBuilt.getRemoteError(), confFailedBuilt.getPermission(), confFailedBuilt.getOtherError())

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

	def verifyBuildCurrentState(extractorCLI, sha, mergeScenarios)
		indexCount = 0
		idLastBuild = extractorCLI.checkIdLastBuild()
		state = false
		if (mergeScenarios == nil)
			state = extractorCLI.replayBuildOnTravis(sha, "master")
		else
			state = extractorCLI.commitAndPushRebuiltMergeScenario(sha, mergeScenarios[0], mergeScenarios[1])
		end
		if (state)
			while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
				sleep(20)
				indexCount += 1
				if (indexCount == 10)
					return nil
				end
			end

			status = extractorCLI.checkStatusBuild()
			while (status == "started" and indexCount < 10)
				sleep(20)
				print "Merge Scenario Parents not built yet\n"
				status = extractorCLI.checkStatusBuild()
			end

			return extractorCLI.getInfoLastBuild()
			end
			return nil
	end

	def verifyEmptyBuildLogs(build)
		indexJob = 0
		while (indexJob < build.job_ids.size)
			build.jobs[indexJob].log.body do |bodyJob|
				if (bodyJob.to_s == "")
					return true
				end
			end
			indexJob += 1
		end
		return false
	end

	def getTravisRepository(username, projectName)
		project = projectName.to_s.split("\/")[1]
		projectBuild = nil
		begin
			projectBuild = Travis::Repository.find("#{username}/#{project}")
			return projectBuild
		rescue Exception => e
			return nil
		end
	end

	def verifyDateDifference(lastScenarioDate, candidateScenarioDate)
		if lastScenarioDate == nil
			return true
		else
			intervalTime = ((DateTime.parse(candidateScenarioDate.to_s) - DateTime.parse(lastScenarioDate.to_s))).to_i
			if (intervalTime > 3 or intervalTime < -3)
				return true
			end
			return false
		end
	end

	def getDataMergeScenario(mergeCommit)
		actualPath = Dir.pwd
		Dir.chdir getPathProject()
		date = %x(git show -s --format=%cd #{mergeCommit})
		Dir.chdir actualPath
		return date
	end

end