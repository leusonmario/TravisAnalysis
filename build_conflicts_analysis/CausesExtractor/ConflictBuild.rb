class ConflictBuild

	def initialize(projectPath)
		@projectPath = projectPath
	end

	def getProjectPath()
		@projectPath
	end

	def typeConflict(sha)
		statusConfig = true
		Dir.chdir @projectPath
		filesConflict = %x(git diff --name-only #{sha}^!)
		if (filesConflict == ".travis.yml\n")
			return "Travis"
		else
			filesConflict.each_line do |newLine|
				if (!newLine[/.*pom.xml\n*$/] and !newLine[/.*.gradle\n*$/])
					statusConfig = false
					break
				end
			end

			if (statusConfig)
				return "Config"
			else
				if (filesConflict.include?('pom.xml') || filesConflict.include?('.gradle') || filesConflict.include?('.travis.yml'))
					if (filesConflict.include?('pom.xml') || filesConflict.include?('.gradle'))
						return "All-Config"
					else
						return "All"
					end	
				else
					return "SourceCode"
				end
			end
		end
	end

	def conflictAnalysisCategories(conflictAnalysis, type, mergeScenario)
		conflictAnalysis.setTotalPushes(1)
		if (type=="Travis")
			conflictAnalysis.setTotalTravis(1)
			if (mergeScenario) 
				conflictAnalysis.setTotalTravisConf(1)
				return true
			end
		elsif (type=="Config")
			conflictAnalysis.setTotalConfig(1)
			if (mergeScenario) 
				conflictAnalysis.setTotalConfigConf(1)
				return true
			end
		elsif (type=="SourceCode")
			conflictAnalysis.setTotalSource(1)
			if (mergeScenario) 
				conflictAnalysis.setTotalSourceConf(1)
				return true
			end
		else
			conflictAnalysis.setTotalAll(1)
			if (mergeScenario) 
				conflictAnalysis.setTotalAllConf(1)
				return true
			end
		end
		return false
	end

	def getBuildStatus(build)
		if build.state == 'errored'  
			return "errored"
		elsif build.state == 'failed'    
			return "failed"
		elsif build.state == 'passed'    
			return "passed"
		elsif build.state == 'canceled'    
			return "canceled"
		end
	end

end
