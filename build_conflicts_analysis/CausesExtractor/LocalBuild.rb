#!/usr/bin/env ruby

require 'require_all'
require 'travis'
require './CausesExtractor/ConflictCategoryErrored.rb'
require './CausesExtractor/ConflictCategoryFailed.rb'
require './MiningRepositories/Data/ConflictAnalysis.rb'
require_rel 'ConflictBuild.rb'
require_rel 'AnalysisFilters/'
require_all '././MiningRepositories/Repository'

class LocalBuild

	def initialize(commitHash, projectLocalPath)
		@build = runLocalBuildForCommit(commitHash, projectLocalPath)
		@buildStatus = checkBuildStatus(@build)
	end

	def getBuild()
		@build
	end

	def getBuildStatus()
		@buildStatus
	end

	def runLocalBuildForCommit(commitHash, projectLocalPath)
		currentPath = Dir.pwd
		Dir.chdir projectLocalPath
		checkout = %x(git checkout -f #{commitHash})
		build = %x(mvn clean install test)
		Dir.chdir currentPath
		return build
	end

	def checkBuildStatus(build)
		if (build != nil)
			if build.to_s[/\[ERROR\] COMPILATION ERROR/]
				return "errored"
			elsif build.to_s[/There are test failures./]
				return "failed"
			else
				return "passed"
			end
		end
	end
	
end
