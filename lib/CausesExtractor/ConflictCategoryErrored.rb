require 'require_all'
require_all './BuildConflictExtractor'
require_rel 'ConflictCategories'
require_rel 'CausesFilesConflicting'
require_rel 'CausesErroredBuild'
require_rel '/IndividualExtractor'

class ConflictCategoryErrored
	include ConflictCategories

	def initialize(projectName, localClone)
		@projectName = projectName
		@pathLocalClone = localClone
		@causesErroredBuild = CausesErroredBuild.new()
		@methodUpdateExtractor = MethodUpdateExtractor.new()
		@statementDuplicationExtractor = StatementDuplicationExtractor.new()
		@unimplementedMethodExtractor = UnimplementedMethodExtractor.new()
		@unavailableSymbolExtractor = UnavailableSymbolExtractor.new()
		@alternativeStatement = AlternativeStatement.new()
		@DependencyExtractor = DependencyExtractor.new()
	end

	def getCausesErroredBuild()
		@causesErroredBuild
	end

	def getPathLocalClone()
		@pathLocalClone
	end

	def getProjectName()
		@projectName
	end

	def getMethodUpdateExtractor()
		@methodUpdateExtractor
	end

	def getDependencyExtractor()
		@dependencyExtractor
	end

	def getStatementDuplicationExtractor()
		@statementDuplicationExtractor
	end

	def getUnimplementedMethodExtractor()
		@unimplementedMethodExtractor
	end

	def getUnavailableSymbolExtractor()
		@unavailableSymbolExtractor
	end

	def getAlternativeStatement()
		@alternativeStatement
	end

	def getTotal()
		return getCausesErroredBuild.getTotal()
	end

	def findConflictCauseFork(logs, sha, pathProject, pathGumTree, type, mergeScenario, cloneProject, superiorParentStatus)
		localUnavailableSymbol = 0
		localMethodUpdate = 0 
		localMalformedExp = 0 
		localDuplicateStatement = 0 
		localDependencyProblem = 0 

		localUnimplementedMethod = 0
		localOtherCase = 0
		localAlternativeStatement = 0

		causesFilesConflicts = CausesFilesConflicting.new()

		logs.each do |log|
			body = ""
			otherCase = true
			if (log.include?('Retrying, 3 of 3'))
				body = log[/Retrying, 3 of 3[\s\S]*/]
			else
				body = log
			end
			otherCase = getCauseByBuild(body, log, causesFilesConflicts, localUnavailableSymbol, localMethodUpdate, localMalformedExp, localDuplicateStatement, localDependencyProblem, localUnimplementedMethod, localAlternativeStatement)
			localUnavailableSymbol = otherCase[1]
			localMethodUpdate = otherCase[2]
			localMalformedExp = otherCase[3]
			localDuplicateStatement = otherCase[4]
			localDependencyProblem = otherCase[5]
			localUnimplementedMethod = otherCase[6]
			localAlternativeStatement = otherCase[7]
			causesFilesConflicts = otherCase[8]
			if (otherCase[0])
				localOtherCase += 1
			end
		end

		if (mergeScenario)
			return causesFilesConflicts.getCausesConflict(), getFinalStatus(pathGumTree, pathProject, sha, causesFilesConflicts, localMethodUpdate, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod, localDependencyProblem, localMalformedExp, localAlternativeStatement, cloneProject, superiorParentStatus), causesFilesConflicts.getCausesNumber()
		else
			return causesFilesConflicts.getCausesConflict()
		end
	end

	def findConflictCause(build, pathProject, pathGumTree, type, mergeScenario, cloneProject, superiorParentStatus)
		localUnavailableSymbol = 0
		localMethodUpdate = 0 
		localMalformedExp = 0 
		localDuplicateStatement = 0 
		localDependencyProblem = 0 
		localUnimplementedMethod = 0
		localOtherCase = 0
		localAlternativeStatement = 0

		indexJob = 0
		causesFilesConflicts = CausesFilesConflicting.new()
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |bodyJob|
						if (bodyJob != nil)
							body = ""
							otherCase = true
							if (bodyJob.include?('Retrying, 3 of 3'))
								body = bodyJob[/Retrying, 3 of 3[\s\S]*/]
							else
								body = bodyJob
							end
							otherCase = getCauseByBuild(body, bodyJob, causesFilesConflicts, localUnavailableSymbol, localMethodUpdate, localMalformedExp, localDuplicateStatement, localDependencyProblem, localUnimplementedMethod, localAlternativeStatement)
							localUnavailableSymbol = otherCase[1]
							localMethodUpdate = otherCase[2]
							localMalformedExp = otherCase[3]
							localDuplicateStatement = otherCase[4]
							localDependencyProblem = otherCase[5]
							localUnimplementedMethod = otherCase[6]
							localAlternativeStatement = otherCase[7]
							causesFilesConflicts = otherCase[8]
							if (otherCase[0])
								localOtherCase += 1
							end
						end
					end
				end
			end
			indexJob += 1
		end
		if (mergeScenario)
			return causesFilesConflicts.getCausesConflict(), getFinalStatus(pathGumTree, pathProject, build.commit.sha, causesFilesConflicts, localMethodUpdate, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod, localDependencyProblem, localMalformedExp, localAlternativeStatement, cloneProject, superiorParentStatus), causesFilesConflicts.getCausesNumber(), causesFilesConflicts
		else
			return causesFilesConflicts.getCausesConflict()
		end
	end

	def findConflictCauseFromFailedScenario(build, pathProject, pathGumTree, type, mergeScenario, cloneProject, superiorParentStatus)
		localUnavailableSymbol = 0
		localMethodUpdate = 0
		localMalformedExp = 0
		localDuplicateStatement = 0
		localDependencyProblem = 0
		localUnimplementedMethod = 0
		localOtherCase = 0
		localAlternativeStatement = 0

		indexJob = 0
		causesFilesConflicts = CausesFilesConflicting.new()
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "failed")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |bodyJob|
						if (bodyJob != nil)
							body = ""
							otherCase = true
							if (bodyJob.include?('Retrying, 3 of 3'))
								body = bodyJob[/Retrying, 3 of 3[\s\S]*/]
							else
								body = bodyJob
							end
							otherCase = getCauseByBuild(body, bodyJob, causesFilesConflicts, localUnavailableSymbol, localMethodUpdate, localMalformedExp, localDuplicateStatement, localDependencyProblem, localUnimplementedMethod, localAlternativeStatement)
							localUnavailableSymbol = otherCase[1]
							localMethodUpdate = otherCase[2]
							localMalformedExp = otherCase[3]
							localDuplicateStatement = otherCase[4]
							localDependencyProblem = otherCase[5]
							localUnimplementedMethod = otherCase[6]
							localAlternativeStatement = otherCase[7]
							causesFilesConflicts = otherCase[8]
							if (otherCase[0])
								localOtherCase += 1
							end
						end
					end
				end
			end
			indexJob += 1
		end
		if (mergeScenario)
			return causesFilesConflicts.getCausesConflict(), getFinalStatus(pathGumTree, pathProject, build.commit.sha, causesFilesConflicts, localMethodUpdate, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod, localDependencyProblem, localMalformedExp, localAlternativeStatement, cloneProject, superiorParentStatus), causesFilesConflicts.getCausesNumber(), causesFilesConflicts
		else
			return causesFilesConflicts.getCausesConflict()
		end
	end

	def getCauseByBuild(body, bodyJob, causesFilesConflicts, localUnavailableSymbol, localMethodUpdate, localMalformedExp, localDuplicateStatement, localDependencyProblem, localUnimplementedMethod, localAlternativeStatemnt)
		otherCase = true

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
		stringNoOverride = "does not override (abstract|or implement a)? method"
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

		if (body[/\[ERROR\] \(actual and formal argument lists differ in length\)/] || body[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* (no suitable method found for|cannot be applied to)+ [a-zA-Z0-9\/\-\.\:\[\]\,]*/] || body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\, ]* has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]*/] || body[/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*(\[#{stringErro}\])?\;/] || body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/] || body[/#{stringWrongReturn}/] || body[/#{stringIncompatibleType}/])
			otherCase = false
			localMethodUpdate = body.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\, ]* has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]*|\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*(\[#{stringErro}\])?\;|\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]|\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}|#{stringWrongReturn}|#{stringIncompatibleType}|\[#{stringErro}\][\s\S]*[#{stringConstructorFound}]?[\s\S]*#{stringDifferArgument}/).size
			extraction = getMethodUpdateExtractor().extractionFilesInfo(body)
			getCausesErroredBuild.setMethodParameterListSize(extraction[2])
			causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
		end

		if (body[/\[ERROR\] [a-zA-Z\/\-0-9\.\:\[\]\,]* error: incompatible types: [a-zA-Z0-9]* cannot be converted to [a-zA-Z0-9]*/])
			otherCase = false
			localUnavailableSymbol = body.scan(/\[ERROR\] [a-zA-Z\/\-0-9\.\:\[\]\,]* error: incompatible types: [a-zA-Z0-9]* cannot be converted to [a-zA-Z0-9]*/).size
			causesFilesConflicts.insertNewCauseOne("incompatibleTypes", ["incompatibleTypes"])
		end

		#if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
		if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*(.*)?[0-9]/])
			otherCase = false
			#localDuplicateStatement = body.scan(/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/).size
			localDuplicateStatement = body.scan(/is already defined/).size
			extraction = getStatementDuplicationExtractor().extractionFilesInfo(body)
			getCausesErroredBuild.setStatementDuplication(extraction[2])
			causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
		end

		if (body[/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/])
			otherCase = false
			#localUnimplementedMethod = body.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/).size
			if (body.scan(/method does not override or implement a method from a supertype/))
				localUnimplementedMethod = body.scan(/method does not override or implement a method from a supertype/).size
				extraction = getUnimplementedMethodExtractor().extractionFilesInfoSecond(body[/BUILD FAILURE[\s\S]*/])
				getCausesErroredBuild.setUnimplementedMethod(extraction[2])
				causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
			end
			if (body.scan(/is not abstract and does not override abstract method/))
				localUnimplementedMethod = body.scan(/is not abstract and does not override abstract method/).size
				extraction = getUnimplementedMethodExtractor().extractionFilesInfo(body[/BUILD FAILURE[\s\S]*/])
				getCausesErroredBuild.setUnimplementedMethod(extraction[2])
				causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
			end
		end

		if (body[/\[INFO\][\s\S]* Alternatives in a multi-catch statement cannot be related by subclassing/])
			otherCase = false
			localAlternativeStatemnt = body.scan(/\[INFO\][\s\S]* Alternatives in a multi-catch statement cannot be related by subclassing/)
			extraction = getAlternativeStatement().extractionFilesInfo(body)
			getCausesErroredBuild.setAlternativeStatement(extraction[2])
			causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
		end

		if (body[/\[javac\] [\/a-zA-Z\_\-\.\:0-9 \-]* cannot find symbol[\s\S]* \[javac\] [ ]*(location:)+/] || body[/\[ERROR\]?[\s\S]*cannot find symbol/] || body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/] || body[/\[#{stringErro}\][\s\S]*#{stringNotFindType}/] || body[/\[#{stringErro}\][\s\S]*#{stringNotMember}/])
			otherCase = false
			localUnavailableSymbol = body.scan(/\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+|\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?|\[#{stringErro}\][\s\S]*#{stringNotFindType}|\[#{stringErro}\][\s\S]*#{stringNotMember}|\[ERROR\]?[\s\S]*cannot find symbol/).size
			extraction = getUnavailableSymbolExtractor().extractionFilesInfo(body, bodyJob)
			begin
				if (extraction[0] == "unavailableSymbolMethod")
					getCausesErroredBuild.setUnavailableMethod(extraction[2])
				elsif (extraction[0] == "unavailableSymbolVariable")
					getCausesErroredBuild.setUnavailableVariable(extraction[2])
				else
					getCausesErroredBuild.setUnavailableFile(extraction[2])
				end
				causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
			rescue
				print "LOG WITHOUT INFORMATION"
			end
		end

		if (body[/The JAVA_HOME environment variable is not defined correctly/] || body[/Could not transfer artifact/] || body[/\[ERROR\][ \t\r\n\f]*Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]*Some Enforcer rules have failed/] || body[/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}/] || body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] || body[/\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?/] || body[/#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/])
			otherCase = false
			begin
				aux = body.scan(/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}|\[#{stringErro}\][\s\S]*#{stringDependency}|\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?|#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/).size
				if (body[/Could not transfer artifact/] and (type=="Config" || type=="All-Config"))
					bodyAux = bodyJob[/BUILD FAILURE[\s\S]*/]
					extraction = getDependencyExtractor().extractionFilesInfo(body, bodyAux)
					getCausesErroredBuild.setDependencyProblem(extraction[2])
					causesFilesConflicts.insertNewCauseOne(extraction[0], extraction[1])
				else
					causesFilesConflicts.insertNewCauseOne("compilerError",["compilerError"])
					getCausesErroredBuild.setCompilerError(extraction[2])
					@compilerError += aux
				end
			rescue
				causesFilesConflicts.insertNewCauseOne("compilerError", ["compilerError"])
			end
		end

		if (body[/\[ERROR\][ \t\r\n\f]Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*\n\[ERROR\][ \t\r\n\f][\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*illegal (character)/] || body[/\[ERROR\]?[ \t\r\n\f]*Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]* Some files do not have the expected license header/] || body[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]* missing return statement/] || body[/\[ERROR\][ \t\r\n\f]* [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]* \'[a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]*\' expected/] || body[/#{stringUnexpectedToken}/]  || body[/\[#{stringErro}\](.*)?(#{stringError}\:)? #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/] or body[/\[ERROR\](.*) (is not (preceded with|followed by)+ whitespace|must match pattern|Unused import)+/] or body[/error: class, interface, or enum expected/] or body[/illegal start of/])
			otherCase = false
			causesFilesConflicts.insertNewCauseOne("malformedExpression",["malformedExpression"])
			localMalformedExp = body.scan(/\[ERROR\][ \t\r\n\f]Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*\n\[ERROR\][ \t\r\n\f][\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*illegal (character)|\[ERROR\]?[ \t\r\n\f]*Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]* Some files do not have the expected license header|\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]* missing return statement|\[ERROR\][ \t\r\n\f]* [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]* \'[a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]*\' expected|\[#{stringErro}\](.*)?(#{stringError}\:)? #{stringMalformed}|\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}|\[ERROR\](.*) (is not (preceded with|followed by)+ whitespace|must match pattern|Unused import)+/).size
			getCausesErroredBuild.setExpectedSymbol(localMalformedExp)
		end
		# depois ver a questao do |Could not transfer
		if (body[/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* Fatal error compiling: invalid/] || body[/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* There (were|was) [0-9]* error(s)?/] || body[/#{stringErroInput}/] || body[/\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}/] || body[/#{stringAccess}/] || body[/#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}/] || body[/#{stringNotDefinedProp}/] || body[/#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?/] || body[/#{stringUnsupported}[\s\S]*#{stringStopped}/] || body[/#{stringErrorProcessing}[\s\S]*/] || body[/\[(ERROR|WARNING)\][ \t\r\n\f]*(Non-resolvable parent POM:)? (Failure to find|Could not find artifact)+/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
			otherCase = false
			causesFilesConflicts.insertNewCauseOne("compilerError",["compilerError"])
			getCausesErroredBuild.setCompilerError(body.scan(/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* Fatal error compiling: invalid|\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* There (were|was) [0-9]* error(s)?|#{stringErroInput}|\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}|#{stringAccess}|#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}|#{stringNotDefinedProp}|#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?|#{stringUnsupported}[\s\S]*#{stringStopped}|#{stringErrorProcessing}[\s\S]*|\[(ERROR|WARNING)\][ \t\r\n\f]*(Non-resolvable parent POM:)? (Failure to find|Could not find artifact)?|\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*|\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*|#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/).size)
		end
		if (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
			otherCase = false
			causesFilesConflicts.insertNewCauseOne("gitProblem",["gitProblem"])
			getCausesErroredBuild.setGitProblem(body.scan(/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/).size)
		end
		if (body[/404 Not Found/] || body[/The job exceeded the maximum time limit for jobs, and has been terminated/] || body[/#{stringServiceUnavailable}/] || body[/No output has been received in the last [0-9]*/] || body[/[\s\S]*#{stringOverflowData}[\s\S]*/] || body[/(y|Y)our test run exceeded 50(.0)? minutes/] || body[/error: device not found/] || body[/ValueError: No JSON object could be decoded/] || body[/The job has been terminated/])
			otherCase = false
			causesFilesConflicts.insertNewCauseOne("remoteError",["remoteError"])
			getCausesErroredBuild.setRemoteError(body.scan(/The job exceeded the maximum time limit for jobs, and has been terminated|No output has been received in the last [0-9]*|#{stringServiceUnavailable}|(y|Y)our test run exceeded 50(.0)? minutes|error: device not found|ValueError: No JSON object could be decoded|#{stringOverflowData}|The job has been terminated/).size)
		end

		if (otherCase)
			getCausesErroredBuild.setOtherError(1)
		end

		return otherCase, localUnavailableSymbol, localMethodUpdate, localMalformedExp, localDuplicateStatement, localDependencyProblem, localUnimplementedMethod, localAlternativeStatemnt, causesFilesConflicts
	end

	def getFinalStatus(pathGumTree, pathProject, sha, conflictCauses, localMethodUpdate, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod, localDependencyProblem, localMalformedExp, localAlternativeStatement, cloneProject, superiorParentStatus)
		gtAnalysis = GTAnalysis.new(pathGumTree, @projectName, getPathLocalClone())
		if(localMethodUpdate > 0 || localUnavailableSymbol > 0 || localDuplicateStatement > 0 || localUnimplementedMethod > 0 || localDependencyProblem > 0 || localMalformedExp > 0 || localAlternativeStatement  > 0)
			if(localUnimplementedMethod > 0 or localUnavailableSymbol > 0 or localDuplicateStatement > 0 or localMethodUpdate > 0 or localDependencyProblem > 0 || localMalformedExp > 0)
				if (conflictCauses.getFilesConflict().size < 1)
					return false, nil
				else
					return gtAnalysis.getGumTreeAnalysis(pathProject, sha, conflictCauses, cloneProject, superiorParentStatus)
				end
			end
			return false, nil
		end
		return false, nil
	end
end
