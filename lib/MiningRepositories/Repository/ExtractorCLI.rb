class ExtractorCLI
	
	def initialize(username, password, token, travis, download, originalRepo)
		@name = ""
		@username = username
		@password = password
		@token = token
		@travisLocation = travis
		@downloadDir = download
		@originalRepo = originalRepo
		@tagID = 0
		setName()
		setFork()
		setForkDir()
		@projectActive = false
		@apiKey = ""
	end

  def getApiKey()
		@apiKey
	end

  def setApiKey(newApi)
		@apiKey = newApi
	end

  def getProjectActive()
		@projectActive
	end

  def setProjectActive(newState)
		@projectActive = newState
	end

  def addEncryptedKeyOnTravis()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		setApiKey(%x(travis encrypt #{@token}))
		sleep(10)
		Dir.chdir getDownloadDir()
	end

	def activeForkProject()
		createFork()
		cloneForkLocally()
		activateTravis()
		setProjectActive(true)
	end

	def replayBuildOnTravis(commit, branch)
		syncProjectWithFork(branch)
		return commitAndPush(commit, branch)
	end

  def syncProjectWithFork(branch)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		%x(git checkout -f #{branch})
		%x(git remote add mainFork https://github.com/#{@originalRepo})
		%x(git fetch mainFork)
		%x(git merge mainFork/#{branch})
		Dir.chdir getDownloadDir()
	end

  def checkoutHardOnCommit(commit)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		#checkTravis = %x(find -name '.travis.yml')
		#if (checkTravis != "")
			begin
				head = "git rev-parse HEAD"
				reset = "git reset --hard " + commit
				%x(#{head})
				%x(#{reset})
			rescue
					print "IT DID NOT WORK\n"
			end
		#end
	end

	def commitAndPush(commit, branch)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		head = "git rev-parse HEAD"
		reset = "git reset --hard " + commit
		forcePush = "git push -f origin #{branch}"
		changeOnHead = false
		begin
			previousHead = %x(#{head})
			%x(#{reset})
			checkTravis = %x(find -name '.travis.yml')
			currentHead = %x(#{head})
			if (previousHead != currentHead and checkTravis != "")
				%x(#{forcePush})
				changeOnHead = true
			end
		rescue
			print "IT DID NOT WORK"
		end

		Dir.chdir getDownloadDir()
		return changeOnHead
	end

	def commitAndPushRebuiltMergeScenario(mergeCommit, leftParent, rightParent)
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		print Dir.pwd
		checkTravis = %x(find -name '.travis.yml')
		mergeResult = false
		if (checkTravis != "")
			mainBranch =  %x(git remote show origin).match(/HEAD branch: [\s\S]*  Remote branches/).to_s.match(/HEAD branch: [\s\S]*(\n)/).to_s.gsub("HEAD branch: ","").gsub("\n","")
			%x(git checkout #{mainBranch})
			%x(git clean -f)
			%x(git checkout -b leftParent #{leftParent})
			%x(git checkout #{mainBranch})
			%x(git checkout -b rightParent #{rightParent})
			merge = %x(git merge leftParent --no-edit)
			if (!merge.match(/Automatic merge failed; fix conflicts and then commit the result/) and !merge.match(/not something we can merge/) and merge != "")
				%x(git commit -a -m "Rebuilt : #{mergeCommit}")
				%x(git push -f origin)
				mergeResult = true
			else
				if (merge.match(/not something we can merge/))
					print "NO REFERENCE AVAILABLE\n"
				elsif (merge.match(/Automatic merge failed; fix conflicts and then commit the result/))
					print "UNRESOVABLE CONFLICT"
				end
				%x(git reset --merge)
			end
			%x(git checkout -f #{mainBranch})
			%x(git branch -D rightParent)
			%x(git checkout -f #{mainBranch})
			%x(git branch -D leftParent)
		end

		Dir.chdir getDownloadDir()
		return mergeResult
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
			teste = %x(#{cmd})
			while (teste.to_s.match('Repository was archived so is read-only'))
				sleep(10)
				teste = %x(#{cmd})
			end
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
=begin
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
=end
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
			deleteAllTags()
		rescue
			print "NOT CLONED"
		end
	end

	def deleteAllTags()
		deleteTags = %x(git tag | xargs git tag -d)
	end

	def checkStatusBuild()
		status = ""
		begin
			Dir.chdir getDownloadDir()
			Dir.chdir getName()
			checkout = "travis show"
			historyBuild = %x(#{checkout})
			status = historyBuild.match(/State:[\s\S]*Type/).to_s.match(/State:[\s\S]*\n/).to_s.match(/ [\s\S]*/).to_s.gsub(" ","").gsub("\n","")
		rescue 
			print "NOT CHECKOUT EXECUTED"
		end
		return status
		Dir.chdir getDownloadDir()
	end

  def buildStatusAfterCoverage()
		logs = getLogsBuild()
		logs.each do |log|
			if (log.to_s.match('Failures: [1-9]+') or log.to_s.match('Failed tests') or log.to_s.match('There are test failures'))
				return "failed"
			end
		end
		return ""
	end

	def commitChanges()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		commitStatus = false
    begin
			addFiles = %x(git add pom.xml)
			addFiles = %x(git add .travis.yml)
			sleep(5)
			commit = %x(git commit -m TT#{@tagID})
			sleep(5)
			tag = %x(git tag -m TT#{@tagID} TT#{@tagID})
			removeRemoteTag = %x(git push origin :TT#{@tagID})
			sleep(5)
			createRemoteTag = %x(git push origin TT#{@tagID})
			setTagID()
			commitStatus = true
		rescue
			print "IT WAS NOT POSSIBLE TO COMMIT\n"
		end
		Dir.chdir getDownloadDir()
		return commitStatus
	end

	def checkIdLastBuild()
		idBuild = ""
		begin
			Dir.chdir getDownloadDir()
			Dir.chdir getName()
			travisShow = "travis show"
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

  def getLogsBuild()
		Dir.chdir getDownloadDir()
		Dir.chdir getName()
		logs = []
		begin
			infoBuild = %x(travis show)
			if (infoBuild.match(/Build #[0-9\.]*:/))
				numberJobs = infoBuild.scan(/\#[0-9]*\.[0-9]*/)
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
		return logs
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

  def getTagID()
		@tagID
	end

  def setTagID()
		@tagID += 1
	end

	def getPathProject()
		return getDownloadDir() + "/" + getName()
	end

  def buildFixConflicts(hash, gitProject, projectBuildsMap)
		print "ExtractorCLI"
		gitProject.getAllChildrenFromCommit(hash).each do |fix|
			print "Attempt"
			if (projectBuildsMap[fix] == nil)
				resultFixBuild = verifyBuildCurrentState(fix, gitProject.getMainProjectBranch())
				if (resultFixBuild != nil and (resultFixBuild[0] == "passed" or resultFixBuild[0] == "failed"))
					return fix, resultFixBuild
				end
			else
				return fix, projectBuildsMap[fix][1][0]
			end
		end
		return nil
	end

	def verifyBuildCurrentState(hash, branch)
		indexCount = 0
		idLastBuild = checkIdLastBuild()
		state = replayBuildOnTravis(hash, branch)
		if (state)
			while (idLastBuild == checkIdLastBuild() and state == true)
				sleep(20)
				indexCount += 1
				if (indexCount == 10)
					return nil
				end
			end

			status = checkStatusBuild()
			while (status == "started" and indexCount < 10)
				sleep(20)
				print "Building Fix Conflict Pattern yet\n"
				status = checkStatusBuild()
			end

			return getInfoLastBuild()
		end
		return nil
	end

end