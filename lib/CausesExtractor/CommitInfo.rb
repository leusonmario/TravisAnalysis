#!/usr/bin/env ruby

require 'require_all'
require 'travis'
require './CausesExtractor/ConflictCategoryErrored.rb'
require './CausesExtractor/ConflictCategoryFailed.rb'
require './MiningRepositories/Data/ConflictAnalysis.rb'
require_rel 'ConflictBuild.rb'
require_rel 'AnalysisFilters/'
require_all '././MiningRepositories/Repository'

class CommitInfo

	def initialize(commitHash, projectLocalPath)
		@commitHash = commitHash
		@localBuild = LocalBuild.new(commitHash, projectLocalPath)
		@parentsCommit = identifyParentCommits(projectLocalPath)
	end

	def getCommitHash()
		@commitHash
	end

	def getParentsCommit()
		@parentsCommit
	end

	def getLocalBuild()
		@localBuild
	end

	def identifyParentCommits(projectLocalPath)
		parentsCommit = []
		Dir.chdir projectLocalPath
		commitType = %x(git cat-file -p #{@commitHash})
		commitType.each_line do |line|
			if(line.include?('author'))
				break
			end
			if(line.include?('parent'))
				commitSHA = line.partition('parent ').last.gsub("\n","").gsub(' ','').gsub('\r','')
				parentsCommit.push(commitSHA)
			end
		end
		return parentsCommit
	end
	
end
