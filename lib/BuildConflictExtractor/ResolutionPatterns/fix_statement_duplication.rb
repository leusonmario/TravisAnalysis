class FixStatementDuplication
  def initialize ()

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
    index = 0
    fixPattern = []
    filesConflictsInfo.each do |fileConflictBuild|
      if (diffErrorFix[0][fileConflictBuild[0]].to_s.match(/Delete SimpleName: #{fileConflictBuild[1]}/))
        fixPattern[index] = "DELETE-DUPLICATED-ELEMENT"
      else
        fixPattern[index] = "OTHER"
      end
      index += 1
    end
    return fixPattern
  end

end