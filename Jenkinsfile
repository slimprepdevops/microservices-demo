pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sshagent(['kube-instance']) {
                  ssh ubuntu@ec2-15-223-49-63.ca-central-1.compute.amazonaws.com      
                  sh "kubectl get all"
                }
               
            }
    
        }
    }
}

