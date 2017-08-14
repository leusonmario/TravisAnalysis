class AlternativeStatement

  def initialize()

  end

  def extractionFilesInfo(buildLog)
    filesInformation = []
    begin
      information = buildLog.to_enum(:scan, /\[ERROR\] Alternative [a-zA-Z0-9\.]* is a subclass of alternative [a-zA-Z0-9\.]*/).map { Regexp.last_match }
      count = 0
      while(count < information.size)
        classFile = information[count].to_s.match(/\[ERROR\] Alternative [a-zA-Z0-9\.]*/).to_s.split("\.").last
        secondClass = information[count].to_s.match(/is a subclass of alternative [a-zA-Z0-9\.]*/).to_s.split("\.").last
        count += 1
        filesInformation.push([classFile, secondClass])
      end
      return "alternativeStatement", filesInformation, information.size
    rescue
      return "alternativeStatement", [], 0
    end
  end

end