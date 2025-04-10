pipeline {
    agent any
    stages {
        stage('Docker Compose Up') {
            steps {
                sh '''
                docker rm -f mysql_db wordpress_app || true
                docker-compose up -d
                '''
            }
        }
        stage('Wait for WordPress') {
            steps {
                script {
                    def maxAttempts = 20
                    def attempt = 1
                    while (attempt <= maxAttempts) {
                        try {
                            sh 'curl http://localhost:8080'
                            echo "WordPress is ready!"
                            break
                        } catch (Exception e) {
                            echo "Attempt ${attempt}: WordPress not ready yet, waiting..."
                            sleep time: 10, unit: 'SECONDS'
                            attempt++
                        }
                    }
                    if (attempt > maxAttempts) {
                        error "WordPress did not become ready after ${maxAttempts} attempts."
                    }
                }
            }
        }
        stage('Verify WordPress Page') {
          steps {
            sh 'curl http://localhost:8080'
          }
        }
        stage('Run WP-CLI Tests') {
            steps {
                sh 'docker-compose exec -T wp-cli wp test'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}

