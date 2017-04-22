class ExtractorCLI
	
	def initialize(username, password, token, travis, download, originalRepo)
		@name = ""
		@username = username
		@password = password
		@token = token
		@travisLocation = travis
		@downloadDir = download
		@originalRepo = originalRepo
		@repositoryTravis = nil
		setName()
		setFork()
		setForkDir()
		createFork()
		activateTravis()
		cloneForkLocally()
		getTravisRepositoryFork()
	end

	def getTravisRepositoryFork()
		begin
			@repositoryTravis = Travis::Repository.find(getFork())
		rescue Exception => e  
			print e
		end
	end

	def getRepositoryTravis()
		@repositoryTravis
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
		print parts[1]
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
			print "PULL IS NOT POSSIBLE"
		end
	end

	def getInfoLastBuild()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		logs = []
		status = ""
		#buildId
		begin
			infoBuild = %x(travis show)
			if (infoBuild.match(/Build #[0-9\.]*:/))
				status = infoBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","").gsub("\n","")
				#buildId = infoBuild.match(/Build #[0-9\.]*:/).to_s.match(/#[0-9]*/).gsub("\#","")
				numberJobs = infoBuild.scan(/\#[0-9\.]* #{status}/).size
				print "FOI AQUI"
				count = 1
				while(count <= numberJobs)
					logs.push(%x(travis logs .#{count}))
					print "FOI AQUI2"
					count += 1
				end
				
			elsif (infoBuild.match(/Job #[0-9\.]*:/))
				#buildId = infoBuild.match(/Job #[0-9\.]*:/).to_s.match(/#[0-9]*/).gsub("\#","")
				status = infoBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","").gsub("\n","")
				logs.push(%x(travis logs))
			end
		rescue
			print "IT DID NOT WORK - GET INFO LAST BUILD"
		end
		return status, logs
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