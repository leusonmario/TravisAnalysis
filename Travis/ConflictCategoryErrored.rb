#!/usr/bin/env ruby
#file: conflictCategory.rb

require 'travis'
require 'csv'
require 'rubygems'
require_relative 'ConflictCategories'

class ConflictCategoryErrored
	include ConflictCategories

	def initialize()
		@gitProblem = 0
		@remoteError = 0
		@compilerError = 0
		@unvailableSymbol = 0
		@otherError = 0
	end

	def getGitProblem()
		@gitProblem
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
		return getGitProblem() + getRemoteError() + getCompilerError() + getUnvailableSymbol() + getOtherError()
	end

	def findConflictCause(build)
		stringCompError = " COMPILATION ERROR :"
		stringNotFind = "cannot finf symbol"
		stringNoConvert = "cannot be converted to"
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
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |part|
						#if (part[/\[ERROR\] COMPILATION ERROR :[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\])]*\[INFO\][(\s)(0-9)]*error[s]?/])
						#(\[ERROR\] COMPILATION ERROR :)[\n]*(.*)[\n]*(.*)[\n]*(.*)cannot find symbol
						#	(symbol:[\s]*variable[\s]*)
						#	location: 
						#(\[INFO\])[\s0-9]*error[s]?
						if (part[/\[#{stringErro}\]#{stringCompError}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*\[#{stringInfo}\][(\s)(0-9)]*#{stringError}[s]?/] || part[/\[#{stringErro}\]#{stringCompError}[\s\S]*[.java][\s\S]*#{stringNoConvert}/])
							@unvailableSymbol += 1
						#elsif (part[/The command "[\.]?[\/]?mvn[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*Your build has been stopped/] || part[/#{stringTheCommand}#{stringPermission}+(.*)#{stringFailed}(.*)/] || part[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
					elsif (part[/#{stringTheCommand}\"[\.]?[\/]?[#{stringMoveCMD}]?[w]?[\s\S]*#{stringStopped}/] || part[/#{stringTheCommand}#{stringPermission}+(.*)#{stringFailed}(.*)/] || part[/#{stringElement}[(\n\s)(a-zA-Z0-9)(\'\-\/\.\:\,\[\])]*#{stringNoExist}/])
							@compilerError += 1
						elsif (part[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
							@gitProblem += 1
						elsif (part[/#{stringNoOutput}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\]\=\")]*#{stringTerminated}/])
							@remoteError += 1
						else
							@otherError += 1
						end
					end
				end
			end
			indexJob += 1
		end
	end
end
