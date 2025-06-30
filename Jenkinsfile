pipeline {
    agent any

    tools {
        jdk 'JDK'         // Pre-configured in Jenkins
        maven 'Maven'     // Pre-configured in Jenkins
    }

    environment {
        DOCKER_IMAGE = 'vishalgandhe/devops_integration'
        DOCKER_CRED_ID = 'dockerhubpwd'  // DockerHub password/token stored in Jenkins credentials
        GIT_REPO = 'https://github.com/VishalGandhe/devops_automation'
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
                    def imageTag = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    def imageTag = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    withCredentials([string(credentialsId: "${DOCKER_CRED_ID}", variable: 'dockerhubpwd')]) {
                        sh "echo ${dockerhubpwd} | docker login -u vishalgandhe --password-stdin"
                        sh "docker push ${imageTag}"
                        sh 'docker logout'
                    }
                }
            }
        }

        stage('Deploy Docker Image on Local Machine') {
            steps {
                script {
                    def imageTag = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"

                    // Stop and remove existing container if running
                    sh "docker rm -f springboot-api || true"

                    // Pull latest image
                    sh "docker pull ${imageTag}"

                    // Run new container
                    sh "docker run -d -p 8080:8080 --name springboot-api ${imageTag}"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    // Wait for the container to start
                    sleep 5
                    sh '''
                        echo "Checking API health..."
                        curl --fail --silent http://localhost:8080/api/hello || exit 1
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and deployment successful!'
        }
        failure {
            echo '❌ Build or deployment failed. Check the logs.'
        }
    }
}
