require 'require_all'
require_all './GumTree' 
require_rel 'ConflictCategories'
require_rel 'CausesFilesConflicting'

class ConflictCategoryErrored
	include ConflictCategories

	def initialize()
		@gitProblem = 0
		@malformedExp = 0
		@remoteError = 0
		@compilerError = 0
		@methodUpdate = 0
		@unavailableSymbol = 0
		@duplicateStatement = 0
		@dependencyProblem = 0
		@unimplementedMethod = 0
		@otherError = 0
	end

	def getGitProblem()
		@gitProblem
	end

	def getMethodUpdate()
		@methodUpdate
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
		return getGitProblem() + getRemoteError() + getCompilerError() + getunavailableSymbol() + getOtherError() + getMethodUpdate() + getMalformedExp() + getDuplicateStatement() + getDependencyProblem() + getUnimplementedMethod()
	end

	def findConflictCause(build, pathProject, pathGumTree, type, mergeScenario)
		localUnavailableSymbol = 0 
		localMethodUpdate = 0 
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
							if (bodyJob.include?('Retrying, 3 of 3'))
								body = bodyJob[/Retrying, 3 of 3[\s\S]*/]
							else
								body = bodyJob
							end

							#if (body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* executor has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]+/])
							#	causesFilesConflicts.insertNewCause("updateModifier", [])
							#end
						
							if (body[/\[ERROR\] \(actual and formal argument lists differ in length\)/] || body[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* (no suitable method found for|cannot be applied to)+ [a-zA-Z0-9\/\-\.\:\[\]\,]*/] || body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\, ]* has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]*/] || body[/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*(\[#{stringErro}\])?\;/] || body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/] || body[/#{stringWrongReturn}/] || body[/#{stringIncompatibleType}/])
								localMethodUpdate = body.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\, ]* has private access in [a-zA-Z0-9\/\-\.\:\[\]\,]*|\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*(\[#{stringErro}\])?\;|\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]|\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}|#{stringWrongReturn}|#{stringIncompatibleType}|\[#{stringErro}\][\s\S]*[#{stringConstructorFound}]?[\s\S]*#{stringDifferArgument}/).size
								@methodUpdate += localMethodUpdate
								filesInformation = []
								otherCase = false
								begin
									if (body[/BUILD FAILURE[\s\S]*/].to_s[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\, ]* no suitable method found for [a-zA-Z0-9\/\-\.\:\[\]\,]*/])
										changedClasses = body[/BUILD FAILURE[\s\S]*/].to_s.to_enum(:scan, /\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\, ]* no suitable method found for [a-zA-Z0-9\/\-\.\:\[\]\,]*/).map { Regexp.last_match }
										callClassFiles = body.to_enum(:scan, /\[ERROR\] method [ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]*[ \t\r\n\f]*/).map { Regexp.last_match }
										count = 0
										while (count < changedClasses.size)
											changedClass = changedClasses[count].to_s.match(/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\,]*/)[0].split("/").last.gsub('.java','')
											aux = callClassFiles[count].to_s.match(/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]*[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]*/)[0].split("method").last
											methodName = aux.split('.').last
											callClassFile = aux.split('.'+methodName).last.split('.').last
											filesInformation.push([changedClass, methodName, callClassFile, "method"])
											count += 1
										end
									end
									if (body[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* cannot be applied to [a-zA-Z0-9\/\-\.\:\[\]\,]*/])
										changedClasses = body[/BUILD FAILURE[\s\S]*/].to_s.to_enum(:scan, /\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* cannot be applied to [a-zA-Z0-9\/\-\.\:\[\]\,]*/).map { Regexp.last_match }
										count = 0
										while (count < changedClasses.size)
											changedClass = changedClasses[count].to_s.match(/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\,]*/)[0].split("/").last.gsub('.java','')
										    aux = changedClasses[count].to_s.match(/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]*[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* cannot be applied to/)[0].split("method").last
										    callClassFile = aux.split('.').last.gsub(' cannot be applied to', '')
										    methodName = aux.split('] ').last.match(/[a-zA-Z]*/)
											filesInformation.push([changedClass, methodName, callClassFile, "method"])
											count += 1
										end
									end
									if (body[/\[ERROR\] \(actual and formal argument lists differ in length\)/])
										changedClasses = body[/BUILD FAILURE[\s\S]*/].to_s.to_enum(:scan, /no suitable constructor found for [a-zA-Z]*/).map { Regexp.last_match }
										count = 0
										while (count < changedClasses.size)
											changedClass = changedClasses[count].to_s.split("no suitable constructor found for ").last
										   	filesInformation.push([changedClass, changedClass, changedClass, "constructor"])
											count += 1
										end
									end
									causesFilesConflicts.insertNewCauseOne("methodUpdate", filesInformation)
								rescue
									causesFilesConflicts.insertNewCauseOne("methodUpdate", [])
								end
							end
							if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
								localDuplicateStatement = body.scan(/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/).size
								@duplicateStatement += localDuplicateStatement
								filesInformation = []
								otherCase = false
								begin
									information = body.to_enum(:scan, /\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,\s]* is already defined in [a-zA-Z0-9\/\-\.\:\[\]\,\_]*/).map { Regexp.last_match }
									count = 0
									while(count < information.size)
										classFile = information[count].to_s.match(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,\s]*.java/)[0].split("/").last.gsub('.java','')
										variableName = information[count].to_s.match(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\,]*\]\s[a-zA-Z0-9\/\-\_]*/)[0].split(" ").last
										methodName = information[count].to_s.match(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\,\]\s\_]*/)[0].split(" ").last
										count += 1
										filesInformation.push([classFile, variableName, methodName])
									end
									causesFilesConflicts.insertNewCauseOne("statementDuplication", filesInformation)
								rescue
									causesFilesConflicts.insertNewCauseOne("statementDuplication", [])
								end
							end
							if (body[/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/])
								localUnimplementedMethod = body.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/).size
								@unimplementedMethod += localUnimplementedMethod
								filesInformation = []
								bodyAux = bodyJob[/BUILD FAILURE[\s\S]*/]
								otherCase = false
								begin
									count = 0
									classFiles = ""
									if (body.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
										classFiles = body.to_enum(:scan, /\[ERROR\] [a-zA-Z\/\-]*\.java/).map { Regexp.last_match }
									elsif (body.match(/error: [a-zA-Z\/\-]* is not abstract/))
										classFiles = body.to_enum(:scan, /error: [a-zA-Z\/\-]* is not abstract/).map { Regexp.last_match }
									end
									interfaceFiles = body.to_enum(:scan, /#{stringNoOverride} [a-zA-Z\(\)]* in [a-zA-Z\.]*[^\n]+/).map { Regexp.last_match }
									methodInterfaces = body.to_enum(:scan, /#{stringNoOverride} [a-zA-Z\(\)]* in/).map { Regexp.last_match }
									while(count < interfaceFiles.size)
										classFile = ""
										if (body.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
											classFile = classFiles[count].to_s.match(/[a-zA-Z]+\.java/)[0].to_s
										elsif (body.match(/error: [a-zA-Z\/\-]* is not abstract/))
											classFile = classFiles[count].to_s.match(/error: [a-zA-Z\/\-]*/).gsub("error: ","")
										end
										interfaceFile = interfaceFiles[count].to_s.split(".").last.gsub("\r", "").to_s
										methodInterface = methodInterfaces[count].to_s.match(/[a-zA-Z\(\)]* in/).to_s.gsub(" in","").to_s
										filesInformation.push([classFile, interfaceFile, methodInterface])
										count += 1
									end
									causesFilesConflicts.insertNewCauseOne("unimplementedMethod",filesInformation)
								rescue
									puts "IT DID NOT WORK"
									causesFilesConflicts.insertNewCauseOne("unimplementedMethod",[""])
								end
							end
							if (body[/\[ERROR\][ \t\r\n\f]*Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]*Some Enforcer rules have failed/] || body[/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}/] || body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] || body[/\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?/] || body[/#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/])
								aux = body.scan(/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}|\[#{stringErro}\][\s\S]*#{stringDependency}|\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?|#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/).size
								if (type=="Config" || type=="All-Config")
									causesFilesConflicts.insertNewCauseOne("dependencyProblem",[])
									localDependencyProblem = aux
									@dependencyProblem += aux
								else
									causesFilesConflicts.insertNewCauseOne("compilerError",[])
									@compilerError += aux
								end
								otherCase = false
							end
							
							if (body[/\[ERROR\]?[\s\S]*cannot find symbol/] || body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/] || body[/\[#{stringErro}\][\s\S]*#{stringNotFindType}/] || body[/\[#{stringErro}\][\s\S]*#{stringNotMember}/])
								localUnavailableSymbol = body.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?|\[#{stringErro}\][\s\S]*#{stringNotFindType}|\[#{stringErro}\][\s\S]*#{stringNotMember}|\[ERROR\]?[\s\S]*cannot find symbol/).size
								@unavailableSymbol += localUnavailableSymbol
								filesInformation = []
								begin
									if (body[/\[ERROR\]?[\s\S]*cannot find symbol/] || body[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/])
										methodNames = body.to_enum(:scan, /\[ERROR\][ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*[method|class|variable|constructor|static]*[ \t\r\n\f]*[a-zA-Z0-9\(\)\.\/\,\_]*[ \t\r\n\f]*\[ERROR\][ \t\r\n\f]*location/).map { Regexp.last_match }
										classFiles = body.to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*(@)?[class|interface|variable]+[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/).map { Regexp.last_match }
										callClassFiles = ""
										if (bodyJob.include?('Retrying, 3 of 3'))
											callClassFiles = body[/BUILD FAILURE[\s\S]*/].to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,]* cannot find symbol/).map { Regexp.last_match }
										else
											callClassFiles = body[/Compilation failure:[\s\S]*/].to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,]* cannot find symbol/).map { Regexp.last_match }
										end
										count = 0
										while (count < classFiles.size)
											methodName = methodNames[count].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|variable|class|constructor|static)[ \t\r\n\f]*[a-zA-Z0-9\_]*/)[0].split(" ").last
											classFile = classFiles[count].to_s.match(/location[ \t\r\n\f]*:[ \t\r\n\f]*(@)?(class|interface)?[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*/)[0].split(".").last.gsub("\r", "").to_s
											callClassFile = callClassFiles[count].to_s.match(/\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z0-9\,]*/)[0].split("/").last.gsub(".java:", "").gsub("\r", "").to_s
											count += 1
											filesInformation.push([classFile, methodName, callClassFile])
										end	
									end
									causesFilesConflicts.insertNewCauseOne("unavailableSymbol",filesInformation)
								rescue
									causesFilesConflicts.insertNewCauseOne("unavailableSymbol",[])
								end
							end

							if (body[/\[ERROR\][ \t\r\n\f]Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*\n\[ERROR\][ \t\r\n\f][\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*illegal (character)/] || body[/\[ERROR\]?[ \t\r\n\f]*Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]* Some files do not have the expected license header/] || body[/\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]* missing return statement/] || body[/\[ERROR\][ \t\r\n\f]* [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]* \'[a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]*\' expected/] || body[/#{stringUnexpectedToken}/]  || body[/\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/])
								causesFilesConflicts.insertNewCauseOne("malformedExpression",[""])
								localMalformedExp = body.scan(/\[ERROR\][ \t\r\n\f]Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*\n\[ERROR\][ \t\r\n\f][\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]*illegal (character)|\[ERROR\]?[ \t\r\n\f]*Failed to execute goal[\/\-\.\:a-zA-Z\[\]0-9\,\(\) ]* Some files do not have the expected license header|\[ERROR\][ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,]* missing return statement|\[ERROR\][ \t\r\n\f]* [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]* \'[a-zA-Z0-9\/\-\.\:\[\]\,\(\)\; ]*\' expected|\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}|\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/).size
								@malformedExp += localMalformedExp
								otherCase = false
							end
							# depois ver a questao do |Could not transfer
							if (body[/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* Fatal error compiling: invalid/] || body[/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* There (were|was) [0-9]* error(s)?/] || body[/#{stringErroInput}/] || body[/\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}/] || body[/#{stringAccess}/] || body[/#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}/] || body[/#{stringNotDefinedProp}/] || body[/#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?/] || body[/#{stringUnsupported}[\s\S]*#{stringStopped}/] || body[/#{stringErrorProcessing}[\s\S]*/] || body[/\[(ERROR|WARNING)\][ \t\r\n\f]*(Non-resolvable parent POM:)? (Failure to find|Could not find artifact)+/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
								causesFilesConflicts.insertNewCauseOne("compilerError",[])
								@compilerError += body.scan(/\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* Fatal error compiling: invalid|\[ERROR\] Failed to execute goal [a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]* There (were|was) [0-9]* error(s)?|#{stringErroInput}|\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}|#{stringAccess}|#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}|#{stringNotDefinedProp}|#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?|#{stringUnsupported}[\s\S]*#{stringStopped}|#{stringErrorProcessing}[\s\S]*|\[(ERROR|WARNING)\][ \t\r\n\f]*(Non-resolvable parent POM:)? (Failure to find|Could not find artifact)?|\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*|\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*|#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/).size
								otherCase = false
							end
							if (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
								causesFilesConflicts.insertNewCauseOne("gitProblem",[])
								@gitProblem += body.scan(/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/).size
								otherCase = false
							end
							if (body[/The job exceeded the maximum time limit for jobs, and has been terminated/] || body[/#{stringServiceUnavailable}/] || body[/No output has been received in the last [0-9]*/] || body[/[\s\S]*#{stringOverflowData}[\s\S]*/] || body[/(y|Y)our test run exceeded 50(.0)? minutes/] || body[/error: device not found/] || body[/ValueError: No JSON object could be decoded/])
								causesFilesConflicts.insertNewCauseOne("remoteError",[])
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
		if (mergeScenario)
			return causesFilesConflicts.getCausesConflict(), getFinalStatus(pathGumTree, pathProject, build, causesFilesConflicts, localMethodUpdate, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod)
		else
			return causesFilesConflicts.getCausesConflict()
		end
	end

	def getFinalStatus(pathGumTree, pathProject, build, conflictCauses, localMethodUpdate, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod)
		gtAnalysis = GTAnalysis.new(pathGumTree)
		if(localMethodUpdate > 0 || localUnavailableSymbol > 0 || localDuplicateStatement > 0 || localUnimplementedMethod > 0)
			if(localUnimplementedMethod > 0 or localUnavailableSymbol > 0 or localDuplicateStatement > 0 or localMethodUpdate > 0)
				if (conflictCauses.getFilesConflict().size < 1)
					return false, nil
				else
					return gtAnalysis.getGumTreeAnalysis(pathProject, build, conflictCauses)
				end
			end
			return false, nil
		end
		return false, nil
	end
end