class FixMethodUpdate

  def initialize

  end

  def verifyFixPattern(filesConflictsInfo, diffErrorFix)
      if (diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete SimpleName: [a-zA-Z0-9\.\_]*#{filesConflictsInfo[2]}[\(\)0-9]*/))
        return "MISSING-ELEMENT-REMOVAL"
      elsif (diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete SimpleName: [a-zA-Z0-9\.\_]*/))
        return "MISSING-ELEMENT-REMOVAL"
      else
        return "OTHER"
      end
  end

end