rAnalysisPath = getwd()
setwd("..")
rootPathProject = getwd()
pathResultsAll = c(rootPathProject, "/FinalResults/AllProjectsResult.csv")
resultsAll = read.csv(paste(pathResultsAll, collapse=""), header=T)

setwd(rootPathProject)
pathTotalMergesScenarios = c(rootPathProject, "/FinalResults/MergeScenariosAnalysis/MergeScenariosProjects.csv")
totalMergeScenarios = read.csv(paste(pathTotalMergesScenarios, collapse=""), header=T)

setwd(rootPathProject)
pathMergeScenarios = c(rootPathProject, "/FinalResults/ConflictsAnalysis/ConflictsAnalysisFinal.csv")
mergeScenarios = read.csv(paste(pathMergeScenarios, collapse=""), header=T)

setwd(rootPathProject)
pathCausesFailed = c(rootPathProject, "/FinalResults/ConflictsCauses/TestConflictsCauses.csv")
causesFailedBuilds = read.csv(paste(pathCausesFailed, collapse=""), header=T)

setwd(rootPathProject)
pathCausesErrored = c(rootPathProject, "/FinalResults/ConflictsCauses/BuildConflictsCauses.csv")
causesErroredBuilds = read.csv(paste(pathCausesErrored, collapse=""), header=T)

setwd(rAnalysisPath)

library(beanplot)
mainDir = getwd()
rq1 = "RQ1"
dir.create(file.path(mainDir, rq1), showWarnings = FALSE)
setwd(file.path(mainDir, rq1))

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

#Agregated
totalPushes = sum(resultsAll$TotalBuildPush)
agregatedPushesPassed = sum(resultsAll$TotalPushPassed)
agregatedPushesErrored = sum(resultsAll$TotalPushErrored)
agregatedPushesFailed = sum(resultsAll$TotalPushFailed)
agregatedPushesCanceled = sum(resultsAll$TotalPushCanceled)
#Agregated - Not Broken Builds (passed and canceled builds)
agregatedPushNotBrokenBuilds = (agregatedPushesPassed+agregatedPushesCanceled)*100/totalPushes
#Average - Broken Builds (errored and failed builds)
agregatedPushBrokenBuilds = (agregatedPushesErrored+agregatedPushesFailed)*100/totalPushes

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

#Agregated
totalPR = sum(resultsAll$TotalBuildPull)
agregatedPRPassed = sum(resultsAll$TotalPullPassed)
agregatedPRErrored = sum(resultsAll$TotalPullErrored)
agregatedPRFailed = sum(resultsAll$TotalPullFailed)
agregatedPRCanceled = sum(resultsAll$TotalPullCanceled)
#Agregated - Not Broken Builds (passed and canceled builds)
agregatedPRNotBrokenBuilds = (agregatedPRPassed+agregatedPRCanceled)*100/totalPR
#Average - Broken Builds (errored and failed builds)
agregatedPRBrokenBuilds = (agregatedPRErrored+agregatedPRFailed)*100/totalPR

#Txt File with the informations about the RQ1
sink("rq1.txt")
cat("How frequently do Broken Builds happen?")
cat("\n")
cat("Pushes")
cat("\n")
print("Agregated Value - Broken Builds")
print(agregatedPushBrokenBuilds)
print("Average Value - Broken Builds")
print(averagePushBrokenBuilds)
cat("\n")
cat("Pull Requests")
cat("\n")
print("Agregated Value - Pull Requests")
print(agregatedPRBrokenBuilds)
print("Average Value - Pull Requests")
print(averagePRBrokenBuilds)
sink()

png(paste("beanplot-broken-build.png", sep=""), width=300, height=350)
beanplot(averagePushesErrored+averagePushesFailed, col="gray")
dev.off()

png(paste("beanplot-broken-pull-request.png", sep=""), width=300, height=350)
beanplot(averagePRErrored+averagePRFailed, col="gray")
dev.off()

