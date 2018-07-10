class FixUnimplementedMethod
  def initialize ()

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
    index = 0
    fixPattern = []
    filesConflictsInfo.each do |fileConflictBuild|
      if (diffErrorFix[0][fileConflictBuild[1].to_s.gsub(".java","")].to_s.match(/Insert SimpleName: #{fileConflictBuild[3]}[a-zA-Z\(\)0-9]* into MethodDeclaration/))
        fixPattern[index] = "METHOD-IMPLEMENTATION"
      else
        fixPattern[index] = "OTHER"
      end
      index += 1
    end
    return fixPattern
  end

end