pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sshagent(['kube-instance']) {
                        sh "kubectl get all"
                }
               
            }
    
        }
    }
}

