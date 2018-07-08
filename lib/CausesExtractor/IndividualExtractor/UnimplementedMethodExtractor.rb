class UnimplementedMethodExtractor

	def initialize()

	end

	def extractionFilesInfo(buildLog)

		begin
			count = 0
			if (buildLog[/method does not override or implement a method from a supertype/])
				return getInfoSecondCase(buildLog)
			else
				return getInfoDefaultCase(buildLog)
			end
		rescue
			return "unimplementedMethod", [], 0
		end
	end

  def getInfoDefaultCase(buildLog)
		stringErro = "ERROR"
		stringNoOverride = "does not override (abstract|or implement a)? method"
		filesInformation = []
		numberOccurrences = buildLog.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*(\[INFO\])?/).size
		classFiles = ""

		if (buildLog.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
			classFiles = buildLog.to_enum(:scan, /\[ERROR\] [a-zA-Z\/\-]*\.java/).map { Regexp.last_match }
		elsif (buildLog.match(/error: [a-zA-Z\/\-]* is not abstract/))
			classFiles = buildLog.to_enum(:scan, /error: [a-zA-Z\/\-]* is not abstract/).map { Regexp.last_match }
		end

		interfaceFiles = buildLog.to_enum(:scan, /#{stringNoOverride} [0-9a-zA-Z\(\)\<\>\.\,]* in [a-zA-Z\.]*[^\n]+/).map { Regexp.last_match }
		methodInterfaces = buildLog.to_enum(:scan, /#{stringNoOverride} [0-9a-zA-Z\(\)\.\,]* in/).map { Regexp.last_match }
		count = 0
		while(count < interfaceFiles.size)
			classFile = ""
			methodInterface = ""
			if (buildLog.match(/\[ERROR\] [0-9a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
				classFile = classFiles[count].to_s.match(/[a-zA-Z]+\.java/)[0].to_s
			elsif (buildLog.match(/error: [0-9a-zA-Z\/\-]* is not abstract/))
				classFile = classFiles[count].to_s.match(/error: [a-zA-Z\/\-]*/).gsub("error: ","")
			end
			interfaceFile = interfaceFiles[count].to_s.split(".").last.gsub("\r", "").to_s
			if (methodInterfaces[count].to_s.match(/does not override abstract method[\s\S]*\(/))
				methodInterface = methodInterfaces[count].to_s.match(/does not override abstract method[\s\S]*\(/).to_s.gsub(/does not override abstract method /,"").to_s.gsub("\(","")
			else
				methodInterface = methodInterfaces[count].to_s.match(/[a-zA-Z\(\)]* in/).to_s.gsub(" in","").to_s
			end
			if (methodInterface == "")
				methodInterface = interfaceFiles[count].to_s.match(/does not override abstract method [a-zA-Z\<\> ]*/).to_s.split("\>").last
			end

			filesInformation.push(["unimplementedMethod", classFile, interfaceFile, methodInterface])
			count += 1
		end
		return "unimplementedMethod", filesInformation, interfaceFiles.size
	end

	def getInfoSecondCase(buildLog)
		filesInformation = []
		classFiles = buildLog.to_enum(:scan, /\[ERROR\] [a-zA-Z\/\-\.\:\,\[\]0-9 ]*cannot find symbol/).map { Regexp.last_match }
		methodInterfaces = buildLog.to_enum(:scan, /symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|variable|class|constructor|static)[ \t\r\n\f]*[a-zA-Z0-9\_]*/).map { Regexp.last_match }
		count = 0
		while(count < classFiles.size)
			classFile = classFiles[count].to_s.match(/[a-zA-Z]+\.java/)[0].to_s.gsub(".java","")
			methodInterface = methodInterfaces[count].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|variable|class|constructor|static)[ \t\r\n\f]*[a-zA-Z0-9\_]*/)[0].split(" ").last
			filesInformation.push(["unimplementedMethodSuperType", classFile, classFile, methodInterface])
			count += 1
		end
		return "unimplementedMethodSuperType", filesInformation, filesInformation.size
	end
	
end