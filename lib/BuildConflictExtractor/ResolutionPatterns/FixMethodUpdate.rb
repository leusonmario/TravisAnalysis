class FixMethodUpdate

  def initialize

  end

  def verifyFixPattern(filesConflictsInfo, diffErrorFix)
    index = 0
    fixPattern = []
    filesConflictsInfo.each do |fileConflictBuild|
      if (diffErrorFix[0][fileConflictBuild[2]].to_s.match(/Delete SimpleName: [a-zA-Z0-9\.\_]*#{fileConflictBuild[1]}[\(\)0-9]*/))
        fixPattern[index] = "MISSING-ELEMENT-REMOVAL"
      elsif (diffErrorFix[0][fileConflictBuild[2]].to_s.match(/Delete SimpleName: [a-zA-Z0-9\.\_]*/))
        fixPattern[index] = "MISSING-ELEMENT-REMOVAL"
      else
        fixPattern[index] = "OTHER"
      end
      index += 1
    end
    return fixPattern
  end

end