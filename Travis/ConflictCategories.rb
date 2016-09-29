#!/usr/bin/env ruby
#file: conflictCategories.rb

require 'travis'
require 'csv'
require 'rubygems'

module ConflictCategories

	def findConflictCause(build)
		raise NotImplementedError
	end

end