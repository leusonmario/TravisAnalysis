#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'csv'

class SampleInfo

  def initialize(pathResultFiles)
    @pathResults = pathResultFiles
  end

  def getProjectList()
    Dir.chdir @pathResults
    allFilesCSVProjects = Array.new
    csvFilesProjects = %x(find . -type f -name 'MergeScenariosProjects.csv')
    csvFilesProjects.each_line do |oneCSV|
      if (!allFilesCSVProjects.include? oneCSV)
        allFilesCSVProjects.push(oneCSV)
      end
    end
    return allFilesCSVProjects
  end

  def getAllErroredFiles()
    Dir.chdir @pathResults
    allFilesCSVProjects = Array.new
    csvFilesProjects = %x(find . -type f -name 'Errored*.csv')
    csvFilesProjects.each_line do |oneCSV|
      if (!allFilesCSVProjects.include? oneCSV)
        allFilesCSVProjects.push(oneCSV)
      end
    end
    return allFilesCSVProjects
  end

end