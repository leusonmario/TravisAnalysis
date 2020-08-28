#!/usr/bin/env ruby

require 'require_all'
require 'travis'
require './CausesExtractor/ConflictCategoryErrored.rb'
require './CausesExtractor/ConflictCategoryFailed.rb'
require './MiningRepositories/Data/ConflictAnalysis.rb'
require_rel 'ConflictBuild.rb'
require_rel 'AnalysisFilters/'
require_all '././MiningRepositories/Repository'

class BuildTravis

	def initialize(projectName, gitProject, localClone)
		@builtMergeScenariosAnalysis = BuiltMergeScenariosAnalysis.new(projectName, gitProject, localClone)
	end

	def getBuiltMergeScenariosAnalysis()
		@builtMergeScenariosAnalysis
	end

	def runAllAnalysisBuilt(projectName, writeCSVAllBuilds, writeCSVBuilt,  writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks, cloneProject, extractorCLI)
		return getBuiltMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVAllBuilds, writeCSVBuilt, writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks, cloneProject, extractorCLI)
	end

	def runAllAnalysisForLocalBuilds(projectName, writeCSVAllBuilds, writeCSVBuilt,  writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks, cloneProject)
		return getBuiltMergeScenariosAnalysis.getStatusBuildsProjectForLocalBuilds(projectName, writeCSVAllBuilds, writeCSVBuilt, writeCSVForkAll, writeCSVForkInterval, pathGumTree, withWithoutForks, cloneProject)
	end
	
end
