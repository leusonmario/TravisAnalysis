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
	end

	def activeForkProject()
		createFork()
		cloneForkLocally()
		activateTravis()
	end

	def replayBuildOnTravis(commit, branch)
		return commitAndPush(commit, branch)
	end

	def commitAndPush(commit, branch)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		head = "git rev-parse HEAD"
		reset = "git reset --hard " + commit
		forcePush = "git push -f origin "
		changeOnHead = false
		begin
			previousHead = %x(#{head})
			%x(#{reset})
			currentHead = %x(#{head})
			%x(#{forcePush})
			if (previousHead != currentHead)
				changeOnHead = true
			end
		rescue
			print "IT DID NOT WORK"	
		end
		Dir.chdir getDownloadDir()
		return changeOnHead
	end

	def setName()
		parts = @originalRepo.split("/")
		@name = parts[1]
	end

	def setFork()
		@fork = getUsername() + "/" + getName()
	end

	def getFork()
		@fork
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
		begin
			Dir.chdir getDownloadDir
			%x(rm -rf #{getName()})
		rescue
			print "PROJECT NOT DELETED"
		end
	end

	def activateTravis()
		Dir.chdir getDownloadDir()
		cmd = "travis" + " login --github-token " + @token
		cmd2 = "travis" + " enable -r " + @username + "/" + @name
		begin
			%x(#{cmd})
			answerLogin = %x(travis whoami)
			while (!answerLogin.include? "#{@username}")
				answerLogin = %x(travis whoami)
				sleep(10)
			end
			answerActivation = %x(#{cmd2})
			while (!answerActivation.include? "enabled")
				sleep(10)
				answerActivation = %x(#{cmd2})
			end
			sleep(20)
		rescue
			print "NOT ALLOWED"
		end
	end

	def cloneForkLocally()
		Dir.chdir getDownloadDir()
		cloneFork = "git clone https://github.com/" + @fork + ".git"
		rmRemote = "git remote rm origin"
		addRemote = "git remote add origin 'git@github.com:" + @fork + ".git'"
		begin
			%x(#{cloneFork})
			Dir.chdir getName()
			%x(#{rmRemote})
			%x(#{addRemote})
		rescue 
			print "NOT CLONED"
		end
	end

	def checkStatusBuild()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		checkout = "travis show"
		status = ""
		begin
			historyBuild = %x(#{checkout})
			status = historyBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","").gsub("\n","")
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
			print "PULL IS NOT POSSIBLE"
		end
	end

	def gitPullUpstream()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		pull = "git pull upstream master"
		begin
			%x(#{pull})
		rescue
			print "PULL IS NOT POSSIBLE"
		end
	end

	def getInfoLastBuild()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		logs = []
		status = ""
		buildId = ""
		status = ""
		begin
			infoBuild = %x(travis show)
			status = infoBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","").gsub("\n","")
			
			while (status == "started")
				infoBuild = %x(travis show)
				status = infoBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","").gsub("\n","")
			end

			if (infoBuild.match(/Build #[0-9\.]*:/))
				buildId = infoBuild.match(/Build #[0-9\.]*:/).to_s.match(/#[0-9]*/).to_s.gsub("#","")
				numberJobs = infoBuild.scan(/\#[0-9\.]* #{status}/)
				
				numberJobs.each do |job|
					jobId = job.to_s.match(/\.[0-9]*/).to_s.gsub(".","")
					logs.push(%x(travis logs .#{jobId}))
				end
				
			elsif (infoBuild.match(/Job #[0-9\.]*:/))
				buildId = infoBuild.match(/Job #[0-9\.]*:/).to_s.match(/#[0-9]*/).to_s.gsub("#","")
				logs.push(%x(travis logs))
			end
		rescue
			print "IT DID NOT WORK - GET INFO LAST BUILD"
		end
		return status, logs, buildId
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