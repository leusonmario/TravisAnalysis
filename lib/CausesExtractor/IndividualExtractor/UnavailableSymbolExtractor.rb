class UnavailableSymbolExtractor

	def initialize()

	end

	def extractionFilesInfo(buildLog, completeBuildLog)
		stringNotFindType = "not find: type"
		stringNotMember = "is not a member of"
		stringErro = "ERROR"
		categoryMissingSymbol = ""

		filesInformation = []
		numberOcccurrences = buildLog.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?|\[#{stringErro}\][\s\S]*#{stringNotFindType}|\[#{stringErro}\][\s\S]*#{stringNotMember}|\[ERROR\]?[\s\S]*cannot find symbol/).size
		begin
			if (buildLog[/\[ERROR\]?[\s\S]*cannot find symbol/] || buildLog[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/])
				methodNames = buildLog.to_enum(:scan, /\[ERROR\][ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*[method|class|variable|constructor|static]*[ \t\r\n\f]*[a-zA-Z0-9\(\)\.\/\,\_]*[ \t\r\n\f]*\[ERROR\][ \t\r\n\f]*location/).map { Regexp.last_match }
				
				if (methodNames[0].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|constructor)[ \t\r\n\f]*[a-zA-Z0-9\_]*/))
					categoryMissingSymbol = "unavailableSymbolMethod"
				elsif (methodNames[0].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(variable)[ \t\r\n\f]*[a-zA-Z0-9\_]*/)) 
					categoryMissingSymbol = "unavailableSymbolVariable"
				else
					categoryMissingSymbol = "unavailableSymbolFile"
				end
				classFiles = buildLog.to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*(@)?[class|interface|variable]+[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/).map { Regexp.last_match }
				callClassFiles = ""
				if (completeBuildLog.include?('Retrying, 3 of 3'))
					callClassFiles = buildLog[/BUILD FAILURE[\s\S]*/].to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,]* cannot find symbol/).map { Regexp.last_match }
				else
					callClassFiles = buildLog[/Compilation failure:[\s\S]*/].to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,]* cannot find symbol/).map { Regexp.last_match }
				end
				count = 0
				while (count < classFiles.size)
					methodName = methodNames[count].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|variable|class|constructor|static)[ \t\r\n\f]*[a-zA-Z0-9\_]*/)[0].split(" ").last
					classFile = classFiles[count].to_s.match(/location[ \t\r\n\f]*:[ \t\r\n\f]*(@)?(class|interface)?[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*/)[0].split(".").last.gsub("\r", "").to_s
					callClassFile = callClassFiles[count].to_s.match(/\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z0-9\,]*/)[0].split("/").last.gsub(".java:", "").gsub("\r", "").to_s
					count += 1
					filesInformation.push([classFile, methodName, callClassFile])
				end
			end
			return categoryMissingSymbol, filesInformation, classFiles.size
		rescue
			return categoryMissingSymbol, [], 0
		end
	end
	
end