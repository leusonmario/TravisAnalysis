#!/usr/bin/env ruby
#file: buildTravis.rb

require 'travis'
require 'csv'
require 'rubygems'
require 'fileutils'
require './Repository/MergeCommit.rb'
require './Travis/ConflictCategoryErrored.rb'
require './Travis/ConflictCategoryFailed.rb'
require './Data/ConflictAnalysis.rb'
require_relative 'ConflictBuild.rb'

class BuildTravis

	def initialize(projectName, projectPath)
		@projectName = projectName
		@projectPath = projectPath.gsub('.travis.yml', '')
		@gitProject = GitProject.new(projectPath)
		@projectMergeScenarios = @gitProject.getMergeScenarios()
	end

	def getProjectName()
		@projectName
	end

	def getProjectPath()
		@projectPath
	end

	def getMergeScenarios()
		@projectMergeScenarios
	end

	def mergeScenariosAnalysis(build)
		mergeCommit = MergeCommit.new()
		resultMergeCommit = mergeCommit.getParentsMergeIfTrue(@projectPath, build.commit.sha)
		return resultMergeCommit
	end

	def getStatusBuildsProject(projectName, pathResultByProject, pathConflicstAnalysis, pathMergeScenariosAnalysis, pathConflicsCauses, pathErroredCases, pathFailedCases)
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
		
		confBuild = ConflictBuild.new(@projectPath)
		confErrored = ConflictCategoryErrored.new()
		confFailed = ConflictCategoryFailed.new()
		
		projectNameFile = projectName.partition('/').last
		createConfictFiles(pathErroredCases, pathFailedCases, projectNameFile)
		Dir.chdir pathResultByProject
		CSV.open(projectName.partition('/').last+"Final.csv", "w") do |csv|
 			csv << ["Status", "Type", "Commit", "ID"]
 		end
		
		projectBuild = Travis::Repository.find(projectName)
		projectBuild.each_build do |build|

			if (build != nil)
				status = confBuild.getBuildStatus(build)
				if build.pull_request
					buildTotalPull += 1
					typeBuild = "pull"
					if (status == "passed")
						buildPullPassed += 1
					elsif (status == "errored")
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
						buildPushErrored += 1
					elsif (status == "failed")
						buildPushFailed += 1
					else
						buildPushCanceled += 1
					end
				end
				
				if (@projectMergeScenarios.include? build.commit.sha+"\n" or @projectMergeScenarios.include? build.commit.sha)					
					totalBuilds += 1

					if(builtMergeScenarios.include? build.commit.sha+"\n" or builtMergeScenarios.include? build.commit.sha)
						totalRepeatedBuilds += 1
					else
						totalPushesMergeScenarios += 1
						builtMergeScenarios.push(build.commit.sha.gsub('\\n',''))
						
						mergeCommit = mergeScenariosAnalysis(build)
						result = @gitProject.conflictScenario(mergeCommit, projectBuild, build)
						if (result)
							totalPushes += 1
						else (!result)
							totalPushesNoBuilt+=1		
						end
						type = confBuild.typeConflict(build)
						if (status == "passed")
							totalMSPassed += 1
							confBuild.conflictAnalysisCategories(passedConflicts, type, result)
						elsif (status == "errored")
							totalMSErrored += 1
							isConflict = confBuild.conflictAnalysisCategories(erroredConflicts, type, result)
							if (isConflict) 
								printConflictBuild(build, pathErroredCases, projectNameFile)
							end
							confErrored.findConflictCause(build)
						elsif (status == "failed")
							totalMSFailed += 1
							isConflict = confBuild.conflictAnalysisCategories(failedConflicts, type, result)
							if (isConflict) 
								printConflictTest(build, pathFailedCases, projectNameFile)
							end
							confFailed.findConflictCause(build)
						else
							totalMSCanceled += 1
							confBuild.conflictAnalysisCategories(canceledConflicts, type, result)
						end
					end
				end
			end

 			Dir.chdir pathResultByProject
			CSV.open(projectName.partition('/').last+"Final.csv", "a+") do |csv|
				csv << [build.state, typeBuild, build.commit.sha, build.id]
			end
		end
		
		Dir.chdir pathMergeScenariosAnalysis
		CSV.open("TotalMergeScenariosFinal.csv", "a+") do |csv|
			csv << [projectName, @projectMergeScenarios.size, builtMergeScenarios.size, totalBuilds, totalRepeatedBuilds, totalMSPassed, totalMSErrored, totalMSFailed, totalMSCanceled]
		end

		Dir.chdir pathConflicsCauses
		CSV.open("CausesBuildConflicts.csv", "a+") do |csv|
			csv << [projectName, confErrored.getTotal(), confErrored.getUnvailableSymbol(), confErrored.getGitProblem(), confErrored.getRemoteError(), 
					confErrored.getCompilerError(), confErrored.getPermission(), confErrored.getOtherError()]
		end

		CSV.open("CausesTestConflicts.csv", "a+") do |csv|
			csv << [projectName, confFailed.getTotal(), confFailed.getFailed(), confFailed.getGitProblem(), confFailed.getRemoteError(), confFailed.getPermission(), 
				confFailed.getOtherError()]
		end

		Dir.chdir pathConflicstAnalysis
		CSV.open("ConflictsAnalysisFinal.csv", "a+") do |csv|
			csv << [projectName, @projectMergeScenarios.size, @projectMergeScenarios.size - builtMergeScenarios.size, totalRepeatedBuilds, totalPushesNoBuilt, totalPushes, 
					passedConflicts.getTotalPushes, passedConflicts.getTotalTravis, passedConflicts.getTotalTravisConf, passedConflicts.getTotalConfig, 
					passedConflicts.getTotalConfigConf, passedConflicts.getTotalSource, passedConflicts.getTotalSourceConf, passedConflicts.getTotalAll, 
					passedConflicts.getTotalAllConf, erroredConflicts.getTotalPushes, erroredConflicts.getTotalTravis, erroredConflicts.getTotalTravisConf, 
					erroredConflicts.getTotalConfig, erroredConflicts.getTotalConfigConf, erroredConflicts.getTotalSource, erroredConflicts.getTotalSourceConf, 
					erroredConflicts.getTotalAll, erroredConflicts.getTotalAllConf, failedConflicts.getTotalPushes, failedConflicts.getTotalTravis, 
					failedConflicts.getTotalTravisConf, failedConflicts.getTotalConfig, failedConflicts.getTotalConfigConf, failedConflicts.getTotalSource, 
					failedConflicts.getTotalSourceConf,failedConflicts.getTotalAll, failedConflicts.getTotalAllConf, canceledConflicts.getTotalPushes, 
					canceledConflicts.getTotalTravis,canceledConflicts.getTotalTravisConf, canceledConflicts.getTotalConfig, canceledConflicts.getTotalConfigConf, 
					canceledConflicts.getTotalSource, canceledConflicts.getTotalSourceConf,canceledConflicts.getTotalAll, canceledConflicts.getTotalAllConf]
		end
		
		return projectName, buildTotalPush, buildPushPassed, buildPushErrored, buildPushFailed, buildPushCanceled, buildTotalPull, buildPullPassed, buildPullErrored, buildPullFailed, buildPullCanceled
	end

	def printConflictBuild(build, path, projectName)
		Dir.chdir path
		CSV.open("Errored"+projectName+".csv", "a+") do |csv|
			csv << [build.id]
		end
	end

	def printConflictTest(build, path, projectName)
		Dir.chdir path
		CSV.open("Failed"+projectName+".csv", "a+") do |csv|
			csv << [build.id]
		end
	end

	def createConfictFiles(pathErrored, pathFailed, projectName)
		Dir.chdir pathErrored
		CSV.open("Errored"+projectName+".csv", "w") do |csv|
			csv << ["BuildID"]
		end		
		Dir.chdir pathFailed
		CSV.open("Failed"+projectName+".csv", "w") do |csv|
			csv << ["BuildID"]
		end		
	end
end
