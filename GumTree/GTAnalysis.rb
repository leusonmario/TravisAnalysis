#!/usr/bin/env ruby
#file: GTAnalysis.rb

require 'rubygems'
require './Repository/MergeCommit.rb'

class GTAnalysis
	def initialize(gumTreePath)
		@mergeCommit = MergeCommit.new()
		@pathGT = gumTreePath
	end

	def getGumTreeAnalysis(pathProject, build, fileConflict)
		parents = @mergeCommit.getParentsMergeIfTrue(pathProject, build.commit.sha)
		actualPath = Dir.pwd
		
		pathCopies = createCopyProject(parents, pathProject)

		puts @pathGT
		Dir.chdir @pathGT
		
		gumLeft = %x(./gumtree webdiff #{pathCopies[0]} #{pathCopies[1]})
		gumRigth = %x(./gumtree webdiff #{pathCopies[0]} #{pathCopies[2]})
		
		deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
	end

	def createCopyProject(parents, pathProject)
		Dir.chdir pathProject
		checkout = %x(git checkout master)
		base = %x(git merge-base --all #{parents[0]} #{parents[1]})
		pasteBase = "/home/leuson/TestePaola/"+"#{base[0..39]}"
		checkout = %x(git checkout #{base})
		clone = %x(cp -R #{pathProject} #{pasteBase})

		index = 0
		while(index < parents.size)
			checkout = %x(git checkout #{parents[index]})
			paste = "/home/leuson/TestePaola/"+"#{parents[index]}"
			clone = %x(cp -R #{pathProject} #{paste})
			checkout = %x(git checkout master)
			index += 1
		end

		left = "/home/leuson/TestePaola/"+parents[0]
		rigth = "/home/leuson/TestePaola/"+parents[1]
		return pasteBase, left, rigth
	end

	def deleteProjectCopies(pathCopies)
		index = 0
		while(index < pathCopies.size)
			delete = %x(rm -rf #{pathCopies[index]})	
			index += 1
		end
	end

	def diffAnalysisGT(gumLeft, gumRigth)
		if(log1[/(Delete)\s([a-zA-Z]*)[\:]?[\s]?#{nome}/])
			puts "Variable deleted on LOG1"
		elsif (log2[/(Delete)\s([a-zA-Z]*)[\:]?[\s]?#{nome}/])
			puts "Variable deleted on LOG2"
		end
	end

end