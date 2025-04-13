pipeline {
    agent any
    stages {
        stage('Docker Compose Up') {
            steps {
                sh '''
                # 1. Force remove specific containers if they exist
                docker rm -f mysql_db wordpress_app wp_cli 2>/dev/null || true
                
                # 2. Full compose down with cleanup
                docker-compose down --volumes --remove-orphans --timeout 1 2>/dev/null || true
                
                # 3. stage('Run WP-CLI Tests') {
    steps {
        sh '''
        docker-compose exec -T -e WORDPRESS_DB_HOST -e WORDPRESS_DB_USER -e WORDPRESS_DB_PASSWORD -e WORDPRESS_DB_NAME wp-cli bash -c '
          if ! wp core is-installed; then
            wp core install --url=http://localhost:8080 --title="Test Site" --admin_user=admin --admin_password=password --admin_email=admin@example.com --skip-email
            wp option update siteurl "http://localhost:8080"
            wp option update home "http://localhost:8080"
            wp config set WP_DEBUG true --raw
            wp config set WP_DEBUG_LOG true --raw
            wp rewrite structure "/%postname%/"
          fi
          wp plugin list
          wp theme list
          wp core version
        '
        '''
    }
}
Wait to ensure cleanup completes
                sleep 2

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
        stage('Wait for WP-CLI Initialization') {
            steps {
                sleep time: 30, unit: 'SECONDS' // Adjust the wait time as needed
                echo "WP-CLI should have initialized WordPress."
            }
        }
        stage('Run WP-CLI Tests') {
            steps {
                sh '''
                docker-compose exec -T wp-cli bash -c '
                # Make sure WordPress is installed
                if ! wp core is-installed; then
                    wp core install --url=http://localhost:8080 --title="Test Site" \
                    --admin_user=admin --admin_password=password \
                    --admin_email=admin@example.com --skip-email
                fi
                
                # Run our custom test command
                wp test
                '
                '''
            }
        }


    }
    post {
        always {
            cleanWs()
        }
    }
}


