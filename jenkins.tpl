<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>when github changes, build {stack} automatically</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <com.coravy.hudson.plugins.github.GithubProjectProperty plugin="github@1.9.1">
      <projectUrl>https://github.com/nicescale/{stack}/</projectUrl>
    </com.coravy.hudson.plugins.github.GithubProjectProperty>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.2.2">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/nicescale/{stack}.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/{branch}</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers>
    <com.cloudbees.jenkins.GitHubPushTrigger plugin="github@1.9.1">
      <spec></spec>
    </com.cloudbees.jenkins.GitHubPushTrigger>
    <hudson.triggers.SCMTrigger>
      <spec>H/10 * * * *</spec>
      <ignorePostCommitHooks>false</ignorePostCommitHooks>
    </hudson.triggers.SCMTrigger>
  </triggers>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>TVAR=`echo $JOB_NAME|cut -f2- -d&apos;-&apos;`
stack=`echo $TVAR|rev|cut -d&apos;-&apos; -f2- |rev`
branch=`echo $TVAR|rev|cut -d&apos;-&apos; -f1|rev`
$JENKINS_HOME/jobs/docker-test/workspace/docker_build.sh $stack $branch
$JENKINS_HOME/jobs/docker-test/workspace/docker_test.sh $stack $branch
$JENKINS_HOME/jobs/docker-test/workspace/docker_push.sh $stack $branch
</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <hudson.tasks.Mailer plugin="mailer@1.6">
      <recipients>hanwoody@gmail.com</recipients>
      <dontNotifyEveryUnstableBuild>false</dontNotifyEveryUnstableBuild>
      <sendToIndividuals>false</sendToIndividuals>
    </hudson.tasks.Mailer>
  </publishers>
  <buildWrappers/>
</project>
