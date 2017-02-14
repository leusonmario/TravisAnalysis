require 'require_all'
require_all './GumTree' 
require_rel 'ConflictCategories'
require_rel 'CausesFilesConflicting'

class ConflictCategoryErroredAll
	include ConflictCategories

	def initialize()
		@gitProblem = 0
		@malformedExp = 0
		@remoteError = 0
		@compilerError = 0
		@updateModifier = 0
		@unavailableSymbol = 0
		@duplicateStatement = 0
		@dependencyProblem = 0
		@unimplementedMethod = 0
		@otherError = 0
	end

	def getGitProblem()
		@gitProblem
	end

	def getUpdateModifier()
		@updateModifier
	end

	def getUnimplementedMethod()
		@unimplementedMethod
	end

	def getDependencyProblem()
		@dependencyProblem
	end

	def getDuplicateStatement()
		@duplicateStatement
	end

	def getMalformedExp()
		@malformedExp
	end

	def getRemoteError()
		@remoteError
	end

	def getCompilerError()
		@compilerError
	end

	def getunavailableSymbol()
		@unavailableSymbol
	end

	def getOtherError()
		@otherError
	end

	def getTotal()
		return getGitProblem() + getRemoteError() + getCompilerError() + getunavailableSymbol() + getOtherError() + getUpdateModifier() + getMalformedExp() + getDuplicateStatement() + getDependencyProblem() + getUnimplementedMethod()
	end

	def findConflictCause(build, pathProject)
		localUnavailableSymbol = 0 
		localUpdateModifier = 0 
		localMalformedExp = 0 
		localDuplicateStatement = 0 
		localDependencyProblem = 0 
		localUnimplementedMethod = 0
		stringCompError = " COMPILATION ERROR :"
		stringNotFind = "cannot find symbol"
		stringNotFindType = "not find: type"
		stringNoConvert = "cannot be converted to"
		stringNoApplied = "cannot be applied to"
		stringMalformed = "illegal start of type"
		stringExpected = " expected"
		stringUpdate = "is a subclass of alternative"
		stringDefined = "is already defined"
		stringDependency = "Could not resolve dependencies for project"
		stringValidVersion = " must be a valid version"
		stringMissing = " failed: A required class was missing while executing"
		stringOverflowData = "The log length has exceeded the limit of 4 Megabytes"
		stringNonResolvable = "Non-resolvable parent POM:"
		stringTransferArt = "Could not transfer"
		stringFindArt = "Could not find artifact"
		stringNonParseable = "Non-parseable POM "
		stringUnexpected = " unexpected character in markup"
		stringUnexpectedToken = "unexpected token: <<"
		stringErrorProcessing = "dpkg: error processing "
		stringUnsupported = "Unsupported major.minor version"
		stringBuildFail = "BUILD FAILED"
		stringUndefinedExt = "uses an undefined extension point"
		stringNoOverride = "does not override abstract method"
		stringInfo = "INFO"
		stringScript = "Script"
		stringGradle = ".gradle"
		stringProblemScript = "A problem occurred evaluating script"
		stringAddTask = "Cannot add task"
		stringTaskExists = "as a task with that name already exists"
		stringFailedGoal = "Failed to execute goal"
		stringNotResolvedDep = "or one of its dependencies could not be resolved:"
		stringFailedCollect = "Failed to collect dependencies"
		stringConnectionReset = "Connection reset"
		stringNotDefinedProp = "Your user name and password are not defined. Ask your database administrator to set up"
		stringBuildsFailed = "builds failed"
		stringDifferArgument = "actual and formal argument lists differ in length"
		stringConstructorFound = "no suitable constructor found"
		stringAccess = "Make sure your network and proxy settings are correct"
		stringWrongReturn = "cannot return a value from method whose result type is void"
		stringIncompatibleType = "incompatible types"
		stringServiceUnavailable = "ERROR 503: Service Unavailable"
		stringNoMaintained = "no longer maintained"
		stringNotMember = "is not a member of"
		stringErroInput = "error reading input file:"
		
		stringTheCommand = "The command "
		stringMoveCMD = "mvn"
		stringGitClone = "\"git clone"
		stringGitCheckout = "\"git checkout"
		stringFailed = "failed"
		stringError = "error"
		stringElement = "Element"
		stringNoExist = "does not exist"
		stringErro = "ERROR"
		stringPermission = "\"cd|\"sudo|\"echo|\"eval"

		stringNoOutput = "No output has been received"
		stringWrong = "wrong"
		stringTerminated = "The build has been terminated"
		stringStopped = "Your build has been stopped"
		
		indexJob = 0
		causesFilesConflicts = CausesFilesConflicting.new()
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |bodyJob|
						if (bodyJob != nil)	
							otherCase = true
							puts build.id
							if (bodyJob.include?('Retrying, 3 of 3'))
								body = bodyJob[/Retrying, 3 of 3[\s\S]*/]
							else
								body = bodyJob
							end

							#if (body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* executor has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]+/])
							#	causesFilesConflicts.insertNewCause("updateModifier", [])
							#end
						
							if (body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\, ]* has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]*/] || body[/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*(\[#{stringErro}\])?\;/] || body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/] || body[/#{stringWrongReturn}/] || body[/#{stringIncompatibleType}/])
								localUpdateModifier = body.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\, ]* has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]*|\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*(\[#{stringErro}\])?\;|\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]|\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}|#{stringWrongReturn}|#{stringIncompatibleType}|\[#{stringErro}\][\s\S]*[#{stringConstructorFound}]?[\s\S]*#{stringDifferArgument}/).size
								@updateModifier += localUpdateModifier
								otherCase = false
								causesFilesConflicts.insertNewCause("updateModifier")
							end
							if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
								localDuplicateStatement = body.scan(/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/).size
								@duplicateStatement += localDuplicateStatement
								otherCase = false
								causesFilesConflicts.insertNewCause("statementDuplication")
							end
							if (body[/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/])
								localUnimplementedMethod = body.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/).size
								@unimplementedMethod += localUnimplementedMethod
								causesFilesConflicts.insertNewCause("unimplementedMethod")
							end
							if (body[/\[ERROR\][ \t\r\n\f]*Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]*Some Enforcer rules have failed/] || body[/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}/] || body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] || body[/\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?/] || body[/#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/])
								aux = body.scan(/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}|\[#{stringErro}\][\s\S]*#{stringDependency}|\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?|#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/).size
								causesFilesConflicts.insertNewCause("dependencyProblem")
								@dependencyProblem += aux
								otherCase = false
							end
							if (body[/\[ERROR\]?[\s\S]*cannot find symbol/] || body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/] || body[/\[#{stringErro}\][\s\S]*#{stringNotFindType}/] || body[/\[#{stringErro}\][\s\S]*#{stringNotMember}/])
								localUnavailableSymbol = body.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?|\[#{stringErro}\][\s\S]*#{stringNotFindType}|\[#{stringErro}\][\s\S]*#{stringNotMember}|\[ERROR\]?[\s\S]*cannot find symbol/).size
								@unavailableSymbol += localUnavailableSymbol
								causesFilesConflicts.insertNewCause("unavailableSymbol")
							end

							if (body[/\[ERROR\][ \t\r\n\f]Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*\n\[ERROR\][ \t\r\n\f][\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*illegal (character)/] || body[/\[ERROR\]?[ \t\r\n\f]*Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]* Some files do not have the expected license header/] || body[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]* missing return statement/] || body[/\[ERROR\][ \t\r\n\f]* [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]* \'[a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]*\' expected/] || body[/#{stringUnexpectedToken}/]  || body[/\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/])
								causesFilesConflicts.insertNewCause("malformedExpression")
								@malformedExp += localMalformedExp
								otherCase = false
							end
							if (body[/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* Fatal error compiling: invalid/] || body[/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* There (were|was) [0-9]* error(s)?/] || body[/#{stringErroInput}/] || body[/\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}/] || body[/#{stringAccess}/] || body[/#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}/] || body[/#{stringNotDefinedProp}/] || body[/#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?/] || body[/#{stringUnsupported}[\s\S]*#{stringStopped}/] || body[/#{stringErrorProcessing}[\s\S]*/] || body[/\[(ERROR|WARNING)\][ \t\r\n\f]*(Non-resolvable parent POM:)? (Failure to find|Could not find artifact|Could not transfer)+/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
								causesFilesConflicts.insertNewCause("compilerError")
								@compilerError += body.scan(/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* Fatal error compiling: invalid|\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* There (were|was) [0-9]* error(s)?|#{stringErroInput}|\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}|#{stringAccess}|#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}|#{stringNotDefinedProp}|#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?|#{stringUnsupported}[\s\S]*#{stringStopped}|#{stringErrorProcessing}[\s\S]*|\[(ERROR|WARNING)\][ \t\r\n\f]*(Non-resolvable parent POM:)? (Failure to find|Could not find artifact|Could not transfer)?|\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*|\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*|#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/).size
								otherCase = false
							end
							if (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
								causesFilesConflicts.insertNewCause("gitProblem")
								@gitProblem += body.scan(/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/).size
								otherCase = false
							end
							if (body[/The job exceeded the maximum time limit for jobs, and has been terminated/] || body[/#{stringServiceUnavailable}/] || body[/No output has been received in the last [0-9]*/] || body[/[\s\S]*#{stringOverflowData}[\s\S]*/] || body[/(y|Y)our test run exceeded 50(.0)? minutes/] || body[/error: device not found/] || body[/ValueError: No JSON object could be decoded/])
								causesFilesConflicts.insertNewCause("remoteError")
								@remoteError += body.scan(/The job exceeded the maximum time limit for jobs, and has been terminated|No output has been received in the last [0-9]*|#{stringServiceUnavailable}|(y|Y)our test run exceeded 50(.0)? minutes|error: device not found|ValueError: No JSON object could be decoded|#{stringOverflowData}/).size
								otherCase = false
							end
							if (otherCase)
								@otherError += 1
							end
						end
					end
				end
			end
			indexJob += 1
		end
		return causesFilesConflicts.getCausesConflict()
	end

end