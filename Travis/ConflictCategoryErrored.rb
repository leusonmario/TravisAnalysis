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
		stringCompError = "COMPILATION ERROR"
	
		stringCompilerError = "internal compiler error"

		stringSymbol = "COMPILATION ERROR"
		stringEndSymbol = "error: cannot find symbol"
			
		stringExcetion = "Exception in thread"
		stringGitProblemClone = "The command \"git clone"
		stringGitProblemCheckout = "The command \"git checkout"
		stringNoOutput = "No output has been received"
		stringStopped = "Your build has been stopped"
		stringTerminated = "The build has been terminated"
		stringDoesNotExist = "does not exist"

		indexJob = 0
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "errored")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |part|
						if (part[/#{stringSymbol}[\n]*(.*)[\n]*(.*)/] || part[/(.*)#{stringDoesNotExist}[\n]*(.*)/])
							@unvailableSymbol += 1
						elsif (part[/#{stringTheCommand}("mvn|"\.\/mvnw)+(.*)failed(.*)/])
							@compilerError += 1
						elsif (part[/#{stringTheCommand}("git clone |"git checkout)(.*?)failed(.*)[\n]*/])
							@gitProblem += 1
						elsif (part[/#{stringNoOutput}(.*)wrong(.*)[\n]*#{stringTerminated}/])
							@remoteError += 1
						elsif (part[/#{stringTheCommand}("cd|"sudo|"echo|"eval)+ (.*)failed(.*)/])
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