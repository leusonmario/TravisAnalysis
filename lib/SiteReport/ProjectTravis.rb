#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'travis'

class ProjectTravis

  def initialize

  end

  def getBuildsProject(projectName)
    projectBuilds = Hash.new
    if (projectName != nil)
      repository = Travis::Repository.find("leusonmario/#{projectName.split('/').last}")
      repository.each_build do |build|
        projectBuilds[build.id] = build.commit.sha
      end
      return projectBuilds
    end
  end

end