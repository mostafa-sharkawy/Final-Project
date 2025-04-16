pipeline {
    agent any
    environment {
        SLACK_CHANNEL = '#final-project' // Your specified Slack channel
    }
    stages {

        stage('Setup test environment') {
            steps {
                sh '''
                # 1. Force remove specific containers if they exist
                docker rm -f mysql_db wordpress_app wp_cli 2>/dev/null || true

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
                            sh 'docker exec wordpress_app curl -s localhost'
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
        stage('Install WordPress if not installed') {
            steps {
                script {
                    def publicIP = sh(
                        script: '''
                            TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \\
                                -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
                            curl -sH "X-aws-ec2-metadata-token: $TOKEN" \\
                                http://169.254.169.254/latest/meta-data/public-ipv4
                        ''',
                        returnStdout: true
                    ).trim()

echo "📡 Retrieved Public IP: [${publicIP}]"



                    def wpUrl = "http://${publicIP}:3000"
                    sleep time: 10, unit: 'SECONDS'

                    sh """
                    docker compose exec -T wp-cli bash -c '
                    cd /var/www/html

                    if ! wp core is-installed; then
                        wp core install \\
                            --url="${wpUrl}" \\
                            --title="Test Site" \\
                            --admin_user="admin" \\
                            --admin_password="admin123" \\
                            --admin_email="admin@example.com"
                    else
                        echo "WordPress is already installed."
                        wp option update home "${wpUrl}"
                        wp option update siteurl "${wpUrl}"
                    fi
                    '
                    """
                }
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    sh '''
                    docker run --rm \
                    -e SONAR_TOKEN=$SONAR_TOKEN \
                    -v "$(pwd)":/usr/src \
                    sonarsource/sonar-scanner-cli \
                    sonar-scanner \
                    -Dsonar.projectKey=devopsprojectteam_computer-stopre \
                    -Dsonar.organization=devopsprojectteam \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=https://sonarcloud.io \
                    -Dsonar.login=$SONAR_TOKEN
                    '''

                }
            }
        }


        stage('Run WP-CLI Tests') {
            steps {
                sh '''
                docker-compose exec -T wp-cli bash -c '
                wp --require=/var/www/html/wp-cli-test-command.php test
                '
                '''
            }
        }

        stage('Tear Down Test Environment') {
            steps {
                sh 'docker-compose down'
            }
        }
        stage('Deploy to Production') {
            steps {
                script {
                    def publicIP = sh(
                        script: '''
                            TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \\
                                -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
                            curl -sH "X-aws-ec2-metadata-token: $TOKEN" \\
                                http://169.254.169.254/latest/meta-data/public-ipv4
                        ''',
                        returnStdout: true
                    ).trim()


                    sh 'docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d'

                    echo "✅ Deployment to production completed."
                    echo "🌐 Site URL: http://${publicIP}:3000"
                }
            }
        }
    }
    post {

        always {

            script {

                sh 'docker compose logs > final_logs.txt 2>/dev/null || true'

                archiveArtifacts artifacts: 'final_logs.txt'

                cleanWs()

            }

        }

        success {

            script {

                slackSend(

                    channel: "${SLACK_CHANNEL}",

                    color: 'good',

                    message: "🚀 WordPress Deployment Successful"

                )

            }

        }

        failure {

            script {

                slackSend(

                    channel: "${SLACK_CHANNEL}",

                    color: 'danger',

                    message: "❌ WordPress Deployment Failed"

                )

            }

        }

    }
}
