
class TestConflictInfo
  def initialize()

  end

  def getInfoTestConflicts(gumTreeDiff, buildsInfo)
    baseLeft = gumTreeDiff[0]
    leftResult = gumTreeDiff[1]
    baseRight = gumTreeDiff[2]
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
            updatedTest = verifyUpdatedTest(baseLeft, buildsInfo)
            if (!updatedTest)
              updatedTest = verifyUpdatedTest(baseRight, buildsInfo)
            end
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

end