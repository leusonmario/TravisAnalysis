class BCUnavailableSymbol

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting, leftPath, rightPath)
		count = 0
		while(count < filesConflicting.size)
			if(baseRight[0][filesConflicting[count][1]] != nil and baseRight[0][filesConflicting[count][1]].to_s.match(/Delete SimpleName: #{filesConflicting[count][2]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
				if (baseLeft[0][filesConflicting[count][3]] != nil and baseLeft[0][filesConflicting[count][3]].to_s.match(/Insert (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][2]}[\s\S]*[\n\r]?/))
					if (filesConflicting[count][0] == "unavailableSymbolVariable" and filesConflicting[count][1] == filesConflicting[count][3])
						return true #verifyVariableActionsSameMethod(baseRight[0][filesConflicting[count][1]], baseRight[0][filesConflicting[count][3]])
					else
						return true
					end
				else
					baseRight[1].each do |item|
						if (item.include?(filesConflicting[count][3].to_s))
							return true
						end
					end

					if (baseLeft[0][filesConflicting[count][3]] == nil)
						return true
					end
				end
			end
			if(baseLeft[0][filesConflicting[count][1]] != nil and baseLeft[0][filesConflicting[count][1]].to_s.match(/Delete SimpleName: #{filesConflicting[count][2]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][2]}[\s\S]*[\n\r]?/))
				if(baseRight[0][filesConflicting[count][3]] != nil and baseRight[0][filesConflicting[count][3]].to_s.match(/Insert (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][2]}[\s\S]*[\n\r]?/))
					return true
				else
					baseLeft[1].each do |item|
						if (item.include?(filesConflicting[count][3].to_s))
							return true
						end
					end

					if (baseRight[0][filesConflicting[count][3]] == nil)
						return true
					end
				end
			end
			Dir.chdir leftPath
			pathFileLeft = %x(find -name #{filesConflicting[count][2]}.java})
			Dir.chdir rightPath
			pathFileRight = %x(find -name #{filesConflicting[count][2]}.java})
			if (pathFileLeft != "" and pathFileRight != "" and pathFileLeft != pathFileRight and filesConflicting[0].size > 1)
				return true
			end
			count += 1
		end
		return false
	end

	def verifyBCDependency(pathLeft, pathRight, filesConflicting, baseLeft, baseRight, leftResult, rightResult)
		#verificando se import feito por um parent foi removido pelo outro
		count = 0
		begin
			while(count < filesConflicting.size)
				if(leftResult[filesConflicting[count][1]] != nil and leftResult[filesConflicting[count][1]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][2]}[\n\r]?/) and rightResult[filesConflicting[count][1]] != nil and rightResult[filesConflicting[count][1]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][2]}[\n\r]?/))
					return false
				end
				if((baseLeft[filesConflicting[count][1]] != nil and baseLeft[filesConflicting[count][1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/)) and (rightResult[filesConflicting[count][1]] != nil and rightResult[filesConflicting[count][1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/)))
					return false
				end
				if((baseRight[filesConflicting[count][1]] != nil and baseRight[filesConflicting[count][1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/)) and (leftResult[filesConflicting[count][1]] != nil and leftResult[filesConflicting[count][1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/)))
					return false
				end
				if((leftResult[filesConflicting[count][1]].to_s.match(/(Delete|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/) or rightResult[filesConflicting[count][1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/)) and (!baseLeft[filesConflicting[count][1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/) or !baseRight[filesConflicting[count][1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][2]}[\n\r]?/)))
					return false
				end
				count += 1
			end
		rescue
			print "NO INFO FROM GUMTREE"
		end

		count = 0
		while(count < filesConflicting.size)
			Dir.chdir pathLeft
			pathFileLeft = %x(find -name #{filesConflicting[count][2]}.java)
			Dir.chdir pathRight
			pathFileRight = %x(find -name #{filesConflicting[count][2]}.java})
			if (pathFileLeft != "" or pathFileRight != "")
				#if (pathFileLeft == "" or pathFileRight == "")
				#return true
				return false
			end
			count += 1
		end
		return true
	end

	def verifyBCDependencyMethod(pathLeft, pathRight, filesConflicting, bcMethodUpdate)
		count = 0
		while (count < filesConflicting.size)
			leftPathMethods = []
			rightPathMethods = []
			leftPathMethods = bcMethodUpdate.verifyMethodAvailable(pathLeft, filesConflicting[0][3], filesConflicting[0][2])
			rightPathMethods = bcMethodUpdate.verifyMethodAvailable(pathRight, filesConflicting[0][3], filesConflicting[0][2])

			if (leftPathMethods == true or rightPathMethods == true)
				return false
			end
			count += 1
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
			methods.push(oneLine.to_s.match(/on Method [a-zA-Z0-9]*/).gsub("on Method ", ""))
		end
		return methods
	end

end