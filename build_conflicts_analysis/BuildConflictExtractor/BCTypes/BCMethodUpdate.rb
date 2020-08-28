class BCMethodUpdate

	def initialize(gumTreePath)
		@gumTreePath = gumTreePath
	end

  def getGumTreePath()
    @gumTreePath
  end

  def verifyBCDependency(leftPath, rightPath, filesConflicting)
    count = 0
    while (count < filesConflicting.size)
      leftPathMethods = []
      rightPathMethods = []
      if (filesConflicting[4] == "method")
        leftPathMethods = getParametersListSizeForMethod(leftPath, filesConflicting[3], filesConflicting[2])
        rightPathMethods = getParametersListSizeForMethod(rightPath, filesConflicting[3], filesConflicting[2])
      elsif (filesConflicting[4] == "constructor")
        leftPathMethods = getParametersListSizeForConstructor(leftPath, filesConflicting[3], filesConflicting[2])
        rightPathMethods = getParametersListSizeForConstructor(rightPath, filesConflicting[3], filesConflicting[2])
      end
      if (leftPathMethods[0].size > 0 or rightPathMethods[0].size > 0)
        return true
      end
      count += 1
    end
    return false
  end

	def verifyBuildConflict(basePath, leftPath, rightPath, filesConflicting, baseLeft, baseRight)
		count = 0
		while (count < filesConflicting.size)
			leftPathMethods = []
			rightPathMethods = []
      basePathMethods = []
			if (filesConflicting[4] == "method")
        leftPathMethods = getParametersListSizeForMethod(leftPath, filesConflicting[3], filesConflicting[2])
				rightPathMethods = getParametersListSizeForMethod(rightPath, filesConflicting[3], filesConflicting[2])
        basePathMethods = getParametersListSizeForMethod(basePath, filesConflicting[3], filesConflicting[2])
        return verifyConflictByMethod(basePathMethods, leftPathMethods, rightPathMethods, baseLeft, baseRight, filesConflicting)
			elsif (filesConflicting[4] == "constructor")
        leftPathMethods = getParametersListSizeForConstructor(leftPath, filesConflicting[3], filesConflicting[2])
				rightPathMethods = getParametersListSizeForConstructor(rightPath, filesConflicting[3], filesConflicting[2])
        basePathMethods = getParametersListSizeForConstructor(basePath, filesConflicting[3], filesConflicting[2])
        return verifyConflictByConstructor(basePathMethods, leftPathMethods, rightPathMethods, baseLeft, baseRight, filesConflicting)
      end
      count += 1
    end
  end

  def verifyConflictByConstructor(basePathMethods, leftPathMethods, rightPathMethods, baseLeft, baseRight, filesConflicting)
    begin
    if (leftPathMethods != nil and rightPathMethods != nil and leftPathMethods[0].size != rightPathMethods[0].size and basePathMethods[0] != nil and basePathMethods[0].size != 0)
      if (baseLeft[0][filesConflicting[5]] != nil and baseLeft[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move) Simple(Name|Type): #{filesConflicting[3]}\([0-9]*\) into SimpleType: #{filesConflicting[3]}/) and (((basePathMethods[0] == nil or basePathMethods[0].size == 0) and (rightPathMethods[0] != nil and rightPathMethods[0].size > 0)) or rightPathMethods[0].size != basePathMethods[0].size or checkNewMethodAddition(baseRight[1], filesConflicting[5]) or baseRight[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move|Delete) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*on Method #{filesConflicting[1]}/)))
        return true
      end
      if (baseRight[0][filesConflicting[5]] != nil and baseRight[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move) Simple(Name|Type): #{filesConflicting[3]}\([0-9]*\) into SimpleType: #{filesConflicting[3]}/) and (((basePathMethods[0] == nil or basePathMethods[0].size == 0) and (leftPathMethods[0] != nil and leftPathMethods[0].size > 0)) or leftPathMethods[0].size != basePathMethods[0].size or checkNewMethodAddition(baseLeft[1], filesConflicting[5]) or baseLeft[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move|Delete) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*on Method #{filesConflicting[1]}/)))
        return true
      end
      #if ((basePathMethods[0] == nil or basePathMethods[0].size == 0) and ((leftPathMethods[0] != nil and leftPathMethods[0].size > 0) or (rightPathMethods[0] != nil and rightPathMethods[0].size > 0)))
      #  return true
      #end
      return false
    elsif ((leftPathMethods != nil or rightPathMethods != nil) and (basePathMethods[0] == nil or basePathMethods[0].size == 0))
      if (baseLeft[0][filesConflicting[5]] != nil and baseLeft[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move) Simple(Name|Type): #{filesConflicting[3]}\([0-9]*\) into SimpleType: #{filesConflicting[3]}/) and ((basePathMethods[0] == nil or basePathMethods[0].size == 0) and (rightPathMethods[0] != nil and rightPathMethods[0].size > 0)))
        return true
      end
      if (baseRight[0][filesConflicting[5]] != nil and baseRight[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move) Simple(Name|Type): #{filesConflicting[3]}\([0-9]*\) into SimpleType: #{filesConflicting[3]}/) and ((basePathMethods[0] == nil or basePathMethods[0].size == 0) and (leftPathMethods[0] != nil and leftPathMethods[0].size > 0)))
        return true
      end
      #if ((basePathMethods[0] == nil or basePathMethods[0].size == 0) and ((leftPathMethods[0] != nil and leftPathMethods[0].size > 0) or (rightPathMethods[0] != nil and rightPathMethods[0].size > 0)))
      #  return true
      #end
      return false
    else
      equalParametersNumberLeft = 0
      equalParametersNumberRight = 0
      leftPathMethods[1].each do |leftMethod|
        basePathMethods[1].each do |baseMethod|
          if (baseMethod != nil and leftMethod != nil and leftMethod.size == baseMethod.size)
            if (leftMethod == baseMethod)
              equalParametersNumberLeft += 1
            end
          end
        end
      end

      rightPathMethods[1].each do |rightMethod|
        basePathMethods[1].each do |baseMethod|
          if (baseMethod != nil and rightMethod != nil and rightMethod.size == baseMethod.size)
            if (rightMethod == baseMethod)
              equalParametersNumberRight += 1
            end
          end
        end
      end
      if (baseLeft[0][filesConflicting[5]] != nil and baseLeft[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move) Simple(Name|Type): #{filesConflicting[3]}\([0-9]*\) into SimpleType: #{filesConflicting[3]}/) and ((checkNewMethodAddition(baseRight[1], filesConflicting[5]) or basePathMethods[0].size != equalParametersNumberRight or baseRight[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move|Delete) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*on Method #{filesConflicting[1]}/))))
        return true
      end
      if (baseRight[0][filesConflicting[5]] != nil and baseRight[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move) Simple(Name|Type): #{filesConflicting[3]}\([0-9]*\) into SimpleType: #{filesConflicting[3]}/) and ((checkNewMethodAddition(baseLeft[1], filesConflicting[5]) or basePathMethods[0].size != equalParametersNumberLeft or baseLeft[0][filesConflicting[5]].to_s.match(/(Insert|Update|Move|Delete) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*on Method #{filesConflicting[1]}/))))
        return true
      end
    end
    return false
    rescue
      return false
     end
  end

  def verifyConflictByMethod(basePathMethods, leftPathMethods, rightPathMethods, baseLeft, baseRight, filesConflicting)
    begin
    if (leftPathMethods != nil and rightPathMethods != nil and leftPathMethods[0].size != rightPathMethods[0].size)
      if ((checkNewMethodAddition(baseLeft[1], filesConflicting[1]) or (baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/(Insert|Update|Move) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{filesConflicting[2]}/))) and ((rightPathMethods[0].size != basePathMethods[0].size)  or baseRight[0][filesConflicting[3]].to_s.match(/(Insert|Update|Move|Delete) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*#{filesConflicting[2]}/)))
        return true
      end
      if ((checkNewMethodAddition(baseRight[1], filesConflicting[1]) or (baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/(Insert|Update|Move) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{filesConflicting[2]}/))) and ((leftPathMethods[0].size != basePathMethods[0].size)  or baseLeft[0][filesConflicting[3]].to_s.match(/(Insert|Update|Move|Delete) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*#{filesConflicting[2]}/)))
        return true
      end
      return false
    elsif ((leftPathMethods != nil or rightPathMethods != nil) and (basePathMethods[0] == nil or basePathMethods[0].size == 0))
      if ((checkNewMethodAddition(baseLeft[1], filesConflicting[1]) or (baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/(Insert|Update|Move) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{filesConflicting[2]}/))) and ((basePathMethods[0] == nil or basePathMethods[0].size == 0) and (rightPathMethods[0] != nil and rightPathMethods[0].size > 0)))
        return true
      end
      if ((checkNewMethodAddition(baseRight[1], filesConflicting[1]) or (baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/(Insert|Update|Move) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{filesConflicting[2]}/))) and ((basePathMethods[0] == nil or basePathMethods[0].size == 0) and (leftPathMethods[0] != nil and leftPathMethods[0].size > 0)))
        return true
      end
      return false
    else
      equalParametersNumberLeft = 0
      equalParametersNumberRight = 0
      leftPathMethods[1].each do |leftMethod|
        basePathMethods[1].each do |baseMethod|
          if (baseMethod != nil and leftMethod != nil and leftMethod.size == baseMethod.size)
            if (leftMethod == baseMethod)
              equalParametersNumberLeft += 1
            end
          end
        end
      end

      rightPathMethods[1].each do |rightMethod|
        basePathMethods[1].each do |baseMethod|
          if (baseMethod != nil and rightMethod != nil and rightMethod.size == baseMethod.size)
            if (rightMethod == baseMethod)
              equalParametersNumberRight += 1
            end
          end
        end
      end
      if ((checkNewMethodAddition(baseLeft[1], filesConflicting[1]) or (baseLeft[0][filesConflicting[1]] != nil and baseLeft[0][filesConflicting[1]].to_s.match(/(Insert|Update|Move|Delete) SimpleName:[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{filesConflicting[2]}/))) and (basePathMethods[0].size != equalParametersNumberRight  or baseRight[0][filesConflicting[3]].to_s.match(/(Insert|Update|Move) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*#{filesConflicting[2]}/)))
        if (baseRight[0][filesConflicting[3]] != nil and baseLeft[0][filesConflicting[3]])
          if (verificationOfChangedMethodCall(baseRight[0][filesConflicting[3]], filesConflicting[2]))
            return true
          end
        else
          return true
        end
      end
      text = filesConflicting[1].split("\/").last.gsub(".java","")
      if ((checkNewMethodAddition(baseRight[1], filesConflicting[1]) or (baseRight[0][filesConflicting[1]] != nil and baseRight[0][filesConflicting[1]].to_s.match(/(Insert|Update|Move|Delete) SimpleName:[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{filesConflicting[2]}/))) and (basePathMethods[0].size != equalParametersNumberLeft  or baseLeft[0][filesConflicting[3]].to_s.match(/(Insert|Update|Move) Simple(Name|Type):[a-zA-Z0-9\(\)\<\>\.\[\] \:]*#{filesConflicting[2]}/)))
        if (baseRight[0][filesConflicting[3]] != nil and baseLeft[0][filesConflicting[3]] != nil)
          if (verificationOfChangedMethodCall(baseRight[0][filesConflicting[3]], filesConflicting[2]))
            return true
          end
        else
          return true
        end
      end
    end
    return false
    rescue
      return false
    end
  end


  def getParametersListSizeForMethod(pathBranch, fileName, methodName)
		    actualPath = Dir.pwd
        countMethod = []
        typeVariableAllMethods = []

        Dir.chdir pathBranch
        pathFile = %x(find -name #{fileName}.java)
        newPathFile = %x(readlink -f #{pathFile})
        Dir.chdir getGumTreePath()
        data = %x(./gumtree parse #{newPathFile})
        begin
          if (data != "")
            stringJson = JSON.parse(data)
            variableDeclaration = 0
            indexMethodID = 0
            stringJson["root"]["children"].each do |child|
              typeVariableMethod = []
              child["children"].each do |newChild|
                if (newChild["typeLabel"] == "MethodDeclaration")
                  aux = false
                  newChild["children"].each do |methodDeclaration|
                    if (methodDeclaration["label"] == methodName)
                      variableDeclaration = true
                    end

                    if (variableDeclaration == true and methodDeclaration["typeLabel"] == "SingleVariableDeclaration")
                      if (countMethod[indexMethodID] != nil)
                        countMethod[indexMethodID] = countMethod[indexMethodID] + 1
                      else
                        #countMethod[indexMethodID] = countMethod[indexMethodID] + 1
                        countMethod[indexMethodID] = 1
                      end
                      typeVariableMethod[indexMethodID] = methodDeclaration["children"][0]["label"]
                    end

                    if (variableDeclaration == true and methodDeclaration["typeLabel"] == "Block")
                      indexMethodID += 1
                      variableDeclaration = false
                    end
                  end
                  if (typeVariableMethod.size > 0)
                    typeVariableAllMethods[indexMethodID-1] = typeVariableMethod
                  end
                  typeVariableMethod = []
                end
              end
            end
          end

        end
        Dir.chdir actualPath
        return countMethod, typeVariableAllMethods
    end

    def getParametersListSizeForConstructor(pathBranch, fileName, methodName)
		    actualPath = Dir.pwd
        Dir.chdir pathBranch
        countMethod = []
        typeVariableAllMethods = []

        begin
          pathFile = %x(find -name #{fileName}".java")
          newPathFile = %x(readlink -f #{pathFile})
          Dir.chdir getGumTreePath()
          data = %x(./gumtree parse #{newPathFile})
          stringJson = JSON.parse(data)

          variableDeclaration = 0
          indexMethodID = 0
          stringJson["root"]["children"].each do |child|
            typeVariableMethod = []
              child["children"].each do |newChild|
                  if (newChild["typeLabel"] == "MethodDeclaration")
                      aux = false
                      newChild["children"].each do |methodDeclaration|
                          if (methodDeclaration["label"] == methodName and methodDeclaration["type"] == "42")
                              variableDeclaration = true
                          end

                          if (variableDeclaration == true and methodDeclaration["typeLabel"] == "SingleVariableDeclaration")
                              if (countMethod[indexMethodID] != nil)
                                  countMethod[indexMethodID] = countMethod[indexMethodID] + 1
                              else
                                  countMethod[indexMethodID] = 0 + 1
                              end
                              typeVariableMethod.push(methodDeclaration["children"][0]["label"])
                          end

                          if (variableDeclaration == true and methodDeclaration["typeLabel"] == "Block")
                              indexMethodID += 1
                              variableDeclaration = false
                          end
                      end
                      if (typeVariableMethod.size > 0)
                        typeVariableAllMethods[indexMethodID-1] = typeVariableMethod
                      end
                      typeVariableMethod = []
                  end
              end
          end
        rescue
          print "\n IT WAS NOT POSSIBLE"
        end
        Dir.chdir actualPath
        return countMethod, typeVariableAllMethods
    end

  def verifyMethodAvailable(pathBranch, fileName, methodName)
    actualPath = Dir.pwd
    countMethod = []
    typeVariableAllMethods = []

    Dir.chdir pathBranch
    pathFile = %x(find -name #{fileName}.java)
    newPathFile = %x(readlink -f #{pathFile})
    Dir.chdir getGumTreePath()
    data = %x(./gumtree parse #{newPathFile})
    begin
      if (data != "")
        stringJson = JSON.parse(data)
        variableDeclaration = 0
        indexMethodID = 0
        stringJson["root"]["children"].each do |child|
          typeVariableMethod = []
          child["children"].each do |newChild|
            if (newChild["typeLabel"] == "MethodDeclaration")
              aux = false
              newChild["children"].each do |methodDeclaration|
                if (methodDeclaration["label"] == methodName)
                  return true
                end
              end
            end
          end
        end
      end
      Dir.chdir actualPath
      return false
    rescue
      return false
    end
  end

  def checkNewMethodAddition(listAddedFiles, file)
    begin
      listAddedFiles.each do |oneFile|
        if (oneFile.include? file)
          return true
        end
      end
      return false
    rescue
      return false
    end
  end

  def verificationOfChangedMethodCall(log, methodName)
    calledMethodStatements = log.to_enum(:scan, /(Insert|Update|Move|Delete) SimpleName:[a-zA-Z0-9\(\)\<\>\.\[\] ]*#{methodName}[\(\)0-9 ]*into MethodInvocation[\(\)0-9]*/).map { Regexp.last_match }
    calledMethodStatements.each do |oneCalledMethod|
      if (verificationOfAddedDeletedParametersOnCallMethod(log, oneCalledMethod.to_s.split("(").last.gsub(")","")))
        return true
      end
    end
    return false
  end

  def verificationOfAddedDeletedParametersOnCallMethod(log, methodReferenceNode)
    log.each_line do |line|
      if (line[/(Insert|Delete) Simple(Name|Type): [a-zA-Z\(\)0-9 ]*into MethodInvocation\(#{methodReferenceNode}\)/])
        return true
      end
    end
    return false
  end
end
