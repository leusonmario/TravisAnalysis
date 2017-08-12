class CausesErroredBuild 

	def initialize()
		@methodParameterListSize = 0
		@methodParameterType = 0
		@statementDuplication = 0
		@missingReturn = 0
		@expectedSymbol = 0
		@unavailableVariable = 0
		@unavailableMethod = 0
		@unavailableFile = 0
		@unimplementedMethod = 0
		@alternativeStatement = 0
		@deniedAccess = 0
		@remoteError = 0
		@compilerError = 0
		@dependencyProblem = 0
		@otherError = 0
		@gitProblem = 0
	end

  def getAlternativeStatement()
		@alternativeStatement
	end

	def getMethodParameterListSize()
		@methodParameterListSize
	end

	def getMethodParameterType()
		@methodParameterType
	end

	def getStatementDuplication()
		@statementDuplication
	end

	def getMissingReturn()
		@missingReturn
	end

	def getExpectedSymbol()
		@expectedSymbol
	end

	def getUnavailableVariable()
		@unavailableVariable
	end

	def getUnavailableFile()
		@unavailableFile
	end

	def getUnavailableMethod()
		@unavailableMethod
	end

	def getUnimplementedMethod()
		@unimplementedMethod
	end
	
	def getDeniedAccess()
		@deniedAccess
	end

	def getRemoteError()
		@remoteError
	end

	def getCompilerError()
		@compilerError
	end

	def getDependencyProblem()
		@dependencyProblem
	end

	def getOtherError()
		@otherError
	end

	def getGitProblem()
		@gitProblem
	end

	def setAlternativeStatement(value)
		@alternativeStatement += value
	end

	def setMethodParameterListSize(value)
		@methodParameterListSize += value
	end

	def setMethodParameterType(value)
		@methodParameterType += value
	end

	def setStatementDuplication(value)
		@statementDuplication += value
	end

	def setMissingReturn(value)
		@missingReturn += value
	end

	def setExpectedSymbol(value)
		@expectedSymbol += value
	end

	def setUnavailableVariable(value)
		@unavailableVariable += value
	end

	def setUnavailableFile(value)
		@unavailableFile += value
	end

	def setUnavailableMethod(value)
		@unavailableMethod += value
	end

	def setUnimplementedMethod(value)
		@unimplementedMethod += value
	end
	
	def setDeniedAccess(value)
		@deniedAccess += value
	end

	def setRemoteError(value)
		@remoteError += value
	end

	def setCompilerError(value)
		@compilerError += value
	end

	def setDependencyProblem(value)
		@dependencyProblem += value
	end

	def setOtherError(value)
		@otherError += value
	end

	def setGitProblem(value)
		@gitProblem += value
	end

	def getTotal()
		return @methodParameterListSize + @methodParameterType + @statementDuplication + @missingReturn + @expectedSymbol + 
			@unavailableVariable + @unavailableMethod + @unavailableFile + @unimplementedMethod + @deniedAccess + @remoteError + 
			@compilerError + @dependencyProblem + @otherError + @gitProblem
	end
end