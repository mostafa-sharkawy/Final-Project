pipeline {
    agent {
        docker {
            image 'docker/compose:1.29.2' // Or a more recent version
            args '-v /var/run/docker.sock:/var/run/docker.sock' // If Jenkins is in a Docker container
        }
    }
    stages {
        stage('Docker Compose Up') {
            steps {
                sh '''
                cat <<EOF > docker-compose.yml
version: '3.8'

services:
  db:
    image: mysql:5.7
    container_name: mysql_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    restart: always
    depends_on:
      - db
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
      WORDPRESS_DB_NAME: wordpress
    ports:
      - "8085:8080"
    volumes:
      - wp_data:/var/www/html

volumes:
  db_data:
  wp_data:
EOF
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
                            sh 'curl http://localhost:8085'
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
            sh 'curl http://localhost:8085'
          }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
