pipeline {
    agent { 
        dockerfile true
        label 'Threadripper'
    }
    stages {
        stage('Test') {
            steps {
                sh 'python -V'
            }
        }
    }
}