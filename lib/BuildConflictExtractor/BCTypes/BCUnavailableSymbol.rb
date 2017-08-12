class BCUnavailableSymbol

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting, leftPath, rightPath)
		count = 0
		while(count < filesConflicting.size)
			if(baseRight[0][filesConflicting[count][0]] != nil and baseRight[0][filesConflicting[count][0]].to_s.match(/Delete SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
				if (baseLeft[0][filesConflicting[count][2]] != nil and baseLeft[0][filesConflicting[count][2]].to_s.match(/Insert (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
					return true
				else
					baseRight[1].each do |item|
						if (item.include?(filesConflicting[count][2].to_s))
							return true
						end
					end

					if (baseLeft[0][filesConflicting[count][2]] == nil)
						return true
					end
				end
			end
			if(baseLeft[0][filesConflicting[count][0]] != nil and baseLeft[0][filesConflicting[count][0]].to_s.match(/Delete SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
				if(baseRight[0][filesConflicting[count][2]] != nil and baseRight[0][filesConflicting[count][2]].to_s.match(/Insert (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
					return true
				else
					baseLeft[1].each do |item|
						if (item.include?(filesConflicting[count][2].to_s))
							return true
						end
					end

					if (baseRight[0][filesConflicting[count][2]] == nil)
						return true
					end
				end
			end
			Dir.chdir leftPath
			pathFileLeft = %x(find -name #{filesConflicting[count][1]}.java})
			Dir.chdir rightPath
			pathFileRight = %x(find -name #{filesConflicting[count][1]}.java})
			if (pathFileLeft != "" and pathFileRight != "" and pathFileLeft != pathFileRight and filesConflicting[0].size > 1)
				return true
			end
			count += 1
		end
		return false
	end

  def verifyBCDependency(pathLeft, pathRight, filesConflicting, baseLeft, baseRight, leftResult, rightResult)
		count = 0
		begin
			while(count < filesConflicting.size)
				if(leftResult[filesConflicting[count][0]] != nil and leftResult[filesConflicting[count][0]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][1]}[\n\r]?/) and rightResult[filesConflicting[count][0]] != nil and rightResult[filesConflicting[count][0]].to_s.match(/(Delete|Update) (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][1]}[\n\r]?/))
					return false
				end
				if((baseLeft[filesConflicting[count][0]] != nil and baseLeft[filesConflicting[count][0]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][1]}[\n\r]?/)) and (rightResult[filesConflicting[count][0]] == nil or !rightResult[filesConflicting[count][0]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][1]}[\n\r]?/)))
					return false
				end
				if((baseRight[filesConflicting[count][0]] != nil and baseRight[filesConflicting[count][0]].to_s.match(/(Insert|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][1]}[\n\r]?/)) and (leftResult[filesConflicting[count][0]] == nil or !leftResult[filesConflicting[count][0]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][1]}[\n\r]?/)))
					return false
				end
				if(leftResult[filesConflicting[count][0]].to_s.match(/(Delete|Update) (ImportDeclaration\([0-9]*\)|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][1]}[\n\r]?/) or rightResult[filesConflicting[count][0]].to_s.match(/(Delete|Update) (ImportDeclaration|QualifiedName:) [a-zA-Z0-9\.]*#{filesConflicting[count][1]}[\n\r]?/))
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
			pathFileLeft = %x(find -name #{filesConflicting[count][1]}.java)
			Dir.chdir pathRight
			pathFileRight = %x(find -name #{filesConflicting[count][1]}.java})
			if (pathFileLeft == "" or pathFileRight == "")
				return true
			end
			count += 1
		end
		return false
	end

	def verifyBCDependencyMethod(pathLeft, pathRight, filesConflicting, bcMethodUpdate)
		count = 0
		while (count < filesConflicting.size)
			leftPathMethods = []
			rightPathMethods = []
			leftPathMethods = bcMethodUpdate.verifyMethodAvailable(pathLeft, filesConflicting[0][2], filesConflicting[0][1])
			rightPathMethods = bcMethodUpdate.verifyMethodAvailable(pathRight, filesConflicting[0][2], filesConflicting[0][1])

			if (leftPathMethods == true or rightPathMethods == true)
				return false
			end
			count += 1
		end
		return true
	end

end