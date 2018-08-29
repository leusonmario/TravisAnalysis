#!/usr/bin/env ruby

require 'open-uri'
require 'rest-client'
require 'net/http'
require 'json'
require 'uri'
require 'nokogiri'
require 'csv'
require 'rubygems'
require 'fileutils'
require 'travis'
require 'require_all'

class RunReport

  def initialize(actualPath, finalResults)
    @path = actualPath
    @pathSite = creatingResultsDirectories()
    @pathFinalResults = finalResults
  end

  def getPath()
    @path
  end

  def getFinalResults()
    @pathFinalResults
  end

  def getSitePath()
    @pathSite
  end

  def setSitePath(path)
    @pathSite = path
  end

  def creatingResultsDirectories()
    Dir.chdir @path
    delete = %x(rm -rf Site)
    FileUtils::mkdir_p 'Site'
    Dir.chdir "Site"
    createFile("build-conflicts", "Build Conflicts")
    createFile("broken-integrator", "Broken Builds by Integrator")
    createFile("sample", "Sample")
    createFile("previous-broken", "Previous Broken Builds")
    createFile("previous-broken-with-integrator", "Broken Builds due to Previous Errors and Integrator Changes")
    return Dir.pwd
  end

  def createFile(fileName, pageTitle)
    stringSite = "
<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"utf-8\">
    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <title>#{pageTitle}</title>

    <link href=\"https://fonts.googleapis.com/css?family=Open+Sans:400,600&amp;subset=latin-ext\" rel=\"stylesheet\">

    <link href=\"css/bootstrap.min.css\" rel=\"stylesheet\">
    <link href=\"css/font-awesome.min.css\" rel=\"stylesheet\">
    <link href=\"style.css\" rel=\"stylesheet\">
  </head>
  <body style=\"font-family:verdana;\">
    <header>
      <div class=\"top\">
          <div class=\"container\">
              <div class=\"row\">
                  <div class=\"col-sm-6\">
                      <p>#{pageTitle}</p>
                  </div>
              </div>
          </div>
      </div>
    </header>
    <main class=\"site-main page-main\">
        <div class=\"container\">
            <div class=\"row\">
                <section class=\"page col-sm-9\">
                    <table class=\"build_conflicts\">
                    </table>
                </section>
            </div>
        </div>
    </main>
    <footer>
      <div class=\"container\">
        <div class=\"row\">
        </div>
        </div>
      <div id=\"copyright\">
            <div class=\"container\">
                <div class=\"cen\">
                    <div class=\"col-md-8\">

                    </div>
                </div>
            </div>
        </div>
    </footer>
    </body>
  </html>
"
    newFile = File.open("#{fileName}.html", "w")
    newFile.write(stringSite)
    newFile.close
  end

  def runReport()
    sampleInfo = SampleInfo.new(@pathFinalResults)
    projectsInfo = ProjectInfoReport.new()
    updateHTMLFile = UpdateHTMLFile.new(getSitePath())
    brokenBuilds = BrokenBuilds.new()

    updateHTMLFile.updateFile("sample", projectsInfo.getAllProjectInfo(sampleInfo.getProjectList))
    updateHTMLFile.updateFile("build-conflicts", brokenBuilds.getAllConflicts(sampleInfo.getAllErroredFiles, projectsInfo.getProjectNames))
    updateHTMLFile.updateFile("broken-integrator", brokenBuilds.getAllBrokenBuildsByIntegrator(sampleInfo.getAllErroredFiles, projectsInfo.getProjectNames))
    updateHTMLFile.updateFile("previous-broken", brokenBuilds.getAllPreviousBrokenBuilds(sampleInfo.getAllErroredFiles, projectsInfo.getProjectNames))
    updateHTMLFile.updateFile("previous-broken-with-integrator", brokenBuilds.getAllPreviousBrokenBuildsWithIntegrator(sampleInfo.getAllErroredFiles, projectsInfo.getProjectNames))
  end
end



