class MergeCommit

	def initialize()
		@parentsCommit = Array.new
	end

	def getParentsMergeIfTrue(pathProject, commit)
		Dir.chdir pathProject.gsub('.travis.yml','')
		commitType = %x(git cat-file -p #{commit})
		commitType.each_line do |line|
			if(line.include?('author'))
				break
			end
			if(line.include?('parent'))
				commitSHA = line.partition('parent ').last.gsub('\n','').gsub(' ','').gsub('\r','')
				@parentsCommit.push(commitSHA[0..39].to_s)
			end
		end

		if (@parentsCommit.size > 1)
			return @parentsCommit
		else
			return nil
		end
	end

	def getTypeConflict(pathProject, commit)
		Dir.chdir @pathProject
		filesConflict = %x(git diff --name-only #{@commit}^!)
		statusConfig = true
		if (filesConflict == ".travis.yml\n")
			return "Travis"
		else
			filesConflict.each_line do |newLine|
				if (!newLine[/.*pom.xml\n*$/] and !newLine[/.*build.gradle\n*$/])
					statusConfig = false
					break
				end
			end

			if (statusConfig)
				return "Config"
			else
				if (filesConflict.include?('pom.xml') || filesConflict.include?('build.gradle') || filesConflict.include?('.travis.yml') || filesConflict.include?('.java'))
					return "All"	
				else
					return "SourceCode"
				end
			end
		end
	end

end