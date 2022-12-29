pipeline{
   agent none
   stages{
      stage("Build web app"){
          agent { label 'slave1' }
          steps{
          sh 'ansible-playbook docker.yml'
          }
       }
    }
}
