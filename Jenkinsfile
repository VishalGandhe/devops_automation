pipeline{
    agent any
    tools{
        jdk 'JDK'
        maven 'Maven'
    }
    stages{
        stage('Build Maven'){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/VishalGandhe/devops_automation']])
                     sh 'mvn clean install'

            }
        }
        stage('Build docker image'){
            steps{
                script{
                    sh 'docker build -t vishalgandhe/devops_integration . '
                }
            }
        }
        stage('Push image to Hub'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'dockerhubpwd', variable: 'dockerhubpwd')]) {
                        sh 'docker login -u vishalgandhe -p ${dockerhubpwd}'
}
                    sh 'docker push vishalgandhe/devops_integration'
                }
            }
        }
    }
}