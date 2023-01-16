pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sshagent(['kube-instance']) {
                  ssh 15.223.49.63      
                  sh "kubectl get all"
                }
               
            }
    
        }
    }
}

