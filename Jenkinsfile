pipeline {
    agent {
        docker {
            image 'alpine:latest' // The Docker image to use
            args '-u root' // Optional: Run as root (use with caution)
        }
    }
    stages {
        stage('Run Container Command') {
            steps {
                sh 'echo "Hello from Alpine!"'
                sh 'apk update && apk add curl' //Update apk and install curl
                sh 'curl https://www.google.com' //Use curl to call google
            }
        }
    }
}
