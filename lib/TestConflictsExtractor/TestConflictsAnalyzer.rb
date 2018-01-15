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

  def runTCAnalysisErrorCases(addModFilesRightResult, addModFilesLeftResult)
    numberChangesByFile = Hash.new
    addModFilesLeftResult.each do |key, methodsLeft|
      if (addModFilesRightResult[key] != nil)
        numberChangesByFile[key] = checkSameMethodsOnParentsFiles(methodsLeft, addModFilesRightResult[key])
      end
    end
    if (numberChangesByFile.size > 0)
      return true, false
    else
      return false,false
    end
  end

  def checkSameMethodsOnParentsFiles(methodsLeft, methodsRight)
    sameMethodChanges = 0
    methodsLeft.each do |methodLeft|
      methodsRight.each do |methodRight|
        if (methodLeft == methodRight)
          sameMethodChanges += 1
        end
      end
    end
    return sameMethodChanges
  end

  def runTCAnalysis(coverageAnalysis, addModFilesRightResult, addModFilesLeftResult)
    changedCoveragedMethodsParentOne = converagedMethodsByFile(coverageAnalysis, addModFilesLeftResult[0])
    changedCoveragedMethodsParentTwo = converagedMethodsByFile(coverageAnalysis, addModFilesRightResult[0])

    sameMethodsModified = checkChangesOnSameMethods(changedCoveragedMethodsParentOne, changedCoveragedMethodsParentTwo)
    changesOnSameMethod = false
    dependentChangesParentOne = false
    dependentChangesParentTwo = false
    if (sameMethodsModified[0].size > 0)
      changesOnSameMethod = true
    end
    if (sameMethodsModified[1].size > 0)
      dependentChangesParentOne = true
    end
    if (sameMethodsModified[2].size > 0)
      dependentChangesParentTwo = true
    end
    return changesOnSameMethod, dependentChangesParentOne, dependentChangesParentTwo, sameMethodsModified
  end

  def converagedMethodsByFile(methodsCoverage, changedMethodsByParent)
    changedCoveragedMethods = Hash.new
    generalChanges = false
    begin
      methodsCoverage.each do |key, value|
        if (changedMethodsByParent[key] != nil)
          auxOne = Array.new
          value.each do |methodName|
            changedMethodsByParent[key].each do |methodNameOne|
              #if(methodName[/#{methodNameOne}\([a-zA-Z0-9\, ]*\)/])
              if(methodName == methodNameOne)
                if (!auxOne.include? methodNameOne)
                  auxOne.push(methodName)
                end
              end
            end
            if (auxOne.size > 0)
              changedCoveragedMethods[key] = auxOne
            end
          end
        end
      end
    rescue
      print "METHODS COVERAGE WAS NULL"
    end
    return changedCoveragedMethods
  end

  def checkChangesOnSameMethods(changedCoveragedMethodsParentOne, changedConveragedMethodsParentTwo)
    sameMethodsModified = Hash.new
    differentModifiedParentOne = Hash.new
    differentModifiedParentTwo = Hash.new
    auxMethods = Array.new
    auxAllKeys = changedConveragedMethodsParentTwo.keys
    sameFile = false
    changedCoveragedMethodsParentOne.each do |key, value|
      sameFile = false
      changedConveragedMethodsParentTwo.each do |keyTwo, valueTwo|
        if (key == keyTwo)
          auxAllKeys.delete(keyTwo)
          sameFile = true
          aux = Array.new
          aux2 = Array.new
          sameMethod = false
          value.each do |methodNameOne|
            sameMethod = false
            auxMethods = Array.new
            valueTwo.each do |methodNameTwo|
              if (methodNameOne == methodNameTwo)
                sameMethod = true
                auxMethods.delete(methodNameTwo)
                if (!aux.include? methodNameTwo)
                  aux.push(methodNameOne)
                end
              elsif (!auxMethods.include? methodNameTwo and !aux.include? methodNameTwo)
                auxMethods.push(methodNameTwo)
              end
            end
            if (!sameMethod and !aux2.include? methodNameOne)
              aux2.push(methodNameOne)
            end
          end
          if (auxMethods.size > 0)
            differentModifiedParentTwo[keyTwo] = auxMethods
          end
          if (aux.size > 0)
            sameMethodsModified[key] = aux
          end
          if (aux2.size > 0)
            differentModifiedParentOne[key] = aux2
          end
        end
      end
      if (!sameFile)
        differentModifiedParentOne[key] = value
      end
    end
    auxAllKeys.each do |oneKey|
      differentModifiedParentTwo[oneKey] = changedConveragedMethodsParentTwo[oneKey]
    end

    return sameMethodsModified, differentModifiedParentOne, differentModifiedParentTwo
  end

end