class UnavailableSymbolExtractor

	def initialize()

	end

	def extractionFilesInfo(buildLog, completeBuildLog, hashCommit, pathToMerge)
		stringNotFindType = "not find: type"
		stringNotMember = "is not a member of"
		stringErro = "ERROR"
		categoryMissingSymbol = ""

		filesInformation = []
		numberOcccurrences = buildLog.scan(/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?|\[#{stringErro}\][\s\S]*#{stringNotFindType}|\[#{stringErro}\][\s\S]*#{stringNotMember}|\[ERROR\]?[\s\S]*cannot find symbol/).size
		begin
			if (buildLog[/\[ERROR\]?[\s\S]*cannot find symbol/] || buildLog[/\[ERROR\] [a-zA-Z0-9\/\-\.\:\[\]\,]* cannot find symbol[\n\r]+\[ERROR\]?[ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*method [a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]+\[ERROR\]?[ \t\r\n\f]*location[ \t\r\n\f]*:[ \t\r\n\f]*class[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\)]*[\n\r]?/] || buildLog[/\[javac\] [\/a-zA-Z\_\-\.\:0-9 ]* cannot find symbol/])
				if (buildLog[/error: package [a-zA-Z\.]* does not exist /])
					return getInfoSecondCase(buildLog, completeBuildLog)
				elsif (buildLog[/error: cannot find symbol/])
					return getInfoThirdCase(completeBuildLog)
				else
					return getInfoDefaultCase(buildLog, completeBuildLog)
				end
			end
		rescue
			return categoryMissingSymbol, [], 0
		end
	end

	def getInfoDefaultCase(buildLog, completeBuildLog)
		classFiles = []
		methodNames = []
		callClassFiles = []
		if (buildLog[/\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+/])
			methodNames = buildLog.to_enum(:scan, /\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+ [a-zA-Z\. ]*/).map { Regexp.last_match }
			classFiles = buildLog.to_enum(:scan, /\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+ [a-zA-Z\. ]*/).map { Regexp.last_match }
			callClassFiles = buildLog.to_enum(:scan, /\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+ [a-zA-Z\. ]*/).map { Regexp.last_match }
		else
			methodNames = buildLog.to_enum(:scan, /\[ERROR\][ \t\r\n\f]*symbol[ \t\r\n\f]*:[ \t\r\n\f]*[method|class|variable|constructor|static]*[ \t\r\n\f]*[a-zA-Z0-9\(\)\.\/\,\_]*[ \t\r\n\f]*(\[INFO\] )?\[ERROR\][ \t\r\n\f]*(location)?/).map { Regexp.last_match }
			classFiles = buildLog.to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*(location)?[ \t\r\n\f]*:[ \t\r\n\f]*(@)?[class|interface|variable instance of type|variable request of type)?|package]+[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]*[\n\r]?/).map { Regexp.last_match }
			callClassFiles = getCallClassFiles(completeBuildLog)
		end
		categoryMissingSymbol = getTypeUnavailableSymbol(methodNames[0])
		filesInformation = []
		count = 0
		while (count < classFiles.size)
			#fazer chamada de categorySymbol aqui... não precisa mudar mais nada no método methodNames[count]
			methodName = methodNames[count].to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|variable|class|constructor|static)[ \t\r\n\f]*[a-zA-Z0-9\_]*/)[0].split(" ").last
			classFile = classFiles[count].to_s.match(/location[ \t\r\n\f]*:[ \t\r\n\f]*(@)?(variable (request|instance) of type|class|interface|package)?[ \t\r\n\f]*[a-zA-Z0-9\/\-\.\:\[\]\,\(\) ]*/)[0].split(".").last.gsub("\r", "").to_s
			callClassFile = ""
			line = callClassFiles[count].to_s.gsub(" cannot find symbol","").to_s.split(".java")[1].to_s.match(/[0-9]*\,[0-9]*/)[0]
			if (buildLog[/\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+/])
				callClassFile = classFile
			else
				callClassFile = callClassFiles[count].to_s.match(/\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z0-9\,\_]*/)[0].split("/").last.gsub(".java:", "").gsub("\r", "").to_s
			end
			categoryMissingSymbol = getTypeUnavailableSymbol(methodNames[count])
			count += 1
			filesInformation.push([categoryMissingSymbol, classFile, methodName, callClassFile, line])
		end
		return categoryMissingSymbol, filesInformation, filesInformation.size
	end

	def getInfoThirdCase(buildLog, hashCommit, pathToMerge)
		filesInformation = []
		classFiles = buildLog.to_enum(:scan, /\[ERROR\][a-zA-Z0-9\/\.\: \[\]\,\-]* error: cannot find symbol/).map { Regexp.last_match }
		count = 0
		while(count < classFiles.size)
			classFile = classFiles[count].to_s.split(".java")[0].to_s.split('\/').last
			filesInformation.push(classFile)
			count += 1
		end
		if (filesInformation.size < 1)
			classFiles = buildLog.to_enum(:scan, /[a-zA-Z0-9\/\.\: \[\]\,\-]* error: cannot find symbol/).map { Regexp.last_match }
			count = 0
			while(count < classFiles.size)
				classFile = classFiles[count].to_s.split(".java")[0].to_s.split('\/').last

				#Extrair linha e coluna do erro dada a linha de log correspondente
				logErrorLine = classFiles[count]

				#Extraindo o texto que contem a linha e a coluna do erro
				logFileErrorPosition = logErrorLine.to_enum(:scan, /\[[0-9]*,[0-9]*\]/).map { Regexp.last_match }

				#puts logFileErrorPosition

				lineErroredPosition = logFileErrorPosition[0].to_s.split(/\[|\]|,/)[1].to_i
				columnErroredPosition = logFileErrorPosition[0].to_s.split(/\[|\]|,/)[2].to_i

				#puts lineErroredPosition
				#puts columnErroredPosition


				#Acessar o arquivo no path correto
				cloneRepo = pathToClone #trocar por pathToClone
				classFile = classFile      #trocar por classFile

				#acessando o repositorio mudando o ponteiro para o commit que quebrou
				Dir.chdir cloneRepo
				%x(git checkout #{hashCommit})

				pathToFile = cloneRepo + classFile + ".java"
				fileErrored = File.open(pathToFile)


				lineErrored = ""
				lineErroredPosition.times { lineErrored = fileErrored.gets }
				#puts "Line length " + lineErrored.length.to_s


				unavailableSymbol = lineErrored[columnErroredPosition..lineErrored.length-1]

				#puts unavailableSymbol

				symbolType = ""
				if(/[\/a-zA-Z\_\-\.\:0-9]*\([\/a-zA-Z\_\-\.\:0-9]*\)/.match(unavailableSymbol))then
					symbolType = "MethodCall"
				elsif(/new ([\/a-zA-Z\_\-\.\:0-9]*)/.match(unavailableSymbol)) then
					symbolType = "ClassInstantiation"
				elsif
				(/class ([\/a-zA-Z\_\-\.\:0-9]*)/.match(unavailableSymbol)) then
					symbolType = "ClassAtribution"
				end



				filesInformation.push(["unavailableSymbolFileSpecialCase", classFile, unavailableSymbol, symbolType])



				count += 1
			end
		end
		return "unavailableSymbolFileSpecialCase", filesInformation, filesInformation.size
	end

	def getInfoSecondCase(buildLog, completeBuildLog)
		#classFiles = buildLog.to_enum(:scan, /\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+/).map { Regexp.last_match }
		methodNames = buildLog.to_enum(:scan, /\[javac\] [\/a-zA-Z\_\-\.\:0-9]* cannot find symbol[\s\S]* \[javac\] (location:)+/).map { Regexp.last_match }
		#categoryMissingSymbol = getTypeUnavailableSymbol(methodNames[0])
		categoryMissingSymbol = getTypeUnavailableSymbol(methodNames[0])
		filesInformation = []
		methodNames = buildLog.to_enum(:scan, /error: package [a-zA-Z\.]* does not exist/).map { Regexp.last_match }
		count = 0
		while (count < methodNames.size)
			packageName = methodNames[count].to_s.split("package ").last.to_s.gsub(" does not exist")
			count += 1
			filesInformation.push([categoryMissingSymbol, packageName])
		end
		return categoryMissingSymbol, filesInformation, filesInformation.size
	end

	def getCallClassFiles(buildLog)
		if (buildLog.include?('Retrying, 3 of 3'))
			aux = buildLog[/BUILD FAILURE[\s\S]*/]
			return aux.to_s.to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,\_]* cannot find symbol/).map { Regexp.last_match }
		else
			return buildLog[/Compilation failure:[\s\S]*/].to_enum(:scan, /\[ERROR\]?[ \t\r\n\f]*[\/\-\.\:a-zA-Z\[\]0-9\,]* cannot find symbol/).map { Regexp.last_match }
		end
	end

	def getTypeUnavailableSymbol(methodNames)
		#update aqui - Receber um array, e retornar todos os valores possíveis
		if (methodNames.to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(method|constructor)[ \t\r\n\f]*[a-zA-Z0-9\_]*/))
			return "unavailableSymbolMethod"
		elsif (methodNames.to_s.match(/symbol[ \t\r\n\f]*:[ \t\r\n\f]*(variable)[ \t\r\n\f]*[a-zA-Z0-9\_]*/))
			return "unavailableSymbolVariable"
		elsif (methodNames.to_s.match(/error: package/))
			return "unavailablePackage"
		else
			return "unavailableSymbolFile"
		end
	end

end