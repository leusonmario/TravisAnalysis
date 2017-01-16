#!/usr/bin/env ruby
#file: conflictCategory.rb

require './GumTree/GTAnalysis.rb'
require_relative 'ConflictCategories'
require_relative 'CausesFilesConflicting'

class ConflictCategoryErrored
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

	def findConflictCause(build, pathProject, pathGumTree, type)
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
		stringTransferArt = "Could not transfer artifact"
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
						otherCase = true
						body = bodyJob[/Retrying, 3 of 3[\s\S]*/]
						if (body[/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*\[#{stringErro}\]/] || body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/] || body[/#{stringWrongReturn}/] || body[/#{stringIncompatibleType}/] || body[/\[#{stringErro}\][\s\S]*[#{stringConstructorFound}]?[\s\S]*#{stringDifferArgument}/])
							causesFilesConflicts.insertNewCause("updateModifier", [""])
							localUpdateModifier = body.scan(/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*\[#{stringErro}\]|\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]|\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}|#{stringWrongReturn}|#{stringIncompatibleType}|\[#{stringErro}\][\s\S]*[#{stringConstructorFound}]?[\s\S]*#{stringDifferArgument}/).size
							@updateModifier += localUpdateModifier
							otherCase = false
						end
						if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
							causesFilesConflicts.insertNewCause("duplicationStatement", [""])
							localDuplicateStatement = body.scan(/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/).size
							@duplicateStatement += localDuplicateStatement
							otherCase = false
						end
						if (body[/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/])
							localUnimplementedMethod = body.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/).size
							@unimplementedMethod += localUnimplementedMethod
							begin
								if (body.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
									classFile = body.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s
								elsif (body.match(/error: [a-zA-Z\/\-]* is not abstract/))
									classFile = body.match(/error: [a-zA-Z\/\-]* is not abstract/).match(/error: [a-zA-Z\/\-]*/).gsub("error: ","")
								end
								interfaceFile = body.match(/#{stringNoOverride} [a-zA-Z\(\)]* in [a-zA-Z\.]*[^\n]+/)[0].split(".").last.gsub("\r", "").to_s
								methodInterface = body.match(/#{stringNoOverride} [a-zA-Z\(\)]* in/)[0].to_s.match(/[a-zA-Z\(\)]* in/).to_s.gsub(" in","").to_s
								causesFilesConflicts.insertNewCause("unimplementedMethod",[classFile, interfaceFile, methodInterface])
							rescue
								puts "NAO PEGOU"
								causesFilesConflicts.insertNewCause("unimplementedMethod",[""])
							end
							otherCase = false
						end
						if (body[/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}/] || body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] || body[/\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*#{stringUnexpected}[\s\S]*\[#{stringErro}\]/] || body[/#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/])
							aux = body.scan(/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}|\[#{stringErro}\][\s\S]*#{stringDependency}|\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*#{stringUnexpected}[\s\S]*\[#{stringErro}\]|#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/).size
							if (type=="Config" || type=="All-Config")
								causesFilesConflicts.insertNewCause("dependencyProblem",[""])
								localDependencyProblem = aux
								@dependencyProblem += aux
							else
								causesFilesConflicts.insertNewCause("compilerError",[""])
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
									methodNames = body.to_enum(:scan, /\[ERROR\][ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*[method|class|variable]*[ \t\r\n\f]*[a-zA-Z0-9\(\)\.\/\,]*[ \t\r\n\f]*\[ERROR\][ \t\r\n\f]*location/).map { Regexp.last_match }
									puts "MethodNames"
									puts methodNames
									classFiles = body.to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/).map { Regexp.last_match }
									puts "classFiles"
									puts classFiles
									callClassFiles = body[/BUILD FAILURE[\s\S]*/].to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,]* cannot find symbol/).map { Regexp.last_match }
									puts "callClassFiles"
									puts callClassFiles
									count = 0
									while (count < classFiles.size)
										methodName = methodNames[count].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*method[ \t\r\n\f]*[a-zA-Z0-9]*/)[0].split(" ").last
										puts "MethodName"
										puts methodName
										classFile = classFiles[count].to_s.match(/location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*/)[0].split(".").last.gsub("\r", "").to_s
										puts "classFile"
										puts classFile
										callClassFile = callClassFiles[count].to_s.match(/\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\,]*/)[0].split("/").last.gsub(".java:", "").gsub("\r", "").to_s
										puts "callClassFile"
										puts callClassFile
										count += 1
										filesInformation.push([classFile, methodName, callClassFile])
									end	
								end
								causesFilesConflicts.insertNewCause("unavailableSymbol",filesInformation)
							rescue
								puts "IT DID NOT WORK"
								causesFilesConflicts.insertNewCause("unavailableSymbol",[""])
							end
						end

						if (body[/#{stringUnexpectedToken}/]  || body[/\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/])
							causesFilesConflicts.insertNewCause("malformedExpression",[""])
							localMalformedExp = body.scan(/#{stringUnexpectedToken}|\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}|\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/).size
							@malformedExp += localMalformedExp
							otherCase = false
						end
						if (body[/#{stringErroInput}/] || body[/\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}/] || body[/#{stringAccess}/] || body[/#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}/] || body[/#{stringNotDefinedProp}/] || body[/#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?/] || body[/#{stringUnsupported}[\s\S]*#{stringStopped}/] || body[/#{stringErrorProcessing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*#{stringNonResolvable}[#{stringTransferArt}|#{stringFindArt}]?[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
							causesFilesConflicts.insertNewCause("compilerError",[""])
							@compilerError += body.scan(/#{stringErroInput}|\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}|#{stringAccess}|#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}|#{stringNotDefinedProp}|#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?|#{stringUnsupported}[\s\S]*#{stringStopped}|#{stringErrorProcessing}[\s\S]*|\[#{stringErro}\][\s\S]*#{stringNonResolvable}[#{stringTransferArt}|#{stringFindArt}]?[\s\S]*|\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*|\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*|#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/).size
							otherCase = false
						end
						if (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
							causesFilesConflicts.insertNewCause("gitProblem",[""])
							@gitProblem += body.scan(/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/).size
							otherCase = false
						end
						if (body[/#{stringServiceUnavailable}/] || body[/#{stringNoOutput}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*#{stringTerminated}/] || body[/[\s\S]*#{stringOverflowData}[\s\S]*/])
							causesFilesConflicts.insertNewCause("remoteError",[""])
							@remoteError += body.scan(/#{stringServiceUnavailable}|#{stringNoOutput}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*#{stringTerminated}|[\s\S]*#{stringOverflowData}[\s\S]*/).size
							otherCase = false
						end
						if (otherCase)
							@otherError += 1
						end
					end
				end
			end
			indexJob += 1
		end
		return causesFilesConflicts.getCausesConflict(), getFinalStatus(pathGumTree, pathProject, build, causesFilesConflicts, localUpdateModifier, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod)
	end

	def getFinalStatus(pathGumTree, pathProject, build, conflictCauses, localUpdateModifier, localUnavailableSymbol, localDuplicateStatement, localUnimplementedMethod)
		gtAnalysis = GTAnalysis.new(pathGumTree)
		if(localUpdateModifier > 0 || localUnavailableSymbol > 0 || localDuplicateStatement > 0 || localUnimplementedMethod > 0)
			#gtAnalysis.getGumTreeAnalysis(pathProject, build, conflictCauses)
			if(localUnimplementedMethod > 0 or localUnavailableSymbol > 0)
				return gtAnalysis.getGumTreeAnalysis(pathProject, build, conflictCauses)
			end
			return false
			sleep(10)
		end
		return false
	end
end