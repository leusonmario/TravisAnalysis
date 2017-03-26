class BCStatementDuplication 

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
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
				if(rightResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
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
				if(leftResult[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
					return true
				end
			end
			count += 1
		end
	end

end

