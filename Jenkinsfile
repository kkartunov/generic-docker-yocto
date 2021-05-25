pipeline {
    agent { 
        dockerfile true
        node {
            label 'Threadripper'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh 'python -V'
            }
        }
    }
}