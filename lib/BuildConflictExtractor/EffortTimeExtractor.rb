require 'require_all'
require 'travis'
require 'active_support/core_ext/numeric/time'
require 'date'

class EffortTimeExtractor
	@projectBuildsMap = Hash.new()
	@projectPath = ""

	def initialize(projectBuilds, path)
		@projectBuildsMap = projectBuilds
		@projectPath = path
	end

	def checkFixedBuild(commit)
		brokenCommit = commit
		numberBuilsTillFix = 0
		@projectBuildsMap.each do |key, value|
			if (checkFailedCommitAsParent(brokenCommit, key))
				if (value[0] == "passed" or value[0] == "failed")
					result = checkTimeEffort(brokenCommit, key)
					return value[1], result[0], numberBuilsTillFix, result[1], result[2]
				else
					numberBuilsTillFix += 1
					brokenCommit = key
				end
			end
		end
		return nil
	end

	def checkFailedCommitAsParent(brokenCommit, fixedCommit)
		Dir.chdir @projectPath

		commitInfo = %x(git cat-file -p #{fixedCommit})
		commitInfo.each_line do |line|
			if(line.include?('author'))
				break
			end
			if(line.include?('parent'))
				commitSHA = line.partition('parent ').last.to_s.gsub("\n","").gsub(' ','').gsub('\r','')
				if (commitSHA == brokenCommit)
					return true
				end
			end
		end
		return false
	end

	def checkTimeEffort (brokenCommit, fixedCommit)
		brokenCommitInfo = getFixedProcessCommit(brokenCommit)
		fixedCommitInfo = getFixedProcessCommit(fixedCommit)
		sameAuthors = false
		sameCommiter = false
		intervalTime = (DateTime.parse(fixedCommitInfo[2]) - DateTime.parse(brokenCommitInfo[2])).to_i

		if (brokenCommitInfo[0] == fixedCommitInfo[0]) 
			sameAuthors = true
		end

		if (brokenCommitInfo[1] == fixedCommitInfo[1]) 
			sameCommiter = true
		end
		return intervalTime, sameAuthors, sameCommiter
	end

	def getFixedProcessCommit(commit)
		Dir.chdir @projectPath

		author = ""
		committer = ""
		date = %x(git show -s --format=%cd #{commit})
		commitInfo = %x(git cat-file -p #{commit})

		commitInfo.each_line do |line|
			if (line.include?('author'))
				author = line.partition('author ').last
			end
			if (line.include?('committer'))
				committer = line.partition('committer ').last
			end
		end

		return author, committer, date
	end
end