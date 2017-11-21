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

class BCTypesCount

  def initializer()

  end

  def getErroredFiles()
    allFilesCSV = Array.new
    csvFiles = %x(find . -type f -name 'Errored*.csv')
    csvFiles.each_line do |oneCSV|
      if (!allFilesCSV.include? oneCSV)
        allFilesCSV.push(oneCSV)
      end
    end
    return allFilesCSV
  end

  def runTypesCount()
    exitString = ""
    cleanBC = Hash.new
    uncleanBC = Hash.new
    badlyDeveloperNotAllIntegrated = Hash.new
    badlyDeveloperAllIntegrated = Hash.new
    cleanBCDep = Hash.new
    uncleanBCDep = Hash.new

    cleanBCConflicting = Hash.new
    cleanDeveloper = Hash.new

    dependencyBC = Hash.new
    fix = 0
    otherFix = 0
    bcCases = 0

    timeClean = Array.new
    timeUnclean = Array.new
    timeBadly = Array.new
    countCases = 0
    sameAuthor = 0
    differentAuthor = 0
    allContributions = 0
    notAllContributions = 0
    bcAllConflicting = 0
    bcAllDeveloper = 0
    bcNotAllConflicting = 0
    bcNotAllDeveloper = 0

    allFilesCSV = getErroredFiles()

    allFilesCSV.each do |oneCsv|
      CSV.foreach(oneCsv.to_s.gsub("./","").gsub("\n","")) do |row|
        countState = 0
        newCount = 0
        if (row[3].to_s != "MessageState")
          countCases += 1
        end
        if (row[3].to_s != "\[\"gitProblem\"\]" and row[3].to_s != "\[\"compilerError\"\]" and row[3].to_s != "\"compilerError\"" and row[3].to_s != "\[\"remoteError\"\]" and row[3].to_s != "\"remoteError\"" and row[3].to_s != "MessageState")
          states = row[5].to_s.gsub("\"","").gsub("\[","").gsub("\]","").to_s.to_enum(:scan, /[a-zA-Z]*/).map { Regexp.last_match }
          bcDependency = row[8].to_s.gsub("\"","").gsub("\[","").gsub("\]","").to_s.to_enum(:scan, /[a-zA-Z]*/).map { Regexp.last_match }
          aux = 0
          if (states[countState].to_s != "ConflictingContributions")
            count = -1
            if (!row[3].to_s.match('MessageState') and !row[3].to_s.match('\[\"gitProblem\"\]') and !row[3].to_s.match('\"gitProblem\"\]') and !row[3].to_s.match('\[\"compilerError\"\]') and !row[3].to_s.match('\"compilerError\"') and !row[3].to_s.match('\[\"remoteError\"\]') and !row[3].to_s.match("\"remoteError\"") and !row[3].to_s.match('\[\]'))
              bcCases += 1
            end

            while (countState < states.size)
              if (states[countState].to_s != "")
                count += 1
                if (states[countState].to_s == "true" and row[6] == "true")
                  conflicts = row[3].to_s.to_enum(:scan, /\"[a-zA-Z]*\"/).map { Regexp.last_match }
                  if (cleanBC[conflicts[count].to_s] != nil and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeClean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    if (bcDependency[countState].to_s == "false")
                      bcAllConflicting += 1
                      aux = cleanBC[conflicts[count].to_s]
                      cleanBC[conflicts[count].to_s] = aux + 1
                    else
                      bcAllConflicting += 1
                      if (cleanBCDep[conflicts[count].to_s] != nil and cleanBCDep[conflicts[count].to_s] != "")
                        aux = cleanBCDep[conflicts[count].to_s]
                        cleanBCDep[conflicts[count].to_s] = aux + 1
                      else
                        #verificar se tem o elemento antes de colocar novamente
                        cleanBCDep[conflicts[count].to_s] = 1
                      end
                    end
                  elsif (conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeClean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end

                    if (bcDependency[countState].to_s == "false")
                      bcAllConflicting += 1
                      cleanBC[conflicts[count].to_s] = 1
                    else
                      bcAllConflicting += 1
                      if (cleanBCDep[conflicts[count].to_s] != nil and cleanBCDep[conflicts[count].to_s] != "")
                        aux = cleanBCDep[conflicts[count].to_s]
                        cleanBCDep[conflicts[count].to_s] = aux + 1
                      else
                        #verificar se tem o elemento antes de colocar novamente
                        cleanBCDep[conflicts[count].to_s] = 1
                      end
                      #cleanBCDep[conflicts[count].to_s] = 1
                    end
                  end
                elsif (states[countState].to_s == "true" and row[6] == "false")
                  #conflicting contributions even when not all contributions are not preserved
                  conflicts = row[3].to_s.to_enum(:scan, /\"[a-zA-Z]*\"/).map { Regexp.last_match }
                  if (uncleanBC[conflicts[count].to_s] != nil and conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeUnclean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    if (bcDependency[countState].to_s == "false")
                      aux = uncleanBC[conflicts[count].to_s]
                      uncleanBC[conflicts[count].to_s] = aux + 1
                      bcNotAllConflicting += 1
                    else
                      bcNotAllConflicting += 1
                      if (uncleanBCDep[conflicts[count].to_s] != nil)
                        aux = uncleanBCDep[conflicts[count].to_s]
                        uncleanBCDep[conflicts[count].to_s] = aux + 1
                      else
                        #verificar se tem o elemento antes de colocar novamente
                        uncleanBCDep[conflicts[count].to_s] = 1
                      end
                    end
                  elsif (conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeUnclean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    if (bcDependency[countState].to_s == "false")
                      uncleanBC[conflicts[count].to_s] = 1
                      bcNotAllConflicting += 1
                    else
                      bcNotAllConflicting += 1
                      if (uncleanBCDep[conflicts[count].to_s] != nil)
                        aux = uncleanBCDep[conflicts[count].to_s]
                        uncleanBCDep[conflicts[count].to_s] = aux + 1
                      else
                        #verificar se tem o elemento antes de colocar novamente
                        uncleanBCDep[conflicts[count].to_s] = 1
                      end
                    end
                  end
                elsif (states[countState].to_s == "false" and row[6] == "false" and row[7] == "true")
                  conflicts = row[3].to_s.to_enum(:scan, /\"[a-zA-Z]*\"/).map { Regexp.last_match }
                  if (badlyDeveloperNotAllIntegrated[conflicts[count].to_s] != nil and conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeUnclean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    aux = badlyDeveloperNotAllIntegrated[conflicts[count].to_s].to_i
                    badlyDeveloperNotAllIntegrated[conflicts[count].to_s] = aux + 1
                    bcNotAllDeveloper += 1
                  elsif (conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeUnclean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    bcNotAllDeveloper += 1
                    badlyDeveloperNotAllIntegrated[conflicts[count].to_s] = 1
                  end
                elsif (states[countState].to_s == "false" and row[6] == "true")
                  conflicts = row[3].to_s.to_enum(:scan, /\"[a-zA-Z]*\"/).map { Regexp.last_match }
                  if (badlyDeveloperAllIntegrated[conflicts[count].to_s] != nil and conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeUnclean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    aux = badlyDeveloperAllIntegrated[conflicts[count].to_s].to_i
                    badlyDeveloperAllIntegrated[conflicts[count].to_s] = aux + 1
                    bcAllDeveloper += 1
                  elsif (conflicts[count].to_s != "" and conflicts[count].to_s != "" and !conflicts[count].to_s.match(/gitProblem/) and !conflicts[count].to_s.match(/compilerError/) and !conflicts[count].to_s.match(/remoteError/) and !conflicts[count].to_s.match(/MessageState/))
                    if (row[9] != "")
                      fix += 1
                      timeUnclean.push(row[11].to_i)
                      otherFix += 1
                      if (row[13] == "true")
                        sameAuthor += 1
                      else
                        differentAuthor += 1
                      end
                    end
                    bcAllDeveloper += 1
                    badlyDeveloperAllIntegrated[conflicts[count].to_s] = 1
                  end
                elsif (row[7] == "false")
                  exitString += "#{row[3]} : #{oneCsv}\n"
                end
              end
              countState += 1
            end
          end
        end
      end
    end

    totalBCConflictsByName = 0
    totalClean = 0
    totalCleanDep = 0
    totalUnclean = 0
    totalUncleanDep = 0
    totalBadly = 0
    totalBadlyConf = 0

    exitString += "BC : UNCLEAN DEP\n"
    uncleanBCDep.each do |key, value|
      exitString += "#{key} : #{value}\n"
      totalBCConflictsByName += value
      totalUncleanDep += value
    end
    exitString +="TOTAL BC DEP: #{totalUncleanDep}"

    exitString += "\n\nBC : CLEAN DEP\n"
    cleanBCDep.each do |key, value|
      exitString += "#{key} : #{value}\n"
      totalBCConflictsByName += value
      totalCleanDep += value
    end
    exitString += "TOTAL BC DEP: #{totalCleanDep}"

    exitString += "\n\nBC : CLEAN\n"
    cleanBC.each do |key, value|
      exitString += "#{key} : #{value}\n"
      totalBCConflictsByName += value
      totalClean += value
    end


    exitString += "TOTAL BC : #{totalClean}"
    exitString += "\nTIME FOR FIXING : "
    exitString += timeClean#/cleanBC.size

    exitString += "\n\nBC : UNCLEAN\n"
    uncleanBC.each do |key, value|
      exitString += "#{key} : #{value}\n"
      totalBCConflictsByName += value
      totalUnclean += value
    end
    exitString += "TOTAL BC : #{totalUnclean}"
    exitString += "\nTIME FOR FIXING : "
    exitString += timeUnclean#/uncleanBC.size

    exitString += "\n\nBC : BADLY - INTEGRATOR (NOT ALL INTEGRATED)\n"
    badlyDeveloperNotAllIntegrated.each do |key, value|
      exitString += "#{key} : #{value}\n"
      totalBCConflictsByName += value
      totalBadly += value
    end

    exitString += "TOTAL BC : #{totalBadly}"
    exitString += "\nTIME FOR FIXING : "
    exitString += timeBadly#/badlyDeveloperNotAllIntegrated.size


    exitString += "\n\nBC : BADLY - INTEGRATOR (ALL INTEGRATED)\n"
    badlyDeveloperAllIntegrated.each do |key, value|
      exitString += "#{key} : #{value}\n"
      totalBCConflictsByName += value
      totalBadlyConf += value
    end

    exitString += "TOTAL BC : #{totalBadlyConf}"
    exitString += "\nTIME FOR FIXING : "
    exitString +=timeBadly#/badlyDeveloperNotAllIntegrated.size

    exitString += "\n\nTOTAL BC CANDIDATES : #{countCases}\n"
    exitString += "TOTAL BC CASES : #{bcCases}\n"
    exitString += "TOTAL BC OCCURRENCE BUILDS: #{totalBCConflictsByName}\n"
    exitString += "TOTAL BC FIXED : #{fix}\n"
    exitString += "TOTAL BC FIXED CASES OTHER: #{otherFix}\n"

    exitString += "\n\nReport by Category\n"
    exitString += "Merge Scenarios CLEAN - #{cleanBC.size + cleanBCDep.size} \n"
    exitString += "Merge Scenarios Unclean - #{uncleanBCDep.size + uncleanBCDep.size + badlyDeveloperNotAllIntegrated.size} \n\n"

    exitString += "\n\nReport by Category\n"
    exitString += "BC CLEAN DEP - #{totalCleanDep} : #{totalCleanDep*100/totalBCConflictsByName}\%\n"
    exitString += "BC UNCLEAN DEP - #{totalUncleanDep} : #{totalUncleanDep*100/totalBCConflictsByName}\%\n"
    exitString += "BC CLEAN - #{totalClean} : #{totalClean*100/totalBCConflictsByName}\%\n"
    exitString += "BC UNCLEAN - #{totalUnclean} : #{totalUnclean*100/totalBCConflictsByName}\%\n"
    exitString += "BC BADLY - #{totalBadly} : #{totalBadly*100/totalBCConflictsByName}\%\n"

    exitString += "\n\n SameAuthor : #{sameAuthor}"
    exitString += "\n DifferentAuthor : #{differentAuthor}\n\n"

    exitString += "All Contributions Preservation: #{totalClean + totalCleanDep + totalBadlyConf}\n"
    exitString += "Not All Contributions Preservation: #{totalUnclean + totalUncleanDep + totalBadly}\n"

    exitString += "Conflicting Contributions ALL INTEGRATED: #{bcAllConflicting}\n"
    exitString += "Conflicting Contributions NOT ALL INTEGRATED: #{bcNotAllConflicting}\n"
    exitString += "Developer Integrator ALL INTEGRATED: #{bcAllDeveloper}\n"
    exitString += "Developer Integrator NOT ALL INTEGRATED: #{bcNotAllDeveloper}\n"

    createFile(exitString)
  end

  def createFile(text)
    outFile = File.new("bcCounts.txt", "w")
    outFile.puts(text)
    outFile.close
  end

end