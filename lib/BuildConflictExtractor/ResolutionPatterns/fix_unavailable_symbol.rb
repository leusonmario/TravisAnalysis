class FixUnavailableSymbol
  def initialize

  end

  def verfyFixPattern(filesConflictsInfo, diffErrorFix)
    if (filesConflictsInfo[0] == "unavailableSymbolVariable")
      if (diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Update (SimpleName|QualifiedName): [a-zA-Z0-9\.\_]*#{filesConflictsInfo[2]}[\(\)0-9]* to [a-zA-Z0-9\.\_]*/))
        return "UPDATE-VARIABLE"
      elsif (diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete QualifiedName: [\s\S]*#{filesConflictsInfo[2]}(\n)?/) or diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete SimpleName: #{filesConflictsInfo[2]}[\(\)0-9]*/))
        return "MISSING-ELEMENT-REMOVAL"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\_]*#{filesConflictsInfo[2]}[\(\)0-9]* to [a-zA-Z0-9\.\_]*#{filesConflictsInfo[1]}/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Insert QualifiedName: [\s\S]*#{filesConflictsInfo[2]}[\s\S]* into ImportDeclaration/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*\.#{filesConflictsInfo[2]}/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*/))
        return "IMPORT-UPDATE"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Delete (QualifiedName:|SimpleName:|SimpleType:) [\s\S]*#{filesConflictsInfo[2]}/))
        return "DELETE-IMPORT"
      end
    elsif (filesConflictsInfo[0] == "unavailableSymbolMethod")
      if (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Insert SimpleName: [a-zA-Z0-9]*#{filesConflictsInfo[2]}[\(\)0-9]* into MethodDeclaration/))
        return "REINTRODUCE-MISSING-METHOD"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update SimpleName: [\s\S]*#{filesConflictsInfo[2]}[\s\S]* to [\s\S]*\n/) or diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Update SimpleName: [\s\S]*#{filesConflictsInfo[2]}[\s\S]* to [\s\S]*\n/))
        return "METHOD-NAME-UPDATE"
      elsif (diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete QualifiedName: [\s\S]*#{filesConflictsInfo[2]}(\n)?/) or diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete SimpleName: #{filesConflictsInfo[2]}[\(\)0-9]*/))
        return "MISSING-ELEMENT-REMOVAL"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\_]*#{filesConflictsInfo[2]}[\(\)0-9]* to [a-zA-Z0-9\.\_]*#{filesConflictsInfo[1]}/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Insert QualifiedName: [\s\S]*#{filesConflictsInfo[2]}[\s\S]* into ImportDeclaration/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*\.#{filesConflictsInfo[2]}/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*/))
        return "IMPORT-UPDATE"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Delete (QualifiedName:|SimpleName:SimpleType:) [\s\S]*#{filesConflictsInfo[2]}/))
        return "DELETE-IMPORT"
      end
    else
      if (diffErrorFix[0].size == 1 and diffErrorFix[0]['pom.xml'] != nil )
        return "DEPENDENCY-CHANGE"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\_]*#{filesConflictsInfo[2]}[\(\)0-9]* to [a-zA-Z0-9\.\_]*#{filesConflictsInfo[1]}/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Insert QualifiedName: [\s\S]*#{filesConflictsInfo[2]}[\s\S]* into ImportDeclaration/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*\.#{filesConflictsInfo[2]}/) or diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Update QualifiedName: [a-zA-Z0-9\.\(\) ]*/))
        return "IMPORT-UPDATE"
      elsif (diffErrorFix[0][filesConflictsInfo[1]].to_s.match(/Delete (QualifiedName:|SimpleName:SimpleType:) [\s\S]*#{filesConflictsInfo[2]}/))
          return "DELETE-IMPORT"
      elsif (diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete QualifiedName: [\s\S]*#{filesConflictsInfo[2]}(\n)?/) or diffErrorFix[0][filesConflictsInfo[3]].to_s.match(/Delete SimpleName: #{filesConflictsInfo[2]}[\(\)0-9]*/))
        return "MISSING-ELEMENT-REMOVAL"
      end
    end
    return "OTHER"
  end
end