pipeline {
    agent {
        docker {
            image 'docker/compose:1.29.2' // Or a more recent version
            args '-u root' // Optional: Run as root (use with caution)
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
      - "8080:80"
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
        stage('Docker Compose Down') {
            steps {
                sh 'docker-compose down'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
