# TravisAnalysis

In this project, we investigate the occurrence and categories of build conflicts on Java projects hosted on GitHub and Travis CI.



## Running the study

To run the analysis, we recommend the adoption of the next steps.: 

<ol type="I">
  <li>
    Once the project is cloned, you must install the dependencies specified on the Gemfile required for this project by running the command <i>bundle install</i>.
  </li>
  <li>
    Next, you must fulfill the with your information the <a href="https://github.com/leusonmario/TravisAnalysis/blob/master/build_conflicts_analysis/properties" target="_blank"><i>properties</i></a> file.
    <ul>  
     <li>
        First, you must inform your <i>login</i> and <i>password</i> of GitHub account; this information is necessary to create the forks that will be created by the scripts.
      </li>
            <li>
        During the analysis, some build process on Travis will require to deploy data in the associated GitHub tag. For that, it is necessary to create and inform an OAuth GitHub token. <a href="https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token" target="_blank" >Here</a> you can find how to create a new OAuth GitHub token.
      </li>
      <li>
        The next property is <i>PathGumTree</i>, that is the location where you saved <a href="https://github.com/leusonmario/gumtree" target="_blank" > Gumtree </a>. We use an improved version of this tool, which can be found <a href="https://drive.google.com/file/d/1FUeWWiolUbPysvLjh9KyAT6COJ2-qyy5/view?usp=sharing" target="_blank" >here</a>. Download and unzip it the file. Go to the directory <i>bin</i> and inform the current local path.
      </li>
    </ul>
  <li>
  Next, you must inform the list of projects to be analyzed using the file <a href="https://github.com/leusonmario/TravisAnalysis/blob/master/build_conflicts_analysis/projectsList" target="_blank"><i>projectsList</i></a>. These projects will be downloaded and temporarily saved. Each new line in this file is associated with a project formed by:
    <ul>
    <li>
      The project owner, for example, "leusonmario", and
    </li>
    <li>
      The name of the project, for instance, "javaToy"
    </li>
    </ul>
    Each project name needs must be informed between <i>quotes</i>. For example, "leusonmario/javaToy"
  </li>
  <li>
    Finally, to start the analysis, locate the <a href="https://github.com/leusonmario/TravisAnalysis/blob/master/build_conflicts_analysis/MainAnalysisProjects.rb" target="_blank"><i>MainAnalysisProjects</i></a> and run it by running the command: "ruby MainAnalysisProjects.rb". After the execution, the folder <i>FinalResults</i> will be created, grouping the generated CSV files with the results.
  </li>
</ol>
