class MergeCommit

	def initialize()

	end

	def getParentsMergeIfTrue(pathProject, commit)
		parentsCommit = []
		Dir.chdir pathProject.to_s.gsub('.travis.yml','')
		commitType = %x(git cat-file -p #{commit})
		commitType.each_line do |line|
			if(line.include?('author'))
				break
			end
			if(line.include?('parent'))
				commitSHA = line.partition('parent ').last.gsub("\n","").gsub(' ','').gsub('\r','')
				parentsCommit.push(commitSHA)
			end
		end

		if (parentsCommit.size > 1)
			baseCommit = checkIfFastFoward(parentsCommit[0], parentsCommit[1])
			if (baseCommit != "")
				parentsCommit.push(baseCommit)
			end
			return parentsCommit
		else
			return nil
		end
	end

  def checkIfFastFoward(parentOne, parentTwo)
		baseCommit = %x(git merge-base #{parentOne} #{parentTwo}).gsub("\n","")
		if (baseCommit == parentOne or baseCommit == parentTwo)
			return ""
		else
			return baseCommit
		end
	end

	def getTypeConflict(pathProject, commit)
		Dir.chdir pathProject
		filesConflict = %x(git diff --name-only #{commit}^!)
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