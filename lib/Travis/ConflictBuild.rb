#!/usr/bin/env ruby
#file: conflictBuild.rb

class ConflictBuild

	def initialize(projectPath)
		@projectPath = projectPath
	end

	def getProjectPath()
		@projectPath
	end

	def typeConflict(build)
		statusConfig = true
		Dir.chdir @projectPath
		filesConflict = %x(git diff --name-only #{build.commit.sha}^!)
		if (filesConflict == ".travis.yml\n")
			return "Travis"
		else
			filesConflict.each_line do |newLine|
				if (!newLine[/.*pom.xml\n*$/] and !newLine[/.*.gradle\n*$/])
					#linha nao apresentou mudanças nos arquivos de configuraçao do projeto - MUDANÇA NAO FOI APENAS NOS ARQUIVOS DE CONFIGURAÇAO
					statusConfig = false
					break
				end
			end

			if (statusConfig)
				return "Config"
			else
				# depois dividir em apenas arquivos de codigo fonte, e a juncao dos outros
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
