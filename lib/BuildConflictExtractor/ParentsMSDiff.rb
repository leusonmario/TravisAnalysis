require 'open-uri'
require 'rest-client'
require 'net/http'
require 'json'
require 'uri'

class ParentsMSDiff

	def initialize(gumTreePath)
		@gumTreePath = gumTreePath
	end

	def getGumTreePath()
		@gumTreePath
	end

	def runAllDiff(firstBranch, secondBranch)
		Dir.chdir getGumTreePath()
		mainDiff = nil
		modifiedFilesDiff = []
		addedFiles = []
		deletedFiles = []
		begin
			kill = %x(pkill -f gumtree)
			sleep(5)
			thr = Thread.new { diff = system "bash", "-c", "exec -a gumtree ./gumtree webdiff #{firstBranch.gsub("\n","")} #{secondBranch.gsub("\n","")}" }
			sleep(10)
			mainDiff = %x(wget http://127.0.0.1:4567/ -q -O -)
			modifiedFilesDiff = getDiffByModification(mainDiff[/Modified files <span class="badge">(.*?)<\/span>/m, 1])
			addedFiles = getDiffByAddedFile(mainDiff[/Added files <span class="badge">(.*?)<\/span>/m, 1])
			deletedFiles = getDiffByDeletedFile(mainDiff[/Deleted files <span class="badge">(.*?)<\/span>/m, 1])
			
			kill = %x(pkill -f gumtree)
			sleep(5)
		rescue Exception => e
			puts "GumTree Failed"
		end
		return modifiedFilesDiff, addedFiles, deletedFiles
	end

	def runOnlyModifiedAddFiles(modifiedFiles, firstBranch, secondBranch)
		#Dir.chdir getGumTreePath()
		#mainDiff = nil
		#modifiedFilesDiff = []
		#addedFiles = []
		#deletedFiles = []
		addedFiles = nil
		modifiedMethodsByFile = Hash.new
		begin
			#kill = %x(pkill -f gumtree)
			#sleep(5)
			#thr = Thread.new { diff = system "bash", "-c", "exec -a gumtree ./gumtree webdiff #{firstBranch.gsub("\n","")} #{secondBranch.gsub("\n","")}" }
			#sleep(10)
			#mainDiff = %x(wget http://127.0.0.1:4754/ -q -O -)
			#modifiedFilesDiff = getDiffByModification(mainDiff[/Modified files \((.*?)\)/m, 1])
			modifiedMethodsByFile = getDiffByModificationAndMethods(modifiedFiles, firstBranch, secondBranch)
			#addedFiles = getDiffByAddedFile(mainDiff[/Added files \((.*?)\)/m, 1])
			#kill = %x(pkill -f gumtree)
			#sleep(5)
		rescue Exception => e
			puts "GumTree Failed"
		end
		return modifiedMethodsByFile, addedFiles
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
			gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4567/script/#{index}"))
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
			begin
				gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4567/"))
				tableDeleted = gumTreePage.to_s.match(/Deleted files[\s\S]*Added files/)[0].match(/<table [\s\S]*<\/table>/)
				Nokogiri::HTML(tableDeleted[0]).css('table tr td').each do |element|
					result.push(element.text)
				end
			rescue

			end
			index += 1
		end
		return result
	end

	def getDiffByAddedFile(numberOcorrences)
		index = 0
		result = []
		while(index < numberOcorrences.to_i)
			gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4567/"))
			tableDeleted = gumTreePage.to_s.match(/Added files[\s\S]*<\/table>/)[0].match(/<table [\s\S]*<\/table>/)
			Nokogiri::HTML(tableDeleted[0]).css('table tr td').each do |element|
				result.push(element.text)
			end
			index += 1
		end
		return result
	end


	def getDiffByModificationAndMethods(modifiedFiles, pathBranchOne, pathBranchTwo)
		changedMethods = Hash.new
		modifiedFiles.each do |key, value|
		 	#changedMethods[key]	= methodsModifiedOnFile(getParsedFile(pathBranchOne, key), getParsedFile(pathBranchTwo, key))
			changedMethods[key]	= methodsModifiedByFile(value)
		end
		return changedMethods
	end

	def methodsModifiedByFile(fileDiff)
		methodNames = Array.new
		information = fileDiff.to_enum(:scan, /on Method [a-zA-Z0-9\-]*/).map { Regexp.last_match }
		count = 0
		while (count < information.size)
			methodName = information[count].to_s.split("on Method ").last
			print methodName
			if (!methodNames.include? methodName)
				methodNames.push(methodName)
			end
			count += 1
		end
		return methodNames
	end

	def methodsModifiedOnFile(parsedFileOne, parsedFileTwo)
		modifiedMethods = []
		parsedFileOne["root"]["children"].each do |child|
			child["children"].each do |newChild|
				if (newChild["typeLabel"] == "MethodDeclaration")
					newChild["children"].each do |methodDeclaration|
						if (methodDeclaration['typeLabel'] == "SimpleName")
							nameMethod = methodDeclaration['label']
							childMod = newChild.to_s.gsub(/\"pos\"\=\>\"[0-9]*\"\,/, "")

							parsedFileTwo["root"]["children"].each do |childTwo|
								childTwo["children"].each do |newChildTwo|
									if (newChildTwo["typeLabel"] == "MethodDeclaration")
										newChildTwo["children"].each do |methodDeclarationTwo|
											if (methodDeclarationTwo['typeLabel'] == "SimpleName" and methodDeclarationTwo['label'] == nameMethod)
												childTwoMod = newChildTwo.to_s.gsub(/\"pos\"\=\>\"[0-9]*\"\,/, "")
												if (childMod != childTwoMod)
													modifiedMethods.push(nameMethod)
													break
												end
											end
										end
									end
								end
								#modifiedMethods.push(nameMethod)
							end

						end
					end
				end
			end
		end
		return modifiedMethods
	end

	def getParsedFile(pathBranch, fileName)
		actualPath = Dir.pwd

		stringJson = ""
		begin
			Dir.chdir pathBranch
			pathFileOne = %x(find -name #{fileName}.java)
			pathFileOneComplete = %x(readlink -f #{pathFileOne})

			Dir.chdir @gumTreePath
			data = %x(./gumtree parse #{pathFileOneComplete})
			sleep 8
			stringJson = JSON.parse(data)
			Dir.chdir actualPath
		rescue

		end
		return stringJson
	end

end