# TravisAnalysis

Initial Analysis of Travis Projects

TravisAnalysis is a project in Ruby that analyses some characteristics of Travis projects. For that end, it uses two external libraries: 
 - Octokit for accessing information from GitHub Projects
 - Travis, for build information related to projects hosted on Github, and
 - R, for statistic analysis.

The project saves the output in a set of .csv files, and additionally, a initial statistical analysis is done by a R script.

To run this project, you need to follow the next instructions: 

1 - Once the project is cloned, set up your information on the file "properties". First you need to inform the path of directory that contains the projets to be analysed. Following, inform your login information of GitHub to allow the extraction of information by the library Octokit.

2 - Run "./MainAnalysisProjects"

3 - After the execution, a new folder containing the .csv files will be created. The output of R script will be available on the directory R.


It is important that the ruby version used locally be compatible with the versions used by the external libraries.

Teste Bruno_Santos