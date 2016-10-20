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
		@permission = 0
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

	def getPermission()
		@permission
	end

	def getTotal()
		return getGitProblem() + getRemoteError() + getCompilerError() + getUnvailableSymbol() + getOtherError() + getPermission()
	end

	def findConflictCause(build)
		stringCompError = "\[ERROR\] COMPILATION ERROR :"
		stringNotFind = "cannot finf symbol"
		stringInfo = "\[INFO\]"
		
		stringTheCommand = "The command "
		stringMoveCMD = "\"[\.\/]?mvn[w]?"
		stringGitClone = "\"git clone"
		stringGitCheckout = "\"git checkout"
		stringFailed = "failed"
		stringError = "error[s]?"
		stringPermission = "\"cd|\"sudo|\"echo|\"eval"

		stringNoOutput = "No output has been received"
		stringWrong = "wrong"
		stringTerminated = "The build has been terminated"
		
		indexJob = 0
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |part|
						if (part[/#{stringCompError}[(\n\s)(a-zA-Z0-9)(\-\/\.\:\,\[\])]*#{stringInfo}[(\s)(0-9)]*#{stringError}/])
							@unvailableSymbol += 1
						elsif (part[/#{stringTheCommand}#{stringMoveCMD}+(.*)#{stringFailed}(.*)/])
							puts build.id
							@compilerError += 1
						elsif (part[/#{stringTheCommand}(#{stringGitClone}|#{stringGitCheckout})(.*?)#{stringFailed}(.*)[\n]*/])
							@gitProblem += 1
						elsif (part[/#{stringNoOutput}(.*)#{stringWrong}(.*)[\n]*#{stringTerminated}/])
							@remoteError += 1
						elsif (part[/#{stringTheCommand}#{stringPermission}+(.*)#{stringFailed}(.*)/])
							@permission += 1
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