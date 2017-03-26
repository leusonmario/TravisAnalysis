require 'require_all'
require_rel 'ConflictCategories'

class ConflictCategoryFailed
	include ConflictCategories

	def initialize()
		@gitProblem = 0
		@remoteError = 0
		@otherError = 0
		@permission = 0
		@failed = 0
	end

	def getGitProblem()
		@gitProblem
	end

	def getRemoteError()
		@remoteError
	end

	def getOtherError()
		@otherError
	end

	def getPermission()
		@permission
	end

	def getFailed()
		@failed
	end

	def getTotal()
		return getGitProblem() + getRemoteError() + getFailed() + getOtherError() + getPermission()
	end

	def findConflictCause(build)
	
		stringBuildFail = "FAILURE"
		stringFailTask = "Execution failed for task"

		stringBuildFailed = "BUILD FAILED"
		stringExcetion = "Exception in thread"
		stringMore = "more"
		stringGitProblemClone = "The command \"git clone"
		stringGitProblemCheckout = "The command \"git checkout"
		stringNoOutput = "No output has been received"
		stringStopped = "Your build has been stopped"
		stringTerminated = "The build has been terminated"
		stringTheCommand = "The command "
		stringDoesNotExist = "does not exist"

		result = ""
		indexJob = 0
		while (indexJob < build.job_ids.size)
			if (build.jobs[indexJob].state == "failed")
				if (build.jobs[indexJob].log != nil)
					build.jobs[indexJob].log.body do |part|
						if (part[/Errors: [0-9]*/])
							@failed += 1
							result = "failed"
						elsif (part[/#{stringBuildFail}\s*([^\n\r]*)\s*([^\n\r]*)\s*([^\n\r]*)failed/] || part[/#{stringTheCommand}("mvn|"\.\/mvnw)+(.*)failed(.*)/])
							@failed += 1
							result = "failed"
						elsif (part[/#{stringTheCommand}("git clone |"git checkout)(.*?)failed(.*)[\n]*/])
							@gitProblem += 1
							result = "gitProblem"
						elsif (part[/#{stringNoOutput}(.*)wrong(.*)[\n]*#{stringTerminated}/])
							@remoteError += 1
							result = "remoteError"
						elsif (part[/#{stringTheCommand}("cd|"sudo|"echo|"eval)+ (.*)failed(.*)/])
							@permission += 1
							result = "permission"
						else
							@otherError += 1
							result = "otherError"
						end
					end
				end
			end
			indexJob += 1
		end
		return result
	end
end