png(paste("broken-build.png", sep=""), width=425, height=350)
mydata <- data.frame(row.names =c("Agregated", "Average"), NotBrokenBuilds =c(agregatedPushNotBrokenBuilds, averagePushNotBrokenBuilds), BrokenBuilds =c(agregatedPushBrokenBuilds, averagePushBrokenBuilds))
x <- barplot(t(as.matrix(mydata)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydata$NotBrokenBuild-10, labels=round(mydata$NotBrokenBuild), col="black")
text(x, mydata$NotBrokenBuild+10, labels=round(mydata$BrokenBuild))
dev.off()

png(paste("broken-pull-request.png", sep=""), width=425, height=350)
mydataPR <- data.frame(row.names =c("Agregated", "Average"), NotBrokenBuilds =c(agregatedPRNotBrokenBuilds, averagePRNotBrokenBuilds), BrokenBuilds =c(agregatedPRBrokenBuilds, averagePRBrokenBuilds))
x <- barplot(t(as.matrix(mydataPR)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydataPR$NotBrokenBuild-10, labels=round(mydataPR$NotBrokenBuild), col="black")
text(x, mydataPR$NotBrokenBuild+10, labels=round(mydataPR$BrokenBuild))
dev.off()

setwd(file.path(mainDir))

#Slide - How frequently do Errored Builds happen?
rq2 = "RQ2"
dir.create(file.path(mainDir, rq2), showWarnings = FALSE)
setwd(file.path(mainDir, rq2))

#Pushes
#Average
#Average - Not Errored Broken Builds (passed, failed and canceled builds)
averagePushNotErroredBuilds = mean(averagePushesCanceled+averagePushesPassed+averagePushesFailed, na=TRUE)
#Average - Errored Broken Builds (errored builds)
averagePushErroredBuilds = mean(averagePushesErrored, na=TRUE)

#Agregated
#Agregated - Not Errored Broken Builds (passed, failed and canceled builds)
agregatedPushNotErroredBuilds = (agregatedPushesCanceled+agregatedPushesPassed+agregatedPushesFailed)*100/totalPushes
#Agregated - Errored Broken Builds (errored builds)
agregatedPushErroredBuilds = (agregatedPushesErrored)*100/totalPushes

#Pull Requests
#Average
#Average - Not Errored Pulls (passed, errored and canceled pulls)
averagePRNotErroredBuilds = mean(averagePRCanceled+averagePRPassed+averagePRFailed, na=TRUE)
#Average - Errored Pulls (passed, errored and canceled pulls)
averagePRErroredBuilds = mean(averagePRErrored, na=TRUE)

#Agregated
#Agregated - Not Errored Pulls (passed and canceled builds)
agregatedPRNotErroredBuilds = (agregatedPRCanceled+agregatedPRPassed+agregatedPRFailed)*100/totalPR
#Average - Errored Pulls (errored builds)
agregatedPRErroredBuilds = (agregatedPRErrored)*100/totalPR

#Txt File with the informations about the RQ2
sink("rq2.txt")
cat("How frequently do Errored Builds happen?")
cat("\n")
cat("Pushes")
cat("\n")
print("Agregated Value - Errored Builds")
print(agregatedPushErroredBuilds)
print("Average Value - Broken Builds")
print(averagePushErroredBuilds)
cat("\n")
cat("Pull Requests")
cat("\n")
print("Agregated Value - Pull Requests")
print(agregatedPRErroredBuilds)
print("Average Value - Pull Requests")
print(averagePRErroredBuilds)
sink()

png(paste("beanplot-errored-build.png", sep=""), width=300, height=350)
beanplot(averagePushesErrored, col="gray")
dev.off()

png(paste("beanplot-errored-pull-request.png", sep=""), width=300, height=350)
beanplot(averagePRErrored, col="gray")
dev.off()

png(paste("errored-build.png", sep=""), width=425, height=350)
mydataErrored <- data.frame(row.names =c("Agregated", "Average"), NotErroredBuilds =c(agregatedPushNotErroredBuilds, averagePushNotErroredBuilds), ErroredBuilds =c(agregatedPushErroredBuilds, averagePushErroredBuilds))
x <- barplot(t(as.matrix(mydataErrored)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydataErrored$NotErroredBuilds-8, labels=round(mydataErrored$NotErroredBuilds), col="black")
text(x, mydataErrored$NotErroredBuilds+5, labels=round(mydataErrored$ErroredBuilds))
dev.off()

png(paste("errored-pull-request.png", sep=""), width=425, height=350)
mydataErroredPR <- data.frame(row.names =c("Agregated", "Average"), NotErroredPR =c(agregatedPRNotErroredBuilds, averagePRNotErroredBuilds), ErroredPR =c(agregatedPRErroredBuilds, averagePRErroredBuilds))
x <- barplot(t(as.matrix(mydataErroredPR)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydataErroredPR$NotErroredPR-10, labels=round(mydataErroredPR$NotErroredPR), col="black")
text(x, mydataErroredPR$NotErroredPR+10, labels=round(mydataErroredPR$ErroredPR))
dev.off()

setwd(file.path(mainDir))

#Slide - How frequently do Errored Builds happen?
rq3 = "RQ3"
dir.create(file.path(mainDir, rq3), showWarnings = FALSE)
setwd(file.path(mainDir, rq3))

#Pushes
#Average
#Average - Not Failed Broken Builds (passed, errored and canceled builds)
averagePushNotFailedBuilds = mean(averagePushesCanceled+averagePushesPassed+averagePushesErrored, na=TRUE)
#Average - Failed Broken Builds (Failed builds)
averagePushFailedBuilds = mean(averagePushesFailed, na=TRUE)

#Agregated
#Agregated - Not Failed Broken Builds (passed, errored and canceled builds)
agregatedPushNotFailedBuilds = (agregatedPushesCanceled+agregatedPushesPassed+agregatedPushesErrored)*100/totalPushes
#Agregated - Failed Broken Builds (Failed builds)
agregatedPushFailedBuilds = (agregatedPushesFailed)*100/totalPushes

#Pull Requests
#Average
#Average - Not Failed Pulls (passed, errored and canceled pulls)
averagePRNotFailedBuilds = mean(averagePRCanceled+averagePRPassed+averagePRErrored, na=TRUE)
#Average - Failed Pulls (Failed pulls)
averagePRFailedBuilds = mean(averagePRFailed, na=TRUE)

#Agregated
#Agregated - Not Failed Pulls (passed, errored and canceled builds)
agregatedPRNotFailedBuilds = (agregatedPRCanceled+agregatedPRPassed+agregatedPRErrored)*100/totalPR
#Average - Failed Pulls (failed builds)
agregatedPRFailedBuilds = (agregatedPRFailed)*100/totalPR

#Txt File with the informations about the RQ3
sink("rq3.txt")
cat("How frequently do Failed Builds happen?")
cat("\n")
cat("Pushes")
cat("\n")
print("Agregated Value - Errored Builds")
print(agregatedPushFailedBuilds)
print("Average Value - Broken Builds")
print(averagePushFailedBuilds)
cat("\n")
cat("Pull Requests")
cat("\n")
print("Agregated Value - Pull Requests")
print(agregatedPRFailedBuilds)
print("Average Value - Pull Requests")
print(averagePRFailedBuilds)
sink()

png(paste("beanplot-failed-build.png", sep=""), width=300, height=350)
beanplot(averagePushesFailed, col="gray")
dev.off()

png(paste("beanplot-failed-pull-request.png", sep=""), width=300, height=350)
beanplot(averagePRFailed, col="gray")
dev.off()

png(paste("failed-build.png", sep=""), width=425, height=350)
mydataFailed <- data.frame(row.names =c("Agregated", "Average"), NotFailedBuilds =c(agregatedPushNotFailedBuilds, averagePushNotFailedBuilds), FailedBuilds =c(agregatedPushFailedBuilds, averagePushFailedBuilds))
x <- barplot(t(as.matrix(mydataFailed)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydataFailed$NotFailedBuilds-8, labels=round(mydataFailed$NotFailedBuilds), col="black")
text(x, mydataFailed$NotFailedBuilds+5, labels=round(mydataFailed$FailedBuilds))
dev.off()

png(paste("failed-pull-request.png", sep=""), width=425, height=350)
mydataFailedPR <- data.frame(row.names =c("Agregated", "Average"), NotFailedPR =c(agregatedPRNotFailedBuilds, averagePRNotFailedBuilds), FailedPR =c(agregatedPRFailedBuilds, averagePRFailedBuilds))
x <- barplot(t(as.matrix(mydataFailedPR)), col=c("darkgreen", "gray"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydataFailedPR$NotFailedPR-10, labels=round(mydataFailedPR$NotFailedPR), col="black")
text(x, mydataFailedPR$NotFailedPR+10, labels=round(mydataFailedPR$FailedPR))
dev.off()

setwd(file.path(mainDir))

#Slide - How frequently are Merge Scenario from Master Built on Travis?
rq4 = "RQ4"
dir.create(file.path(mainDir, rq4), showWarnings = FALSE)
setwd(file.path(mainDir, rq4))

#Merge Scenarios
#Average
averageMergeScenarios = (totalMergeScenarios$TotalMSBuilt)*100/totalMergeScenarios$TotalMS
averageMergeScenrioPerc = mean(averageMergeScenarios, na=TRUE)
averageNotBuiltMS = (totalMergeScenarios$TotalMS - totalMergeScenarios$TotalMSBuilt)*100/totalMergeScenarios$TotalMS
averageNotMergeScenrioPerc = mean(averageNotBuiltMS, na=TRUE)

#Agregated
agregatedMergeScenarios = sum(totalMergeScenarios$TotalMSBuilt)*100/sum(totalMergeScenarios$TotalMS)
agregatedNotMergeScenarios = sum(totalMergeScenarios$TotalMS - totalMergeScenarios$TotalMSBuilt)*100/sum(totalMergeScenarios$TotalMS)

#Txt File with the informations about the RQ4
sink("rq4.txt")
cat("How frequently are Merge Scenarios from Master Built on Travis?")
cat("\n")
cat("Merge Scenarios")
cat("\n")
print("Agregated Value - Merge Scenarios")
print(agregatedMergeScenarios)
print("Average Value - Merge Scenarios")
print(averageMergeScenrioPerc)
cat("\n")
sink()

png(paste("beanplot-merge-scenario.png", sep=""), width=300, height=350)
beanplot(averageMergeScenarios, col="gray")
dev.off()

png(paste("merge-scenario.png", sep=""), width=425, height=350)
mydataMergeScenario <- data.frame(row.names =c("Agregated", "Average"), NotBuilt =c(agregatedNotMergeScenarios, averageNotMergeScenrioPerc), Built =c(agregatedMergeScenarios, averageMergeScenrioPerc))
x <- barplot(t(as.matrix(mydataMergeScenario)), col=c("gray", "cornflowerblue"), legend=TRUE, border=NA, xlim=c(0,4), args.legend=list(bty="n", border=NA), ylab="% Percentage")
text(x, mydataMergeScenario$NotBuilt-8, labels=round(mydataMergeScenario$NotBuilt), col="black")
text(x, mydataMergeScenario$NotBuilt+10, labels=round(mydataMergeScenario$Built))
dev.off()

setwd(file.path(mainDir))

#Slide - How frequently are Errored Builds resulting from Built Merge Scenarios?
#What files are modified in Built Merge Scenarios of Errored Builds?
rq5 = "RQ5"
dir.create(file.path(mainDir, rq5), showWarnings = FALSE)
setwd(file.path(mainDir, rq5))

#Average
averageMergeScenariosErrored = mergeScenarios$PushesErrored*100/(totalMergeScenarios$TotalMSBuilt)
averageMergeScenariosErroredPerc = mean(averageMergeScenariosErrored, na=TRUE)
#Agregated
agregatedMergeScenariosErrored = sum(mergeScenarios$PushesErrored)*100/sum(totalMergeScenarios$TotalMSBuilt)

#Changes Distributions on modified Files

erroredPushTravisAll = mergeScenarios$ErroredTravis*100/mergeScenarios$PushesErrored
erroredPushConfigAll = mergeScenarios$ErroredConfig*100/mergeScenarios$PushesErrored
erroredPushSourceAll = mergeScenarios$ErroredSource*100/mergeScenarios$PushesErrored
erroredPushAllTogether = mergeScenarios$ErroredAll*100/mergeScenarios$PushesErrored

averageErroredPushTravisAllPerc = mean(erroredPushTravisAll, na=TRUE)
averageErroredPushConfigAllPerc = mean(erroredPushConfigAll, na=TRUE)
averageErroredPushSourceAllPerc = mean(erroredPushSourceAll, na=TRUE)
averageErroredPushAllTogetherPerc = mean(erroredPushAllTogether, na=TRUE)

#Txt File with the informations about the RQ5
sink("rq5.txt")
cat("How frequently are Errored Builds resulting from Built Merge Scenarios?")
cat("\n")
cat("Errored Builds from Merge Scenarios")
cat("\n")
print("Agregated Value - Errored Builds")
print(agregatedMergeScenariosErrored)
print("Average Value - Errored Builds")
print(averageMergeScenariosErroredPerc)
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

setwd(file.path(mainDir))

#Slide - How frequently are Failed Builds resulting from Built Merge Scenarios?
#What files are modified in Built Merge Scenarios of Failed Builds?
rq6 = "RQ6"
dir.create(file.path(mainDir, rq6), showWarnings = FALSE)
setwd(file.path(mainDir, rq6))

#Average
averageMergeScenariosFailed = mergeScenarios$PushesFailed*100/(totalMergeScenarios$TotalMSBuilt)
averageMergeScenariosFailedPerc = mean(averageMergeScenariosFailed, na=TRUE)
#Agregated
agregatedMergeScenariosFailed = sum(mergeScenarios$PushesFailed)*100/sum(totalMergeScenarios$TotalMSBuilt)

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
print("Agregated Value - Failed Builds")
print(agregatedMergeScenariosFailed)
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
dir.create(file.path(mainDir, rq7), showWarnings = FALSE)
setwd(file.path(mainDir, rq7))

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

#Agregated
agregatedErroredConf = (sum(mergeScenarios$ErroredTravisConf, na.rm=TRUE) + sum(mergeScenarios$ErroredConfigConf, na.rm=TRUE) + sum(mergeScenarios$ErroredSourceConf, na.rm=TRUE) + sum(mergeScenarios$ErroredAllConf, na.rm=TRUE))*100/sum(mergeScenarios$PushesErrored, na.rm=TRUE)

#Build Conflicts - All Merge Scenarios
#Average
averageErroredPushTravisConfAll = mergeScenarios$ErroredTravisConf*100/(totalMergeScenarios$TotalMSBuilt)
averageErroredPushConfigConfAll = mergeScenarios$ErroredConfigConf*100/(totalMergeScenarios$TotalMSBuilt)
averageErroredPushSourceConfAll = mergeScenarios$ErroredSourceConf*100/(totalMergeScenarios$TotalMSBuilt)
averageErroredPushAllTogetherConfAll = mergeScenarios$ErroredAllConf*100/(totalMergeScenarios$TotalMSBuilt)

averageErroredPushTravisConfAllPerc = mean(averageErroredPushTravisConfAll, na=TRUE)
averageErroredPushConfigConfAllPerc = mean(averageErroredPushConfigConfAll, na=TRUE)
averageErroredPushSourceConfAllPerc = mean(averageErroredPushSourceConfAll, na=TRUE)
averageErroredPushAllTogetherConfAllPerc = mean(averageErroredPushAllTogetherConfAll, na=TRUE)
averageErroredBuildConflictAll = averageErroredPushTravisConfAllPerc + averageErroredPushConfigConfAllPerc + averageErroredPushSourceConfAllPerc + averageErroredPushAllTogetherConfAllPerc

#Agregated
agregatedErroredConfAll = (sum(mergeScenarios$ErroredTravisConf, na.rm=TRUE) + sum(mergeScenarios$ErroredConfigConf, na.rm=TRUE) + sum(mergeScenarios$ErroredSourceConf, na.rm=TRUE) + sum(mergeScenarios$ErroredAllConf, na.rm=TRUE))*100/sum(totalMergeScenarios$TotalMSBuilt, na.rm=TRUE)

#Txt File with the informations about the RQ7
sink("rq7.txt")
cat("How frequently do Build Conflicts happen on built Merge Scenarios of Errored Builds?")
cat("\n")
cat("Build Conflicts only from Errored Scenarios")
cat("\n")
print("Agregated Value - Errored Builds")
print(agregatedErroredConf)
print("Average Value - Errored Builds")
print(averageErroredBuildConflict)
cat("\n")
cat("\n")
cat("Build Conflicts from Merge Scenarios")
cat("\n")
print("Agregated Value - Errored Builds")
print(agregatedErroredConfAll)
print("Average Value - Errored Builds")
print(averageErroredBuildConflictAll)
cat("\n")
sink()

setwd(file.path(mainDir))

#Slide - How frequently do Test Conflicts happen on Built Merge Scenarios of Failed Builds?
#What files are modified on Test Conflicts Scenarios?
rq8 = "RQ8"
dir.create(file.path(mainDir, rq8), showWarnings = FALSE)
setwd(file.path(mainDir, rq8))

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

#Agregated
agregatedFailedConf = (sum(mergeScenarios$FailedTravisConf, na.rm=TRUE) + sum(mergeScenarios$FailedConfigConf, na.rm=TRUE) + sum(mergeScenarios$FailedSourceConf, na.rm=TRUE) + sum(mergeScenarios$FailedAllConf, na.rm=TRUE))*100/sum(mergeScenarios$PushesFailed, na.rm=TRUE)

#Build Conflicts - All Merge Scenarios
#Average
averageFailedPushTravisConfAll = mergeScenarios$FailedTravisConf*100/(totalMergeScenarios$TotalMSBuilt)
averageFailedPushConfigConfAll = mergeScenarios$FailedConfigConf*100/(totalMergeScenarios$TotalMSBuilt)
averageFailedPushSourceConfAll = mergeScenarios$FailedSourceConf*100/(totalMergeScenarios$TotalMSBuilt)
averageFailedPushAllTogetherConfAll = mergeScenarios$FailedAllConf*100/(totalMergeScenarios$TotalMSBuilt)

averageFailedPushTravisConfAllPerc = mean(averageFailedPushTravisConfAll, na=TRUE)
averageFailedPushConfigConfAllPerc = mean(averageFailedPushConfigConfAll, na=TRUE)
averageFailedPushSourceConfAllPerc = mean(averageFailedPushSourceConfAll, na=TRUE)
averageFailedPushAllTogetherConfAllPerc = mean(averageFailedPushAllTogetherConfAll, na=TRUE)
averageFailedBuildConflictAll = averageFailedPushTravisConfAllPerc + averageFailedPushConfigConfAllPerc + averageFailedPushSourceConfAllPerc + averageFailedPushAllTogetherConfAllPerc

#Agregated
agregatedFailedConfAll = (sum(mergeScenarios$FailedTravisConf, na.rm=TRUE) + sum(mergeScenarios$FailedConfigConf, na.rm=TRUE) + sum(mergeScenarios$FailedSourceConf, na.rm=TRUE) + sum(mergeScenarios$FailedAllConf, na.rm=TRUE))*100/sum(totalMergeScenarios$TotalMSBuilt, na.rm=TRUE)

#Txt File with the informations about the RQ8
sink("rq8.txt")
cat("How frequently do Test Conflicts happen on built Merge Scenarios of Errored Builds?")
cat("\n")
cat("Build Conflicts only from Failed Scenarios")
cat("\n")
print("Agregated Value - Failed Builds")
print(agregatedFailedConf)
print("Average Value - Failed Builds")
print(averageFailedBuildConflict)
cat("\n")
cat("\n")
cat("Build Conflicts from Merge Scenarios")
cat("\n")
print("Agregated Value - Failed Builds")
print(agregatedFailedConfAll)
print("Average Value - Failed Builds")
print(averageFailedBuildConflictAll)
cat("\n")
sink()

setwd(file.path(mainDir))

#Slide - What are the Causes of Errored Builds in Build Conflicts Scenarios?
rq9 = "RQ9"
dir.create(file.path(mainDir, rq9), showWarnings = FALSE)
setwd(file.path(mainDir, rq9))

totalCausesErrored = sum(causesErroredBuilds$Total, na.rm=TRUE)
noFoundSymbolErrored = sum(causesErroredBuilds$NO.FOUND.SYMBOL, na.rm=TRUE)*100/totalCausesErrored
gitProblemErrored = sum(causesErroredBuilds$GIT.PROBLEM, na.rm=TRUE)*100/totalCausesErrored
remoteErrorErrored = sum(causesErroredBuilds$REMOTE.ERROR, na.rm=TRUE)*100/totalCausesErrored
compilerErrorErrored = sum(causesErroredBuilds$COMPILER.ERROR, na.rm=TRUE)*100/totalCausesErrored
permissionErrored = sum(causesErroredBuilds$PERMISSION, na.rm=TRUE)*100/totalCausesErrored
anotherErrorErrored = sum(causesErroredBuilds$ANOTHER.ERROR, na.rm=TRUE)*100/totalCausesErrored

#Txt File with the informations about the RQ10
sink("rq9.txt")
cat("What are the Causes of Failed Builds in Test Conflicts Scenarios?")
cat("\n")
cat("Test Conflicts from Failed Scenarios")
cat("\n")
print("No Found Symbol")
print(noFoundSymbolErrored)
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
dir.create(file.path(mainDir, rq10), showWarnings = FALSE)
setwd(file.path(mainDir, rq10))

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
