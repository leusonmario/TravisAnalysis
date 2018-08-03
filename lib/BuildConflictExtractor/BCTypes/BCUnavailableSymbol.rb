class BCUnavailableSymbol

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting, basePath, leftPath, rightPath)
		count = 0
    begin
			if(baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/(Delete|Move|Update) (SimpleName|QualifiedName): [a-zA-Z0-9\.\(\)]*#{filesConflicting[2]}/))
				if (baseLeft[0][filesConflicting[3]] != nil and baseLeft[0][filesConflicting[3]].to_s.match(/(Insert|Move) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[2]}[\s\S]*[\n\r]?/))
					if (filesConflicting[0] == "unavailableSymbolVariable" and filesConflicting[1] == filesConflicting[3])
						#if (verifyVariableActionsSameMethod(baseRight[0][filesConflicting[count][1]], baseRight[0][filesConflicting[count][3]], filesConflicting[count][1]))
						if (verifyVariableActionsSameMethod(baseRight[0][filesConflicting[1]], baseLeft[0][filesConflicting[1]], filesConflicting[2]))
							return true
						else
							return false
						end
					#	return true
					else
						return true
					end
				else
					baseLeft[1].each do |item|
						if (item.include?(filesConflicting[3].to_s)) # and baseRight[0][filesConflicting[1]] != nil)
							return true
						end
					end

#					if (baseRight[0][filesConflicting[3]] == nil)
#						return true
#					end
				end
			end
			if(baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/(Delete|Move|Update) (SimpleName|QualifiedName): [a-zA-Z0-9\.\(\)]*#{filesConflicting[2]}/))
				if(baseRight[0][filesConflicting[3]] != nil and baseRight[0][filesConflicting[3]].to_s.match(/(Insert|Move) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[2]}[\s\S]*[\n\r]?/))
					if (filesConflicting[0] == "unavailableSymbolVariable" and filesConflicting[1] == filesConflicting[3])
						if (verifyVariableActionsSameMethod(baseLeft[0][filesConflicting[1]], baseRight[0][filesConflicting[1]], filesConflicting[2]))
							return true
						else
							return false
						end
						#	return true
					else
						return true
					end
				else
					baseRight[1].each do |item|
						if (item.include?(filesConflicting[3].to_s)) # and baseLeft[0][filesConflicting[1]] != nil )
							return true
						end
					end

#					if (baseLeft[0][filesConflicting[3]] == nil)
#						return true
#					end
				end
			end
			Dir.chdir basePath
			pathFileBase = %x(find -name #{filesConflicting[2]}.java)
			print "#{basePath} - #{pathFileBase}\n"
			Dir.chdir leftPath
			pathFileLeft = %x(find -name #{filesConflicting[2]}.java})
			print "#{leftPath} - #{pathFileLeft}\n"
			Dir.chdir rightPath
			pathFileRight = %x(find -name #{filesConflicting[2]}.java})
			print "#{rightPath} - #{pathFileRight}\n"
			if (pathFileBase != "" and (pathFileLeft != "" or pathFileRight != "") and pathFileLeft != pathFileRight)
				return true
			end
			count += 1
    rescue
      print "PROBLEM ON GUMTREE LOG"
    end
		return false
	end

	def verifyBCDependency(pathLeft, pathRight, filesConflicting, baseLeft, baseRight, leftResult, rightResult)
		#verificando se import feito por um parent foi removido pelo outro
		begin
				if ((baseLeft[filesConflicting[1]] == nil and baseLeft[filesConflicting[2]] == nil and baseLeft[filesConflicting[3]] == nil) or (baseRight[filesConflicting[2]] == nil and baseRight[filesConflicting[1]] == nil and baseRight[filesConflicting[3]] == nil))
					return false
				end
=begin
				if(leftResult[filesConflicting[1]] != nil and leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): #{filesConflicting[2]}[\n\r]?/) != nil and rightResult[filesConflicting[1]] != nil and rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): #{filesConflicting[2]}[\n\r]?/) != nil)
					return true
				end
				if((baseLeft[filesConflicting[1]] != nil and baseLeft[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil) and (rightResult[filesConflicting[1]] != nil and rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) #{filesConflicting[2]}[\n\r]?/)) != nil)
					return true
				end
				if((baseRight[filesConflicting[1]] != nil and baseRight[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil) and (leftResult[filesConflicting[1]] != nil and leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) #{filesConflicting[2]}[\n\r]?/)) != nil)
					return true
				end
				if((leftResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil or rightResult[filesConflicting[1]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil) and (baseLeft[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil or !baseRight[filesConflicting[1]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) #{filesConflicting[2]}[\n\r]?/) != nil))
					return true
				end
=end
		rescue
			print "NO INFO FROM GUMTREE"
		end

			Dir.chdir pathLeft
			pathFileLeft = %x(find -name #{filesConflicting[2]}.java)
			Dir.chdir pathRight
			pathFileRight = %x(find -name #{filesConflicting[2]}.java})
			if ((pathFileLeft != "" or pathFileRight != "") and (pathLeft != pathRight))
				#if (pathFileLeft == "" or pathFileRight == "")
				#return true
				return true
			end
		return false
	end

	def verifyBCDependencyMethod(pathLeft, pathRight, filesConflicting, bcMethodUpdate)
			leftPathMethods = []
			rightPathMethods = []
			leftPathMethods = bcMethodUpdate.verifyMethodAvailable(pathLeft, filesConflicting[1], filesConflicting[2])
			rightPathMethods = bcMethodUpdate.verifyMethodAvailable(pathRight, filesConflicting[1], filesConflicting[2])

			if (leftPathMethods == true or rightPathMethods == true)
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

end