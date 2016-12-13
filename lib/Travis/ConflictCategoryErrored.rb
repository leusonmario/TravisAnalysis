#!/usr/bin/env ruby
#file: conflictCategory.rb

require './GumTree/GTAnalysis.rb'
require_relative 'ConflictCategories'

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
		result = []
		
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |bodyJob|
						otherCase = true
						body = bodyJob[/Retrying, 3 of 3[\s\S]*/]
						if (body[/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*\[#{stringErro}\]/] || body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/] || body[/#{stringWrongReturn}/] || body[/#{stringIncompatibleType}/] || body[/\[#{stringErro}\][\s\S]*[#{stringConstructorFound}]?[\s\S]*#{stringDifferArgument}/])
							result.push("updateModifier")
							@updateModifier += 1
							otherCase = false
						end
						if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
							result.push("duplicationStatement")
							@duplicateStatement += body.scan(/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/).size
							otherCase = false
						end
						if (body[/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/])
							result.push("unimplementedMethod")
							@unimplementedMethod += body.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/).size
							otherCase = false
						end
						if (body[/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}/] || body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] || body[/\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*#{stringUnexpected}[\s\S]*\[#{stringErro}\]/] || body[/#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/])
							if (type=="Config" || type=="All-Config")
								result.push("dependencyProblem")
								@dependencyProblem += 1
							else
								result.push("compilerError")
								@compilerError += 1
							end
							otherCase = false
						end
						if (body[/\[#{stringErro}\]#{stringCompError}[\s\S]*\[#{stringInfo}\][\s\S]*\[#{stringErro}\][\s\S]*#{stringNotFind}/] || body[/[\[#{stringErro}\]]?[\s\S]*#{stringNotFind}/] || body[/\[#{stringErro}\][\s\S]*#{stringNotFindType}/] || body[/\[#{stringErro}\][\s\S]*#{stringNotMember}/])
							text = body[/\[ERROR\] COMPILATION ERROR :[\s\S]*\[ERROR\](.*?)\[INFO\] [0-9]+/m, 1]
							#fileConflict = text.match(/[A-Za-z]+\.java/)[0].to_s
							#gtAnalysis.getGumTreeAnalysis(pathProject, build, fileConflict)
							result.push("unavailableSymbol")
							@unavailableSymbol += 1
							otherCase = false
						end
						if (body[/#{stringUnexpectedToken}/]  || body[/\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/])
							result.push("malformedExpression")
							@malformedExp += 1
							otherCase = false
						end
						if (body[/#{stringErroInput}/] || body[/\[#{stringErro}\][\s\S]*deprecated[\s\S]*#{stringNoMaintained}/] || body[/#{stringAccess}/] || body[/#{stringFailedGoal}[\s\S]*#{stringBuildsFailed}/] || body[/#{stringNotDefinedProp}/] || body[/#{stringFailedGoal}[\s\S]*#{stringNotResolvedDep}[#{stringFailedCollect}]?[\s\S]*[#{stringConnectionReset}]?/] || body[/#{stringUnsupported}[\s\S]*#{stringStopped}/] || body[/#{stringErrorProcessing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*#{stringNonResolvable}[#{stringTransferArt}|#{stringFindArt}]?[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringValidVersion}[\s\S]*/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
							result.push("compilerError")
							@compilerError += 1
							otherCase = false
						end
						if (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
							result.push("gitProblem")
							@gitProblem += body.scan(/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/)
							otherCase = false
						end
						if (body[/#{stringServiceUnavailable}/] || body[/#{stringNoOutput}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*#{stringTerminated}/] || body[/[\s\S]*#{stringOverflowData}[\s\S]*/])
							result.push("remoteError")
							@remoteError += 1
							otherCase = false
						end
						if (otherCase)
							@otherError += 1
						end
					end
				end
			end
			#chamar o GumTree quando o ciclo de uma build for finalizado, e portanto, todos os eventuais problemas foram identificados.
			indexJob += 1
		end
		getFinalStatus(pathGumTree, pathProject, build, result)
		return result
	end

	def getFinalStatus(pathGumTree, pathProject, build, fileConflict)
		gtAnalysis = GTAnalysis.new(pathGumTree)
		if(getUpdateModifier() > 0 || getunavailableSymbol() > 0 || getDuplicateStatement() > 0 || getUnimplementedMethod() > 0)
			gtAnalysis.getGumTreeAnalysis(pathProject, build, fileConflict)
		end
	end
end