#!/usr/bin/env ruby
#file: conflictCategory.rb

require './Repository/MergeCommit.rb'
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
		@unvailableSymbol = 0
		@duplicateStatement = 0
		@dependencyProblem = 0
		@otherError = 0
	end

	def getGitProblem()
		@gitProblem
	end

	def getUpdateModifier()
		@updateModifier
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

	def getUnvailableSymbol()
		@unvailableSymbol
	end

	def getOtherError()
		@otherError
	end

	def getTotal()
		return getGitProblem() + getRemoteError() + getCompilerError() + getUnvailableSymbol() + getOtherError() + getUpdateModifier() + getMalformedExp() + getDuplicateStatement() + getDependencyProblem()
	end

	def findConflictCause(build, pathProject, pathGumTree, type)
		stringCompError = " COMPILATION ERROR :"
		stringNotFind = "cannot finf symbol"
		stringNoConvert = "cannot be converted to"
		stringMalformed = "illegal start of type"
		stringExpected = " expected"
		stringUpdate = "is a subclass of alternative"
		stringDefined = "is already defined"
		stringDependency = "Could not resolve dependencies for project"
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
		result = ""
		gtAnalysis = GTAnalysis.new(pathGumTree)
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					body = build.jobs[indexJob].log.body
					if (body[/\[#{stringErro}\][\s\S]*#{stringUpdate}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
						result = "updateModifier"
						@updateModifier += 1
					elsif (body[/\[#{stringErro}\][\s\S]*#{stringDefined}[\s\S]*\[#{stringInfo}\](.*)?[0-9]/])
						result = "duplicationStatement"
						@duplicateStatement += 1
					elsif (body[/\[#{stringErro}\][\s\S]*#{stringDependency}/] and type=="Config")
						result = "dependencyProblem"
						@dependencyProblem += 1
					elsif (body[/\[#{stringErro}\]#{stringCompError}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*\[#{stringInfo}\][(\s)(0-9)]*#{stringError}[s]?/] || body[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/])
						text = body[/\[ERROR\] COMPILATION ERROR :[\s\S]*\[ERROR\](.*?)\[INFO\] [0-9]+/m, 1]
						fileConflict = text.match(/[A-Za-z]+\.java/)[0].to_s
						#gtAnalysis.getGumTreeAnalysis(pathProject, build, fileConflict)
						result = "unvailableSymbol"
						@unvailableSymbol += 1
					elsif (body[/\[ERROR\](.*)?#{stringError}\: #{stringMalformed}/] or body[/\[ERROR\](.*)?#{stringError}\:\'(.*)?\'#{stringExpected}/])
						#gtAnalysis.getGumTreeAnalysis(pathProject, build, fileConflict)
						result = "malformedExpression"
						@malformedExp += 1
					elsif (body[/#{stringTheCommand}\"[\.]?[\/]?[#{stringMoveCMD}]?[w]?[\s\S]*#{stringStopped}/] || body[/#{stringTheCommand}#{stringPermission}+(.*)#{stringFailed}(.*)/] || body[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
						result = "compilerError"
						@compilerError += 1
					elsif (body[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
						result = "gitProblem"
						@gitProblem += 1
					elsif (body[/#{stringNoOutput}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*#{stringTerminated}/])
						result = "remoteError"
						@remoteError += 1
					else
						result = "otherError"
						@otherError += 1
					end
				end
			end
			indexJob += 1
		end
		return result
	end
end
