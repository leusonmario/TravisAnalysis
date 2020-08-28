class BCAlternativeStatement

  def initialize()

  end

  def verifyBuildConflict(baseLeft, leftResult, baseRight, rightResult, filesConflicting)
    count = 0
    while (count < filesConflicting.size)
      if(baseLeft[filesConflicting[count][1]] != nil and baseLeft[filesConflicting[count][1].to_s].to_s.match(/Update SimpleType: [a-zA-Z0-9\(\)]* to #{filesConflicting[count][2]}/))
          return true
      end
      if(baseRight[filesConflicting[count][1]] != nil and baseRight[filesConflicting[count][1].to_s].to_s.match(/Update SimpleType: [a-zA-Z0-9\(\)]* to #{filesConflicting[count][2]}/))
        return true
      end
      count += 1
    end
    return false
  end

end