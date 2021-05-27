pipeline {
    agent { 
        label 'AVAM'
    }
    stages {
        stage('Test') {
            steps {
                sh 'docker build --build-arg BITBAKE_TARGET=core-image-minimal -t yocto/core-image-minimal .'
            }
        }
    }
}