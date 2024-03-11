pipeline {
    agent any
    environment {
        //once you sign up for Docker hub, use that user_id here
        registry = "reactweb11.azurecr.io/react-app"
        //- update your credentials ID after creating credentials for connecting to Docker Hub
        registryCredential = 'azure_acr_registry'
        dockerImage = ''
    } 
    stages {
        stage ('checkout') {
            steps {
                git branch: 'main', credentialsId: 'Github_login', url: 'https://github.com/mukthiyarglobal/React_Azure_appservices.git'
            }
        }
        stage ('build docker image') {
            steps {
                script {
                    dockerImage = docker.build registry
                    dockerImage.tag("$BUILD_NUMBER") // Add dynamic tag
                }
            }
        }
        stage ('push image into acr') {
            steps {
                script {
                    // docker.withRegistry('', registryCredential) {
                    //     //dockerImage.push()
                    //     dockerImage.push("${registry}:${BUILD_NUMBER}") // Push image with dynamic tag
                    // }
                    withCredentials([usernamePassword(credentialsId: 'azure_acr_registry', passwordVariable: 'password', usernameVariable: 'username')]) {
                       sh 'docker login -u ${username} -p ${password} ${registry}'
                    }
                    sh "docker push ${registry}:${BUILD_NUMBER}"
                   // sh "docker push ${registry}:latest"
                }
            }
        }
        stage ('Deploy react app into azure app service') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('azure_loginid')]) {
                       
                    }
                    withCredentials([usernamePassword(credentialsId: 'azure_acr_registry', passwordVariable: 'password', usernameVariable: 'username')]) {
                       sh 'az webapp config container set --name material-react --resource-group react-rg --docker-custom-image-name ${registry}:${BUILD_NUMBER} --docker-registry-server-url https://reactweb11.azurecr.io --docker-registry-server-user ${username} --docker-registry-server-password ${password}'
                    }
                }
            }
        }
    }
}
