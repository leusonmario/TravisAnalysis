class CausesFilesConflicting

	def initialize()
		@causesConflict = Array.new
		@filesConflict = Array.new
	end

	def getCausesConflict()
		@causesConflict
	end

	def getFilesConflict()
		@filesConflict
	end

	def insertNewCause(cause, filesRelated)
		if (filesRelated.size > 0)
			@causesConflict.push(cause)
			@filesConflict.push(filesRelated)
		elsif (cause=="compilerError" or cause=="dependencyProblem" or cause=="remoteError" or cause=="gitProblem")
			@causesConflict.push(cause)
			@filesConflict.push(filesRelated)
		end
	end
end