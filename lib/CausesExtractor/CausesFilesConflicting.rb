class CausesFilesConflicting

	def initialize()
		@causesFilesInfoConflicts = Array.new
	end

  def getCausesFilesInfoConflicts()
		@causesFilesInfoConflicts
	end

	def getCausesConflict()
		@causesFilesInfoConflicts
	end

	def getFilesConflict()
		@causesFilesInfoConflicts
	end

	def getCausesNumber()
		return @causesFilesInfoConflicts.size
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
		#if (@causesFilesInfoConflicts.include?(cause))
		filesRelated.each do |fileRelatedOne|
			if (!@causesFilesInfoConflicts.include? fileRelatedOne)
				@causesFilesInfoConflicts.push(fileRelatedOne)
			end
		end

		#else
		#	@causesFilesInfoConflicts[cause] = filesRelated
		#end
	end
end