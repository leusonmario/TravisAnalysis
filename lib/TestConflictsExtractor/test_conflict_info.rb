
class TestConflictInfo
  def initialize()

  end

  def getInfoTestConflicts(gumTreeDiff, buildsInfo)
    baseLeft = gumTreeDiff[1]
    leftResult = gumTreeDiff[2]
    baseRight = gumTreeDiff[3]
    rightResult = gumTreeDiff[4]

    newTestFile = false
    newTestCase = false
    if (!verifyIfNewTestFile(baseLeft, buildsInfo[2]))
      newTestFile = verifyIfNewTestFile(baseRight, buildsInfo[2])
      if (newTestFile)
        newTestCase = true
      else
        if (verifyIfNewTestCase(baseLeft, buildsInfo[2]))
          newTestCase = true
        else
          newTestCase = verifyIfNewTestCase(baseRight, buildsInfo[2])
        end
      end
    else
      newTestFile = true
      newTestCase = true
    end
    return newTestFile, newTestCase
  end

  def verifyIfNewTestFile(gumTreeDiff, buildInfo)
    gumTreeDiff[1].each do |fileName|
      if (fileName.include? "#{buildInfo[0]}")
        return true
      end
    end
    return false
  end

  def verifyIfNewTestCase(gumTreeDiff, buildInfo)
    if (gumTreeDiff[0][buildInfo[0]].to_s.match(/Insert SimpleName: #{buildInfo[1]}\([0-9]*\) into MethodDeclaration\([0-9]*\)/))
      return true
    else
      return false
    end
  end

end