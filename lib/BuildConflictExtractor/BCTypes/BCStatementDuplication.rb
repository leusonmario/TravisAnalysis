class BCStatementDuplication 

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		count = 0
		print filesConflicting[count][0]
		print filesConflicting[count][1]
		print filesConflicting[count][2]

		while(count < filesConflicting.size)
			if (filesConflicting[count][1] != "method")
				if(baseRight[0][filesConflicting[count][0]] != nil and baseRight[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
					internalCount = 0
					methodOccurence = baseRight[0][filesConflicting[count][0]].to_s.to_enum(:scan, /Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/).map { Regexp.last_match }
					while(internalCount < methodOccurence.size)
						nodeMethod = methodOccurence[count].to_s.split("(").last.gsub(')','')
						print nodeMethod
						print "\n"
						print baseLeft[0][filesConflicting[count][0]]
						if (baseRight[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[0-9\(\)]* into [a-zA-Z]*\(#{nodeMethod}\)/) and baseLeft[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}\([0-9]*\) into /))
							return true
						end
						internalCount += 1
					end
				end
				if(baseLeft[0][filesConflicting[count][0]] != nil and baseLeft[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
					internalCount = 0
					methodOccurence = baseLeft[0][filesConflicting[count][0]].to_s.to_enum(:scan, /Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/).map { Regexp.last_match }
					while(internalCount < methodOccurence.size)
						nodeMethod = methodOccurence[count].to_s.split("(").last.gsub(')','')
						print nodeMethod
						print "\n"
						if (baseLeft[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}[0-9\(\)]* into [a-zA-Z]*\(#{nodeMethod}\)/) and baseRight[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][1]}\([0-9]*\) into /))
							return true
						end
						internalCount += 1
					end
				end
			else
				if(baseLeft[0][filesConflicting[count][0]] != nil and baseLeft[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/) and baseRight[0][filesConflicting[count][0]] != nil and baseRight[0][filesConflicting[count][0]].to_s.match(/Insert SimpleName: #{filesConflicting[count][2]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
					return true
				end
			end
			count += 1
		end
		return false
	end

end

