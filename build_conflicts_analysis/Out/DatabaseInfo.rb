require 'fileutils'
require 'csv'
require 'require_all'
require_all './CausesExtractor'

class DatabaseInfo

  def initialize(actualPath)
    @databaseInfoPath = actualPath
  end

  def checkDirectoryExists(directoryName)
    return File.directory? (directoryName.gsub("/","#"))
  end

  def createDirectoryForProject(projectName)
    Dir.chdir @databaseInfoPath
    if (!checkDirectoryExists(projectName))
      directoryName = projectName.gsub("/","#")
      FileUtils::mkdir_p directoryName
    end
  end

  def createBuildDirectoryForMergeScenario(hashCommit, projectName)
    Dir.chdir @databaseInfoPath
    if (File.directory? (projectName.gsub("/","#")))
      FileUtils::mkdir_p "#{hashCommit}/files/build"
    end
  end

  def createSourceCodeDirectoryForMergeScenario(hashCommit, projectName)
    Dir.chdir @databaseInfoPath
    if (File.directory? (projectName.gsub("/","#")))
      FileUtils::mkdir_p "#{hashCommit}/files/code"
    end
  end


  def saveBuildLogForCommit(hashCommit, mergeCommit, projectName, buildLog)
    Dir.chdir @databaseInfoPath
    directoryName = projectName.gsub("/","#")

    if (!checkDirectoryExists("#{projectName}/#{hashCommit}/files/build"))
      createBuildDirectoryForMergeScenario(hashCommit, projectName)
    end
    Dir.chdir "#{directoryName}/#{mergeCommit}/files/build"
    file = File.open("#{hashCommit}.log", "w")
    file.puts buildLog
    file.close
  end

  def saveCodeForCommit(hashCommit, mergeCommit, projectName, pathClone, category)
    Dir.chdir @databaseInfoPath
    directoryName = projectName.gsub("/","#")

    if (!checkDirectoryExists("#{projectName}/#{hashCommit}/files/code"))
      createSourceCodeDirectoryForMergeScenario(hashCommit, projectName)
    end

    Dir.chdir "#{directoryName}/#{mergeCommit}/files/code"
    FileUtils::mkdir_p "#{category}-#{hashCommit}"
    Dir.chdir "#{category}-#{hashCommit}"
    destination = Dir.pwd

    FileUtils.copy_entry pathClone, destination
  end

  def creatingResultsDirectories(actualPath)
    Dir.chdir actualPath
    FileUtils::mkdir_p 'ErroredCauses'
    FileUtils::mkdir_p 'ErroredCases/AllBuilds'
    FileUtils::mkdir_p 'ErroredCases/PullRequests'
    FileUtils::mkdir_p 'FailedCases'

    Dir.chdir "ErroredCauses"
    @pathErroredCauses = Dir.pwd
    Dir.chdir actualPath
    Dir.chdir "ErroredCases/AllBuilds"
    @pathErroredCasesBuilds = Dir.pwd
    Dir.chdir actualPath
    Dir.chdir "ErroredCases/PullRequests"
    @pathErroredCasesPullRequests = Dir.pwd
    Dir.chdir actualPath
    Dir.chdir "FailedCases"
    @pathFailedCases = Dir.pwd
    createCSV()
  end

end