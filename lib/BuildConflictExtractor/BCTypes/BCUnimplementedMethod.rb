class BCUnimplementedMethod

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		#begin
				if(baseLeft[0][filesConflicting[2]] != nil and baseLeft[0][filesConflicting[2].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[3].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or baseLeft[0][filesConflicting[2].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/) or baseLeft[0][filesConflicting[2].to_s].to_s.match(/Insert (SimpleName|Modifier): abstract[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]* on Method #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/))
					if ((rightResult[0][filesConflicting[2]].to_s.match(/Insert SimpleName: #{filesConflicting[3].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or rightResult[0][filesConflicting[2].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/)) and ((rightResult[0][filesConflicting[1].to_s].to_s.match(/Insert SimpleType: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[0-9\(\)]* into TypeDeclaration[0-9\(\)]*/)) and (!rightResult[0][filesConflicting[1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or !rightResult[0][filesConflicting[1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/))) or checkIfFileIsNew(baseRight[1], filesConflicting[1]))
						#BUILD CONFLICT DETECTED
						return true
					end
				end
				if(baseRight[0][filesConflicting[2]] != nil and baseRight[0][filesConflicting[2]].to_s.match(/Insert SimpleName: #{filesConflicting[3].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or baseRight[0][filesConflicting[2].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/) or baseRight[0][filesConflicting[2].to_s].to_s.match(/Insert (SimpleName|Modifier): abstract[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]* on Method #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/))
					if ((leftResult[0][filesConflicting[2]].to_s.match(/Insert SimpleName: #{filesConflicting[3].to_s.gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or leftResult[0][filesConflicting[2].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/)) and ((leftResult[0][filesConflicting[1].to_s].to_s.match(/Insert SimpleType: #{filesConflicting[2].gsub(/\(.*/, '').gsub('(', '')}[0-9\(\)]* into TypeDeclaration[0-9\(\)]*/)) and (!leftResult[0][filesConflicting[1].to_s].to_s.match(/Insert SimpleName: #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}[\(\)0-9]* into MethodDeclaration[\(\)0-9]* at [0-9]*/) or !leftResult[0][filesConflicting[1].to_s].to_s.match(/Update SimpleName: [\s\S]* to #{filesConflicting[3].gsub(/\(.*/, '').gsub('(', '')}/))) or checkIfFileIsNew(baseLeft[1], filesConflicting[1]))
						#BUILD CONFLICT DETECTED"
						return true
					end
				end
		#rescue
			print "NOT VALID VALUES #{filesConflicting}"
		#end
		return false
	end

	private

	def checkIfFileIsNew(files, possibleFileName)
		files.each do |file|
			if (file.to_s.include? possibleFileName)
				return true
			end
		end
		return false
	end

end

