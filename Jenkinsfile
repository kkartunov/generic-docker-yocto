pipeline {
    agent { 
        label 'AVAM'
        dockerfile true
    }
    stages {
        stage('Test') {
            steps {
                docker build --build-arg BITBAKE_TARGET=core-image-minimal -t yocto/core-image-minimal .
            }
        }
    }
}