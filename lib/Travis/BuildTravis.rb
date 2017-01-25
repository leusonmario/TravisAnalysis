#!/usr/bin/env ruby
#file: buildTravis.rb

require 'travis'
require './Repository/MergeCommit.rb'
require './Travis/ConflictCategoryErrored.rb'
require './Travis/ConflictCategoryFailed.rb'
require './Data/ConflictAnalysis.rb'
require_relative 'ConflictBuild.rb'
require_relative 'BuiltMergeScenariosAnalysis.rb'
require_relative 'MergeScenariosAnalysis.rb'
require_relative 'AllMergeScenariosAnalysis.rb'

class BuildTravis

	def initialize(projectName, gitProject)
		@builtMergeScenariosAnalysis = BuiltMergeScenariosAnalysis.new(projectName, gitProject)
		@allMergeScenariosAnalysis = AllMergeScenariosAnalysis.new(projectName, gitProject)
	end

	def getBuiltMergeScenariosAnalysis()
		@builtMergeScenariosAnalysis
	end

	def getAllMergeScenariosAnalysis()
		@allMergeScenariosAnalysis
	end

	def runAllAnalysisBuilt(projectName, writeCSVs, pathGumTree, withWithoutForks)
		return getBuiltMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVs, pathGumTree, withWithoutForks)
	end

	def runAllAnalysisAll(projectName, writeCSVs, pathGumTree, withWithoutForks)
		return getAllMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVs, pathGumTree, withWithoutForks)
	end
	
end
