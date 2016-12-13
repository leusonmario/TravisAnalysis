#!/usr/bin/env ruby
#file: GTAnalysis.rb

require 'nokogiri'
require 'open-uri'
require 'rest-client'
require './Repository/MergeCommit.rb'

class GTAnalysis
	def initialize(gumTreePath)
		@mergeCommit = MergeCommit.new()
		@gumTreePath = gumTreePath
	end

	def getGumTreePath()
		@gumTreePath
	end

	def getGumTreeAnalysis(pathProject, build, fileConflict)
		parents = @mergeCommit.getParentsMergeIfTrue(pathProject, build.commit.sha)
		actualPath = Dir.pwd
		
		pathCopies = createCopyProject(build.commit.sha, parents, pathProject)

		Dir.chdir getGumTreePath()
		#  		   result 			left 		right 		MergeCommit 	parent1 	parent2 	problemas
		gumTreeDiffByBranch(pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4])
		deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
	end

	def createDirectories(pathProject)
		copyBranch = []
		Dir.chdir pathProject
		Dir.chdir ".."
		FileUtils::mkdir_p 'Copies/Result'
		FileUtils::mkdir_p 'Copies/Left'
		FileUtils::mkdir_p 'Copies/Right'
		FileUtils::mkdir_p 'Copies/Base'		
		Dir.chdir "Copies"
		copyBranch.push(Dir.pwd)
		Dir.chdir "Result"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Left"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Right"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Base"
		copyBranch.push(Dir.pwd)
		return copyBranch
	end
	
	def createCopyProject(mergeCommit, parents, pathProject)
		copyBranch = createDirectories(pathProject)
		Dir.chdir pathProject
		checkout = %x(git checkout master > /dev/null 2>&1)
		base = %x(git merge-base --all #{parents[0]} #{parents[1]})
		checkout = %x(git checkout #{base} > /dev/null 2>&1)
		clone = %x(cp -R #{pathProject} #{copyBranch[4]})
		checkout = %x(git checkout #{mergeCommit} > /dev/null 2>&1)
		clone = %x(cp -R #{pathProject} #{copyBranch[1]})
		
		index = 0
		while(index < parents.size)
			checkout = %x(git checkout #{parents[index]} > /dev/null 2>&1)
			clone = %x(cp -R #{pathProject} #{copyBranch[index+2]} > /dev/null 2>&1)
			checkout = %x(git checkout master > /dev/null 2>&1)
			index += 1
		end

		return copyBranch[0], copyBranch[1], copyBranch[2], copyBranch[3], copyBranch[4], mergeCommit
		#      copies         result 			left 		right 			base			mergeCommit
	end

	def deleteProjectCopies(pathCopies)
		index = 0
		while(index < pathCopies.size)
			delete = %x(rm -rf #{pathCopies[index]})	
			index += 1
		end
	end

	def diffAnalysisGT(gumLeft, gumRight, allProblems)
		allProblems.each do |problem|
			if (problem == "unavailableSymbol")
				if(gumLeft[/(Update SimpleName:)\s([a-zA-Z0-9]*)/])
					puts "LeftBranch updated symbol name"
				elsif (gumRight[/(Update SimpleName:)\s([a-zA-Z0-9]*)/])
					puts "RightBranch updated symbol name"
				end
				if(gumLeft[/(Delete)\s([a-zA-Z]*)[\:]?[\s]?/])
					puts "Variable deleted on LOG1"
				elsif (gumRight[/(Delete)\s([a-zA-Z]*)[\:]?[\s]?/])
					puts "Variable deleted on LOG2"
				end
			end
		end
	end

	def getAllProblemsByFile(fileName, resultProblems)
		allProblems = []
		resultProblems.each do |problem|
			if (!(allProblems.include? problem[1]) and problem[0]==fileName)
				allProblems.push(problem[1])
			end
		end
		return allProblems
	end

	def runAllDiff(firstBranch, secondBranch)
		Dir.chdir @gumTreePath
		mainDiff = nil
		modifiedFilesDiff = []
		addedFiles = []
		deletedFiles = []
		begin
			thr = Thread.new { diff = system "bash", "-c", "exec -a gumtree ./gumtree webdiff #{firstBranch.gsub("\n","")} #{secondBranch.gsub("\n","")}" }
			sleep(10)
			mainDiff = %x(wget http://127.0.0.1:4754/ -q -O -)
			modifiedFilesDiff = getDiffByModification(mainDiff[/Modified files \((.*?)\)/m, 1])
			addedFiles = getDiffByAddedFile(mainDiff[/Added files \((.*?)\)/m, 1])
			deletedFiles = getDiffByDeletedFile(mainDiff[/Deleted files \((.*?)\)/m, 1])
			
			kill = %x(pkill -f gumtree)
			sleep(5)
		rescue Exception => e
			puts "GumTree Failed"
		end
		return modifiedFilesDiff, addedFiles, deletedFiles
	end

	def gumTreeDiffByBranch(result, left, right, base)
		baseLeft = runAllDiff(base, left)
		baseRight = runAllDiff(base, right)
		leftResult = runAllDiff(left, result)
		rightResult = runAllDiff(right, result)
		verifyModificationStatus(baseLeft, leftResult, baseRight, rightResult)
	end

	def verifyModificationStatus(baseLeft, leftResult, baseRight, rightResult)
		statusModified = true
		statusModified = verifyModifiedFile(baseLeft[0], leftResult[0], baseRight[0], rightResult[0])
		statusAdded = verifyAddedDeletedFile(baseLeft[1], leftResult[1], baseRight[1], rightResult[1])
		statusDeleted = verifyAddedDeletedFile(baseLeft[2], leftResult[2], baseRight[2], rightResult[2])
		if (statusModified and statusAdded and statusDeleted)
			puts "IT WAS LOVE (MERGE WITHOUT CONFLICTS), IT WAS NOT A PERFECT ILLUSION"
		else 
			puts "IT WAS NOT LOVE (MERGE WITH CONFLICTS), IT WAS A PERFECT ILLUSION"
		end
	end

	def verifyAddedDeletedFile(baseLeftInitial, leftResultFinal, baseRightInitial, rightResultFinal)
		status = true
		if(baseLeftInitial.size > 0) 
			baseLeftInitial.each do |fileLeft|
				if (!rightResultFinal.include?(fileLeft))
					status = false
					break
				end
			end
		end
		if (baseRightInitial.size > 0)
			baseRightInitial.each do |fileLeft|
				if (!leftResultFinal.include?(fileLeft))
					status = false
					break
				end
			end
		end
		return status
	end

	def verifyModifiedFile(baseLeftInitial, leftResultFinal, baseRightInitial, rightResultFinal)
		status = true
		if(baseLeftInitial.size > 0)
			baseLeftInitial.each do |keyFile, fileLeft|
				fileRight = rightResultFinal[keyFile]
				if (fileRight == nil or fileLeft != fileRight)
					status = false
					break
				end
			end
		end
		if(baseRightInitial.size > 0) 
			baseRightInitial.each do |keyFile, fileRight|
				fileLeft = leftResultFinal[keyFile]
				if (fileLeft == nil or fileRight != fileLeft)
					status = false
					break
				end
			end
		end
		return status
	end

	def getDiffByModification(numberOcorrences)
		index = 0
		result = Hash.new()
		while(index < numberOcorrences.to_i)
			gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4754/script?id=#{index}"))
			file = gumTreePage.css('div.col-lg-12 h3 small').text[/(.*?) \-\>/m, 1]
			script = gumTreePage.css('div.col-lg-12 pre').text
			result[file] = script
			index += 1
		end
		return result
	end

	def getDiffByDeletedFile(numberOcorrences)
		index = 0
		result = []
		while(index < numberOcorrences.to_i)
			gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4754/"))
			gumTreePage.css('div#collapse-deleted-files table tr td').each do |element|
				result.push(element.text)
			end
			index += 1
		end
		return result
	end

	def getDiffByAddedFile(numberOcorrences)
		index = 0
		result = []
		while(index < numberOcorrences.to_i)
			gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4754/"))
			gumTreePage.css('div#collapse-added-files table tr td').each do |element|
				result.push(element.text)
			end
			index += 1
		end
		return result
	end
end