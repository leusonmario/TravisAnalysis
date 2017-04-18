class ExtractorCLI
	
	def initialize(username, password, token, travis, download, originalRepo)
		@name = ""
		@username = username
		@password = password
		@token = token
		@travisLocation = travis
		@downloadDir = download
		@originalRepo = originalRepo
		setName()
		setFork()
		setForkDir()
		createFork()
		activateTravis()
		cloneForkLocally()
		#createBranches()
		originalToReplayedMerge = Hash.new
	end

	def replayBuildOnTravis(commit, branch)
		commitAndPush(commit, branch)
	end

	def commitAndPush(commit, branch)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		checkout = "git checkout " + branch
		reset = "git reset --hard " + commit
		forcePush = "git push -f origin " + branch
		
		begin
			%x(#{checkout})
			%x(#{reset})
			%x(#{forcePush})
		rescue
			print "IT DID NOT WORK"	
		end
		Dir.chdir getDownloadDir()
	end

	def setName()
		parts = @originalRepo.split("/")
		print parts[1]
		@name = parts[1]
	end

	def setFork()
		@fork = getUsername() + "/" + getName()
	end

	def setForkDir()
		@forkDir = @downloadDir + "/" + @name
	end

	def createFork()
		cmd = "curl -u " + @username + ":" + @password + " -X POST https://api.github.com/repos/" + @originalRepo + "/forks"
		begin
			%x(#{cmd})
		rescue
			print "NOT FORKED"
		end
	end

	def deleteProject()
		Dir.chdir getDownloadDir
		%x(rm -rf #{getName()})
	end

	def activateTravis()
		cmd = "travis" + " login --github-token " + @token
		cmd2 = "travis" + " enable -r " + @username + "/" + @name
		begin
			%x(#{cmd})
			sleep(20)
			answer = %x(#{cmd2})
			while (answer == "409: {\"message\":\"Sync already in progress. Try again later.\"}")
				sleep(10)
				answer = %x(#{cmd2})
			end
			sleep(20)
		rescue
			print "NOT ALLOWED"
		end
	end

	def cloneForkLocally()
		Dir.chdir getDownloadDir()
		cloneFork = "git clone https://github.com/" + @fork + ".git"
		begin
			%x(#{cloneFork})
		rescue 
			print "NOT CLONED"
		end
	end

	def createBranches()
		createbranch("children")
		checkoutBranch("master")
		createbranch("merges")
		pushBranchToRemote("merges")
		pushBranchToRemote("children")
		checkoutBranch("master")
	end

	def createbranch(branchName)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		
		createBranchCMD = "git checkout -b " + branchName
		print createBranchCMD
		begin
			%x(#{createBranchCMD})
		rescue 
			print "NOT CREATED BRANCH"
		end
		Dir.chdir getDownloadDir()
	end

	def checkoutBranch(branch)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		checkout = "git checkout " + branch
		begin
			%x(#{checkout})
		rescue 
			print "NOT CHECKOUT EXECUTED"
		end
		Dir.chdir getDownloadDir()
	end

	def pushBranchToRemote(branchName)
		Dir.chdir getName()
		pushBranch = "git push origin " + branchName
		begin
			%x(#{pushBranch})
		rescue 
			print "NOT CHECKOUT EXECUTED"
		end
		Dir.chdir getDownloadDir()
	end

	def checkStatusBuild()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		checkout = "travis show"
		status = ""
		begin
			historyBuild = %x(#{checkout})
			status = historyBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","")
		rescue 
			print "NOT CHECKOUT EXECUTED"
		end
		return status
		Dir.chdir getDownloadDir()
	end

	def checkIdLastBuild()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		travisShow = "travis show"
		idBuild = ""
		begin
			historyBuild = %x(#{travisShow})
			idBuild = historyBuild.match(/(Build|Job)[\s\S]*State/).to_s.match(/(Build|Job)[ 0-9\.\#]*:/).to_s.match(/#[\s\S]*:/).to_s.gsub(":","")
		rescue 
			print "NOT CHECKOUT EXECUTED"
		end
		return idBuild
		Dir.chdir getDownloadDir()
	end

	def gitPull()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		pull = "git pull"
		begin
			%x(#{pull})
		rescue
			print "NOT PULL IS POSSIBLE"
		end
	end


	def getUsername()
		@username
	end

	def getPassword()
		@password
	end

	def getName()
		@name
	end

	def getDownloadDir()
		@downloadDir
	end

	def getPathProject()
		return getDownloadDir() + "/" + getName()
	end

end