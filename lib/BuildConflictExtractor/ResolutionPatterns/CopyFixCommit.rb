require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'require_all'
require 'net/http'
require 'json'
require 'uri'

class CopyFixCommit

  def initialize (pathProject, brokenCommit, fixedCommit)
    @pathProject = pathProject
    @pathCopyFix = ""
    @brokenCopyBroken = ""
    @pathCopyDirectory = ""
    createDirectories()
    createCopyProject(fixedCommit, brokenCommit)
  end

  def getPathCopyFix()
    @pathCopyFix
  end

  def createDirectories()
    Dir.chdir @pathProject
    Dir.chdir ".."
    FileUtils::mkdir_p 'Copies/Fix'
    FileUtils::mkdir_p 'Copies/Broken'
    Dir.chdir "Copies"
    @pathCopyDirectory = Dir.pwd
    Dir.chdir "Fix"
    @pathCopyFix = Dir.pwd
    Dir.chdir ".."
    Dir.chdir "Broken"
    @brokenCopyBroken = Dir.pwd
  end

  def createCopyProject(fixCommit, brokenCommit)
    Dir.chdir @pathProject
    checkout = %x(git checkout #{fixCommit} > /dev/null 2>&1)
    clone = %x(cp -R #{@pathProject} #{@pathCopyFix})
    invalidFiles = %x(find #{@pathCopyFix} -type f -regextype posix-extended -iregex '.*\.(sh|md|yaml|yml|conf|scala|properties|less|txt|gitignore|sql|html|generator|in|am|mk|ac|ico|md5)$' -delete)
    invalidFiles = %x(find #{@pathCopyFix} -type f  ! -name "*.?*" -delete)
    checkout = %x(git checkout #{brokenCommit} > /dev/null 2>&1)
    clone = %x(cp -R #{@pathProject} #{@brokenCopyBroken})
    invalidFiles = %x(find #{@brokenCopyBroken} -type f -regextype posix-extended -iregex '.*\.(sh|md|yaml|yml|conf|scala|properties|less|txt|gitignore|sql|html|generator|in|am|mk|ac|ico|md5)$' -delete)
    invalidFiles = %x(find #{@brokenCopyBroken} -type f  ! -name "*.?*" -delete)
  end

  def runAllDiff(pathGumtree)
    Dir.chdir pathGumtree
    mainDiff = nil
    modifiedFilesDiff = []
    addedFiles = []
    deletedFiles = []
    begin
      kill = %x(pkill -f gumtree)
      sleep(5)
      thr = Thread.new { diff = system "bash", "-c", "exec -a gumtree ./gumtree webdiff #{@brokenCopyBroken.gsub("\n","")} #{@pathCopyFix.gsub("\n","")}" }
      sleep(10)
      mainDiff = %x(wget http://127.0.0.1:4567/ -q -O -)
      modifiedFilesDiff = getDiffByModification(mainDiff[/Modified files <span class="badge">(.*?)<\/span>/m, 1])
      addedFiles = getDiffByAddedFile(mainDiff[/Added files <span class="badge">(.*?)<\/span>/m, 1])
      deletedFiles = getDiffByDeletedFile(mainDiff[/Deleted files <span class="badge">(.*?)<\/span>/m, 1])

      kill = %x(pkill -f gumtree)
      sleep(5)
    rescue Exception => e
      puts "GumTree Failed"
    end
    return modifiedFilesDiff, addedFiles, deletedFiles
  end

  def getDiffByModification(numberOcorrences)
    index = 0
    result = Hash.new()
    while(index < numberOcorrences.to_i)
      gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4567/script/#{index}"))
      file = gumTreePage.css('div.col-lg-12 h3 small').text[/(.*?) \-\>/m, 1].gsub(".java", "")
      script = gumTreePage.css('div.col-lg-12 pre').text
      result[file.to_s] = script.gsub('"', "\"")
      index += 1
    end
    return result
  end

  def getDiffByDeletedFile(numberOcorrences)
    index = 0
    result = []
    while(index < numberOcorrences.to_i)
      gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4567/"))
      tableDeleted = gumTreePage.to_s.match(/Deleted files[\s\S]*Added files/)[0].match(/<table [\s\S]*<\/table>/)
      Nokogiri::HTML(tableDeleted[0]).css('table tr td').each do |element|
        result.push(element.text)
      end
      index += 1
    end
    return result
  end

  def getDiffByAddedFile(numberOcorrences)
    index = 0
    result = []
    while(index < numberOcorrences.to_i)
      gumTreePage = Nokogiri::HTML(RestClient.get("http://127.0.0.1:4567/"))
      tableDeleted = gumTreePage.to_s.match(/Added files[\s\S]*<\/table>/)[0].match(/<table [\s\S]*<\/table>/)
      Nokogiri::HTML(tableDeleted[0]).css('table tr td').each do |element|
        result.push(element.text)
      end
      index += 1
    end
    return result
  end

  def deleteProjectCopies()
      delete = %x(rm -rf #{@pathCopyFix})
      delete = %x(rm -rf #{@brokenCopyBroken})
      delete = %x(rm -rf #{@pathCopyDirectory})
  end

  end