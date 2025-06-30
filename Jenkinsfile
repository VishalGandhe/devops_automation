pipeline {
    agent any

    tools {
        jdk 'JDK'
        maven 'Maven'
    }

    environment {
        DOCKER_IMAGE = 'vishalgandhe/devops_integration'
        DOCKER_CRED_ID = 'dockerhubpwd'
        GIT_REPO = 'https://github.com/VishalGandhe/devops_automation'
        CONTAINER_NAME = 'springboot-api'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    sh "docker build -t ${IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: "${DOCKER_CRED_ID}", variable: 'dockerhubpwd')]) {
                        sh "echo ${dockerhubpwd} | docker login -u vishalgandhe --password-stdin"
                        sh "docker push ${IMAGE_TAG}"
                        sh "docker logout"
                    }
                }
            }
        }

        stage('Deploy Docker Image on Local Machine') {
            steps {
                script {
                    // Stop and remove old container if exists
                    sh "docker rm -f ${CONTAINER_NAME} || true"

                    // Check if port 8080 is in use, fallback to 8081
                    def portCheck = sh(script: "lsof -i :8080 || netstat -an | grep 8080", returnStatus: true)
                    env.HOST_PORT = (portCheck == 0) ? "8081" : "8080"
                    echo "Using port ${env.HOST_PORT} for deployment"

                    // Pull latest image
                    sh "docker pull ${IMAGE_TAG}"

                    // Run the new container
                    sh "docker run -d -p ${env.HOST_PORT}:8080 --name ${CONTAINER_NAME} ${IMAGE_TAG}"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sleep 5 // Wait for app to start
                    echo "Checking API at http://localhost:${env.HOST_PORT}/api/hello"
                    sh """
                        curl --fail --silent http://localhost:${env.HOST_PORT}/api/hello || exit 1
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build and deployment successful at http://localhost:${env.HOST_PORT}/api/hello"
        }
        failure {
            echo '❌ Build or deployment failed. Please check logs.'
        }
    }
}
