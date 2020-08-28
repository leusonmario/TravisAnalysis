class BCStatementDuplication 

	def initialize()

	end

	def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
		count = 0

		#while(count < filesConflicting.size)
		#	begin
				if (filesConflicting[2] != "method")
					if(baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/Insert SimpleName: #{filesConflicting[2]}[0-9\(\)]* into [a-zA-Z\:\= 0-9\(\)]* on Method #{filesConflicting[3]}/))
						if (baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/Insert SimpleName: #{filesConflicting[2]}[0-9\(\)]* into [a-zA-Z\:\= 0-9\(\)]* on Method #{filesConflicting[3]}/))
							return true
						end
					end
					if(baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/Insert SimpleName: #{filesConflicting[2]}[0-9\(\)]* into [a-zA-Z\:\= 0-9\(\)]* on Method #{filesConflicting[3]}/))
						if (baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/Insert SimpleName: #{filesConflicting[2]}[0-9\(\)]* into [a-zA-Z\:\= 0-9\(\)]* on Method #{filesConflicting[3]}/))
							return true
						end
					end
				else
					begin
						if(baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/Insert SimpleName: #{filesConflicting[3]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/) and baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/Insert SimpleName: #{filesConflicting[3]}[0-9\(\)]* into [a-zA-Z]*[0-9\(\)]*/))
							return true
						end
					rescue
						print "EMPTY INFO FROM GUMTREE"
					end
				end
		#	rescue

		#	end
		#	count += 1
		#end
		return false
	end

end

