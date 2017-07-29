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

  def initialize(pathProject)
    @pathProject = pathProject
  end

  def runTestCase(testFileName, testCaseName, sha)
    actualPath = Dir.pwd
    Dir.chdir @pathProject

    begin
      checkout = %x(git checkout #{sha})
      addPluginOnPom()
      Dir.chdir @pathProject
      sleep 5
      stringRunTest = "mvn clean -Dtest=#{testFileName}##{testCaseName} test jacoco:report coveralls:report"
      runTest = %x(#{stringRunTest})
      sleep 30
      coverageResult = coverageAnalysis()
      undoPomChanges()
      return coverageResult
    rescue
      return nil
    end
    Dir.chdir actualPath
  end

  def addPluginOnPom()
    begin
      file = File.read("pom.xml")
      pluginsOnPom = "  <plugin>
        <groupId>org.eluder.coveralls</groupId>
        <artifactId>coveralls-maven-plugin</artifactId>
        <version>4.3.0</version>
        <configuration>
            <repoToken>yourcoverallsprojectrepositorytoken</repoToken>
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
          file.write(first)
          file.write(aux)
          file.write(second)
          file.close
        end
      end
      return true
    rescue
      return false
    end
  end

  def undoPomChanges()
    Dir.chdir @pathProject
    checkout = %x(git checkout .)
    sleep 5
  end

  def coverageAnalysis()
    begin
      pathReport = %x(find . -name 'jacoco.csv')

      Dir.chdir pathReport.gsub('jacoco.csv','').gsub('./','').gsub("\n",'').to_s

      packagesCovered = []
      csvCoverageFile = File.read('jacoco.csv')
      csv = CSV.parse(csvCoverageFile, :headers => true)

      csv.each do |row|
        if (row[4] != "0")
          packagesCovered.push([row[1], row[2]])
        end
      end
      return coveragedMethodsByFile(packagesCovered)
    rescue
      return nil
    end
  end

  def coveragedMethodsByFile(packagesCovered)
    localPath = Dir.pwd
    hashMap = Hash.new
    packagesCovered.each do |package|
      Dir.chdir package[0]
      actualFile = package[1].to_s.gsub("\.", "\$")
      begin
        doc = File.open("#{actualFile}.html") { |f| Nokogiri::XML(f) }
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

end