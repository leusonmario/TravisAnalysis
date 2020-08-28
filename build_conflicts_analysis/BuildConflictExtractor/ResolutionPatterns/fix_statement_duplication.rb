class FixStatementDuplication
  def initialize ()

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
      if (filesConflictsInfo[2] == "method")
        if (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Delete SimpleName: #{filesConflictsInfo[3]}/))
          return "DELETE-DUPLICATED-METHOD"
        else
          return "OTHER"
        end
      else
        if (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Delete SimpleName: #{filesConflictsInfo[2]}/))
          return "DELETE-DUPLICATED-ELEMENT"
        else
          return "OTHER"
        end
      end
  end

end