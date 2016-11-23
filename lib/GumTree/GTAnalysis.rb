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
		
		pathCopies = createCopyProject(parents, pathProject)

		Dir.chdir getGumTreePath()
		diffGT(pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4], parents[0], parents[1])
		deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
	end

	def diffGT(baseBranch, leftBranch, rightBranch, baseCommit, leftCommit, rightCommit)
		baseFiles = getAllFiles(baseBranch)
		leftFiles = getFilesConflicts(baseBranch, leftBranch, baseCommit, leftCommit)
		rightFiles = getFilesConflicts(baseBranch, rightBranch, baseCommit, rightCommit)
		
		leftDiff = ""
		rigthDiff = ""

		baseFiles.each do |baseFile|
			leftFiles.each do |leftFile|
				if (baseFile[/\/+[a-zA-Z]*\.java/] == leftFile[/\/+[a-zA-Z]*\.java/])
					leftDiff = leftFile
					break
				end
			end
			rightFiles.each do |rigthFile|
				if (baseFile[/\/+[a-zA-Z]*\.java/] == rigthFile[/\/+[a-zA-Z]*\.java/])
					rigthDiff = rigthFile
					break
				end
			end

			if (leftDiff != "")
				leftDiffGT = runGTDiff(baseFile, leftDiff)
			end
			if (rigthDiff != "")
				rigthDiffGT = runGTDiff(baseFile, rigthDiff)
			end
			#Aqui fazer chamada para verificacao do erro
			leftDiff = ""
			rigthDiff = ""
		end
	end

	def runGTDiff(baseFile, branchFile)
		Dir.chdir @gumTreePath
		diff = %x(./gumtree diff #{baseFile} #{branchFile})
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
		FileUtils::mkdir_p 'Copies/Base'
		FileUtils::mkdir_p 'Copies/Left'
		FileUtils::mkdir_p 'Copies/Right'		
		Dir.chdir "Copies"
		copyBranch.push(Dir.pwd)
		Dir.chdir "Base"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Left"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Right"
		copyBranch.push(Dir.pwd)
		return copyBranch
	end
	
	def createCopyProject(parents, pathProject)
		copyBranch = createDirectories(pathProject)
		Dir.chdir pathProject
		checkout = %x(git checkout master)
		base = %x(git merge-base --all #{parents[0]} #{parents[1]})
		checkout = %x(git checkout #{base})
		clone = %x(cp -R #{pathProject} #{copyBranch[1]})

		index = 0
		while(index < parents.size)
			checkout = %x(git checkout #{parents[index]})
			clone = %x(cp -R #{pathProject} #{copyBranch[index+2]})
			checkout = %x(git checkout master)
			index += 1
		end

		return copyBranch[0], copyBranch[1], copyBranch[2], copyBranch[3], base
	end

	def deleteProjectCopies(pathCopies)
		index = 0
		while(index < pathCopies.size)
			delete = %x(rm -rf #{pathCopies[index]})	
			index += 1
		end
	end

	def diffAnalysisGT(gumLeft, gumRigth)
		if(gumLeft[/(Delete)\s([a-zA-Z]*)[\:]?[\s]?#{nome}/])
			puts "Variable deleted on LOG1"
		elsif (gumRigth[/(Delete)\s([a-zA-Z]*)[\:]?[\s]?#{nome}/])
			puts "Variable deleted on LOG2"
		end
	end

end