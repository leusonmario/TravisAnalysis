class CausesFilesConflicting

	def initialize()
		@causesFilesInfoConflicts = Hash.new
	end

  def getCausesFilesInfoConflicts()
		@causesFilesInfoConflicts
	end

	def getCausesConflict()
		@causesFilesInfoConflicts.keys
	end

	def getFilesConflict()
		@causesFilesInfoConflicts.values
	end

	def getCausesNumber()
		return @causesFilesInfoConflicts.keys.size
	end

	def insertNewCauseOne(cause, filesRelated)
		if (filesRelated.size > 0)
			includeNewCause(cause, filesRelated)
		elsif (cause=="compilerError" or cause=="dependencyProblem" or cause=="remoteError" or cause=="gitProblem")
			includeNewCause(cause, filesRelated)
		end
	end

	def insertNewCause(cause)
		includeNewCause(cause, nil)
	end

  def includeNewCause(cause, filesRelated)
		if (@causesFilesInfoConflicts.include?(cause))
			@causesFilesInfoConflicts[cause] += filesRelated
		else
			@causesFilesInfoConflicts[cause] = filesRelated
		end
	end
end