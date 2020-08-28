#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'

class UpdateHTMLFile

  def initialize(pathProject)
    @pathProject = pathProject
  end

  def updateFile(fileName, newTextHTML)
    Dir.chdir @pathProject
    oldFile = File.read("#{fileName}.html")
    if (oldFile.match('<table class="build_conflicts">[\s\S]*<\/table>'))
      first = oldFile.split(/<table class="build_conflicts">[\s\S]*<\/table>/)[0]
      second = oldFile.split(/<table class="build_conflicts">[\s\S]*<\/table>/)[1]
      setNewFile(fileName, first, newTextHTML, second)
    end
  end

  def updateFileBrokenIntegrator(fileName, newTextHTML)
    Dir.chdir @pathProject
    oldFile = File.read("#{fileName}.html")
    if (oldFile.match('<table class="build_conflicts">[\s\S]*<\/table>'))
      first = oldFile.split(/<table class="build_conflicts">[\s\S]*<\/table>/)[0]
      second = oldFile.split(/<table class="build_conflicts">[\s\S]*<\/table>/)[1]
      newFile = File.open("#{fileName}.html", "w")
      sleep(2)
      newFile.write(first)
      sleep(2)
      newFile.write(newTextHTML)
      sleep(2)
      newFile.write(second)
      sleep(2)
      newFile.close
    end
  end

  def setNewFile(fileName, first, newTextHTML, second)
    newFile = File.open("#{fileName}.html", "w")
    sleep(2)
    newFile.write(first)
    sleep(2)
    newFile.write(newTextHTML)
    sleep(2)
    newFile.write(second)
    sleep(2)
    newFile.close
  end

end