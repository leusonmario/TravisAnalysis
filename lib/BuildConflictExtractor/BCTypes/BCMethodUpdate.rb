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
      if (filesConflicting[0][3] == "method")
        leftPathMethods = getParametersListSizeForMethod(leftPath, filesConflicting[0][2], filesConflicting[0][1])
        rightPathMethods = getParametersListSizeForMethod(rightPath, filesConflicting[0][2], filesConflicting[0][1])
      elsif (filesConflicting[0][3] == "constructor")
        leftPathMethods = getParametersListSizeForConstructor(leftPath, filesConflicting[0][2], filesConflicting[0][1])
        rightPathMethods = getParametersListSizeForConstructor(rightPath, filesConflicting[0][2], filesConflicting[0][1])
      end
      if (leftPathMethods[0].size > 0 or rightPathMethods[0].size > 0)
        return true
      end
      count += 1
    end
    return false
  end

	def verifyBuildConflict(leftPath, rightPath, filesConflicting)
		count = 0
		while (count < filesConflicting.size)
			leftPathMethods = []
			rightPathMethods = []
			if (filesConflicting[0][3] == "method")
				leftPathMethods = getParametersListSizeForMethod(leftPath, filesConflicting[0][2], filesConflicting[0][1])
				rightPathMethods = getParametersListSizeForMethod(rightPath, filesConflicting[0][2], filesConflicting[0][1])
			elsif (filesConflicting[0][3] == "constructor")
				leftPathMethods = getParametersListSizeForConstructor(leftPath, filesConflicting[0][2], filesConflicting[0][1])
				rightPathMethods = getParametersListSizeForConstructor(rightPath, filesConflicting[0][2], filesConflicting[0][1])
			end
			if (leftPathMethods[0].size != rightPathMethods[0].size)
				return true
			else
				equalParametersNumber = 0
				leftPathMethods[1].each do |leftMethod|
				    rightPathMethods[1].each do |rightMethod|
				        if (leftMethod.size == rightMethod.size)
				            if (leftMethod == rightMethod)
				                equalParametersNumber += 1
				            end
				        end
				    end
				end
				if (leftPathMethods[0].size == equalParametersNumber)
					return false
				end
			end
			count += 1
		end
		return true
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
    end
  end
end
