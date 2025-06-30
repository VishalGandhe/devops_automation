pipeline {
    agent any

    tools {
        jdk 'JDK'         // Ensure 'JDK' is set in Jenkins -> Global Tool Configuration
        maven 'Maven'     // Ensure 'Maven' is set there too
    }

    environment {
        DOCKER_IMAGE = 'vishalgandhe/devops_integration'
        DOCKER_CRED_ID = 'dockerhubpwd'  // Jenkins credentials ID for DockerHub password/token
        GIT_REPO = 'https://github.com/VishalGandhe/devops_automation'
        EMAIL_RECIPIENTS = 'vishalgandhe1806@gmail.com'
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

        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = "${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    withCredentials([string(credentialsId: "${DOCKER_CRED_ID}", variable: 'dockerhubpwd')]) {
                        sh 'docker login -u vishalgandhe -p ${dockerhubpwd}'
                        sh "docker push ${imageTag}"
                        sh 'docker logout'
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and Docker push successful!'
        }

        failure {
            echo '❌ Build failed! Sending notification email...'

            emailext(
                to: "${EMAIL_RECIPIENTS}",
                subject: "❌ Jenkins Job '${env.JOB_NAME}' (#${env.BUILD_NUMBER}) Failed",
                body: """<p>Hi Team,</p>
                         <p>The Jenkins build <b>#${env.BUILD_NUMBER}</b> of job <b>${env.JOB_NAME}</b> has <span style='color:red;'>FAILED</span>.</p>
                         <p><b>Branch:</b> ${env.GIT_BRANCH}<br/>
                         <b>URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                         <br/>
                         <p>Regards,<br/>Jenkins</p>""",
                mimeType: 'text/html'
            )
        }
    }
}
