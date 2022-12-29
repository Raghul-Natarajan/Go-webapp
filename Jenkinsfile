pipeline{
   agent none
   stages{
      stage("Build web app"){
          agent { label 'slave1' }
          step{
          sh 'ansible-playbook docker.yml'
          }
       }
    }
}
