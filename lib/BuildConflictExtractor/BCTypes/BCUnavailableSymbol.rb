class BCUnavailableSymbol

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting, leftPath, rightPath)
		count = 0
		while(count < filesConflicting.size)
			if(leftResult[0][filesConflicting[count][0]] != nil and leftResult[0][filesConflicting[count][0]].to_s.match(/Delete SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?|Update SimpleName: #{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
				if (rightResult[0][filesConflicting[count][2]] != nil and rightResult[0][filesConflicting[count][2]].to_s.match(/Insert (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
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
				if(leftResult[0][filesConflicting[count][2]] != nil and leftResult[0][filesConflicting[count][2]].to_s.match(/Insert (SimpleName|QualifiedName): [a-zA-Z\.]*?#{filesConflicting[count][1]}[\s\S]*[\n\r]?/))
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
			Dir.chdir leftPath
			pathFileLeft = %x(find -name #{filesConflicting[count][1]+".java"})
			Dir.chdir rightPath
			pathFileRight = %x(find -name #{filesConflicting[count][1]+".java"})
			if (pathFileLeft != pathFileRight)
				return true
			end
			count += 1
		end
		return false
	end

end