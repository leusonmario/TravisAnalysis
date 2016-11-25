#!/usr/bin/env ruby
#file: GTAnalysis.rb

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
		diffGT(pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4], parents[0], parents[1], fileConflict)
		deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
	end

#  			     result 	left 		right 		MergeCommit   parent1 	 parent2 	  problemas
	def diffGT(baseBranch, leftBranch, rightBranch, baseCommit, leftCommit, rightCommit, fileConflict)
		baseFiles = getAllFiles(baseBranch)
		leftFiles = getFilesConflicts(baseBranch, leftBranch, baseCommit, leftCommit)
		rightFiles = getFilesConflicts(baseBranch, rightBranch, baseCommit, rightCommit)
		
		baseDiff = ""
		rightDiff = ""
		leftDiffGT = nil
		rightDiffGT = nil

		leftFiles.each do |leftFile|
			fileName = leftFile.match(/[A-Za-z]+\.java/)[0].to_s
			baseFiles.each do |baseFile|
				if (baseFile[/\/+[a-zA-Z]*\.java/] == leftFile[/\/+[a-zA-Z]*\.java/])
					baseDiff = baseFile
					break
				end
			end
			rightFiles.each do |rightFile|
				if (rightFile[/\/+[a-zA-Z]*\.java/] == leftFile[/\/+[a-zA-Z]*\.java/])
					rightDiff = rightFile
					rightFiles.delete(rightFile)
					break
				end
			end

			if (baseDiff != "")
				leftDiffGT = runGTDiff(baseDiff, leftFile)
			end
			if (rightDiff != "")
				rightDiffGT = runGTDiff(baseDiff, rightDiff)
			end
			
			if(leftDiffGT != nil and rightDiffGT != nil)
				diffAnalysisGT(leftDiffGT, rightDiffGT, fileConflict)
			end
				
			leftDiff = ""
			rightDiff = ""
			leftDiffGT = nil
			rightDiffGT = nil
		end
		if(rightFiles.size > 0)
			baseDiff = ""
			leftDiff = ""
			leftDiffGT = nil
			rightDiffGT = nil

			rightFiles.each do |rightFile|
				fileName = rightFile.match(/[A-Za-z]+\.java/)[0].to_s
				baseFiles.each do |baseFile|
					if (baseFile[/\/+[a-zA-Z]*\.java/] == rightFile[/\/+[a-zA-Z]*\.java/])
						baseDiff = baseFile
						break
					end
				end
				leftFiles.each do |leftFile|
					if (rightFile[/\/+[a-zA-Z]*\.java/] == leftFile[/\/+[a-zA-Z]*\.java/])
						leftDiff = leftFile
						break
					end
				end

				if (baseDiff != "")
					rightDiffGT = runGTDiff(baseDiff, rightFile)
				end
				if (leftDiff != "")
					leftDiffGT = runGTDiff(baseDiff, leftDiff)
				end
				
				if(leftDiffGT != nil and rightDiffGT != nil)
					diffAnalysisGT(leftDiffGT, rightDiffGT, fileConflict)
				end
					
				leftDiff = ""
				rightDiff = ""
				leftDiffGT = nil
				rightDiffGT = nil
			end
		end
	end

	def runGTDiff(baseFile, branchFile)
		Dir.chdir @gumTreePath
		diff = nil
		begin
			diff = %x(./gumtree diff #{branchFile.gsub("\n","")} #{baseFile.gsub("\n","")})
		rescue Exception => e
			puts "NOT FOUND PROJECT"
		end
		return diff
	end

	def getAllFiles(pathFiles)
		pathAllFiles = []
		Find.find(pathFiles) do |path|
	  		pathAllFiles << path if path =~ /.*\.java$/
	  	end
		pathAllFiles.sort_by!{ |e| e.downcase }
		
		return pathAllFiles
	end

#  						     result 	left 	MergeCommit   parent
	def getFilesConflicts(baseFiles, pathFiles, baseCommit, branchCommit)
		Dir.chdir pathFiles
		Dir.chdir "localProject"
		pathAllFiles = []
		files = %x(git diff --name-only #{baseCommit.gsub("\n","")} #{branchCommit.gsub("\n","")})

		files.each_line do |file|
			pathAllFiles.push(Dir.pwd+"/"+file)
		end
		
		return pathAllFiles
	end

	def createDirectories(pathProject)
		copyBranch = []
		Dir.chdir pathProject
		Dir.chdir ".."
		FileUtils::mkdir_p 'Copies/Result'
		FileUtils::mkdir_p 'Copies/Left'
		FileUtils::mkdir_p 'Copies/Right'		
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
		return copyBranch
	end
	
	def createCopyProject(mergeCommit, parents, pathProject)
		copyBranch = createDirectories(pathProject)
		Dir.chdir pathProject
		checkout = %x(git checkout master)
		#base = %x(git merge-base --all #{parents[0]} #{parents[1]})
		checkout = %x(git checkout #{mergeCommit})
		clone = %x(cp -R #{pathProject} #{copyBranch[1]})

		index = 0
		while(index < parents.size)
			checkout = %x(git checkout #{parents[index]})
			clone = %x(cp -R #{pathProject} #{copyBranch[index+2]})
			checkout = %x(git checkout master)
			index += 1
		end

		return copyBranch[0], copyBranch[1], copyBranch[2], copyBranch[3], mergeCommit
		#      copies         result 			left 		right 			mergeCommit
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

end