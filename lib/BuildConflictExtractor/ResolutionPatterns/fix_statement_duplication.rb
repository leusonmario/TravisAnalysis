class FixStatementDuplication
  def initialize ()

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
    index = 0
    fixPattern = []
    filesConflictsInfo.each do |fileConflictBuild|
      if (fileConflictBuild[2] == "method")
        if (diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Delete SimpleName: #{fileConflictBuild[3]}/))
          fixPattern[index] = "DELETE-DUPLICATED-METHOD"
        else
          fixPattern[index] = "OTHER"
        end
      else
        if (diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Delete SimpleName: #{fileConflictBuild[2]}/))
          fixPattern[index] = "DELETE-DUPLICATED-ELEMENT"
        else
          fixPattern[index] = "OTHER"
        end
      end
      index += 1
    end
    return fixPattern
  end

end