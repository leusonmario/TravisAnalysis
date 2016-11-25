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
		stringNonResolvable = "Non-resolvable parent POM: Could not transfer artifact"
		stringNonParseable = "Non-parseable POM "
		stringUnexpected = " unexpected character in markup"
		stringErrorProcessing = "dpkg: error processing "
		stringUnsupported = "Unsupported major.minor version"
		stringBuildFail = "BUILD FAILED"
		stringUndefinedExt = "uses an undefined extension point"
		stringNoOverride = "does not override abstract method"
		stringInfo = "INFO"
		
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
					build.jobs[indexJob].log.body do |body|
						otherCase = true
						if (body[/\[#{stringErro}\][\s\S]*#{stringNoApplied}[\s\S]*\[#{stringErro}\]/] || body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/])
							result.push("updateModifier")
							@updateModifier += 1
							otherCase = false
						end
						if (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
							result.push("duplicationStatement")
							@duplicateStatement += 1
							otherCase = false
						end
						if (body[/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/])
							result.push("unimplementedMethod")
							@unimplementedMethod += 1
							otherCase = false
						end
						if (body[/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}/] || body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] || body[/\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*#{stringUnexpected}[\s\S]*\[#{stringErro}\]/])
							if (type=="Config" || type=="All-Config")
								result.push("dependencyProblem")
								@dependencyProblem += 1
							else
								result.push("compilerError")
								@compilerError += 1
							end
							otherCase = false
						end
						if (body[/\[#{stringErro}\]#{stringCompError}[\s\S]*\[#{stringInfo}\][\s\S]*\[#{stringErro}\][\s\S]*#{stringNotFind}/])
							text = body[/\[ERROR\] COMPILATION ERROR :[\s\S]*\[ERROR\](.*?)\[INFO\] [0-9]+/m, 1]
							fileConflict = text.match(/[A-Za-z]+\.java/)[0].to_s
							#gtAnalysis.getGumTreeAnalysis(pathProject, build, fileConflict)
							result.push("unavailableSymbol")
							@unavailableSymbol += 1
							otherCase = false
						end
						if (body[/\[#{stringErro}\](.*)?#{stringError}\: #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/])
							result.push("malformedExpression")
							@malformedExp += 1
							otherCase = false
						end
						if (body[/#{stringUnsupported}[\s\S]*#{stringStopped}/] || body[/#{stringErrorProcessing}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*#{stringNonResolvable}[\s\S]*/] || body[/\[#{stringErro}\][\s\S]*(\:jar)#{stringMissing}[\s\S]*/] || body[/\[#{stringErro}\]#{stringValidVersion}[\s\S]*(\:jar)[\s\S]*/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
							result.push("compilerError")
							@compilerError += 1
							otherCase = false
						end
						if (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
							result.push("gitProblem")
							@gitProblem += 1
							otherCase = false
						end
						if (body[/#{stringNoOutput}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*#{stringTerminated}/] || body[/[\s\S]*#{stringOverflowData}[\s\S]*/])
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
		#getFinalStatus(pathGumTree, pathProject, build, result)
		return result
	end

	def getFinalStatus(pathGumTree, pathProject, build, fileConflict)
		gtAnalysis = GTAnalysis.new(pathGumTree)
		if(getUpdateModifier() > 0 || getunavailableSymbol() > 0 || getDuplicateStatement() > 0 || getUnimplementedMethod() > 0)
			gtAnalysis.getGumTreeAnalysis(pathProject, build, fileConflict)
		end
	end
end