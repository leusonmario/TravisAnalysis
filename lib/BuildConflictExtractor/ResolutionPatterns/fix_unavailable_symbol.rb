class FixUnavailableSymbol
  def initialize

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
    index = 0
    fixPattern = []
    filesConflictsInfo.each do |fileConflictBuild|
      if (diffErrorFix[0].size == 1 and diffErrorFix[0]['pom.xml'] != nil )
        fixPattern[index] = "DEPENDENCY-CHANGE"
      elsif (diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Insert SimpleName: [a-zA-Z0-9]*#{fileConflictBuild[2]}[\(\)0-9]* into MethodDeclaration/))
        fixPattern[index] = "REINTRODUCE-MISSING-METHOD"
      elsif (diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\_]*#{fileConflictBuild[2]}[\(\)0-9]* to [a-zA-Z0-9\.\_]*#{fileConflictBuild[1]}/) or diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Insert QualifiedName: [\s\S]*#{fileConflictBuild[2]}[\s\S]* into ImportDeclaration/) or diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*\.#{fileConflictBuild[2]}/) or diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*/))
        fixPattern[index] = "IMPORT-UPDATE"
      elsif (diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Delete (QualifiedName:|SimpleName:SimpleType:) [\s\S]*#{fileConflictBuild[2]}/))
        fixPattern[index] = "DELETE-IMPORT"
      elsif (diffErrorFix[0][fileConflictBuild[1]].to_s.match(/Update SimpleName: [\s\S]*#{fileConflictBuild[2]}[\s\S]* to [\s\S]*\n/) or diffErrorFix[0][fileConflictBuild[3]].to_s.match(/Update SimpleName: [\s\S]*#{fileConflictBuild[2]}[\s\S]* to [\s\S]*\n/))
          fixPattern[index] = "METHOD-NAME-UPDATE"
      elsif (diffErrorFix[0][fileConflictBuild[3]].to_s.match(/Delete QualifiedName: [\s\S]*#{fileConflictBuild[2]}(\n)?/) or diffErrorFix[0][fileConflictBuild[3]].to_s.match(/Delete SimpleName: #{fileConflictBuild[2]}[\(\)0-9]*/))
        fixPattern[index] = "MISSING-ELEMENT-REMOVAL"
      elsif (diffErrorFix[0][fileConflictBuild[3]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\_]*#{fileConflictBuild[2]}[\(\)0-9]* to [a-zA-Z0-9\.\_]*/))
          fixPattern[index] = "UPDATE-VARIABLE"
      else
        fixPattern[index] = "OTHER"
      end
      index += 1
    end
    return fixPattern
  end
end