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
		createBranches()
		originalToReplayedMerge = Hash.new
		#File d = new File(this.downloadDir);
		#d.mkdir();
	end

	def replayBuildsOnTravis(leftParent, rightParent, mergeCommit, mergeDir)
		#print "Reseting to parent 1 and pushing to master"
		resetToOldCommitAndPush(leftParent)
		mergeBranches("origHist")
		#print "Reseting to parent 2 and pushing to master"
		resetToOldCommitAndPush(rightParent)
		mergeBranches("origHist")
		#print "Reseting to merge commit and pushing to master"
		resetToOldCommitAndPush(mergeCommit)
		#print "Replacing files from original merge to replayed merge and pushing to merges"
		commitEditedMergeAndPush(mc, mergeDir)
		mergeBranches("origHist")
	end

	def commitEditedMergeAndPush(leftParent, rightParent, mergeCommit, mergeDir)
		checkoutBranch("merges")
		commitAndPushMerge(mc)
		checkoutBranch("master")
	end

	def commitAndPushMerge(mergeCommit)
		add = "git add ."
		commit = "git commit -m \"merge\" "
		push = "git push origin merges"
		
		begin
			%x(#{add})
			%x(#{commit})
			%x(#{push})
			newSha = getHead()
			@originalToReplayedMerge.put(newSha, mergeCommit)
		rescue 
			print "IT DID NOT WORK"
		end
	end

	def getHead()
		sha = ""
		
		return sha
	end

	def mergeBranches(branchName)
		pull = "git merge " + branchName
		
		begin
			%x(#{pull})
		rescue 
			print "IT DID NOT WORK"
		end
	end

	def resetToOldCommitAndPush(sha)
		reset = "git reset --hard " + sha
		forcePush = "git push -f origin HEAD:master"
		
		begin
			%x(#{reset})
			%x(#{forcePush})
		rescue
			print "IT DID NOT WORK"	
		end
		
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

	def activateTravis()
		cmd = "travis" + " login --github-token " + @token
		cmd2 = "travis" + " enable -r " + @username + "/" + @name
		begin
			%x(#{cmd})
			%x(#{cmd2})
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
		createbranch("origHist")
		checkoutBranch("master")
		createbranch("merges")
		pushBranchToRemote("merges")
		checkoutBranch("master")
	end

	def createbranch(branchName)
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

end
