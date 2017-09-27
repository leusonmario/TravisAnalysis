require 'open-uri'
require 'rest-client'
require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'
require 'csv'
require 'rubygems'
require 'fileutils'
require 'csv'

class TestCaseCoverage

  def initialize(pathProject, extractorCLI)
    @pathProject = pathProject
    @extractorCLI = extractorCLI
  end

  def runTestCase(testFileName, testCaseName, sha)
    actualPath = Dir.pwd
    Dir.chdir @pathProject
    coverageResult = nil
    begin
      @extractorCLI.checkoutHardOnCommit(sha)
      resultPluginPom = addPluginOnPom(nil)
      if (@extractorCLI.getApiKey == "")
        @extractorCLI.addEncryptedKeyOnTravis()
      end
      resultTravisFile = addInfoOnTravisFile(testFileName, testCaseName, @extractorCLI.getApiKey)
      #@extractorCLI.addEncryptedKeyOnTravis()
      if (resultPluginPom and resultTravisFile)
        state = @extractorCLI.commitChanges()
        Dir.chdir @pathProject
        if (verifyBuildCurrentState(state) == "failed")
          coverageResult = coverageAnalysis(@extractorCLI.getUsername, @extractorCLI.getName, @pathProject)
        end
      end
    rescue
      print "NOT A VALID CASE\n"
    end
    Dir.chdir actualPath
    return coverageResult, @extractorCLI.checkIdLastBuild()
  end

  def verifyBuildCurrentState(state)
    indexCount = 0
    idLastBuild = @extractorCLI.checkIdLastBuild()
    if (state)
      while (idLastBuild == @extractorCLI.checkIdLastBuild() and state == true)
        sleep(20)
        indexCount += 1
        if (indexCount == 10)
          return nil
        end
      end

      status = @extractorCLI.checkStatusBuild()
      while (status == "started" and indexCount < 10)
        sleep(20)
        print "Build commit for covergare report\n"
        status = @extractorCLI.checkStatusBuild()
      end
      if (@extractorCLI.buildStatusAfterCoverage == "failed")
        return "failed"
      end
      return status
    end
    return nil
  end

  def addInfoOnTravisFile(testFileName, testCaseName, apiKey)
    actualPath = Dir.pwd
    Dir.chdir @extractorCLI.getDownloadDir
    Dir.chdir @extractorCLI.getName
    finalResult = false
    begin
      file = File.read(".travis.yml")
      lines = ""
      beforeDeploy = false
      deploy = false
      script = false
      testScript = false
      requiredSudo = false
      onTags = false
      providerReleases = false
      fileGlob = false
      overwrite = false
      skipCleanup = false
      fileAdd = false

      file.each_line do |line|
        if (line.match('sudo: false') or line.match('sudo: required'))
          lines += "\nsudo: required\n"
          requiredSudo = true
        elsif (line.match('before_deploy:'))
          beforeDeploy = true
          lines += line
          lines += "\n- tar -zcvf coverage-result.tar.gz /home/travis/build/#{@extractorCLI.getUsername}/#{@extractorCLI.getName}/target/site\n"
        elsif (line.match('deploy'))
          deploy = true
          lines += line
        elsif (line.match('script:'))
          script = true
          lines += line
        elsif (script and !testScript)
          if (line.match('mvn (clean)? test'))
            lines += "\n  - mvn clean -Dtest=#{testFileName}##{testCaseName} test jacoco:report coveralls:report\n"
            testScript = true
          elsif ((line == "\n" or line == "") and testScript)
            script = true
            testScript = true
            lines += "\n  - mvn clean -Dtest=#{testFileName}##{testCaseName} test jacoco:report coveralls:report\n"
          else
            lines += line
          end
        elsif (deploy)
          if (line.match('provider:'))
            lines += "\nprovider: releases"
            providerRelease = true
          elsif (line.match('file_glob:'))
            lines += "\nfile_glob: true"
            fileGlob = true
          elsif (line.match('overwrite:'))
            lines += "\noverwrite: true"
            overwrite = true
          elsif (line.match('skip_cleanup:'))
            lines += "\nskip_cleanup: true"
            skipCleanup = true
          elsif (line.match("file:"))
            deploy = true
            lines +=  line
            lines += "\nfile: coverage-result.tar.gz"
            fileAdd = true
          elsif (line.match('on:'))
            lines += "\non:\ttags: true"
            onTags = true
          else
            lines += line
          end
        else
          lines += line
        end
      end

      requiredSudoText = ""
      deployText = ""
      beforeDeployText = ""
      scriptText = ""

      if (!script)
        scriptText = "\nscript:\n- mvn clean -Dtest=#{testFileName}##{testCaseName} test jacoco:report coveralls:report\n"
      end
      #if (!testScript)
      #  scriptText = "\n- mvn clean -Dtest=#{testFileName}##{testCaseName} test jacoco:report coveralls:report\n"
      #end

      if (!beforeDeploy)
        beforeDeployText = "\n\nbefore_deploy:\n- tar -zcvf coverage-result.tar.gz /home/travis/build/#{@extractorCLI.getUsername}/#{@extractorCLI.getName}/target/site\n"
      end

      if (!requiredSudo)
        requiredSudoText = "\nsudo: required\n"
      end

      if (!deploy)
        deployText = "\ndeploy:\n  provider: releases
  api_key:
    secure: #{apiKey}
  file: coverage-result.tar.gz
  file_glob: true
  overwrite: true
  skip_cleanup: true
  on:
    tags: true"
      else
        deployText = "api_key:
    secure: #{apiKey}"
        if (!fileGlob)
          deployText += "\nfile_glob: true"
        end
        if (!overwrite)
          deployText += "\noverwrite: true"
        end
        if (!skipCleanup)
          deployText += "\nskip_cleanup: true"
        end
        if(!fileAdd)
          deployText += "\nfile: coverage-result.tar.gz"
        end
        if (!onTags)
          deployText += "\non:
    tags: true"
        end
      end
      newText = ""
      newText += requiredSudoText
      newText += lines
      if (!script)
        newText += scriptText
      end
      if (deploy)
        newText += deployText
        newText += beforeDeployText
      else
        newText += beforeDeployText
        newText += deployText
      end
      out_file = File.new(".travis.yml", "w")
      sleep(5)
      out_file.puts(newText)
      sleep(5)
      out_file.close
      finalResult = true
    rescue
      print "NOT POSSIBLE TO EDIT TRAVIS FILE\n"
    end
    Dir.chdir actualPath
    return finalResult
  end

  def addPluginOnPom(coverallsID)
    coverallsID = "0LB8D9FfE1FwmYHkWiVLVg4TFsI5gX64k"
    actualPath = Dir.pwd
    Dir.chdir @extractorCLI.getDownloadDir
    Dir.chdir @extractorCLI.getName
    begin
      file = File.read("pom.xml")
      sleep (5)
      pluginsOnPom = "  <plugin>
        <groupId>org.eluder.coveralls</groupId>
        <artifactId>coveralls-maven-plugin</artifactId>
        <version>4.3.0</version>
        <configuration>
            <repoToken>#{coverallsID}</repoToken>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <version>0.7.6.201602180812</version>
        <executions>
            <execution>
                <id>prepare-agent</id>
                <goals>
                    <goal>prepare-agent</goal>
                </goals>
            </execution>
        </executions>
      </plugin>
    <\/plugins>"

      if (file.match('<build>[\s\S]*<plugins>[\s\S]*<\/build>'))
        first = file.split(/<build>[\s\S]*<plugins>[\s\S]*<\/build>/)[0]
        second = file.split(/<build>[\s\S]*<plugins>[\s\S]*<\/build>/)[1]
        aux = file.match(/<build>[\s\S]*<plugins>[\s\S]*<\/build>/)[0]
        if (aux.match(/<\/plugins>[\s\S]*<\/build>/))
          aux = aux.to_s.gsub(/<\/plugins>/, pluginsOnPom)
          file = File.open("pom.xml", "w")
          sleep(5)
          file.write(first)
          file.write(aux)
          file.write(second)
          sleep(5)
          file.close
        end
      end
      pluginTag = false
      configTag = false
      closeConfigTag = false
      pluginSurefire = false
      newText = ""
      file = File.read("pom.xml")
      sleep (5)
      file.each_line do |line|
        newText += line
        if (line.match("<plugin>"))
          pluginTag = true
        end
        if (line.match("</plugin>"))
          pluginTag = true
        end
        if (line.match("<artifactId>maven-surefire-plugin</artifactId>"))
          pluginSurefire = true
        end
        if (line.match('<configuration>') and pluginSurefire and pluginTag)
          newText += "<testFailureIgnore>true</testFailureIgnore>"
          configTag = false
          pluginSurefire = false
        end
        if (line.match("</configuration>"))
          configTag = false
        end
      end

      out_file = File.new("pom.xml", "w")
      sleep(5)
      out_file.puts(newText)
      out_file.close

      Dir.chdir actualPath
      return true
    rescue
      print "POM ERROR - PROBLEM"
      Dir.chdir actualPath
      return false
    end
  end

  def undoPomChanges()
    Dir.chdir @pathProject
    checkout = %x(git checkout .)
    sleep 5
  end

  def coverageAnalysis(username, projectName, pathDownload)
    #vai receber como parâmetro o nome do projeto, e o path
    coverageResult = nil
    begin
      pathReport = checkoutFilesLastBuild(pathDownload)

      #Dir.chdir pathReport.gsub('jacoco.csv','').gsub('./','').gsub("\n",'').to_s
      Dir.chdir pathReport.split('jacoco.csv')[0]

      packagesCovered = []
      csvCoverageFile = File.read('jacoco.csv')
      csv = CSV.parse(csvCoverageFile, :headers => true)

      csv.each do |row|
        if (row[4] != "0")
          packagesCovered.push([row[1], row[2]])
        end
      end
      #dormir aqui
      coverageResult = coveragedMethodsByFile(packagesCovered)
      deleteFilesLastBuild(pathDownload)
    rescue
      print "0NOT AVAILABLE INFORMATION\n"
    end
    return coverageResult
  end

  def coveragedMethodsByFile(packagesCovered)
    localPath = Dir.pwd
    hashMap = Hash.new
    packagesCovered.each do |package|
      Dir.chdir package[0]
      actualFile = package[1].to_s.gsub("\.", "\$")
      begin
        doc = File.open("#{actualFile}.html") { |f| Nokogiri::XML(f) }
        sleep(2)
        #dormir aqui
        values = Array.new
        doc.css('table tbody tr').each do |element|
          if (element.css('td')[2].text != "n/a" and element.css('td')[2].text != "0%")
            values.push(element.css('td')[0].text)
          end
        end
        hashMap[actualFile] = values
      rescue

      end
      Dir.chdir localPath
    end
    return hashMap
  end

  def deleteFilesLastBuild(pathCheckoutFiles)
    actualPath = Dir.pwd
    Dir.chdir pathCheckoutFiles
    begin
      deleteZip = %x(rm -r coverage-result.tar.gz)
      deleteFolder = %x(rm -r home)
    rescue
      print "NO FILE WAS FOUND\n"
    end
    #Dir.chdir actualPath
  end

  def checkoutFilesLastBuild(pathCheckoutFiles)
    actualPath = Dir.pwd
    Dir.chdir pathCheckoutFiles
    jacocoPath = ""
    begin
      resultRequestion =%x(curl https://api.github.com/repos/#{@extractorCLI.getUsername}/#{@extractorCLI.getName}/releases/latest)
      jsonInfo = JSON.parse(resultRequestion)
      assetID = jsonInfo['assets'][0]['id']
      result = %x(curl -vLJO -H 'Accept: application/octet-stream' 'https://api.github.com/repos/#{@extractorCLI.getUsername}/#{@extractorCLI.getName}/releases/assets/#{assetID}')
      sleep(20)
      unzip = %x(tar xvzf coverage-result.tar.gz)
      jacocoPath = %x(find -name jacoco.csv)
    rescue
      print "NOT AVAILABLE INFORMATION\n"
    end
    return jacocoPath
  end

end