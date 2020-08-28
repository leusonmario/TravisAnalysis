#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'

class ProjectInfoReport

  def initialize()
    @textConflict = "<table class=\"build_conflicts\">
                      <thead>
                        <tr>
                          <th> Project Name </th>
                          <th> Merge Scenarios (MS) </th>
                          <th> MS Not Built </th>
                          <th> Errored MS </th>
                          <th> Failed MS </th>
                        </tr>
                      </thded>
                      <tbody>"
    @projectNames = Hash.new

  end

  def getProjectNames()
    @projectNames
  end

  def getAllProjectInfo(allFilesCSVProjects)
    allFilesCSVProjects.each do |oneCsv|
      CSV.foreach(oneCsv.to_s.gsub("./","").gsub("\n","")) do |row|
        if (row[0] != "Project")
          @projectNames[row[0].gsub("-","/")] = row[0]
          @textConflict += htmlTextForProject(row[0], row[1], row[2], row[10], row[15])
        end
      end
    end
    finalText()
    return @textConflict
  end

  def finalText()
    @textConflict += "
                      </tbody>
                     </table>"
  end

  def htmlTextForProject(projectName, ms, msNoBuilt, erroredMS, failedMS)
    print projectName+"\n"
    return "
                        <tr>
                          <td> <a href=\"http://github.com/#{projectName}\" target=\"_blank\"> #{projectName} </th>
                          <td> #{ms} </td>
                          <td> #{msNoBuilt} </td>
                          <td> #{erroredMS} </td>
                          <td> #{failedMS} </td>
                        </tr>"
  end

  def latexCommandTable(projectName, ms, msNoBuilt, erroredMS, failedMS)
    return "

                        <tr>
                          <td> <a href=\"http://github.com/#{projectName}\" target=\"_blank\"> #{projectName} </th>
                          <td> #{ms} </td>
                          <td> #{msNoBuilt} </td>
                          <td> #{erroredMS} </td>
                          <td> #{failedMS} </td>
                        </tr>"
  end
end