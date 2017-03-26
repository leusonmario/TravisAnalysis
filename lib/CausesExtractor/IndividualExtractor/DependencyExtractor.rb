class DependencyExtractor

	def initialize()

	end

	def extractionFilesInfo(buildLog, buildLogExtra)
		filesInformation = []
		stringBuildFail = "BUILD FAILED"
		stringUndefinedExt = "uses an undefined extension point"
		stringErro = "ERROR"
		stringDependency = "Could not resolve dependencies for project"
		stringNonParseable = "Non-parseable POM "
		stringUnexpected = " unexpected character in markup"
		stringGradle = ".gradle"
		stringProblemScript = "A problem occurred evaluating script"
		stringScript = "Script"
		stringAddTask = "Cannot add task"
		stringTaskExists = "as a task with that name already exists"
		numberOccurrences = buildLog.scan(/#{stringBuildFail}[\s\S]*#{stringUndefinedExt}|\[#{stringErro}\][\s\S]*#{stringDependency}|\[#{stringErro}\][\s\S]*#{stringNonParseable}[\s\S]*(#{stringUnexpected}[\s\S]*\[#{stringErro}\])?|#{stringScript}[\s\S]*#{stringGradle}[\s\S]*#{stringProblemScript}[\s\S]*#{stringAddTask}[\s\S]*#{stringTaskExists}[\s\S]*#{stringBuildFail}/).size
		begin
			if (buildLogExtra.match(/Could not transfer artifact/))
				filesInformation = buildLogExtra.match(/Could not transfer artifact [a-zA-Z\:\-0-9\.]*/).to_s.gsub("Could not transfer artifact ", "").split("\:")
			end
			return "dependencyProblem", filesInformation, numberOccurrences
		rescue
			return "dependencyProblem", [], numberOccurrences
		end
		return "dependencyProblem", [], numberOccurrences
	end
	
end