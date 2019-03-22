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
		failedBCConflicts = Hash.new
		totalPushesNoBuilt = 0
		totalParentsNoPassed = 0
		totalPushes = 0
		totalPushesNormalScenarios = 0
		totalPushesMergeScenarios = 0
		totalRepeatedBuilds = 0
		totalErroredBuildsMS = 0
		totalFailedBuildsMS = 0
		totalMSErroredWithoutExternal = 0
		totalMSFailedWithoutExternal = 0
		totalMSErroredParentsPreservation = 0
		totalMSErroredParentsNoPreservation = 0
		totalMSFailedParentsPreservation = 0
		totalMSFailedParentsNoPreservation = 0
		totalMS = 0
		totalBuilds = 0
		totalMSPassed = 0
		totalMSErrored = 0
		totalMSFailed = 0
		totalMSCanceled = 0
		validScenarioProject = 0
		validScenarioProjectFailed = 0
		validScenarioProjectList = Array.new
		validParentsMergeScenarios = Array.new

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
		confFailedBuilt = ConflictCategoryFailed.new(pathGumTree, projectName, cloneProject, extractorCLI)

		projectBuildsMap = Hash.new()

		projectNameFile = projectName.gsub('/','-')
		@repositoryTravisProject = getGitProject.getRepositoryTravisByProject()
		validMergeScenario = Array.new
		lastScenarioDate = nil
		lastScenarioDateFailed = nil
		countIntervalCommits = 0
		travisProjectClone = getTravisRepository(getGitProject.getLogin(), getGitProject.getProjectName)
		extractorCLI.activeForkProject()

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
								mergeCommit = mergeScenariosAnalysis(build)
								if (mergeCommit != nil)
									totalPushesMergeScenarios += 1

									if (status == "errored")
										totalErroredBuildsMS += 1
									elsif (status == "failed")
										totalFailedBuildsMS += 1
									end

									result = @gitProject.conflictScenario(mergeCommit, allBuilds)
									if (true)
										totalPushes += 1

										type = confBuild.typeConflict(build)
										if (status == "passed")
											totalMSPassed += 1
											confBuild.conflictAnalysisCategories(passedConflicts, type, result[0])
										elsif (status == "errored")
											statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], build.commit.sha)
											if (statusModified)
												builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
											else
												rebuiltMergeScenarios.push(build.commit.sha.gsub('\\n',''))
											end

											validMergeScenario.push(build.commit.sha)
											totalMSErrored += 1
											if (verifyDateDifference(mergeCommit, validParentsMergeScenarios))
												if (!verifyEmptyBuildLogs(build))
													stateBC = confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject, result[0])
													effort = nil
													print result
													if (stateBC.size > 2)
														effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3], extractorCLI, getGitProject())
													end
													if (typeErrorVerification(stateBC[0]))
														if (result[1] == nil)
															aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
															if (aux != nil)
																result[1] = aux[2]
																result[3] = aux[0]
															end
														end
														if (result[2] == nil)
															aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
															if (aux != nil)
																result[2] = aux[2]
																result[4] = aux[0]
															end
														end
													end
													writeCSVBuilt.printConflictBuild(build.id, build.commit.sha, result[1], result[3], result[2], result[4], stateBC, projectNameFile, effort, statusModified)
													externalCause = verifyExternalCauseConflict(stateBC[0])
													if (!externalCause)
														totalMSErroredWithoutExternal += 1
														if (stateBC[1][1])
															totalMSErroredParentsPreservation += 1
														else
															totalMSErroredParentsNoPreservation += 1
														end
													end
													validScenarioProject += 1
													lastScenarioDate = getDataMergeScenario(build.commit.sha)
													validParentsMergeScenarios.push([mergeCommit[0], mergeCommit[1]])
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
												else
													builtMergeScenarios.delete(build.commit.sha)
												end
											end
										elsif (status == "failed")
											if (!extractorCLI.getProjectActive)
												extractorCLI.activeForkProject()
											end
											validMergeScenario.push(build.commit.sha)
											totalMSFailed += 1

											if (result[1] == nil)
												aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
												if (aux != nil)
													result[1] = aux[2]
													result[3] = aux[0]
												end
											end

											if (result[2] == nil)
												aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
												if (aux != nil)
													result[2] = aux[2]
													result[4] = aux[0]
												end
											end
											writeCSVBuilt.printAllConflictTest(build.id, build.commit.sha, result[1], result[2],projectNameFile, result[3], result[4])
											if (verifyDateDifference(mergeCommit, validParentsMergeScenarios))
												resultFailed = @gitProject.conflictScenarioFailed(mergeCommit, allBuilds)
												isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, resultFailed[0])

												if ((resultFailed[5] == "passed") and (resultFailed[6] == "passed") and verifyDateDifference(mergeCommit, validParentsMergeScenarios))
													if (verifyDateDifference(mergeCommit, validParentsMergeScenarios))
														resultFailedBuild = confFailedBuilt.findConflictCause(build, getPathProject(), resultFailed[3], resultFailed[4], build.commit.sha)
														if (resultFailedBuild[1] != nil)
															verifyCompilationProblem(resultFailedBuild[0][0], build, failedBCConflicts)

															if (resultFailedBuild[2][1] == true)
																totalMSFailedParentsPreservation += 1
															else
																totalMSFailedParentsNoPreservation += 1
															end
															checkForBuildsWithExternalProblems(resultFailedBuild[2][3], writeCSVBuilt, build.id, result[1], result[2], projectNameFile, resultFailedBuild[2][4])
															if (resultFailedBuild[2][2])
																externalCause = verifyExternalCauseConflict(resultFailedBuild[0][0])
																if (externalCause)
																	totalMSFailedWithoutExternal += 1
																end
																resultFailedBuild[2][0].each do |onePrint|
																	effort = effortTimeExtractor.checkFixedBuildFailed(build.commit.sha, mergeCommit, pathGumTree, onePrint[0], onePrint[2][3])
																	writeCSVBuilt.printConflictTest(build.id, build.commit.sha, result[1], result[2], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], onePrint[3][0], onePrint[3][1], onePrint[3][2], onePrint[2][0], onePrint[2][1], onePrint[2][2], resultFailedBuild[2][4], resultFailedBuild[2][1], onePrint[0], onePrint[2][3], resultFailed[5], resultFailed[6])
																end
																validScenarioProjectFailed += 1
																lastScenarioDateFailed = getDataMergeScenario(build.commit.sha)
															end
														end
													end
												end
											end
										else
											totalMSCanceled += 1
											confBuild.conflictAnalysisCategories(canceledConflicts, type, result[0])
										end
									else
										totalParentsNoPassed += 1
									end
								else
									builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
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
									mergeCommit = mergeScenariosAnalysis(build)
									if (mergeCommit != nil)
										totalPushesMergeScenarios += 1

										if (status == "errored")
											totalErroredBuildsMS += 1
										elsif (status == "failed")
											totalFailedBuildsMS += 1
										end

										result = @gitProject.conflictScenario(mergeCommit, allBuilds)
										if (true)
											totalPushes += 1

											type = confBuild.typeConflict(build)
											if (status == "passed")
												totalMSPassed += 1
												confBuild.conflictAnalysisCategories(passedConflicts, type, result[0])
											elsif (status == "errored")
												statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], build.commit.sha)
												if (statusModified)
													builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
												else
													rebuiltMergeScenarios.push(build.commit.sha.gsub('\\n',''))
												end

												validMergeScenario.push(build.commit.sha)
												totalMSErrored += 1
												if (verifyDateDifference(mergeCommit, validParentsMergeScenarios))
													if (!verifyEmptyBuildLogs(build))
														isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
														stateBC = confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject, result[0])
														effort = nil
														if (stateBC.size > 2)
															effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3], extractorCLI, getGitProject())
														end
														externalCause = verifyExternalCauseConflict(stateBC[0])
														if (!externalCause)
															totalMSErroredWithoutExternal += 1
															if (stateBC[1][1])
																totalMSErroredParentsPreservation += 1
															else
																totalMSErroredParentsNoPreservation += 1
															end
														end
														if (typeErrorVerification(stateBC[0]))
															if (result[1] == nil)
																aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
																if (aux != nil)
																	result[1] = aux[2]
																	result[3] = aux[0]
																end
															end
															if (result[2] == nil)
																aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
																if (aux != nil)
																	result[2] = aux[2]
																	result[4] = aux[0]
																end
															end
														end
														writeCSVBuilt.printConflictBuild(build.id, build.commit.sha, result[1], result[3], result[2], result[4], stateBC, projectNameFile, effort, statusModified)
														validScenarioProject += 1
														lastScenarioDate = getDataMergeScenario(build.commit.sha)
														validParentsMergeScenarios.push([mergeCommit[0], mergeCommit[1]])
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
													else
														builtMergeScenarios.delete(build.commit.sha)
													end
												end
											elsif (status == "failed")
												if (!extractorCLI.getProjectActive)
													extractorCLI.activeForkProject()
												end
												totalMSFailed += 1

												if (result[1] == nil)
													aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
													if (aux != nil)
														result[1] = aux[2]
														result[3] = aux[0]
													end
												end
												if (result[2] == nil)
													aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
													if (aux != nil)
														result[2] = aux[2]
														result[4] = aux[0]
													end
												end
												writeCSVBuilt.printAllConflictTest(build.id, build.commit.sha, result[1], result[2],projectNameFile, result[3], result[4])

												if (verifyDateDifference(mergeCommit, validParentsMergeScenarios))
													resultFailed = @gitProject.conflictScenarioFailed(mergeCommit, allBuilds)
													isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, resultFailed[0])

													if ((result[3] == "passed") and (result[4] == "passed"))
														resultFailedBuild = confFailedBuilt.findConflictCause(build, getPathProject(), resultFailed[3], resultFailed[4], build.commit.sha)
														verifyCompilationProblem(resultFailedBuild[0][0], build, failedBCConflicts)
														if (resultFailedBuild[2][1] == true)
															totalMSFailedParentsPreservation += 1
														else
															totalMSFailedParentsNoPreservation += 1
														end
														checkForBuildsWithExternalProblems(resultFailedBuild[2][3], writeCSVBuilt, build.id, result[1], result[2], projectNameFile, resultFailedBuild[2][4])
														if (resultFailedBuild[2][2])
															externalCause = verifyExternalCauseConflict(resultFailedBuild[0][0])
															if (externalCause)
																totalMSFailedWithoutExternal += 1
															end
															resultFailedBuild[2][0].each do |onePrint|
																effort = effortTimeExtractor.checkFixedBuildFailed(build.commit.sha, mergeCommit, pathGumTree, onePrint[0], onePrint[2][3])
																writeCSVBuilt.printConflictTest(build.id, build.commit.sha, result[1], result[2], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], onePrint[3][0], onePrint[3][1], onePrint[3][2], onePrint[2][0], onePrint[2][1], onePrint[2][2], resultFailedBuild[2][4], resultFailedBuild[2][1], onePrint[0], onePrint[2][3], resultFailed[5], resultFailed[6])
															end
															validScenarioProjectFailed += 1
															lastScenarioDateFailed = getDataMergeScenario(build.commit.sha)
														end
													end
												end
											else
												totalMSCanceled += 1
												confBuild.conflictAnalysisCategories(canceledConflicts, type, result[0])
											end
										else
											totalParentsNoPassed += 1
										end
									else
										builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
									end
								end
							end
						end
						writeCSVBuilt.writeResultByProject(projectName.gsub('/','-'), typeBuild, build)
					end
				end
			end

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

			@projectMergeScenarios.each do |mergeScenario|
				if (!builtMergeScenarios.include? mergeScenario)
					mergeScenarioDate = getDataMergeScenario(mergeScenario)
					mergeScenarios = nil
					if (rebuiltMergeScenarios.include? mergeScenario)
						mergeScenarios = mergeScenariosAnalysisCommit(mergeScenario)
					end
					if (verifyDateDifference(mergeScenarios,validParentsMergeScenarios))
						lastScenarioDate = mergeScenarioDate

						resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeScenario, mergeScenarios)
						if (resultBuildProcess != nil)
							forkAllBuilds[mergeScenario] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
							if (extractorCLI.checkStatusBuild() == "errored")
								mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
								if (mergeCommit != nil)
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
								end
							elsif (extractorCLI.checkStatusBuild() == "passed")
								totalMSPassed += 1
							elsif (extractorCLI.checkStatusBuild() == "failed")
								if (!extractorCLI.getProjectActive)
									extractorCLI.activeForkProject()
								end
								mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
								if (mergeCommit != nil)
									totalMSFailed += 1
									result = @gitProject.conflictScenario(mergeCommit, allBuilds)
									firstParentStatus = ""
									secondParentStatus = ""
									if (result[1] != nil and result[2] != nil)
										validScenarioProject += 1
										validScenarioProjectList.push(mergeScenario)
									else
										if (result[1] == nil)
											resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeScenario, mergeCommit)
											if (resultBuildProcess != nil)
												forkAllBuilds[mergeCommit[0]] = [resultBuildProcess[0], resultBuildProcess[1], resultBuildProcess[2]]
											else
												break
											end
											firstParentStatus = extractorCLI.checkStatusBuild()
										end
										if (result[2] == nil and firstParentStatus == "passed")
											resultBuildProcess = verifyBuildCurrentState(extractorCLI, mergeScenario, mergeCommit)
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
								end
							elsif (extractorCLI.checkStatusBuild() == "canceled")
								totalMSCanceled += 1
							end
						end
					end
				end
			end

			getRepositoryTravisProject().each_build do |build|
				if (build != nil and !(validMergeScenario.include? build.commit.sha+"\n" or validMergeScenario.include? build.commit.sha))
					status = confBuild.getBuildStatus(build)
					if (!build.pull_request)
						if (@projectMergeScenarios.include? build.commit.sha+"\n" or @projectMergeScenarios.include? build.commit.sha)
							mergeCommit = mergeScenariosAnalysis(build)
							if (mergeCommit != nil)
								if (status == "errored")
									totalErroredBuildsMS += 1
								elsif (status == "failed")
									totalFailedBuildsMS += 1
								end
								result = @gitProject.conflictScenarioAll(mergeCommit, allBuilds, forkAllBuilds)
								if (true)
									totalPushes += 1
									type = confBuild.typeConflict(build)
									if (status == "errored")
										statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], build.commit.sha)

										statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], build.commit.sha)
										totalMSErrored += 1
										isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
										stateBC = confErroredForkBuilt.findConflictCause(build, getPathProject(), pathGumTree, type, true, cloneProject, result[0])
										effort = nil
										if (stateBC.size > 2)
											effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3], extractorCLI, getGitProject())
										end
										externalCause = verifyExternalCauseConflict(stateBC[0])
										if (!externalCause)
											totalMSErroredWithoutExternal += 1
											if (stateBC[1][1])
												totalMSErroredParentsPreservation += 1
											else
												totalMSErroredParentsNoPreservation += 1
											end
										end

										if (typeErrorVerification(stateBC[0]))
											if (result[1] == nil)
												aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
												if (aux != nil)
													result[1] = aux[2]
													result[3] = aux[0]
												end
											end
											if (result[2] == nil)
												aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
												if (aux != nil)
													result[2] = aux[2]
													result[4] = aux[0]
												end
											end
										end
										writeCSVBuilt.printConflictBuild(build.id, build.commit.sha, result[1], result[3], result[2], result[4], stateBC, projectNameFile, effort, statusModified)
										validScenarioProject += 1
										lastScenarioDate = getDataMergeScenario(build.commit.sha)
										validParentsMergeScenarios.push([mergeCommit[0], mergeCommit[1]])
									elsif (status == "failed")
										if (!extractorCLI.getProjectActive)
											extractorCLI.activeForkProject()
										end
										totalMSFailed += 1
										isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, result[0])

										if (result[1] == nil)
											aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
											if (aux != nil)
												result[1] = aux[2]
												result[3] = aux[0]
											end
										end
										if (result[2] == nil)
											aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
											if (aux != nil)
												result[2] = aux[2]
												result[4] = aux[0]
											end
										end
										writeCSVBuilt.printAllConflictTest(build.id, build.commit.sha, result[1], result[2],projectNameFile, result[3], result[4])


										if ((result[3] == "passed") and (result[4] == "passed"))
											resultFailedBuild = confFailedBuilt.findConflictCause(build, getPathProject(), nil, nil, build.commit.sha)
											if (resultFailedBuild[2][1] == true)
												totalMSFailedParentsPreservation += 1
											else
												totalMSFailedParentsNoPreservation += 1
											end
											checkForBuildsWithExternalProblems(resultFailedBuild[2][3], writeCSVBuilt, build.id, result[1], result[2], projectNameFile, resultFailedBuild[2][4])
											if (resultFailedBuild[2][2])
												externalCause = verifyExternalCauseConflict(resultFailedBuild[0][0])
												if (externalCause)
													totalMSFailedWithoutExternal += 1
												end
												resultFailedBuild[2][0].each do |onePrint|
													effort = effortTimeExtractor.checkFixedBuildFailed(build.commit.sha, mergeCommit, pathGumTree, onePrint[0], onePrint[2][3])
													writeCSVBuilt.printConflictTest(build.id, build.commit.sha, result[1], result[2], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], onePrint[3][0], onePrint[3][1], onePrint[3][2], onePrint[2][0], onePrint[2][1], onePrint[2][2], resultFailedBuild[2][4], resultFailedBuild[2][1], onePrint[0], onePrint[2][3], result[3], result[4])
												end
											end
										end
									end
								end
							end
						end
					end
				end

				failedBCConflicts.each do |mergeFailedBC, build|
					mergeCommit = mergeScenariosAnalysisCommit(mergeFailedBC)
					if (mergeCommit != nil)
						if (verifyDateDifference(mergeFailedBC, validParentsMergeScenarios))
							if (!verifyEmptyBuildLogs(build))
								#if (validScenarioProject < 100)
								type = confBuild.typeConflict(mergeFailedBC)
								result = @gitProject.conflictScenario(mergeCommit, allBuilds)
								isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
								stateBC = confErroredForkBuilt.findConflictCauseFromFailedScenario(build, getPathProject(), pathGumTree, type, true, cloneProject, result[0])
								effort = nil
								if (stateBC.size > 2)
									effort = effortTimeExtractor.checkFixedBuild(build.commit.sha, mergeCommit, getPathProject(), pathGumTree, stateBC[3], extractorCLI, getGitProject())
								end
								if (typeErrorVerification(stateBC[0]))
									if (result[1] == nil)
										aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
										if (aux != nil)
											result[1] = aux[2]
											result[3] = aux[0]
										end
									end
									if (result[2] == nil)
										aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
										if (aux != nil)
											result[2] = aux[2]
											result[4] = aux[0]
										end
									end
								end
								writeCSVBuilt.printConflictBuildFromFailedBuils(build.id, build.commit.sha, result[1], result[3], result[2], result[4], stateBC, projectNameFile, effort)
								validScenarioProject += 1
								lastScenarioDate = getDataMergeScenario(build.commit.sha)
							else
								builtMergeScenarios.delete(build.commit.sha)
							end
						end
					end
				end

				validScenarioProjectList.each do |mergeScenario|
					if (@projectMergeScenarios.include? mergeScenario+"\n" or @projectMergeScenarios.include? mergeScenario)
						mergeCommit = mergeScenariosAnalysisCommit(mergeScenario)
						if (mergeCommit != nil)
							result = @gitProject.conflictScenarioAll(mergeCommit, allBuilds, forkAllBuilds)
							infoValidScenario = forkAllBuilds[mergeScenario]
							if (infoValidScenario[0] == "errored")
								totalErroredBuildsMS += 1
							elsif (infoValidScenario[0] == "failed")
								totalFailedBuildsMS += 1
							end
							if (true)
								totalPushes += 1
								type = confBuild.typeConflict(mergeScenario)
								if (infoValidScenario[0] == 'errored')
									statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], mergeScenario)
									statusModified = cloneProject.verifyBadlyMergeScenario(mergeCommit[0], mergeCommit[1], mergeScenario)

									totalMSErrored += 1
									isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result[0])
									if (result[0] == true)
										stateBC = confErroredForkBuilt.findConflictCauseFork(infoValidScenario[1], mergeScenario, getPathProject(), pathGumTree, type, true, cloneProject, result[0])
										effort = nil
										if (stateBC.size > 1)
											effort = effortTimeExtractor.checkFixedBuild(mergeScenario, mergeCommit, getPathProject(), pathGumTree, stateBC[3], extractorCLI, getGitProject())
										end
										externalCause = verifyExternalCauseConflict(stateBC[0])
										if (!externalCause)
											totalMSErroredWithoutExternal += 1
											if (stateBC[1][1])
												totalMSErroredParentsPreservation += 1
											else
												totalMSErroredParentsNoPreservation += 1
											end
										end
										print result
										if (typeErrorVerification(stateBC[0]))
											if (result[1] == nil)
												aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
												if (aux != nil)
													result[1] = aux[2]
													result[3] = aux[0]
												end
											end
											if (result[2] == nil)
												aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
												if (aux != nil)
													result[2] = aux[2]
													result[4] = aux[0]
												end
											end
										end
										writeCSVBuilt.printConflictBuild(@gitProject.getBuildID(mergeScenario, allBuilds, forkAllBuilds), mergeScenario, result[1], result[3], result[2], result[4], stateBC, projectNameFile, effort, statusModified)
										validParentsMergeScenarios.push([mergeCommit[0], mergeCommit[1]])
									end
								elsif (infoValidScenario[0] == "failed")
									if (!extractorCLI.getProjectActive)
										extractorCLI.activeForkProject()
									end
									totalMSFailed += 1

									if (result[1] == nil)
										aux = verifyBuildCurrentState(extractorCLI, mergeCommit[0], nil)
										if (aux != nil)
											result[1] = aux[2]
											result[3] = aux[0]
										end
									end
									if (result[2] == nil)
										aux = verifyBuildCurrentState(extractorCLI, mergeCommit[1], nil)
										if (aux != nil)
											result[2] = aux[2]
											result[4] = aux[0]
										end
									end
									writeCSVBuilt.printAllConflictTest(@gitProject.getBuildID(mergeScenario, allBuilds, forkAllBuilds), mergeScenario, result[1], result[2], projectNameFile, result[3], result[4])

									if (verifyDateDifference(mergeCommit, validParentsMergeScenarios))
										result = @gitProject.conflictScenarioFailed(mergeCommit, allBuilds)
										isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, result[0])
										if ((result[5] == "passed") and (result[6] == "passed"))
											resultFailedBuild = confFailedBuilt.findConflictCauseFork(infoValidScenario[1], mergeScenario, getPathProject())
											if (resultFailedBuild[2][1] == true)
												totalMSFailedParentsPreservation += 1
											else
												totalMSFailedParentsNoPreservation += 1
											end
											checkForBuildsWithExternalProblems(resultFailedBuild[2][3], writeCSVBuilt, @gitProject.getBuildID(mergeScenario, allBuilds, forkAllBuilds), result[1], result[2], projectNameFile, resultFailedBuild[2][4])
											if (resultFailedBuild[2][2])
												externalCause = verifyExternalCauseConflict(resultFailedBuild[0][0])
												if (externalCause)
													totalMSFailedWithoutExternal += 1
												end
												resultFailedBuild[2][0].each do |onePrint|
													effort = effortTimeExtractor.checkFixedBuildFailed(mergeScenario, mergeCommit, pathGumTree, onePrint[0], onePrint[2][3])
													writeCSVBuilt.printConflictTest(@gitProject.getBuildID(mergeScenario, allBuilds, forkAllBuilds), mergeCommit, result[1], result[2], resultFailedBuild[0][0], projectNameFile, effort, resultFailedBuild[0][1], onePrint[3][0], onePrint[3][1], onePrint[3][2], onePrint[2][0], onePrint[2][1], onePrint[2][2], resultFailedBuild[2][4], resultFailedBuild[2][1], onePrint[0], onePrint[2][3], result[5], result[6])
												end
												validScenarioProjectFailed += 1
											end
										end
									end
								end
							end
						end
					end
				end
			end

			writeCSVBuilt.writeMergeScenariosFinal(projectName, @projectMergeScenarios.size, @projectMergeScenarios.size-builtMergeScenarios.size,
																						 totalPushes, totalParentsNoPassed, totalPushesNoBuilt, totalRepeatedBuilds, totalBuilds, totalPushes+totalParentsNoPassed,
																						 totalMSPassed, totalErroredBuildsMS, totalMSErrored, totalMSErroredWithoutExternal, totalMSErroredParentsPreservation, totalMSErroredParentsNoPreservation,
																						 totalFailedBuildsMS, totalMSFailed, totalMSFailedWithoutExternal, totalMSFailedParentsPreservation, totalMSFailedParentsNoPreservation, totalMSCanceled)

			writeCSVBuilt.writeBuildConflicts(projectName, confErroredForkBuilt.getTotal(), confErroredForkBuilt.getCausesErroredBuild.getUnavailableVariable(),
																				confErroredForkBuilt.getCausesErroredBuild.getExpectedSymbol(), confErroredForkBuilt.getCausesErroredBuild.getMethodParameterListSize(),
																				confErroredForkBuilt.getCausesErroredBuild.getStatementDuplication(), confErroredForkBuilt.getCausesErroredBuild.getDependencyProblem(),
																				confErroredForkBuilt.getCausesErroredBuild.getUnimplementedMethod(), confErroredForkBuilt.getCausesErroredBuild.getGitProblem(),
																				confErroredForkBuilt.getCausesErroredBuild.getRemoteError(), confErroredForkBuilt.getCausesErroredBuild.getCompilerError(),
																				confErroredForkBuilt.getCausesErroredBuild.getOtherError())

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

	def getStatusBuildsProjectForLocalBuilds(projectName, writeCSVAllBuilds, writeCSVBuilt, writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks, cloneProject)

	end

	def collectLocalBuildLog()
		@projectMergeScenarios.each do |oneMergeScenario|
			commitInfo = CommitInfo.new(oneMergeScenario, @pathProject)
			@projectCommits[oneMergeScenario] = commitInfo
			commitInfo.getParentsCommit.each do |oneParentCommit|
				if (!@projectCommits.include? oneParentCommit)
					@projectCommits[oneParentCommit] = CommitInfo.new(oneParentCommit, @pathProject)
				end
			end
		end
	end

	def verifyBuildCurrentState(extractorCLI, sha, mergeScenarios)
		indexCount = 0
		idLastBuild = extractorCLI.checkIdLastBuild()
		state = false
		if (mergeScenarios == nil)
			state = extractorCLI.replayBuildOnTravis(sha, @gitProject.getMainProjectBranch())
		end
		if (state)
			while (idLastBuild == extractorCLI.checkIdLastBuild() and state == true)
				sleep(5)
				indexCount += 1
				if (indexCount == 5)
					return nil
				end
			end

			status = extractorCLI.checkStatusBuild()
			while (status == "started" and indexCount < 5)
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
		begin
			while (indexJob < build.job_ids.size)
				build.jobs[indexJob].log.body do |bodyJob|
					if (bodyJob.to_s == "")
						return true
					end
				end
				indexJob += 1
			end
			return false
		rescue
			return true
		end
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

	def verifyDateDifference(mergeCommitParents, allMergeParents)
		begin
			allMergeParents.each do |mergeParent|
				if ((mergeParent[0] == mergeCommitParents[0] or mergeParent[0] == mergeCommitParents[1]) and (mergeParent[1] == mergeCommitParents[0] or mergeParent[1] == mergeCommitParents[1]))
					return false
				end
			end
			return true
		rescue
			print "Merge Parents are nil\n"
		end
		return false
	end

	def getDataMergeScenario(mergeCommit)
		actualPath = Dir.pwd
		Dir.chdir getPathProject()
		date = %x(git show -s --format=%cd #{mergeCommit})
		Dir.chdir actualPath
		return date
	end

	def verifyExternalCauseConflict(cause)
		externalCause = false
		cause.each do |singleCause|
			if (singleCause == "compilerError" or singleCause == "remoteError" or singleCause == "gitProblem" or singleCause == "")
				externalCause = true
			end
		end
		return externalCause
	end

	def verifyCompilationProblem(problem, build, failedBCConflicts)
		begin
			problem.each do |oneProblem|
				if (oneProblem == "CompilationProblem")
					failedBCConflicts[build.commit.sha] = build
				end
			end
		rescue

		end
	end

	def checkForBuildsWithExternalProblems(buildStatus, printer, buildId, buildOneID, buildTwoId, projectName, buildsReport)
		finalPrinter = false
		buildStatus.each do |status|
			if (status == "failed")
				finalPrinter = true
			end
		end
		if (finalPrinter)
			printer.printAllConflictTestExternalCauses(buildId, buildOneID, buildTwoId, projectName, buildsReport)
		end
	end

	def typeErrorVerification(infoError)
		begin
			infoError.each do |error|
				if (error != "" and error != "[]" and error != "compilerError" and error != "remoteError" and error != "githubProblem")
					return true
				end
			end
		rescue

		end
		return false
	end

end
