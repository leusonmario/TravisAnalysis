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