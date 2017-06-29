class StatementDuplicationExtractor

	def initialize()

	end

	def extractionFilesInfo(buildLog)
		#buildLog = build.match(/[\s\S]* BUILD FAILURE/)
		filesInformation = []
		numberOccurrences = buildLog.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\s]* is already defined in [a-zA-Z0-9\/\-\.\:\[\]\,\_]*/).size
		begin
			information = buildLog.to_enum(:scan, /\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,\(\)\s]* is already defined in [a-zA-Z0-9\/\-\.\:\[\]\,\_]*/).map { Regexp.last_match }
			count = 0
			while(count < information.size)
				classFile = information[count].to_s.match(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,\s]*.java:/)[0].split("/").last.gsub('.java:','')
				variableName = information[count].to_s.match(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\,]*\]\s[a-zA-Z0-9\/\-\_]*/)[0].split(" ").last
				methodName = information[count].to_s.match(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\,\]\s\_]*/)[0].split(" ").last
				count += 1
				filesInformation.push([classFile, variableName, methodName])
			end
			return "statementDuplication", filesInformation, information.size
		rescue
			return "statementDuplication", [], 0
		end
	end
	
end