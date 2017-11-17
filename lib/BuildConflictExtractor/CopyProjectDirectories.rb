class CopyProjectDirectories

	def initialize()

	end

	def createDirectories(pathProject)
		copyBranch = []
		Dir.chdir pathProject
		Dir.chdir ".."
		FileUtils::mkdir_p 'Copies/Result'
		FileUtils::mkdir_p 'Copies/Left'
		FileUtils::mkdir_p 'Copies/Right'
		FileUtils::mkdir_p 'Copies/Base'		
		Dir.chdir "Copies"
		copyBranch.push(Dir.pwd)
		Dir.chdir "Result"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Left"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Right"
		copyBranch.push(Dir.pwd)
		Dir.chdir copyBranch[0]
		Dir.chdir "Base"
		copyBranch.push(Dir.pwd)
		return copyBranch
	end
	
	def createCopyProject(mergeCommit, parents, pathProject)
		copyBranch = createDirectories(pathProject)
		Dir.chdir pathProject
		checkout = %x(git checkout master > /dev/null 2>&1)
		base = %x(git merge-base --all #{parents[0]} #{parents[1]})
		checkout = %x(git checkout #{base} > /dev/null 2>&1)
		clone = %x(cp -R #{pathProject} #{copyBranch[4]})
		invalidFiles = %x(find #{copyBranch[4]} -type f -regextype posix-extended -iregex '.*\.(sh|vm|md|yaml|yml|conf|scala|properties|less|txt|gitignore|sql|html|gradle|stg|lex|classpath|jsp|form|sql|stg|sql.stg|py|groovy|generator|in|am|mk|ac|ico|md5)$' -delete)
		invalidFiles = %x(find #{copyBranch[4]} -type f  ! -name "*.?*" -delete)
		checkout = %x(git checkout #{mergeCommit} > /dev/null 2>&1)
		clone = %x(cp -R #{pathProject} #{copyBranch[1]})
		invalidFiles = %x(find #{copyBranch[1]} -type f -regextype posix-extended -iregex '.*\.(sh|vm|md|yaml|yml|conf|scala|properties|less|txt|gitignore|sql|html|gradle|stg|lex|classpath|jsp|form|sql|stg|sql.stg|py|groovy|generator|in|am|mk|ac|ico|md5)$' -delete)
		invalidFiles = %x(find #{copyBranch[1]} -type f  ! -name "*.?*" -delete)

		index = 0
		while(index < parents.size)
			checkout = %x(git checkout #{parents[index]} > /dev/null 2>&1)
			clone = %x(cp -R #{pathProject} #{copyBranch[index+2]} > /dev/null 2>&1)
			invalidFiles = %x(find #{copyBranch[index+2]} -type f -regextype posix-extended -iregex '.*\.(sh|vm|md|yaml|yml|conf|scala|properties|less|txt|gitignore|sql|html|gradle|stg|lex|classpath|jsp|form|sql|stg|sql.stg|py|groovy|generator|in|am|mk|ac|ico|md5)$' -delete)
			invalidFiles = %x(find #{copyBranch[index+2]} -type f  ! -name "*.?*" -delete)
			checkout = %x(git checkout master > /dev/null 2>&1)
			index += 1
		end

		return copyBranch[0], copyBranch[1], copyBranch[2], copyBranch[3], copyBranch[4]
		#      copies         result 			left 		right 			base			mergeCommit
	end

	def deleteProjectCopies(pathCopies)
		delete = %x(rm -rf #{pathCopies[0]})
	end

end