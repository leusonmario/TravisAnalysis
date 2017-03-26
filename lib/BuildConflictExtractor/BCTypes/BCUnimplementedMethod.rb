class BCUnimplementedMethod

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		count = 0
		while (count < filesConflicting.size)
			if(baseLeft[filesConflicting[count][1]] != nil and baseLeft[filesConflicting[count][1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[count][2].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or baseLeft[filesConflicting[count][1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}/))
				if ((rightResult[filesConflicting[count][1]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or rightResult[filesConflicting[count][1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}/)) and (rightResult[filesConflicting[count][0].to_s].to_s.match(/Insert SimpleType: #{filesConflicting[count][1].gsub(/\(.*/, '').gsub('(', '')}[0-9\(\)]* into TypeDeclaration[0-9\(\)]*/)) and (!rightResult[filesConflicting[count][0].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or !rightResult[filesConflicting[count][0].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}/)))
					#BUILD CONFLICT DETECTED
					return true
				end
			end
			if(baseRight[filesConflicting[count][1]] != nil and baseRight[filesConflicting[count][1]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or baseRight[filesConflicting[count][1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}/))
				if ((leftResult[filesConflicting[count][1]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or leftResult[filesConflicting[count][1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}/)) and (leftResult[filesConflicting[count][0].to_s].to_s.match(/Insert SimpleType: #{filesConflicting[count][1].gsub(/\(.*/, '').gsub('(', '')}[0-9\(\)]* into TypeDeclaration[0-9\(\)]*/)) and (!leftResult[filesConflicting[count][0].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or !leftResult[filesConflicting[count][0].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[count][2].gsub(/\(.*/, '').gsub('(', '')}/)))
					#BUILD CONFLICT DETECTED"
					return true
				end
			end
			count += 1
		end
		return false
	end

end

