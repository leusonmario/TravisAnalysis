#!/usr/bin/env ruby
#file: buildTravis.rb

require 'travis'
require 'csv'
require 'rubygems'

class BuildTravis

	def initialize()
		
	end

	def getStatusBuildsProject(projectName, pathResultByProject)
		buildTotalPush = 0
		buildTotalPull = 0
		buildPushPassed = 0
		buildPushErrored = 0
		buildPushFailed = 0
		buildPushCanceled = 0
		buildPullPassed = 0
		buildPullErrored = 0
		buildPullFailed = 0
		buildPullCanceled = 0
		type = ""

		Dir.chdir pathResultByProject
		CSV.open(projectName.partition('/').last+"FinalTest.csv", "w") do |csv|
 			csv << ["Status", "Type", "Commit", "ID"]
 		end
		
		buildProjeto = Travis::Repository.find(projectName)
		buildProjeto.each_build do |build|
			if (build != nil)
				status = getInfoBuild(build)
				if build.pull_request
					buildTotalPull += 1
					type = "pull"
					if (status == "passed")
						buildPullPassed += 1
					elsif (status == "errored")
						buildPullErrored += 1
					elsif (status == "failed")
						buildPullFailed += 1
					else
						buildPullCanceled += 1
					end
				else
					buildTotalPush += 1
					type = "push"
					if (status == "passed")
						buildPushPassed += 1
					elsif (status == "errored")
						buildPushErrored += 1
					elsif (status == "failed")
						buildPushFailed += 1
					else
						buildPushCanceled += 1
					end
				end
			end
			CSV.open(projectName.partition('/').last+"FinalTest.csv", "a+") do |csv|
 				csv << [build.state, type, build.commit.sha, build.id]
 			end
		end
		
		return projectName, buildTotalPush, buildPushPassed, buildPushErrored, buildPushFailed, buildPushCanceled, buildTotalPull, buildPullPassed, buildPullErrored, buildPullFailed, buildPullCanceled
	end

	def getInfoBuild(build)
		if build.state == 'errored'  
			return "errored"
		elsif build.state == 'failed'    
			return "failed"
		elsif build.state == 'passed'    
			return "passed"
		elsif build.state == 'canceled'    
			return "canceled"
		end
	end

end