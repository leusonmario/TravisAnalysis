# TravisAnalysis

Initial Analysis of Travis Projects

TravisAnalysis is a project in Ruby that analyses some characteristics of Travis projects. For that end, it uses some external resources: 
 - Octokit, for accessing information from GitHub Projects,
 - Travis, for getting information related to projects hosted on Github,
 - GumTree, for a syntatic diff (https://github.com/GumTreeDiff/gumtree/wiki/Getting-Started), and
 - R, for statistic analysis.

# Versions
<table style="width:100%">
  <tr>
    <th>API</th>
    <th>Version</th> 
    <th>Available on</th>
  </tr>
  <tr>
    <td>Ruby</td>
    <td>2.1.9</td> 
    <td></td>
  </tr>
  <tr>
    <td>Octokit</td>
    <td>4.3.0</td> 
    <td>https://github.com/octokit/octokit.rb/</td>
  </tr>
  <tr>
    <td>Travis</td>
    <td>1.8.3</td> 
    <td>https://github.com/travis-ci/travis.rb/</td>
  </tr>
  <tr>
    <td>GumTree</td>
    <td>gumtree-20160921-2.1.0-SNAPSHOT.zip</td> 
    <td>https://bintray.com/jrfaller/GumTree/nightlies/99.99.99#files</td>
  </tr>
</table>

For using GumTree, we recommend to download the zip file, see the table above, unzip and inform the directory where it was saved.

# Running the Analysis

All results generated by the analysis are saved as .csv files. Additionally, a initial statistical analysis is done by a R script.

To run this project, you need to follow the instructions: 

<ol type="I">
  <li>
    Once the project is cloned, execute <i>bundle install</i> to install the dependencies specified on the Gemfile. 
  </li>
  <li>
  Set up your information on the <i>properties</i> file.
  <p>
  First, you need to inform your login and password from GitHub to allow the extraction of information by the library Octokit. Following, inform the directory that GumTree project was saved.

For example:

<table style="width:100%">
  <tr>
    <th>Property</th>
    <th>Example</th> 
  </tr>
  <tr>
    <td>Login</td>
    <td>jpds</td> 
  </tr>
  <tr>
    <td>Password</td>
    <td>123456</td> 
  </tr>
  <tr>
    <td>PathGumTree</td>
    <td>/home/jpds/GumTree/gumtree-20160921-2.1.0-SNAPSHOT/bin/</td> 
  </tr>
</table>
  </li>
  <li>
  On the <i>projectsList</i> file, inform the projects that you want to analysis. These projects will be downloaded and saved temporally for the analysis execution. Each line of the file represents a project that is formed by:
    <ul>
    <li>
      The owner of the project, for example "jpds", and
    </li>
    <li>
      The name of the project, for instance "javaToy"
    </li>
    </ul>
    Each project name needs to start and finish with ". For example, "leusonmario/javaToy"
  </li>
  <li>
    On the <i>lib</i> directory, run "./MainAnalysisProjects"
  </li>
  <li>
    After the execution, a new folder, ResultsAll, containing the .csv files will be created. The output of R script will be available on the R directory.
  </li>
</ol>

It is important that the ruby version used locally be compatible with the versions used by the external libraries.
