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
		@causesConflict.push(cause)
		@filesConflict.push(filesRelated)
	end
end