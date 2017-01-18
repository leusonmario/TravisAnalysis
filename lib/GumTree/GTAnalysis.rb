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

	def getGumTreeAnalysis(pathProject, build, conflictCauses)
		parents = @mergeCommit.getParentsMergeIfTrue(pathProject, build.commit.sha)
		actualPath = Dir.pwd
		
		pathCopies = createCopyProject(build.commit.sha, parents, pathProject)

		Dir.chdir getGumTreePath()
		#  		   result 			left 		right 		MergeCommit 	parent1 	parent2 	problemas
		out = gumTreeDiffByBranch(pathCopies[1], pathCopies[2], pathCopies[3], pathCopies[4], conflictCauses)
		deleteProjectCopies(pathCopies)
		Dir.chdir actualPath
		return out
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
		invalidFiles = %x(find #{copyBranch[4]} -type f -regextype posix-extended -iregex '.*\.(sh|md|yaml|yml|conf|txt)$' -delete)
		invalidFiles = %x(find #{copyBranch[4]} -type f  ! -name "*.?*" -delete)
		checkout = %x(git checkout #{mergeCommit} > /dev/null 2>&1)
		clone = %x(cp -R #{pathProject} #{copyBranch[1]})
		invalidFiles = %x(find #{copyBranch[1]} -type f -regextype posix-extended -iregex '.*\.(sh|md|yaml|yml|conf|txt)$' -delete)
		invalidFiles = %x(find #{copyBranch[4]} -type f  ! -name "*.?*" -delete)
		
		index = 0
		while(index < parents.size)
			checkout = %x(git checkout #{parents[index]} > /dev/null 2>&1)
			clone = %x(cp -R #{pathProject} #{copyBranch[index+2]} > /dev/null 2>&1)
			invalidFiles = %x(find #{copyBranch[index+2]} -type f -regextype posix-extended -iregex '.*\.(sh|md|yaml|yml|conf|txt)$' -delete)
			invalidFiles = %x(find #{copyBranch[index+2]} -type f  ! -name "*.?*" -delete)
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

	def gumTreeDiffByBranch(result, left, right, base, conflictCauses)
		baseLeft = runAllDiff(base, left)
		baseRight = runAllDiff(base, right)
		leftResult = runAllDiff(left, result)
		rightResult = runAllDiff(right, result)
		return verifyModificationStatus(baseLeft, leftResult, baseRight, rightResult, conflictCauses)
	end

	def verifyModificationStatus(baseLeft, leftResult, baseRight, rightResult, conflictCauses)
		statusModified = verifyModifiedFile(baseLeft[0], leftResult[0], baseRight[0], rightResult[0])
		statusAdded = verifyAddedDeletedFile(baseLeft[1], leftResult[1], baseRight[1], rightResult[1])
		statusDeleted = verifyAddedDeletedFile(baseLeft[2], leftResult[2], baseRight[2], rightResult[2])
		
		if (statusModified and statusAdded and statusDeleted)
			#IT WAS LOVE (COMMIT WITHOUT MERGE CONFLICTS), IT WAS NOT A PERFECT ILLUSION
			indexValue = 0
			conflictCauses.getCausesConflict().each do |conflictCause|
				if(conflictCause == "unimplementedMethod")
					if (verifyBuildConflictByUnimplementedMethod(baseLeft[0], leftResult[0], baseRight[0], rightResult[0], conflictCauses.getFilesConflict()[indexValue]) == false)
						return false
					end
				elsif (conflictCause == "unavailableSymbol")
					if (verifyBuildConflictByUnavailableSymbol(baseLeft, leftResult, baseRight, rightResult, conflictCauses.getFilesConflict()[indexValue]) == false)
						return false
					end
				elsif (conflictCause == "statementDuplication")
					if (verifyBuildConflictByStatementDuplication(baseLeft, leftResult, baseRight, rightResult, conflictCauses.getFilesConflict()[indexValue]) == false)
						return false
					end
				end
				indexValue += 1
			end
			return true
		else 
			#IT WAS NOT LOVE (COMMIT WITH MERGE CONFLICTS), IT WAS A PERFECT ILLUSION
			indexValue = 0
			conflictCauses.getCausesConflict().each do |conflictCause|
				if(conflictCause == "unimplementedMethod")
					if (verifyBuildConflictByUnimplementedMethod(baseLeft[0], leftResult[0], baseRight[0], rightResult[0], conflictCauses.getFilesConflict()[indexValue]) == false)
						return false	
					end
				elsif (conflictCause == "unavailableSymbol")
					if (verifyBuildConflictByUnavailableSymbol(baseLeft, leftResult, baseRight, rightResult, conflictCauses.getFilesConflict()[indexValue]) == false)
						return false
					end
				elsif (conflictCause == "statementDuplication")
					if (verifyBuildConflictByStatementDuplication(baseLeft, leftResult, baseRight, rightResult, conflictCauses.getFilesConflict()[indexValue]) == false)
						return false
					end
				end
				indexValue += 1
			end
			return true
		end
		return false
	end

	def verifyBuildConflictByStatementDuplication(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		count = 0
		while(count < filesConflicting.size)
			if(leftResult[0][filesConflicting[count][0]] != nil and leftResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
				internalCount = 0
				methodOccurence = leftResult[0][filesConflicting[count][0]].to_s.to_enum(:scan, /Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/).map { Regexp.last_match }
				while(internalCount < methodOccurence.size)
					nodeMethod = methodOccurence[count].to_s.split("(").last.gsub(')','')
					if (!leftResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[0-9\(\)]* into [a-zA-Z]*\(#{nodeMethod}\)/))
						return false
					end
					internalCount += 1
				end
				if(rightResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: f[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
					return true
				end
			end
			if(rightResult[0][filesConflicting[count][0]] != nil and rightResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
				internalCount = 0
				methodOccurence = rightResult[0][filesConflicting[count][0]].to_s.to_enum(:scan, /Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/).map { Regexp.last_match }
				while(internalCount < methodOccurence.size)
					nodeMethod = methodOccurence[count].to_s.split("(").last.gsub(')','')
					if (!rightResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[0-9\(\)]* into [a-zA-Z]*\(#{nodeMethod}\)/))
						return false
					end
					internalCount += 1
				end
				if(leftResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: f[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
					return true
				end
			end
			count += 1
		end
	end

	def verifyBuildConflictByUnavailableSymbol (baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		count = 0
		while(count < filesConflicting.size)
			if(leftResult[0][filesConflicting[count][0]] != nil and leftResult[0][filesConflicting[count][0]].to_s.match(/Delete SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
				if (rightResult[0][filesConflicting[count][2]] != nil and rightResult[0][filesConflicting[count][2]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
					return true
				else
					baseLeft[1].each do |item|
						if (item.include?(filesConflicting[count][2].to_s))
							return true
						end
					end

					if (rightResult[0][filesConflicting[count][2]] == nil)
						return true
					end
				end
			end
			if(rightResult[0][filesConflicting[count][0]] != nil and rightResult[0][filesConflicting[count][0]].to_s.match(/Delete SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
				if(leftResult[0][filesConflicting[count][2]] != nil and leftResult[0][filesConflicting[count][2]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
					return true
				else
					rightResult[1].each do |item|
						if (item.include?(filesConflicting[count][2].to_s))
							return true
						end
					end

					if (leftResult[0][filesConflicting[count][2]] == nil)
						return true
					end
				end
			end
			count += 1
		end
		return false
	end

	def verifyBuildConflictByUnimplementedMethod(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		if(baseLeft[filesConflicting[1].to_s] != nil and baseLeft[filesConflicting[1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or baseLeft[filesConflicting[1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}/))
			if ((rightResult[filesConflicting[1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or rightResult[filesConflicting[1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}/)) and (!rightResult[filesConflicting[0].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or !rightResult[filesConflicting[0].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}/)))
				#BUILD CONFLICT DETECTED
				return true
			end
		end
		if(baseRight[filesConflicting[1].to_s] != nil and baseRight[filesConflicting[1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or baseRight[filesConflicting[1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}/))
			if ((leftResult[filesConflicting[1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or leftResult[filesConflicting[1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}/)) and (!leftResult[filesConflicting[0].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or !leftResult[filesConflicting[0].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}/)))
				#BUILD CONFLICT DETECTED"
				return true
			end
		end
		return false
	end

	def verifyAddedDeletedFile(baseLeftInitial, leftResultFinal, baseRightInitial, rightResultFinal)
		if(baseLeftInitial.size > 0) 
			baseLeftInitial.each do |fileLeft|
				if (!rightResultFinal.include?(fileLeft))
					return false
				end
			end
		end
		if (baseRightInitial.size > 0)
			baseRightInitial.each do |fileLeft|
				if (!leftResultFinal.include?(fileLeft))
					return false
				end
			end
		end
		return true
	end

	def verifyModifiedFile(baseLeftInitial, leftResultFinal, baseRightInitial, rightResultFinal)
		if(baseLeftInitial.size > 0)
			baseLeftInitial.each do |keyFile, fileLeft|
				fileRight = rightResultFinal[keyFile]
				if (fileRight == nil or fileLeft != fileRight)
					return false
				end
			end
		end
		if(baseRightInitial.size > 0) 
			baseRightInitial.each do |keyFile, fileRight|
				fileLeft = leftResultFinal[keyFile]
				if (fileLeft == nil or fileRight != fileLeft)
					return false
				end
			end
		end
		return true
	end

	def getDiffByModification(numberOcorrences)
		index = 0
		result = Hash.new()
		while(index < numberOcorrences.to_i)
			gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4754/script?id=#{index}"))
			file = gumTreePage.css('div.col-lg-12 h3 small').text[/(.*?) \-\>/m, 1].gsub(".java", "")
			script = gumTreePage.css('div.col-lg-12 pre').text
			result[file.to_s] = script.gsub('"', "\"")
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