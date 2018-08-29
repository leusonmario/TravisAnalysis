#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'

class BuildConflict

  def initialize()
    @textConflict = "<table class=\"build_conflicts\">
                      <thead>
                        <tr>
                          <th> Project Name </th>
                          <th> Broken Build ID </th>
                          <th> Commit </th>
                          <th> Build Conflict Type </th>
                          <th> Parent Build One </th>
                          <th> Parent One Status</th>
                          <th> Parent Build Two </th>
                          <th> Parent Two Status </th>
                          <th> Build Fix </th>
                          <th> Build Fix Status </th>
                          <th> Resolution Pattern </th>
                        </tr>
                      </thded>
                      <tbody>"
    @projectTravis = ProjectTravis.new()
  end

  def getAllConflicts(files, projectNames)
    files.each do |file|
      buildsProject = @projectTravis.getBuildsProject(projectNames[file.to_s.split("/").last.to_s.gsub("Errored","").gsub(".csv\n","").gsub("BCFromFailed","").gsub("-","/")])
      CSV.foreach(file.to_s.gsub("./","").gsub("\n","")) do |row|
        if (row[8] == "true" or ((row[3] == "failed" or row[3] == "[\"failed\"]" or row[3] == "[\"passed\"]" or row[3] == "passed") and (row[5] == "failed" or row[5] == "[\"failed\"]" or row[5] == "[\"passed\"]" or row[5] == "passed") and row[21] == "false"))
          projectName = projectNames[file.to_s.split("/").last.to_s.gsub("Errored","").gsub(".csv\n","").gsub("BCFromFailed","").gsub("-","/")]
          htmlTextForCoflict(projectName, adjustInfo(row[0]), adjustInfo(row[1]), row[6], adjustInfo(row[2]), adjustInfo(row[3]), adjustInfo(row[4]), adjustInfo(row[5]), adjustInfo(row[12]), adjustInfo(row[13]), adjustInfo(row[19]), buildsProject)
        end
      end
    end
    finalText()
    return updateConflictNames
  end

  def htmlTextForCoflict(projectName, brokenBuild, commit, message, parentOne, parentOneStatus, parentTwo, parentTwoStatus, buildFix, buildFixStatus, resolutionPattern, buildsProject)
    @textConflict += "<tr>
                            <td> <a href=\"https://github.com/#{projectName}\" target=\"_blank\" > #{projectName} </td>
                            <td> #{internalOrExternalBuild(buildsProject, brokenBuild, projectName)} #{brokenBuild} </a> </td>
                            <td> <a href=\"https://github.com/#{projectName}/commit/#{commit}\" target=\"_blank\" > #{commit[0..6]} </a> </td>
                            <td> #{message} </td>
                            <td> #{internalOrExternalBuild(buildsProject, parentOne, projectName)} #{parentOne} </a> </td>
                            <td> #{parentOneStatus} </td>
                            <td> #{internalOrExternalBuild(buildsProject, parentTwo, projectName)} #{parentTwo} </a> </td>
                            <td> #{parentTwoStatus} </td>
                            <td> #{internalOrExternalBuild(buildsProject, buildFix, projectName)} #{buildFix} </a> </td>
                            <td> #{buildFixStatus} </td>
                            <td> #{resolutionPattern} </td>
                          </tr>"
  end

  def adjustInfo(buildId)
    if (buildId.to_s == "1" or buildId.to_s == "0" or buildId.to_s == "OTHER")
      return ""
    else
      return buildId.to_s.gsub("[","").gsub("]","").gsub("\"","")
    end
  end

  def internalOrExternalBuild(buildProjects, buildID, projectName)
    if (buildID == "0" or buildID == "1")
      return "<a href=\"https://travis-ci.org/#{projectName}/builds/\" target=\"_blank\" >"
    else
      begin
        buildProjects.each do |build, sha|
          if (build.to_s == buildID.gsub("\"",""))
            return "<a href=\"https://github.com/#{projectName}/commit/#{sha[0..6]}\" target=\"_blank\" >"
          end
        end
        return "<a href=\"https://travis-ci.org/#{projectName}/builds/#{buildID}\" target=\"_blank\" >"
      rescue
        return "<a href=\"https://travis-ci.org/#{projectName}/builds/#{buildID}\" target=\"_blank\" >"
      end
    end

  end

  def finalText()
    @textConflict += "
                      </tbody>
                     </table>"
  end

  def updateConflictNames()
    @textConflict = @textConflict.to_s.gsub("statementDuplication", "duplicatedDeclaration").to_s.gsub("methodParameterListSize","incompatibleMethodSignature").gsub("malformedExpression","projectRules")
  end

end