rAnalysisPath = getwd()
setwd("..")
rootPathProject = getwd()

frequencyBuildConflicts = c()
frequencyConflictingContributions = c()
csvFileCCPercent = ""
csvFileBCPercent = ""

library(vioplot)
library(ggplot2)
library(reshape2)

mergeScenariosBuilds = "MergeScenariosBuilds"
dir.create(file.path(rAnalysisPath, mergeScenariosBuilds), showWarnings = FALSE)
frequencyAnalysis = "FrequencyAnalysis"
dir.create(file.path(rAnalysisPath, frequencyAnalysis), showWarnings = FALSE)

setwd(file.path(rAnalysisPath, mergeScenariosBuilds))
mergeScenariosBuildsPath = getwd()
setwd(file.path(rAnalysisPath, frequencyAnalysis))
frequencyAnalysisPath = getwd()

setwd(file.path(rAnalysisPath, frequencyAnalysis))
unlink("AllScenariosAnalysis.csv", recursive = FALSE, force = FALSE)
infoCSVFile = matrix(c("Evaluated Scenarios", "Causes", "Percentage"), ncol=3)
write.table(infoCSVFile, file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")

pathFoldersMergeScenarios = c()
count = 1

library(vioplot)
mainDir = getwd()

count = 1
#while (count <= length(pathFoldersMergeScenarios)){
while (count <= 1){
	setwd(rootPathProject)
	pathCausesFailed = c(rootPathProject, paste("/FinalResults/MergeScenarios/BuiltMergeScenarios/ConflictsCauses/TestConflictsCauses.csv", sep="/"))
	causesFailedBuilds = read.csv(paste(pathCausesFailed, collapse=""), header=T)

	setwd(rootPathProject)
	pathCausesErrored = c(rootPathProject, paste("/FinalResults/MergeScenarios/BuiltMergeScenarios/ConflictsCauses/BuildConflictsCauses.csv", sep="/"))
	causesErroredBuilds = read.csv(paste(pathCausesErrored, collapse=""), header=T)

	setwd(rootPathProject)
	pathMergeScenarios = c(rootPathProject, paste("/FinalResults/MergeScenarios/BuiltMergeScenarios/ConflictsAnalysis/ConflictsAnalysisFinal.csv", sep="/"))
	mergeScenarios = read.csv(paste(pathMergeScenarios, collapse=""), header=T)

	if (count == 1) 
	{
		pathResultsAll = c(rootPathProject, "/FinalResults/MergeScenarios/BuiltMergeScenarios/AllProjectsResult.csv")
		resultsAll = read.csv(paste(pathResultsAll, collapse=""), header=T)

		setwd(rootPathProject)
		pathTotalMergesScenarios = c(rootPathProject, "/FinalResults/MergeScenarios/BuiltMergeScenarios/MergeScenariosAnalysis/MergeScenariosProjects.csv")
		totalMergeScenarios = read.csv(paste(pathTotalMergesScenarios, collapse=""), header=T)

		setwd(rootPathProject)
		pathErroredCases = c(rootPathProject,"/FinalResults/MergeScenarios/BuiltMergeScenarios/ErroredCases")
		
		setwd(rAnalysisPath)

		rq1 = "RQ1"
		dir.create(file.path(mergeScenariosBuildsPath, rq1), showWarnings = FALSE)
		setwd(file.path(mergeScenariosBuildsPath, rq1))

		#Slide - How frequently do Broken Builds happen?
		#Pushes
		#Average
		averagePushesPassed = resultsAll$TotalPushPassed*100/resultsAll$TotalBuildPush
		averagePushesErrored = resultsAll$TotalPushErrored*100/resultsAll$TotalBuildPush
		averagePushesFailed = resultsAll$TotalPushFailed*100/resultsAll$TotalBuildPush
		averagePushesCanceled = resultsAll$TotalPushCanceled*100/resultsAll$TotalBuildPush
		#Average - Not Broken Builds (passed and canceled builds)
		averagePushNotBrokenBuilds = mean(averagePushesCanceled+averagePushesPassed, na=TRUE)
		#Average - Broken Builds (errored and failed builds)
		averagePushBrokenBuilds = mean(averagePushesErrored+averagePushesFailed, na=TRUE)

		#Aggregated
		totalPushes = sum(resultsAll$TotalBuildPush)
		AggregatedPushesPassed = sum(resultsAll$TotalPushPassed)
		AggregatedPushesErrored = sum(resultsAll$TotalPushErrored)
		AggregatedPushesFailed = sum(resultsAll$TotalPushFailed)
		AggregatedPushesCanceled = sum(resultsAll$TotalPushCanceled)
		#Aggregated - Not Broken Builds (passed and canceled builds)
		AggregatedPushNotBrokenBuilds = (AggregatedPushesPassed+AggregatedPushesCanceled)*100/totalPushes
		#Average - Broken Builds (errored and failed builds)
		AggregatedPushBrokenBuilds = (AggregatedPushesErrored+AggregatedPushesFailed)*100/totalPushes

		#Pull Requests
		#Average
		averagePRPassed = resultsAll$TotalPullPassed*100/resultsAll$TotalBuildPull
		averagePRErrored = resultsAll$TotalPullErrored*100/resultsAll$TotalBuildPull
		averagePRFailed = resultsAll$TotalPullFailed*100/resultsAll$TotalBuildPull
		averagePRCanceled = resultsAll$TotalPullCanceled*100/resultsAll$TotalBuildPull
		#Average - Not Broken Builds (passed and canceled builds)
		averagePRNotBrokenBuilds = mean(averagePRCanceled+averagePRPassed, na=TRUE)
		#Average - Broken Builds (errored and failed builds)
		averagePRBrokenBuilds = mean(averagePRErrored+averagePRFailed, na=TRUE)

		#Aggregated
		totalPR = sum(resultsAll$TotalBuildPull)
		AggregatedPRPassed = sum(resultsAll$TotalPullPassed)
		AggregatedPRErrored = sum(resultsAll$TotalPullErrored)
		AggregatedPRFailed = sum(resultsAll$TotalPullFailed)
		AggregatedPRCanceled = sum(resultsAll$TotalPullCanceled)
		#Aggregated - Not Broken Builds (passed and canceled builds)
		AggregatedPRNotBrokenBuilds = (AggregatedPRPassed+AggregatedPRCanceled)*100/totalPR
		#Average - Broken Builds (errored and failed builds)
		AggregatedPRBrokenBuilds = (AggregatedPRErrored+AggregatedPRFailed)*100/totalPR

		#Txt File with the informations about the RQ1
		sink("rq1.txt")
		cat("How frequently do Broken Builds happen?")
		cat("\n")
		cat("Pushes")
		cat("\n")
		print("Aggregated Value - Broken Builds")
		print(AggregatedPushBrokenBuilds)
		print("Average Value - Broken Builds")
		print(averagePushBrokenBuilds)
		cat("\n")
		cat("Pull Requests")
		cat("\n")
		print("Aggregated Value - Pull Requests")
		print(AggregatedPRBrokenBuilds)
		print("Average Value - Pull Requests")
		print(averagePRBrokenBuilds)
		sink()

		png(paste("vioplot-broken-build.png", sep=""), width=300, height=350)
		vioplot(averagePushesErrored+averagePushesFailed, col="gray")
		title(y="Percentage(%)")
		dev.off()

		png(paste("vioplot-broken-pull-request.png", sep=""), width=300, height=350)
		vioplot(averagePRErrored+averagePRFailed, col="gray")
		title(y="Percentage(%)")
		dev.off()

		png(paste("broken-build.png", sep=""), width=425, height=350)
		mydata <- data.frame(row.names =c("Aggregated", "Average"), NotBrokenBuilds =c(AggregatedPushNotBrokenBuilds, averagePushNotBrokenBuilds), BrokenBuilds =c(AggregatedPushBrokenBuilds, averagePushBrokenBuilds))
		x <- barplot(t(as.matrix(mydata)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydata$NotBrokenBuild-10, labels=round(mydata$NotBrokenBuild), col="black")
		text(x, mydata$NotBrokenBuild+10, labels=round(mydata$BrokenBuild))
		dev.off()

		png(paste("broken-pull-request.png", sep=""), width=425, height=350)
		mydataPR <- data.frame(row.names =c("Aggregated", "Average"), NotBrokenBuilds =c(AggregatedPRNotBrokenBuilds, averagePRNotBrokenBuilds), BrokenBuilds =c(AggregatedPRBrokenBuilds, averagePRBrokenBuilds))
		x <- barplot(t(as.matrix(mydataPR)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataPR$NotBrokenBuild-10, labels=round(mydataPR$NotBrokenBuild), col="black")
		text(x, mydataPR$NotBrokenBuild+10, labels=round(mydataPR$BrokenBuild))
		dev.off()

		setwd(file.path(mainDir))

		#Slide - How frequently do Errored Builds happen?
		rq2 = "RQ2"
		dir.create(file.path(mergeScenariosBuildsPath, rq2), showWarnings = FALSE)
		setwd(file.path(mergeScenariosBuildsPath, rq2))

		#Pushes
		#Average
		#Average - Not Errored Broken Builds (passed, failed and canceled builds)
		averagePushNotErroredBuilds = mean(averagePushesCanceled+averagePushesPassed+averagePushesFailed, na=TRUE)
		#Average - Errored Broken Builds (errored builds)
		averagePushErroredBuilds = mean(averagePushesErrored, na=TRUE)

		#Aggregated
		#Aggregated - Not Errored Broken Builds (passed, failed and canceled builds)
		AggregatedPushNotErroredBuilds = (AggregatedPushesCanceled+AggregatedPushesPassed+AggregatedPushesFailed)*100/totalPushes
		#Aggregated - Errored Broken Builds (errored builds)
		AggregatedPushErroredBuilds = (AggregatedPushesErrored)*100/totalPushes

		#Pull Requests
		#Average
		#Average - Not Errored Pulls (passed, errored and canceled pulls)
		averagePRNotErroredBuilds = mean(averagePRCanceled+averagePRPassed+averagePRFailed, na=TRUE)
		#Average - Errored Pulls (passed, errored and canceled pulls)
		averagePRErroredBuilds = mean(averagePRErrored, na=TRUE)

		#Aggregated
		#Aggregated - Not Errored Pulls (passed and canceled builds)
		AggregatedPRNotErroredBuilds = (AggregatedPRCanceled+AggregatedPRPassed+AggregatedPRFailed)*100/totalPR
		#Average - Errored Pulls (errored builds)
		AggregatedPRErroredBuilds = (AggregatedPRErrored)*100/totalPR

		#Txt File with the informations about the RQ2
		sink("rq2.txt")
		cat("How frequently do Errored Builds happen?")
		cat("\n")
		cat("Pushes")
		cat("\n")
		print("Aggregated Value - Errored Builds")
		print(AggregatedPushErroredBuilds)
		print("Average Value - Broken Builds")
		print(averagePushErroredBuilds)
		cat("\n")
		cat("Pull Requests")
		cat("\n")
		print("Aggregated Value - Pull Requests")
		print(AggregatedPRErroredBuilds)
		print("Average Value - Pull Requests")
		print(averagePRErroredBuilds)
		sink()

		png(paste("vioplot-errored-build.png", sep=""), width=300, height=350)
		vioplot(averagePushesErrored, col="gray")
		title(ylab="Percentage(%)")
		dev.off()

		png(paste("vioplot-errored-pull-request.png", sep=""), width=300, height=350)
		vioplot(averagePRErrored, col="gray")
		title(ylab="Percentage(%)")
		dev.off()

		png(paste("errored-build.png", sep=""), width=425, height=350)
		mydataErrored <- data.frame(row.names =c("Aggregated", "Average"), NotErroredBuilds =c(AggregatedPushNotErroredBuilds, averagePushNotErroredBuilds), ErroredBuilds =c(AggregatedPushErroredBuilds, averagePushErroredBuilds))
		x <- barplot(t(as.matrix(mydataErrored)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataErrored$NotErroredBuilds-8, labels=round(mydataErrored$NotErroredBuilds), col="black")
		text(x, mydataErrored$NotErroredBuilds+5, labels=round(mydataErrored$ErroredBuilds))
		dev.off()

		png(paste("errored-pull-request.png", sep=""), width=425, height=350)
		mydataErroredPR <- data.frame(row.names =c("Aggregated", "Average"), NotErroredPR =c(AggregatedPRNotErroredBuilds, averagePRNotErroredBuilds), ErroredPR =c(AggregatedPRErroredBuilds, averagePRErroredBuilds))
		x <- barplot(t(as.matrix(mydataErroredPR)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataErroredPR$NotErroredPR-10, labels=round(mydataErroredPR$NotErroredPR), col="black")
		text(x, mydataErroredPR$NotErroredPR+10, labels=round(mydataErroredPR$ErroredPR))
		dev.off()

		setwd(file.path(mainDir))

		#Slide - How frequently do Errored Builds happen?
		rq3 = "RQ3"
		dir.create(file.path(mergeScenariosBuildsPath, rq3), showWarnings = FALSE)
		setwd(file.path(mergeScenariosBuildsPath, rq3))

		#Pushes
		#Average
		#Average - Not Failed Broken Builds (passed, errored and canceled builds)
		averagePushNotFailedBuilds = mean(averagePushesCanceled+averagePushesPassed+averagePushesErrored, na=TRUE)
		#Average - Failed Broken Builds (Failed builds)
		averagePushFailedBuilds = mean(averagePushesFailed, na=TRUE)

		#Aggregated
		#Aggregated - Not Failed Broken Builds (passed, errored and canceled builds)
		AggregatedPushNotFailedBuilds = (AggregatedPushesCanceled+AggregatedPushesPassed+AggregatedPushesErrored)*100/totalPushes
		#Aggregated - Failed Broken Builds (Failed builds)
		AggregatedPushFailedBuilds = (AggregatedPushesFailed)*100/totalPushes

		#Pull Requests
		#Average
		#Average - Not Failed Pulls (passed, errored and canceled pulls)
		averagePRNotFailedBuilds = mean(averagePRCanceled+averagePRPassed+averagePRErrored, na=TRUE)
		#Average - Failed Pulls (Failed pulls)
		averagePRFailedBuilds = mean(averagePRFailed, na=TRUE)

		#Aggregated
		#Aggregated - Not Failed Pulls (passed, errored and canceled builds)
		AggregatedPRNotFailedBuilds = (AggregatedPRCanceled+AggregatedPRPassed+AggregatedPRErrored)*100/totalPR
		#Average - Failed Pulls (failed builds)
		AggregatedPRFailedBuilds = (AggregatedPRFailed)*100/totalPR

		#Txt File with the informations about the RQ3
		sink("rq3.txt")
		cat("How frequently do Failed Builds happen?")
		cat("\n")
		cat("Pushes")
		cat("\n")
		print("Aggregated Value - Errored Builds")
		print(AggregatedPushFailedBuilds)
		print("Average Value - Broken Builds")
		print(averagePushFailedBuilds)
		cat("\n")
		cat("Pull Requests")
		cat("\n")
		print("Aggregated Value - Pull Requests")
		print(AggregatedPRFailedBuilds)
		print("Average Value - Pull Requests")
		print(averagePRFailedBuilds)
		sink()

		png(paste("vioplot-failed-build.png", sep=""), width=300, height=350)
		vioplot(averagePushesFailed, col="gray")
		title(ylab="Percentage(%)")
		dev.off()

		png(paste("vioplot-failed-pull-request.png", sep=""), width=300, height=350)
		vioplot(averagePRFailed, col="gray")
		title(ylab="Percentage(%)")
		dev.off()

		png(paste("failed-build.png", sep=""), width=425, height=350)
		mydataFailed <- data.frame(row.names =c("Aggregated", "Average"), NotFailedBuilds =c(AggregatedPushNotFailedBuilds, averagePushNotFailedBuilds), FailedBuilds =c(AggregatedPushFailedBuilds, averagePushFailedBuilds))
		x <- barplot(t(as.matrix(mydataFailed)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataFailed$NotFailedBuilds-8, labels=round(mydataFailed$NotFailedBuilds), col="black")
		text(x, mydataFailed$NotFailedBuilds+5, labels=round(mydataFailed$FailedBuilds))
		dev.off()

		png(paste("failed-pull-request.png", sep=""), width=425, height=350)
		mydataFailedPR <- data.frame(row.names =c("Aggregated", "Average"), NotFailedPR =c(AggregatedPRNotFailedBuilds, averagePRNotFailedBuilds), FailedPR =c(AggregatedPRFailedBuilds, averagePRFailedBuilds))
		x <- barplot(t(as.matrix(mydataFailedPR)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataFailedPR$NotFailedPR-10, labels=round(mydataFailedPR$NotFailedPR), col="black")
		text(x, mydataFailedPR$NotFailedPR+10, labels=round(mydataFailedPR$FailedPR))
		dev.off()

		setwd(file.path(mainDir))

		#Slide - How frequently are Merge Scenario from Master Built on Travis?
		rq4 = "RQ4"
		dir.create(file.path(mergeScenariosBuildsPath, rq4), showWarnings = FALSE)
		setwd(file.path(mergeScenariosBuildsPath, rq4))

		#Merge Scenarios
		#Average
		averageMergeScenarios = (totalMergeScenarios$TotalMS-totalMergeScenarios$TotalMSNoBuilt)*100/totalMergeScenarios$TotalMS
		averageMergeScenrioPerc = mean(averageMergeScenarios, na=TRUE)
		averageNotBuiltMS = (totalMergeScenarios$TotalMSNoBuilt)*100/totalMergeScenarios$TotalMS
		averageNotMergeScenrioPerc = mean(averageNotBuiltMS, na=TRUE)

		averageMergeScenariosValid = (totalMergeScenarios$TotalMSParentPassed+totalMergeScenarios$TotalMSParentsNoPassed)*100/(totalMergeScenarios$TotalMSParentPassed+totalMergeScenarios$TotalMSParentsNoPassed+totalMergeScenarios$TotalParentNoBuilt)
		averageMergeScenrioPercValid = mean(averageMergeScenariosValid, na=TRUE)
		averageNotBuiltMSValid = (totalMergeScenarios$TotalParentNoBuilt)*100/(totalMergeScenarios$TotalMSParentPassed+totalMergeScenarios$TotalMSParentsNoPassed+totalMergeScenarios$TotalParentNoBuilt)
		averageNotMergeScenrioPercValid = mean(averageNotBuiltMSValid, na.rm=TRUE)

		#Aggregated
		AggregatedMergeScenarios = sum(totalMergeScenarios$TotalMS-totalMergeScenarios$TotalMSNoBuilt)*100/sum(totalMergeScenarios$TotalMS)
		AggregatedNotMergeScenarios = sum(totalMergeScenarios$TotalMSNoBuilt)*100/sum(totalMergeScenarios$TotalMS)

		AggregatedMergeScenariosValid = sum(totalMergeScenarios$TotalMSParentPassed+totalMergeScenarios$TotalMSParentsNoPassed)*100/sum(totalMergeScenarios$TotalMSParentPassed+totalMergeScenarios$TotalMSParentsNoPassed+totalMergeScenarios$TotalParentNoBuilt)
		AggregatedNotMergeScenariosValid = sum(totalMergeScenarios$TotalParentNoBuilt)*100/sum(totalMergeScenarios$TotalMSParentPassed+totalMergeScenarios$TotalMSParentsNoPassed+totalMergeScenarios$TotalParentNoBuilt)

		totalMergeScenariosAnalyzed = sum(totalMergeScenarios$TotalMS)
		totalMergeScenariosAnalyzedErrored = sum(totalMergeScenarios$TotalErroredMS)
		totalMergeScenariosAnalyzedErroredParentsPassed = sum(totalMergeScenarios$TotalMSErrored)
		totalMergeScenariosAnalyzedErroredParentsPassedWithoutExternal = sum(totalMergeScenarios$TotalMSErroredWithoutExternal)
		totalMergeScenariosAnalyzedFailed = sum(totalMergeScenarios$TotalFailedMS)
		totalMergeScenariosAnalyzedFailedParentsPassed = sum(totalMergeScenarios$TotalMSFailed)
		totalMergeScenariosAnalyzedFailedParentsPassedWithoutExternal = sum(totalMergeScenarios$TotalMSFailedWithoutExternal)
		#Txt File with the informations about the RQ4
		sink("rq4.txt")
		cat("How frequently are Merge Scenarios from Master Built on Travis?")
		cat("\n")
		cat("Merge Scenarios")
		cat("\n")
		print("Aggregated Value - Merge Scenarios")
		print(AggregatedMergeScenarios)
		print("Average Value - Merge Scenarios")
		print(averageMergeScenrioPerc)
		cat("\n")
		print("Total : Merge Scenarios")
		print(totalMergeScenariosAnalyzed)
		cat("\n")
		print("Total : Merge Scenarios Errored")
		print(totalMergeScenariosAnalyzedErrored)
		cat("\n")
		print("Total : Merge Scenarios Errored with Parents Passed")
		print(totalMergeScenariosAnalyzedErroredParentsPassed)
		cat("\n")
		print("Total : Merge Scenarios Errored with Parents Passed Without External Causes")
		print(totalMergeScenariosAnalyzedErroredParentsPassedWithoutExternal)
		cat("\n")
		print("Total : Merge Scenarios Failed")
		print(totalMergeScenariosAnalyzedFailed)
		cat("\n")
		print("Total : Merge Scenarios Failed with Parents Passed")
		print(totalMergeScenariosAnalyzedFailedParentsPassed)
		cat("\n")
		print("Total : Merge Scenarios Failed with Parents Passed Without External Causes")
		print(totalMergeScenariosAnalyzedFailedParentsPassedWithoutExternal)
		sink()

		png(paste("vioplot-merge-scenario.png", sep=""), width=300, height=350)
		vioplot(averageMergeScenarios, col="gray")
		title(ylab="Percentage(%)")
		dev.off()

		png(paste("merge-scenario.png", sep=""), width=425, height=350)
		mydataMergeScenario <- data.frame(row.names =c("Aggregated", "Average"), NotBuilt =c(AggregatedNotMergeScenarios, averageNotMergeScenrioPerc), Built =c(AggregatedMergeScenarios, averageMergeScenrioPerc))
		x <- barplot(t(as.matrix(mydataMergeScenario)), col=c("gray", "cornflowerblue"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataMergeScenario$NotBuilt-8, labels=round(mydataMergeScenario$NotBuilt), col="black")
		text(x, mydataMergeScenario$NotBuilt+10, labels=round(mydataMergeScenario$Built))
		dev.off()

		png(paste("vioplot-merge-scenario-valid.png", sep=""), width=300, height=350)
		vioplot(averageMergeScenariosValid, col="gray")
		title(ylab="Percentage(%)")
		dev.off()

		png(paste("merge-scenario-valid.png", sep=""), width=425, height=350)
		mydataMergeScenario <- data.frame(row.names =c("Aggregated", "Average"), NoParentBuilt =c(AggregatedNotMergeScenariosValid, averageNotMergeScenrioPercValid), ParentBuilt =c(AggregatedMergeScenariosValid, averageMergeScenrioPercValid))
		x <- barplot(t(as.matrix(mydataMergeScenario)), col=c("gray", "cornflowerblue"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataMergeScenario$NoParentBuilt-8, labels=round(mydataMergeScenario$NoParentBuilt), col="black")
		text(x, mydataMergeScenario$NoParentBuilt+10, labels=round(mydataMergeScenario$ParentBuilt))
		dev.off()

		setwd(file.path(mainDir))

		#Slide - How frequently are Errored Builds resulting from Built Merge Scenarios?
		#What files are modified in Built Merge Scenarios of Errored Builds?
		rq5 = "RQ5"
		dir.create(file.path(mergeScenariosBuildsPath, rq5), showWarnings = FALSE)
		setwd(file.path(mergeScenariosBuildsPath, rq5))
		#Average
		averageMergeScenariosErrored = mergeScenarios$PushesErrored*100/(totalMergeScenarios$TotalMS-totalMergeScenarios$TotalMSNoBuilt)
		#averageMergeScenariosErrored = mergeScenarios$PushesErrored*100/(totalMergeScenarios$ValidBuilds)
		averageMergeScenariosErroredPerc = mean(averageMergeScenariosErrored, na=TRUE)
		#Aggregated
		
		AggregatedMergeScenariosErrored = sum(mergeScenarios$PushesErrored)*100/sum(totalMergeScenarios$TotalMS-totalMergeScenarios$TotalMSNoBuilt)
		#AggregatedMergeScenariosErrored = sum(mergeScenarios$PushesErrored)*100/sum(totalMergeScenarios$ValidBuilds)

		#Changes Distributions on modified Files

		erroredPushTravisAll = mergeScenarios$ErroredTravis*100/mergeScenarios$PushesErrored
		erroredPushConfigAll = mergeScenarios$ErroredConfig*100/mergeScenarios$PushesErrored
		erroredPushSourceAll = mergeScenarios$ErroredSource*100/mergeScenarios$PushesErrored
		erroredPushAllTogether = mergeScenarios$ErroredAll*100/mergeScenarios$PushesErrored

		averageErroredPushTravisAllPerc = mean(erroredPushTravisAll, na=TRUE)
		averageErroredPushConfigAllPerc = mean(erroredPushConfigAll, na=TRUE)
		averageErroredPushSourceAllPerc = mean(erroredPushSourceAll, na=TRUE)
		averageErroredPushAllTogetherPerc = mean(erroredPushAllTogether, na=TRUE)

		png(paste("vioplot-errored-build-errored-ms.png", sep=""), width=300, height=350)
		vioplot(averageMergeScenariosErrored, col="gray")
		title(xlab="", ylab="Percentage(%)")
		dev.off()

		png(paste("errored-build-frequency-ms.png", sep=""), width=425, height=350)
		mydataMergeScenario <- data.frame(row.names =c("Aggregated", "Average"), NotErrored =c(100-AggregatedMergeScenariosErrored, 100-averageMergeScenariosErroredPerc), Errored =c(AggregatedMergeScenariosErrored, averageMergeScenariosErroredPerc))
		x <- barplot(t(as.matrix(mydataMergeScenario)), col=c("gray", "red"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataMergeScenario$NotErrored-8, labels=round(mydataMergeScenario$NotErrored), col="black")
		text(x, mydataMergeScenario$NotErrored+10, labels=round(mydataMergeScenario$Errored))
		dev.off()
		#Txt File with the informations about the RQ5
		sink("rq5.txt")
		cat("How frequently are Errored Builds resulting from Built Merge Scenarios?")
		cat("\n")
		cat("Errored Builds from Merge Scenarios")
		cat("\n")
		print("Aggregated Value - Errored Builds")
		print(AggregatedMergeScenariosErrored)
		print("Average Value - Errored Builds")
		print(mean(averageMergeScenariosErrored))
		cat("\n")
		cat("\n")
		cat("What files are modified in Built Merge Scenarios of Errored Builds?")
		cat("\n")
		cat("Changes Distribution on Modified Files - Average")
		print("Travis Changes")
		print(averageErroredPushTravisAllPerc)
		print("Config Changes")
		print(averageErroredPushConfigAllPerc)
		print("Souce-code Changes")
		print(averageErroredPushSourceAllPerc)
		print("All Together Changes")
		print(averageErroredPushAllTogetherPerc)
		cat("\n")
		sink()

		png(paste("errored-build-changes-file.png", sep=""), width=425, height=350)
		mydataErroredChanges <- data.frame(row.names =c("Average"), Travis=c(averageErroredPushTravisAllPerc), Config=c(averageErroredPushConfigAllPerc), Source=c(averageErroredPushSourceAllPerc), All=c(averageErroredPushAllTogetherPerc))
		x <- barplot(t(as.matrix(mydataErroredChanges)), col=c("cornflowerblue", "red", "darkgreen", "violet"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
		text(x, mydataErroredChanges$Travis-1, labels=round(mydataErroredChanges$Travis), col="black")
		text(x, mydataErroredChanges$Travis+3, labels=round(mydataErroredChanges$Config), col="black")
		text(x, mydataErroredChanges$Source-8, labels=round(mydataErroredChanges$Source), col="black")
		text(x, mydataErroredChanges$Source+10, labels=round(mydataErroredChanges$All), col="black")
		dev.off()
	}

	setwd(file.path(mainDir))

	#Slide - How frequently are Failed Builds resulting from Built Merge Scenarios?
	#What files are modified in Built Merge Scenarios of Failed Builds?
	rq6 = "RQ6"
	dir.create(file.path(mergeScenariosBuildsPath, rq6), showWarnings = FALSE)
	setwd(file.path(mergeScenariosBuildsPath, rq6))

	#Average
	averageMergeScenariosFailed = mergeScenarios$PushesFailed*100/(totalMergeScenarios$TotalMS-totalMergeScenarios$TotalMSNoBuilt)
	averageMergeScenariosFailedPerc = mean(averageMergeScenariosFailed, na=TRUE)
	#Aggregated
	AggregatedMergeScenariosFailed = sum(mergeScenarios$PushesFailed)*100/sum(totalMergeScenarios$TotalMS-totalMergeScenarios$TotalMSNoBuilt)

	failedPushTravisAll = mergeScenarios$FailedTravis*100/mergeScenarios$PushesFailed
	failedPushConfigAll = mergeScenarios$FailedConfig*100/mergeScenarios$PushesFailed
	failedPushSourceAll = mergeScenarios$FailedSource*100/mergeScenarios$PushesFailed
	failedPushAllTogether = mergeScenarios$FailedAll*100/mergeScenarios$PushesFailed

	averageFailedPushTravisAllPerc = mean(failedPushTravisAll, na=TRUE)
	averageFailedPushConfigAllPerc = mean(failedPushConfigAll, na=TRUE)
	averageFailedPushSourceAllPerc = mean(failedPushSourceAll, na=TRUE)
	averageFailedPushAllTogetherPerc = mean(failedPushAllTogether, na=TRUE)

	#Txt File with the informations about the RQ6
	sink("rq6.txt")
	cat("How frequently are Failed Builds resulting from Built Merge Scenarios?")
	cat("\n")
	cat("What files are modified in Built Merge Scenarios of Failed Builds?")
	cat("\n")
	cat("Failed Builds from Merge Scenarios")
	cat("\n")
	print("Aggregated Value - Failed Builds")
	print(AggregatedMergeScenariosFailed)
	print("Average Value - Failed Builds")
	print(averageMergeScenariosFailedPerc)
	cat("\n")
	cat("\n")
	cat("What files are modified in Built Merge Scenarios of Failed Builds?")
	cat("\n")
	cat("Changes Distribution on Modified Files - Average")
	print("Travis Changes")
	print(averageFailedPushTravisAllPerc)
	print("Config Changes")
	print(averageFailedPushConfigAllPerc)
	print("Souce-code Changes")
	print(averageFailedPushSourceAllPerc)
	print("All Together Changes")
	print(averageFailedPushAllTogetherPerc)
	cat("\n")
	sink()

	png(paste("failed-build-changes-file.png", sep=""), width=425, height=350)
	mydataFailedChanges <- data.frame(row.names =c("Average"), Travis=c(averageFailedPushTravisAllPerc), Config=c(averageFailedPushConfigAllPerc), Source=c(averageFailedPushSourceAllPerc), All=c(averageFailedPushAllTogetherPerc))
	x <- barplot(t(as.matrix(mydataFailedChanges)), col=c("cornflowerblue", "red", "darkgreen", "violet"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
	text(x, mydataFailedChanges$Travis-1, labels=round(mydataFailedChanges$Travis), col="black")
	text(x, mydataFailedChanges$Travis+3, labels=round(mydataFailedChanges$Config), col="black")
	text(x, mydataFailedChanges$Source-8, labels=round(mydataFailedChanges$Source), col="black")
	text(x, mydataFailedChanges$Source+10, labels=round(mydataFailedChanges$All), col="black")
	dev.off()

	setwd(file.path(mainDir))

	#Slide - How frequently do Build Conflicts happen on Built Merge Scenarios of Errored Builds?
	#What files are modified on Build Conflicts Scenarios?
	rq7 = "RQ7"
	dir.create(file.path(mergeScenariosBuildsPath, rq7), showWarnings = FALSE)
	setwd(file.path(mergeScenariosBuildsPath, rq7))

	#Build Conflicts - Errored Merge Scenarios
	#Average
	averageErroredPushTravisConf = mergeScenarios$ErroredTravisConf*100/mergeScenarios$PushesErrored
	averageErroredPushConfigConf = mergeScenarios$ErroredConfigConf*100/mergeScenarios$PushesErrored
	averageErroredPushSourceConf = mergeScenarios$ErroredSourceConf*100/mergeScenarios$PushesErrored
	averageErroredPushAllTogetherConf = mergeScenarios$ErroredAllConf*100/mergeScenarios$PushesErrored

	averageErroredPushTravisConfPerc = mean(averageErroredPushTravisConf, na=TRUE)
	averagevErroredPushConfigConfPerc = mean(averageErroredPushConfigConf, na=TRUE)
	averageErroredPushSourceConfPerc = mean(averageErroredPushSourceConf, na=TRUE)
	averageErroredPushAllTogetherConfPerc = mean(averageErroredPushAllTogetherConf, na=TRUE)
	averageErroredBuildConflict = averageErroredPushTravisConfPerc + averagevErroredPushConfigConfPerc + averageErroredPushSourceConfPerc + averageErroredPushAllTogetherConfPerc

	#Aggregated
	AggregatedErroredConf = (sum(mergeScenarios$ErroredTravisConf, na.rm=TRUE) + sum(mergeScenarios$ErroredConfigConf, na.rm=TRUE) + sum(mergeScenarios$ErroredSourceConf, na.rm=TRUE) + sum(mergeScenarios$ErroredAllConf, na.rm=TRUE))*100/sum(mergeScenarios$PushesErrored, na.rm=TRUE)

	#Build Conflicts - All Merge Scenarios
	#Average
	averageErroredPushTravisConfAll = mergeScenarios$ErroredTravisConf*100/(totalMergeScenarios$ValidBuilds)
	averageErroredPushConfigConfAll = mergeScenarios$ErroredConfigConf*100/(totalMergeScenarios$ValidBuilds)
	averageErroredPushSourceConfAll = mergeScenarios$ErroredSourceConf*100/(totalMergeScenarios$ValidBuilds)
	averageErroredPushAllTogetherConfAll = mergeScenarios$ErroredAllConf*100/(totalMergeScenarios$ValidBuilds)

	averageErroredPushTravisConfAllPerc = mean(averageErroredPushTravisConfAll, na=TRUE)
	averageErroredPushConfigConfAllPerc = mean(averageErroredPushConfigConfAll, na=TRUE)
	averageErroredPushSourceConfAllPerc = mean(averageErroredPushSourceConfAll, na=TRUE)
	averageErroredPushAllTogetherConfAllPerc = mean(averageErroredPushAllTogetherConfAll, na=TRUE)
	averageErroredBuildConflictAll = averageErroredPushTravisConfAllPerc + averageErroredPushConfigConfAllPerc + averageErroredPushSourceConfAllPerc + averageErroredPushAllTogetherConfAllPerc

	#Aggregated
	AggregatedErroredConfAll = (sum(mergeScenarios$ErroredTravisConf, na.rm=TRUE) + sum(mergeScenarios$ErroredConfigConf, na.rm=TRUE) + sum(mergeScenarios$ErroredSourceConf, na.rm=TRUE) + sum(mergeScenarios$ErroredAllConf, na.rm=TRUE))*100/sum(totalMergeScenarios$ValidBuilds, na.rm=TRUE)

	#Txt File with the informations about the RQ7
	sink("rq7.txt")
	cat("How frequently do Build Conflicts happen on built Merge Scenarios of Errored Builds?")
	cat("\n")
	cat("Build Conflicts only from Errored Scenarios")
	cat("\n")
	print("Aggregated Value - Errored Builds")
	print(AggregatedErroredConf)
	print("Average Value - Errored Builds")
	print(averageErroredBuildConflict)
	cat("\n")
	cat("\n")
	cat("Build Conflicts from Merge Scenarios")
	cat("\n")
	print("Aggregated Value - Errored Builds")
	print(AggregatedErroredConfAll)
	print("Average Value - Errored Builds")
	print(averageErroredBuildConflictAll)
	cat("\n")
	sink()

	setwd(file.path(mainDir))

	#Slide - How frequently do Test Conflicts happen on Built Merge Scenarios of Failed Builds?
	#What files are modified on Test Conflicts Scenarios?
	rq8 = "RQ8"
	dir.create(file.path(mergeScenariosBuildsPath, rq8), showWarnings = FALSE)
	setwd(file.path(mergeScenariosBuildsPath, rq8))

	#Test Conflicts - Failed Merge Scenarios
	#Average
	averageFailedPushTravisConf = mergeScenarios$FailedTravisConf*100/mergeScenarios$PushesFailed
	averageFailedPushConfigConf = mergeScenarios$FailedConfigConf*100/mergeScenarios$PushesFailed
	averageFailedPushSourceConf = mergeScenarios$FailedSourceConf*100/mergeScenarios$PushesFailed
	averageFailedPushAllTogetherConf = mergeScenarios$FailedAllConf*100/mergeScenarios$PushesFailed

	averageFailedPushTravisConfPerc = mean(averageFailedPushTravisConf, na=TRUE)
	averageFailedPushConfigConfPerc = mean(averageFailedPushConfigConf, na=TRUE)
	averageFailedPushSourceConfPerc = mean(averageFailedPushSourceConf, na=TRUE)
	averageFailedPushAllTogetherConfPerc = mean(averageFailedPushAllTogetherConf, na=TRUE)
	averageFailedBuildConflict = averageFailedPushTravisConfPerc + averageFailedPushConfigConfPerc + averageFailedPushSourceConfPerc + averageFailedPushAllTogetherConfPerc

	#Aggregated
	AggregatedFailedConf = (sum(mergeScenarios$FailedTravisConf, na.rm=TRUE) + sum(mergeScenarios$FailedConfigConf, na.rm=TRUE) + sum(mergeScenarios$FailedSourceConf, na.rm=TRUE) + sum(mergeScenarios$FailedAllConf, na.rm=TRUE))*100/sum(mergeScenarios$PushesFailed, na.rm=TRUE)

	#Build Conflicts - All Merge Scenarios
	#Average
	averageFailedPushTravisConfAll = mergeScenarios$FailedTravisConf*100/(totalMergeScenarios$ValidBuilds)
	averageFailedPushConfigConfAll = mergeScenarios$FailedConfigConf*100/(totalMergeScenarios$ValidBuilds)
	averageFailedPushSourceConfAll = mergeScenarios$FailedSourceConf*100/(totalMergeScenarios$ValidBuilds)
	averageFailedPushAllTogetherConfAll = mergeScenarios$FailedAllConf*100/(totalMergeScenarios$ValidBuilds)

	averageFailedPushTravisConfAllPerc = mean(averageFailedPushTravisConfAll, na=TRUE)
	averageFailedPushConfigConfAllPerc = mean(averageFailedPushConfigConfAll, na=TRUE)
	averageFailedPushSourceConfAllPerc = mean(averageFailedPushSourceConfAll, na=TRUE)
	averageFailedPushAllTogetherConfAllPerc = mean(averageFailedPushAllTogetherConfAll, na=TRUE)
	averageFailedBuildConflictAll = averageFailedPushTravisConfAllPerc + averageFailedPushConfigConfAllPerc + averageFailedPushSourceConfAllPerc + averageFailedPushAllTogetherConfAllPerc

	#Aggregated
	AggregatedFailedConfAll = (sum(mergeScenarios$FailedTravisConf, na.rm=TRUE) + sum(mergeScenarios$FailedConfigConf, na.rm=TRUE) + sum(mergeScenarios$FailedSourceConf, na.rm=TRUE) + sum(mergeScenarios$FailedAllConf, na.rm=TRUE))*100/sum(totalMergeScenarios$ValidBuilds, na.rm=TRUE)

	#Txt File with the informations about the RQ8
	sink("rq8.txt")
	cat("How frequently do Test Conflicts happen on built Merge Scenarios of Errored Builds?")
	cat("\n")
	cat("Build Conflicts only from Failed Scenarios")
	cat("\n")
	print("Aggregated Value - Failed Builds")
	print(AggregatedFailedConf)
	print("Average Value - Failed Builds")
	print(averageFailedBuildConflict)
	cat("\n")
	cat("\n")
	cat("Build Conflicts from Merge Scenarios")
	cat("\n")
	print("Aggregated Value - Failed Builds")
	print(AggregatedFailedConfAll)
	print("Average Value - Failed Builds")
	print(averageFailedBuildConflictAll)
	cat("\n")
	sink()

	setwd(file.path(mainDir))

	#Slide - What are the Causes of Errored Builds in Build Conflicts Scenarios?
	rq9 = "RQ9"
	dir.create(file.path(mergeScenariosBuildsPath, rq9), showWarnings = FALSE)
	setwd(file.path(mergeScenariosBuildsPath, rq9))

	totalCausesErrored = sum(causesErroredBuilds$PERMISSION, na.rm=TRUE)+sum(causesErroredBuilds$GIT.PROBLEM, na.rm=TRUE)+sum(causesErroredBuilds$UNIMPLEMENTED.METHOD, na.rm=TRUE)+sum(causesErroredBuilds$DEPENDENCY, na.rm=TRUE)+sum(causesErroredBuilds$DUPLICATE.STATEMENT, na.rm=TRUE)+sum(causesErroredBuilds$METHOD.UPDATE, na.rm=TRUE)+sum(causesErroredBuilds$UNAVAILABLE.FILE, na.rm=TRUE)+sum(causesErroredBuilds$UNAVAILABLE.METHOD, na.rm=TRUE)+sum(causesErroredBuilds$UNAVAILABLE.VARIABLE, na.rm=TRUE)+sum(causesErroredBuilds$MALFORMED.EXPRESSION, na.rm=TRUE)+sum(causesErroredBuilds$ANOTHER.ERROR, na.rm=TRUE)+sum(causesErroredBuilds$COMPILER.ERROR, na.rm=TRUE)
	noFoundSymbolErrored = (sum(causesErroredBuilds$UNAVAILABLE.FILE, na.rm=TRUE)+sum(causesErroredBuilds$UNAVAILABLE.METHOD, na.rm=TRUE)+sum(causesErroredBuilds$UNAVAILABLE.VARIABLE, na.rm=TRUE))*100/totalCausesErrored
	malformedExpression = sum(causesErroredBuilds$MALFORMED.EXPRESSION, na.rm=TRUE)*100/totalCausesErrored
	methodUpdate = sum(causesErroredBuilds$METHOD.UPDATE, na.rm=TRUE)*100/totalCausesErrored
	duplicate = sum(causesErroredBuilds$DUPLICATE.STATEMENT, na.rm=TRUE)*100/totalCausesErrored
	dependency = sum(causesErroredBuilds$DEPENDENCY, na.rm=TRUE)*100/totalCausesErrored
	unimplementedMethod = sum(causesErroredBuilds$UNIMPLEMENTED.METHOD, na.rm=TRUE)*100/totalCausesErrored
	gitProblemErrored = sum(causesErroredBuilds$GIT.PROBLEM, na.rm=TRUE)*100/totalCausesErrored
	remoteErrorErrored = sum(causesErroredBuilds$REMOTE.ERROR, na.rm=TRUE)*100/totalCausesErrored
	compilerErrorErrored = sum(causesErroredBuilds$COMPILER.ERROR, na.rm=TRUE)*100/totalCausesErrored
	permissionErrored = sum(causesErroredBuilds$PERMISSION, na.rm=TRUE)*100/totalCausesErrored
	anotherErrorErrored = sum(causesErroredBuilds$ANOTHER.ERROR, na.rm=TRUE)*100/totalCausesErrored

	#Txt File with the informations about the RQ10
	sink("rq9.txt")
	cat("What are the Causes of Errored Builds in Test Conflicts Scenarios?")
	cat("\n")
	cat("Test Conflicts from Errored Scenarios")
	cat("\n")
	print("No Found Symbol")
	print(noFoundSymbolErrored)
	print("Malformed Expression")
	print(malformedExpression)
	print("Update Modifier")
	print(methodUpdate)
	print("Duplicate Statement")
	print(duplicate)
	print("Dependency")
	print(dependency)
	print("Unimplemented Method")
	print(unimplementedMethod)
	print("Git Problem")
	print(gitProblemErrored)
	print("Remote Error")
	print(remoteErrorErrored)
	print("Compiler Error")
	print(compilerErrorErrored)
	print("Permission")
	print(permissionErrored)
	print("Another Error")
	print(anotherErrorErrored)
	cat("\n")
	sink()

	setwd(file.path(mainDir))

	#Slide - What are the Causes of Failed Builds in Test Conflicts Scenarios?
	rq10 = "RQ10"
	dir.create(file.path(mergeScenariosBuildsPath, rq10), showWarnings = FALSE)
	setwd(file.path(mergeScenariosBuildsPath, rq10))

	totalCauses = sum(causesFailedBuilds$Total, na.rm=TRUE)
	gitProblem = sum(causesFailedBuilds$GIT.PROBLEM, na.rm=TRUE)*100/totalCauses
	remoteError = sum(causesFailedBuilds$REMOTE.ERROR, na.rm=TRUE)*100/totalCauses
	permission = sum(causesFailedBuilds$PERMISSION, na.rm=TRUE)*100/totalCauses
	failed = sum(causesFailedBuilds$FAILED, na.rm=TRUE)*100/totalCauses
	anotherError = sum(causesFailedBuilds$ANOTHER.ERROR, na.rm=TRUE)*100/totalCauses

	#Txt File with the informations about the RQ10
	sink("rq10.txt")
	cat("What are the Causes of Failed Builds in Test Conflicts Scenarios?")
	cat("\n")
	cat("Test Conflicts from Failed Scenarios")
	cat("\n")
	print("Git Problem")
	print(gitProblem)
	print("Remote Error")
	print(remoteError)
	print("Permission")
	print(permission)
	print("Failed")
	print(failed)
	print("Another Error")
	print(anotherError)
	cat("\n")
	sink()

	setwd(file.path(mainDir))

	rq11 = "ErroredCases"
	dir.create(file.path(mergeScenariosBuildsPath, rq11), showWarnings = FALSE)
	setwd(file.path(rootPathProject, paste("FinalResults/MergeScenarios/BuiltMergeScenarios/ErroredCases", sep="/")))
	listFiles = list.files(path = ".", pattern = "*.csv", all.files = FALSE, full.names = FALSE, recursive = FALSE)
	setwd(file.path(mergeScenariosBuildsPath, rq11))
	unlink("AllBuiltMergeAnalysis.csv", recursive = FALSE, force = FALSE)
	unlink("BuildConflictsAnalysis.csv", recursive = FALSE, force = FALSE)
	unlink("ConflictingContributionAnalysis.csv", recursive = FALSE, force = FALSE)
	unlink("FrequencyBuildsContributionsConflict.csv", recursive = FALSE, force = FALSE)
	infoCSVFile = matrix(c("ProjectName", "gitProblem", "unavailableSymbol", "compilerError", "MethodParameterListSize", "AnotherError", "remoteError", "malformedExpression", "unimplementedMethod", "statementDuplication", "dependencyProblem"), ncol=11)
	write.table(infoCSVFile, file = "AllBuiltMergeAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(infoCSVFile, file = "BuildConflictsAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(infoCSVFile, file = "ConflictingContributionAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	infoFrequency = matrix(c("ProjectName", "BuildConflict", "ContributionConflicting"), ncol=3)
	write.table(infoFrequency, file = "FrequencyBuildsContributionsConflict.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	
	indexFiles = 1
	while(indexFiles <= length(listFiles)){
		setwd(file.path(rootPathProject, paste("FinalResults/MergeScenarios/BuiltMergeScenarios/ErroredCases", sep="/")))
		projectInfo = read.csv(listFiles[indexFiles], header=T)
		projectName = strsplit(strsplit(listFiles[indexFiles], "Errored")[[1]], ".csv")[[2]][1]
		infoValues = matrix(c("gitProblem", 0, "unavailableSymbol", 0, "compilerError", 0, "methodParameterListSize", 0, " ", 0, "remoteError", 0, "malformedExpression", 0, "unimplementedMethod", 0, "statementDuplication", 0, "dependencyProblem", 0), ncol=10, nrow=2)
		buildConflicts = matrix(c("gitProblem", 0, "unavailableSymbol", 0, "compilerError", 0, "MethodParameterListSize", 0, " ", 0, "remoteError", 0, "malformedExpression", 0, "unimplementedMethod", 0, "statementDuplication", 0, "dependencyProblem", 0), ncol=10, nrow=2)
		conflictingContribution = matrix(c("gitProblem", 0, "unavailableSymbol", 0, "compilerError", 0, "MethodParameterListSize", 0, " ", 0, "remoteError", 0, "malformedExpression", 0, "unimplementedMethod", 0, "statementDuplication", 0, "dependencyProblem", 0), ncol=10, nrow=2)
		countLines = 1
		numberLines = length(projectInfo$MessageState)
		while (countLines <= numberLines){
			countMessage = 0
			while ((countMessage/2)+1 <= length(infoValues[1,])){
				a = projectInfo$MessageState[countLines]
				if (projectInfo$MessageState[countLines] != "[]"){
					a = gsub("\\[", "", a)
					a = gsub("\\]", "", a)
					a = gsub("\"", "", a)
					a = gsub(" ", "", a)
					a = strsplit(a, ",")[[1]]
				}else{
					a = gsub("\\[", " ", a)
					a = gsub("\\]", "", a)
				}

				matchLine = grepl(infoValues[countMessage+1],a)
				countMatchLine = 1
				while (countMatchLine <= length(matchLine)){
					if (matchLine[countMatchLine] == TRUE){
						infoValues[countMessage+2] = strtoi(infoValues[countMessage+2]) + 1
						cc = projectInfo$ConflictingContributions[countLines]
						if (projectInfo$MessageState[countLines] != "[]"){
							cc = gsub("\\[", "", cc)
							cc = gsub("\\]", "", cc)
							cc = gsub("\"", "", cc)
							cc = gsub(" ", "", cc)
							cc = strsplit(cc, ",")[[1]]
						}
						status = 1
						statusFinal = TRUE
						while (status <= length(cc)) {
							if (cc[status] == "false"){
								statusFinal = FALSE
							}
							status = status + 1
						}

						if (statusFinal == TRUE){
							if (projectInfo$AllColaborationsIntgrated[countLines] == "true"){
								buildConflicts[countMessage+2] = strtoi(buildConflicts[countMessage+2]) + 1
							}else{
								conflictingContribution[countMessage+2] = strtoi(conflictingContribution[countMessage+2]) + 1
							}
							
						}
					}
					countMatchLine = countMatchLine + 1
				}
				countMessage = countMessage + 2
			}
			countLines = countLines + 1	
			setwd(file.path(mergeScenariosBuildsPath, rq11))
		}
		setwd(file.path(mergeScenariosBuildsPath, rq11))
		write.table(matrix(c(projectName, infoValues[2,]), ncol=11), file = "AllBuiltMergeAnalysis.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		write.table(matrix(c(projectName, buildConflicts[2,]), ncol=11), file = "BuildConflictsAnalysis.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		write.table(matrix(c(projectName, conflictingContribution[2,]), ncol=11), file = "ConflictingContributionAnalysis.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		write.table(matrix(c(projectName, sum(strtoi(buildConflicts[2,]))*100/sum(strtoi(infoValues[2,])), sum(strtoi(conflictingContribution[2,]))*100/sum(strtoi(infoValues[2,]))), ncol=3), file = "FrequencyBuildsContributionsConflict.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		indexFiles = indexFiles + 1
	}

	setwd(file.path(mergeScenariosBuildsPath, rq11))
	frequencyBCC = read.csv("FrequencyBuildsContributionsConflict.csv", header=T)
	frequencyBuildConflicts = cbind(frequencyBuildConflicts, frequencyBCC$BuildConflict)
	frequencyConflictingContributions = cbind(frequencyConflictingContributions, frequencyBCC$ContributionConflicting)

	filesConflicts = c("ErroredCases/BuildConflictsAnalysis.csv", "ErroredCases/ConflictingContributionAnalysis.csv")
	namesConflictingPics = c("build-conflicts", "conflicting-contributions")
	countFilesConflicting = 1
	while (countFilesConflicting <= length(filesConflicts)){
		setwd(file.path(mergeScenariosBuildsPath, rq11))
		pathFileConflicting = c(mergeScenariosBuildsPath, paste("",filesConflicts[countFilesConflicting], sep="/"))
		allErroredAnalysis = read.csv(paste(pathFileConflicting, collapse=""), header=T)

		allErroredGitProblem = mean(allErroredAnalysis$gitProblem)
		allErroredUnavailableSymbol = mean(allErroredAnalysis$unavailableSymbol)
		allErroredCompilerError = mean(allErroredAnalysis$compilerError)
		allErroredMethodUpdate = mean(allErroredAnalysis$MethodParameterListSize)
		allErroredAnother = mean(allErroredAnalysis$AnotherError)
		allErroredRemote = mean(allErroredAnalysis$remoteError)
		allErroredMalformed = mean(allErroredAnalysis$malformedExpression)
		allErroredUnimplemented = mean(allErroredAnalysis$unimplementedMethod)

		GitProblem = allErroredAnalysis[,2]
		UnavSymbol = allErroredAnalysis[,3]
		CompilerError = allErroredAnalysis[,4]
		MethodUpdate = allErroredAnalysis[,5]
		Remote = allErroredAnalysis[,7]
		Malformed = allErroredAnalysis[,8]
		Unimplemented = allErroredAnalysis[,9]
		StatDuplication = allErroredAnalysis[,10]
		Another = allErroredAnalysis[,6]

		Compilation = allErroredAnalysis[,3] + allErroredAnalysis[,5] + allErroredAnalysis[,8] + allErroredAnalysis[,9] + allErroredAnalysis[,10]
		Environment = allErroredAnalysis[,2] + allErroredAnalysis[,4]
		bplotIndividual = cbind(UnavSymbol, MethodUpdate, Unimplemented, StatDuplication)
		
		countFilesConflicting = countFilesConflicting + 1
	}

	setwd(file.path(mergeScenariosBuildsPath, rq11))
	csvFileAll = read.csv("AllBuiltMergeAnalysis.csv", header=T)
	csvFileBC = read.csv("BuildConflictsAnalysis.csv", header=T)
	csvFileCC = read.csv("ConflictingContributionAnalysis.csv", header=T)
	unlink("BuildConflictsPercentage.csv", recursive = FALSE, force = FALSE)
	unlink("ConflictingContributionsPercentage.csv", recursive = FALSE, force = FALSE)
	unlink("BuildConflictsPercentageGeneral.csv", recursive = FALSE, force = FALSE)
	infoCSVFile = matrix(c("ProjectName", "unavailableSymbol", "MethodParameterListSize", "malformedExpression", "unimplementedMethod", "statementDuplication", "dependencyProblem", "General"), ncol=8)
	infoCSVBCGeneral = matrix(c("ProjectName", "BC", "CC"), ncol=3)
	write.table(infoCSVFile, file = "BuildConflictsPercentage.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(infoCSVFile, file = "ConflictingContributionsPercentage.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	countLine = 1

	while (countLine < length(readLines("AllBuiltMergeAnalysis.csv"))) {
		write.table(matrix(c( as.character(csvFileAll[countLine,1]), 
							sum(strtoi(csvFileBC[countLine,3]))*100/(sum(strtoi(csvFileBC[countLine,]))-countLine),
							sum(strtoi(csvFileBC[countLine,5]))*100/(sum(strtoi(csvFileBC[countLine,]))-countLine),
							sum(strtoi(csvFileBC[countLine,8]))*100/(sum(strtoi(csvFileBC[countLine,]))-countLine),
							sum(strtoi(csvFileBC[countLine,9]))*100/(sum(strtoi(csvFileBC[countLine,]))-countLine),
							sum(strtoi(csvFileBC[countLine,10]))*100/(sum(strtoi(csvFileBC[countLine,]))-countLine),
							sum(strtoi(csvFileBC[countLine,11]))*100/(sum(strtoi(csvFileBC[countLine,]))-countLine),
							sum(sum(strtoi(csvFileBC[countLine,3]), strtoi(csvFileBC[countLine,5]), strtoi(csvFileBC[countLine,8]), strtoi(csvFileBC[countLine,9]), strtoi(csvFileBC[countLine,10])))*100/sum(sum(strtoi(csvFileAll[countLine,3]),strtoi(csvFileAll[countLine,5]),strtoi(csvFileAll[countLine,8]),strtoi(csvFileAll[countLine,9]), strtoi(csvFileAll[countLine,10])))
		), ncol=8), file = "BuildConflictsPercentage.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		write.table(matrix(c( as.character(csvFileAll[countLine,1]), 
							sum(strtoi(csvFileCC[countLine,3]))*100/(sum(strtoi(csvFileCC[countLine,]))-countLine),
							sum(strtoi(csvFileCC[countLine,5]))*100/(sum(strtoi(csvFileCC[countLine,]))-countLine),
							sum(strtoi(csvFileCC[countLine,8]))*100/(sum(strtoi(csvFileCC[countLine,]))-countLine),
							sum(strtoi(csvFileCC[countLine,9]))*100/(sum(strtoi(csvFileCC[countLine,]))-countLine),
							sum(strtoi(csvFileCC[countLine,10]))*100/(sum(strtoi(csvFileCC[countLine,]))-countLine),
							sum(strtoi(csvFileCC[countLine,11]))*100/(sum(strtoi(csvFileCC[countLine,]))-countLine),
							sum(sum(strtoi(csvFileCC[countLine,3]), strtoi(csvFileCC[countLine,5]), strtoi(csvFileCC[countLine,8]), strtoi(csvFileCC[countLine,9]), strtoi(csvFileCC[countLine,10])))*100/sum(sum(strtoi(csvFileAll[countLine,3]),strtoi(csvFileAll[countLine,5]),strtoi(csvFileAll[countLine,8]),strtoi(csvFileAll[countLine,9]), strtoi(csvFileAll[countLine,10])))
		), ncol=8), file = "ConflictingContributionsPercentage.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		#write.table(matrix(c(as.character(csvFileAll[countLine,1]), (sum(strtoi(csvFileBC[countLine, ]))-1)*100/(sum(strtoi(csvFileAll[countLine,]))-1), (sum(strtoi(csvFileCC[countLine, ]))-1)*100/(sum(strtoi(csvFileAll[countLine,]))-1)), ncol=3), file="BuildConflictsPercentageGeneral.csv", row.names=F, col.names=F, sep=",", append=TRUE)
		countLine = countLine + 1
	}

	setwd(file.path(mergeScenariosBuildsPath, rq11))
	csvFileCCPercent = read.csv("ConflictingContributionAnalysis.csv", header=T)
	csvFileBCPercent = read.csv("BuildConflictsAnalysis.csv", header=T)	
	unavailableSymbolBCPercent = sum(csvFileBCPercent$unavailableSymbol)
	updateSymbolBCPercent = sum(csvFileBCPercent$MethodParameterListSize)
	unimplementedSymbolBCPercent = sum(csvFileBCPercent$unimplementedMethod)
	statementSymbolBCPercent = sum(csvFileBCPercent$statementDuplication)
	totalBCPercent = unavailableSymbolBCPercent + updateSymbolBCPercent + unimplementedSymbolBCPercent + statementSymbolBCPercent
	print (totalBCPercent)
	sink("causes-frequency-BC.txt")
	cat("What are the Causes of Build Conflicts?")
	cat("\n")
	print("No Found Symbol")
	print(unavailableSymbolBCPercent*100/totalBCPercent)
	print("Unimplemented Method")
	print(unimplementedSymbolBCPercent*100/totalBCPercent)
	print("Method Update")
	print(updateSymbolBCPercent*100/totalBCPercent)
	print("Duplicate Statement")
	print(statementSymbolBCPercent*100/totalBCPercent)
	cat("\n")
	sink()

	setwd(file.path(rAnalysisPath, frequencyAnalysis))
	write.table(matrix(c("Build Conflicts", "Semantic", unavailableSymbolBCPercent*100/totalBCPercent + unimplementedSymbolBCPercent*100/totalBCPercent), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(matrix(c("Build Conflicts", "Syntax", statementSymbolBCPercent*100/totalBCPercent), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(matrix(c("Build Conflicts", "Type Mismatch", updateSymbolBCPercent*100/totalBCPercent), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(matrix(c("Build Conflicts", "Dependency", 0), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	setwd(file.path(mergeScenariosBuildsPath, rq11))

	unavailableSymbolCCPercent = sum(csvFileCCPercent$unavailableSymbol)
	updateSymbolCCPercent = sum(csvFileCCPercent$MethodParameterListSize)
	unimplementedSymbolCCPercent = sum(csvFileCCPercent$unimplementedMethod)
	statementSymbolCCPercent = sum(csvFileCCPercent$statementDuplication)
	totalCCPercent = unavailableSymbolCCPercent + updateSymbolCCPercent + unimplementedSymbolCCPercent + statementSymbolCCPercent

	setwd(file.path(rAnalysisPath, frequencyAnalysis))
	write.table(matrix(c("Badly-Solved Scenarios", "Semantic", unavailableSymbolCCPercent*100/totalCCPercent + unimplementedSymbolCCPercent*100/totalCCPercent), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(matrix(c("Badly-Solved Scenarios", "Syntax", statementSymbolCCPercent*100/totalCCPercent), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(matrix(c("Badly-Solved Scenarios", "Type Mismatch", updateSymbolCCPercent*100/totalCCPercent), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	write.table(matrix(c("Badly-Solved Scenarios", "Dependency", 0), ncol=3), file = "AllScenariosAnalysis.csv", col.names=F, row.names=F, append=TRUE, sep=",")
	setwd(file.path(mergeScenariosBuildsPath, rq11))
	
	sink("causes-frequency-CC.txt")
	cat("What are the Causes of Conflicting Contributions?")
	cat("\n")
	print("No Found Symbol")
	print(unavailableSymbolCCPercent*100/totalCCPercent)
	print("Unimplemented Method")
	print(unimplementedSymbolCCPercent*100/totalCCPercent)
	print("Method Update")
	print(updateSymbolCCPercent*100/totalCCPercent)
	print("Duplicate Statement")
	print(statementSymbolCCPercent*100/totalCCPercent)
	cat("\n")
	sink()

	csvFileCCPercent = read.csv("ConflictingContributionsPercentage.csv", header=T)
	png(paste("percentage-CC", sep="-"), width=650, height=550)
	boxplot(csvFileCCPercent$unavailableSymbol, csvFileCCPercent$MethodParameterListSize, csvFileCCPercent$unimplementedMethod, csvFileCCPercent$statementDuplication, csvFileCCPercent$dependencyProblem, col="gray", names=c("UnavSymbol", "MethodUpda", "Unimplemented", "StatDuplication", "Dependency"))
	title(ylab="Percentage(%)")
	dev.off()

	csvFileBCPercent = read.csv("BuildConflictsPercentage.csv", header=T)	
	png(paste("percentage-BC", sep="-"), width=650, height=550)
	boxplot(csvFileBCPercent$unavailableSymbol, csvFileBCPercent$MethodParameterListSize, csvFileBCPercent$unimplementedMethod, csvFileBCPercent$statementDuplication, csvFileCCPercent$dependencyProblem, col="gray", names=c("UnavSymbol", "MethodUpda", "Unimplemented", "StatDuplication", "Dependency"))
	title(ylab="Percentage(%)")
	dev.off()

	count = count + 1
}

setwd(file.path(rAnalysisPath, frequencyAnalysis))
charts.data <- read.csv("AllScenariosAnalysis.csv")
png(paste("distribution-problems", sep="-"), width=700, height=650)
p4 <- ggplot() + geom_bar(aes(y = Percentage, x = Evaluated.Scenarios, fill = Causes), data = charts.data, stat="identity") + coord_flip()
p4 <- p4 + geom_text(data=charts.data, aes(x = Evaluated.Scenarios, y = Percentage, label = paste0("")), size=4) + theme_minimal() +  ggtitle("Distribution of Errored Build Causes") + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold")) + theme(plot.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=22, hjust=0))
p4
dev.off()

png(paste("frequency-build-conflicts-BC.png", sep="-"), width=600, height=550)
vioplot(frequencyBuildConflicts[,1], col="gray", names=c("BuiltMergeScenarios"))
title(ylab="Percentage(%)", xlab="Merge Scenarios")
dev.off()

png(paste("frequency-conflicting-contribution-CC.png", sep="-"), width=600, height=550)
vioplot(frequencyConflictingContributions[,1], col="gray", names=c("BuiltMergeScenarios"))
title(ylab="Percentage(%)", xlab="Merge Scenarios")
dev.off()