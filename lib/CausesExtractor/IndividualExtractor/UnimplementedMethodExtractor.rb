class UnimplementedMethodExtractor

	def initialize()

	end

	def extractionFilesInfo(buildLog)
		filesInformation = []
		stringErro = "ERROR"
		stringNoOverride = "does not override abstract method"
		numberOccurrences = buildLog.scan(/\[#{stringErro}\][\s\S]*#{stringNoOverride}[\s\S]*\[#{stringErro}\]/).size
		begin
			count = 0
			classFiles = ""
			if (buildLog.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
				classFiles = buildLog.to_enum(:scan, /\[ERROR\] [a-zA-Z\/\-]*\.java/).map { Regexp.last_match }
			elsif (buildLog.match(/error: [a-zA-Z\/\-]* is not abstract/))
				classFiles = buildLog.to_enum(:scan, /error: [a-zA-Z\/\-]* is not abstract/).map { Regexp.last_match }
			end
			interfaceFiles = buildLog.to_enum(:scan, /#{stringNoOverride} [a-zA-Z\(\)]* in [a-zA-Z\.]*[^\n]+/).map { Regexp.last_match }
			methodInterfaces = buildLog.to_enum(:scan, /#{stringNoOverride} [a-zA-Z\(\)]* in/).map { Regexp.last_match }
			while(count < interfaceFiles.size)
				classFile = ""
				if (buildLog.match(/\[ERROR\] [a-zA-Z\/\-]*\.java/).to_s.match(/[a-zA-Z]+\.java/)[0].to_s)
					classFile = classFiles[count].to_s.match(/[a-zA-Z]+\.java/)[0].to_s
				elsif (buildLog.match(/error: [a-zA-Z\/\-]* is not abstract/))
					classFile = classFiles[count].to_s.match(/error: [a-zA-Z\/\-]*/).gsub("error: ","")
				end
				interfaceFile = interfaceFiles[count].to_s.split(".").last.gsub("\r", "").to_s
				methodInterface = methodInterfaces[count].to_s.match(/[a-zA-Z\(\)]* in/).to_s.gsub(" in","").to_s
				filesInformation.push([classFile, interfaceFile, methodInterface])
				count += 1
			end
			return "unimplementedMethod", filesInformation, interfaceFiles.size
		rescue
			return "unimplementedMethod", [], 0
		end
	end
	
end