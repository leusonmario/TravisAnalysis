class BCUnavailableSymbol

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting, basePath, leftPath, rightPath, superiorParentStatus)
		count = 0
		begin
			if(baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/(Delete|Move|Update) (SimpleName|QualifiedName): [a-zA-Z0-9\.\(\) ]*#{filesConflicting[2]}/) or verifyRemovedFileMyParent(basePath, leftPath, rightPath, filesConflicting[2]))
				if (baseLeft[0][filesConflicting[3]] != nil and baseLeft[0][filesConflicting[3]].to_s.match(/(Insert|Move) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[2]}[\s\S]*[\n\r]?/) or checkNewMethodAddition(baseLeft[1], filesConflicting[3]))
					if (filesConflicting[0] == "unavailableSymbolVariable" and filesConflicting[1] == filesConflicting[3])
						#if (verifyVariableActionsSameMethod(baseRight[0][filesConflicting[count][1]], baseRight[0][filesConflicting[count][3]], filesConflicting[count][1]))
						if (verifyVariableActionsSameMethod(baseRight[0][filesConflicting[1]], baseLeft[0][filesConflicting[1]], filesConflicting[2]))
							return true
						else
							return false
						end
					else
						return true
					end
				else
					baseLeft[1].each do |item|
						if (item.include?(filesConflicting[3].to_s)) # and baseRight[0][filesConflicting[1]] != nil)
							return true
						end
					end
					if (superiorParentStatus)
						if (baseRight[0][filesConflicting[3]] == nil)
							return true
						end
					end
				end
			end
			if(baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/(Delete|Move|Update) (SimpleName|QualifiedName): [a-zA-Z0-9\.\(\) ]*#{filesConflicting[2]}/) or verifyRemovedFileMyParent(basePath, rightPath, leftPath, filesConflicting[2]))
				if(baseRight[0][filesConflicting[3]] != nil and baseRight[0][filesConflicting[3]].to_s.match(/(Insert|Move) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[2]}[\s\S]*[\n\r]?/) or checkNewMethodAddition(baseRight[1], filesConflicting[3]))
					if (filesConflicting[0] == "unavailableSymbolVariable" and filesConflicting[1] == filesConflicting[3])
						if (verifyVariableActionsSameMethod(baseLeft[0][filesConflicting[1]], baseRight[0][filesConflicting[1]], filesConflicting[2]))
							return true
						else
							return false
						end
					else
						return true
					end
				else
					baseRight[1].each do |item|
						if (item.include?(filesConflicting[3].to_s)) # and baseLeft[0][filesConflicting[1]] != nil )
							return true
						end
					end
					if (superiorParentStatus)
						if (baseLeft[0][filesConflicting[3]] == nil)
							return true
						end
					end
				end
			end
			count += 1
		rescue
			print "PROBLEM ON GUMTREE LOG"
		end
		return false
	end

  def verifyRemovedFileMyParent(basePath, parentOnePath, parentTwoPath, fileName)
		Dir.chdir basePath
		pathFileBase = splitFileNames(%x(find -name #{fileName}.java))
		print "#{basePath} - #{pathFileBase}\n"
		Dir.chdir parentOnePath
		pathFileParentOne = splitFileNames(%x(find -name #{fileName}.java))
		print "#{parentOnePath} - #{pathFileParentOne}\n"
		Dir.chdir parentTwoPath
		pathFileParentTwo = splitFileNames(%x(find -name #{fileName}.java))
		print "#{parentTwoPath} - #{pathFileParentTwo}\n"

		pathFileBase.each do |file|
			if ((pathFileParentOne.include? file) and !(pathFileParentTwo.include? file))
				return true
			end
		end
		return false
	end

	def verifyBCDependency(pathLeft, pathRight, filesConflicting, baseLeft, baseRight, leftResult, rightResults, superiorParentStates)
		#verificando se import feito por um parent foi removido pelo outro
		begin
			if (superiorParentStates)
				if(leftResult[filesConflicting[1]] != nil and leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): #{filesConflicting[2]}[\n\r]?/) and rightResult[filesConflicting[1]] != nil and rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): #{filesConflicting[2]}[\n\r]?/))
					return false
				end
				if((baseLeft[filesConflicting[1]] != nil and baseLeft[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/)) and (rightResult[filesConflicting[1]] != nil and rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) #{filesConflicting[2]}[\n\r]?/)))
					return false
				end
				if((baseRight[filesConflicting[1]] != nil and baseRight[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/)) and (leftResult[filesConflicting[1]] != nil and leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) #{filesConflicting[2]}[\n\r]?/)))
					return false
				end
				if((leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[2]}[\n\r]?/) or rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[2]}[\n\r]?/)) and (!baseLeft[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[2]}[\n\r]?/) or !baseRight[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[2]}[\n\r]?/)))
					#if((leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil or rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil) and (baseLeft[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil or !baseRight[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil))
					return false
				end
			else
				if ((baseLeft[filesConflicting[1]] == nil and baseLeft[filesConflicting[2]] == nil and baseLeft[filesConflicting[3]] == nil) or (baseRight[filesConflicting[2]] == nil and baseRight[filesConflicting[1]] == nil and baseRight[filesConflicting[3]] == nil))
					return false
				end
			end
		rescue
			print "NO INFO FROM GUMTREE"
		end
		return false
	end

	def verifyBCDependencyMethod(pathLeft, pathRight, filesConflicting, bcMethodUpdate)
		leftPathMethods = []
		rightPathMethods = []
		leftPathMethods = bcMethodUpdate.verifyMethodAvailable(pathLeft, filesConflicting[1], filesConflicting[2])
		rightPathMethods = bcMethodUpdate.verifyMethodAvailable(pathRight, filesConflicting[1], filesConflicting[2])

		if leftPathMethods == true or rightPathMethods == true or (leftPathMethods == false and rightPathMethods == false)
			return false
		end
		return true
	end

	def verifyVariableActionsSameMethod(logOne, logTwo, variableName)
		infoLogOneRemoval = getMehtodNamesRemoval(logOne, variableName)
		infoLogOneAdition = getMehtodNamesAdition(logOne, variableName)

		infoLogTwoRemoval = getMehtodNamesRemoval(logTwo, variableName)
		infoLogTwoAdition = getMehtodNamesAdition(logTwo, variableName)

		infoLogOneAdition.each do |oneAdition|
			infoLogTwoRemoval.each do |twoRemoval|
				if oneAdition == twoRemoval
					return true
				end
			end
		end

		infoLogTwoAdition.each do |oneAdition|
			infoLogOneRemoval.each do |twoRemoval|
				if oneAdition == twoRemoval
					return true
				end
			end
		end
	end

	def getMehtodNamesRemoval(log, variable)
		infoLog = log.to_enum(:scan, /Delete SimpleName: #{variable}\([0-9]*\) on Method [a-zA-Z0-9]*/).map { Regexp.last_match }
		return getGeneralMethodNames(infoLog)
	end

	def getMehtodNamesAdition(log, variable)
		infoLog = log.to_enum(:scan, /Insert (SimpleName|QualifiedName): #{variable}\([0-9]*\) into [a-zA-Z0-9\(\)]* at [0-9]* on Method [a-zA-Z0-9]*/).map { Regexp.last_match }
		return getGeneralMethodNames(infoLog)
	end

	def getGeneralMethodNames(infoLog)
		methods = []
		infoLog.each do |oneLine|
			methodName = ""
			begin
				methodName = oneLine.to_s.match(/on Method [a-zA-Z0-9]*/).to_s.gsub("on Method ", "")
			rescue

			end
			if (methodName != "")
				methods.push(methodName)
			end
		end
		return methods
	end

  def splitFileNames(filePaths)
		files = Array.new
		filePaths.each_line do |line|
			files.push(line)
		end
		return files
	end

	def checkNewMethodAddition(listAddedFiles, file)
		begin
			listAddedFiles.each do |oneFile|
				if (oneFile.include? file)
					return true
				end
			end
			return false
		rescue
			return false
		end
	end

end