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

class BuildTravis

	def initialize(projectName, gitProject)
		@builtMergeScenariosAnalysis = BuiltMergeScenariosAnalysis.new(projectName, gitProject)
	end

	def getBuiltMergeScenariosAnalysis()
		@builtMergeScenariosAnalysis
	end

	def runAllAnalysis(projectName, writeCSVs, pathGumTree, withWithoutForks)
		return getBuiltMergeScenariosAnalysis.getStatusBuildsProject(projectName, writeCSVs, pathGumTree, withWithoutForks)
	end
	
end
