#!/usr/bin/env ruby
#file: buildTravis.rb

require 'travis'
require 'csv'
require 'rubygems'
require './Repository/MergeCommit.rb'

class ConflictAnalysis

	def initialize()
		
		@totalPushes = 0
		@totalTravis = 0
		@totalConfig = 0
		@totalSource = 0
		@totalAll = 0
		@totalTravisConf = 0
		@totalConfigConf = 0
		@totalSourceConf = 0
		@totalAllConf = 0
	end

	def getTotalPushes()
		@totalPushes
	end

	def getTotalTravis()
		@totalTravis
	end

	def getTotalConfig()
		@totalConfig
	end

	def getTotalSource()
		@totalSource
	end

	def getTotalAll()
		@totalAll
	end

	def getTotalTravisConf()
		@totalTravisConf
	end

	def getTotalConfigConf()
		@totalConfigConf
	end

	def getTotalSourceConf()
		@totalSourceConf
	end

	def getTotalAllConf()
		@totalAllConf
	end

	def setTotalPushes(value)
		@totalPushes += value
	end

	def setTotalTravis(value)
		@totalTravis += value
	end

	def setTotalConfig(value)
		@totalConfig += value
	end

	def setTotalSource(value)
		@totalSource += value
	end

	def setTotalAll(value)
		@totalAll += value
	end

	def setTotalTravisConf(value)
		@totalTravisConf += value
	end

	def setTotalConfigConf(value)
		@totalConfigConf += value
	end

	def setTotalSourceConf(value)
		@totalSourceConf += value
	end

	def setTotalAllConf(value)
		@totalAllConf += value
	end

end

