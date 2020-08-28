class FixUnimplementedMethod
  def initialize ()

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
      if (diffErrorFix[0][filesConflictsInfo[1].to_s.gsub(".java","")].to_s.match(/Insert SimpleName: #{filesConflictsInfo[3]}[a-zA-Z\(\)0-9]* into MethodDeclaration/))
        return "METHOD-IMPLEMENTATION"
      else
        return "OTHER"
      end
  end

end