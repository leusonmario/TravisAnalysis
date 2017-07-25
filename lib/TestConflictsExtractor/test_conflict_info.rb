
class TestConflictInfo
  def initialize()

  end

  def getInfoTestConflicts(gumTreeDiff, pathCopies, buildsInfo, pathGumTree)
    #baseLeft = gumTreeDiff[0]
    baseLeft = gumTreeDiff[3]
    leftResult = gumTreeDiff[1]
    #baseRight = gumTreeDiff[2]
    baseRight = gumTreeDiff[1]
    rightResult = gumTreeDiff[3]

    newTestFile = false
    newTestCase = false
    updatedTest = false
    if (!verifyIfNewTestFile(baseLeft, buildsInfo))
      newTestFile = verifyIfNewTestFile(baseRight, buildsInfo)
      if (newTestFile)
        newTestCase = true
      else
        if (verifyIfNewTestCase(baseLeft, buildsInfo))
          newTestCase = true
        else
          newTestCase = verifyIfNewTestCase(baseRight, buildsInfo)
          if (!newTestCase)
            #updatedTest = verifyUpdatedTest(baseLeft, buildsInfo)
            #quando os parents mudam o teste mas esse não mudou em relação a base, entende-se que tais modificações são inválidas
            updatedTest = verifyChangesOnSameMethod(pathCopies[1], pathCopies[4], buildsInfo[0], buildsInfo[1], pathGumTree)
            #updatedTest = verifyChangesOnSameMethod(pathCopies[2], pathCopies[3], buildsInfo[0], buildsInfo[1], pathGumTree)
            #if (!updatedTest)
              #updatedTest = verifyUpdatedTest(baseRight, buildsInfo)
              #updatedTest = verifyChangesOnSameMethod(baseRight, buildsInfo)
            #end
          end
        end
      end
    else
      newTestFile = true
      newTestCase = true
    end
    return newTestFile, newTestCase, updatedTest
  end

  def verifyIfNewTestFile(gumTreeDiff, buildInfo)
    if (gumTreeDiff[1] == nil)
      return false
    end
    gumTreeDiff[1].each do |fileName|
      if (fileName.include? "#{buildInfo[0]}")
        return true
      end
    end
    return false
  end

  def verifyIfNewTestCase(gumTreeDiff, buildInfo)
    if (gumTreeDiff[0][buildInfo[0]] == nil)
      return false
    elsif (gumTreeDiff[0][buildInfo[0]].to_s.match(/Insert SimpleName: #{buildInfo[1]}\([0-9]*\) into MethodDeclaration\([0-9]*\)/))
      return true
    else
      return false
    end
  end

  def verifyUpdatedTest(gumTreeDiff, buildInfo)
    if (gumTreeDiff[0][buildInfo[0]] == nil)
      return false
    else
      return true
    end
  end

  def verifyChangesOnSameMethod(parentOnePath, parentTwoPath, fileName, caseTest, gumTreePath)
    diffParentOne = getMethodChangesByParent(parentOnePath, fileName, caseTest, gumTreePath)
    diffParentTwo = getMethodChangesByParent(parentTwoPath, fileName, caseTest, gumTreePath)
    if (diffParentOne == diffParentTwo)
      return false
    else
      return true
    end
  end


  def getMethodChangesByParent(branchPath, fileName, caseTest, gumTreePath)
    Dir.chdir branchPath
    pathFile = %x(find -name #{fileName+".java"})
    branchFile = %x(readlink -f #{pathFile})

    Dir.chdir gumTreePath
    data = %x(./gumtree parse #{branchFile})
    stringJson = JSON.parse(data)

    stringJson["root"]["children"].each do |child|
      child["children"].each do |newChild|
        if (newChild["typeLabel"] == "MethodDeclaration")
          newChild["children"].each do |methodDeclaration|
            if (methodDeclaration["label"] == caseTest)
              return newChild.to_s.gsub(/\"pos\"\=\>\"[0-9]*\"\,/, "")
            end
          end
        end
      end
    end
    return ""
  end

end