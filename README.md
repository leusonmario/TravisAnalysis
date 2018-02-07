# TravisAnalysis

This is an ongoing project to analyze Java projects that use Travis CI aiming to identify and categorize build and test conflicts. 


# Running the Analysis

Follow the next instruction to perform a new analysis: 

<ol type="I">
  <li>
    Once the project is cloned, execute <i>bundle install</i> to install the dependencies specified on the Gemfile. 
  </li>
  <li>
  Set up your information on the <i>properties</i> file.
  <p>
  First, you need to inform your login and password from GitHub to allow the extraction of GitHub and Travis CI information. Then, inform the local path for GumTree tool.
   
We use an improved version of <a href="https://github.com/leusonmario/gumtree" target="_blank" > Gumtree </a>. The improved tool can be found <a href="https://drive.google.com/file/d/1FUeWWiolUbPysvLjh9KyAT6COJ2-qyy5/view?usp=sharing" target="_blank" >here</a>. Downloand it and unzip the file. Go to the diretory <i>bin</i> and inform the whole local path for the propertity <i>PathGumTree</i>.

During the analysis, some builds will require to deploy coverage information in GitHub. Consequently, it is necessary to give permission using OAuth GitHub token. <a href="https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/" target="_blank" >Here</a> you can find how to create a new OAuth GitHub token.

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
    <td>token</td>
    <td>123456789ktl</td> 
  </tr>
  <tr>
    <td>PathGumTree</td>
    <td>/home/jpds/GumTree/gumtree-20160921-2.1.0-SNAPSHOT/bin/</td> 
  </tr>
</table>
  </li>
  <li>
  The file <i>projectsList</i> groups the list of projects to be analyzed. These projects will be downloaded and saved temporarily. Each line represents a project formed by:
    <ul>
    <li>
      The project owner, for example "jpds", and
    </li>
    <li>
      The name of the project, for instance "javaToy"
    </li>
    </ul>
    Each project name needs to start and finish with ". For example, "leusonmario/javaToy"
  </li>
  <li>
    On the <i>lib</i> directory, run "./MainAnalysisProjects.rb"
  </li>
  <li>
    After the execution, a new folder, FinalResults, containing the .csv files will be created.
  </li>
</ol>
