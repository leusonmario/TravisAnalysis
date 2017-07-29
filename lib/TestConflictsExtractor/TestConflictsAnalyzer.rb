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

class TestConflictsAnalyzer

  def initialize()

  end

  def runTCAnalysis(coverageAnalysis, addModFilesRightResult, addModFilesLeftResult)
    if (coverageAnalysis != nil and addModFilesRightResult[0] != nil and addModFilesLeftResult[0] != nil)
      changedCoveragedMethodsParentOne = converagedMethodsByFile(coverageAnalysis, addModFilesLeftResult[0])
      changedCoveragedMethodsParentTwo = converagedMethodsByFile(coverageAnalysis, addModFilesRightResult[0])

      sameMethodsModified = checkChangesOnSameMethods(changedCoveragedMethodsParentOne, changedCoveragedMethodsParentTwo)
      changesOnSameMethod = false
      dependentChanges = false
      if (sameMethodsModified.size > 0)
        changesOnSameMethod = true
      end
      if (sameMethodsModified.size < changedCoveragedMethodsParentOne.size or sameMethodsModified.size < changedCoveragedMethodsParentTwo.size)
        dependentChanges = true
      end
      return changesOnSameMethod, dependentChanges
    else
      return false, false
    end

  end

  def converagedMethodsByFile(methodsCoverage, changedMethodsByParent)
    changedCoveragedMethods = Hash.new
    methodsCoverage.each do |key, value|
      if (changedMethodsByParent[key] != nil)
        auxOne = Array.new
        value.each do |methodName|
          changedMethodsByParent[key].each do |methodNameOne|
            if(methodName[/#{methodNameOne}\([a-zA-Z0-9\, ]*\)/])
              if (!auxOne.include? methodNameOne)
                auxOne.push(methodName)
              end
            end
          end
          if (auxOne.size > 1)
            changedCoveragedMethods[key] = auxOne
          end
        end
      end
    end
    return changedCoveragedMethods
  end

  def checkChangesOnSameMethods(changedCoveragedMethodsParentOne, changedConveragedMethodsParentTwo)
    sameMethodsModified = Hash.new
    changedCoveragedMethodsParentOne.each do |key, value|
      changedConveragedMethodsParentTwo.each do |keyTwo, valueTwo|
        if (key == keyTwo)
          aux = Array.new
          value.each do |methodNameOne|
            valueTwo.each do |methodNameTwo|
              if (methodNameOne == methodNameTwo)
                if (!aux.include? methodNameTwo)
                  aux.push(methodNameOne)
                end
              end
            end
          end
          if (aux.size > 0)
            sameMethodsModified[key] = aux
          end
        end
      end
    end
    return sameMethodsModified
  end
end