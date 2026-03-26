pipeline {
    agent { label 'agent-1' }

    environment {
        ACR_REGISTRY = "demojenkinsacr.azurecr.io" 
        IMAGE_NAME = "react-app"
        RESOURCE_GROUP = "aditya"
        ACI_NAME = "reactappcontainer"
    }

    stages {
        stage('Approve Build') {
            steps { 
                input message: 'Do you want to proceed with the build?', ok: 'Yes, proceed'
            }
        }

        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/Adityarrudola/reactapp-jenkins-cicd.git', branch: 'main'
            }
        }

        stage('Build Image') {
            steps {
                sh """
                docker build --no-cache \
                  -t ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} \
                  -t ${ACR_REGISTRY}/${IMAGE_NAME}:latest \
                  .
                """
            }
        }

        stage('Push to ACR') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'azure-sp',
                    subscriptionIdVariable: 'AZ_SUB',
                    clientIdVariable: 'AZ_CLIENT',
                    clientSecretVariable: 'AZ_SECRET',
                    tenantIdVariable: 'AZ_TENANT'
                )]) {
                    sh """
                    # Log in to Azure first
                    az login --service-principal -u $AZ_CLIENT -p $AZ_SECRET --tenant $AZ_TENANT
                    
                    # Log in to ACR using the Azure CLI context
                    az acr login --name ${ACR_REGISTRY.split('\\.')[0]}

                    # Push the images
                    docker push ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${ACR_REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to Azure Container Instances') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'azure-sp',
                    subscriptionIdVariable: 'AZ_SUB',
                    clientIdVariable: 'AZ_CLIENT',
                    clientSecretVariable: 'AZ_SECRET',
                    tenantIdVariable: 'AZ_TENANT'
                )]) {
                    sh """
                    az login --service-principal -u $AZ_CLIENT -p $AZ_SECRET --tenant $AZ_TENANT
                    az account set --subscription $AZ_SUB

                    # Re-create the ACI. Note: Added --registry-login-server for ACR authentication
                    az container create \
                    --resource-group ${RESOURCE_GROUP} \
                    --name ${ACI_NAME} \
                    --image ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} \
                    --registry-login-server ${ACR_REGISTRY} \
                    --registry-username $AZ_CLIENT \
                    --registry-password $AZ_SECRET \
                    --dns-name-label react-app-${BUILD_NUMBER} \
                    --ports 80 \
                    --os-type Linux \
                    --cpu 1 \
                    --memory 1.5 \
                    --restart-policy Always
                    """
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build SUCCESS for ${env.JOB_NAME}. Image: ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}",
                mimeType: 'text/html',
                to: 'aditya.rudola@quokkalabs.com'
            )
        }
        failure {
            emailext(
                subject: "FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <h2 style="color:red;">Build FAILED</h2>
                    <p><b>Job:</b> ${env.JOB_NAME}</p>
                    <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>Check Console:</b> ${env.BUILD_URL}</p>
                """,
                mimeType: 'text/html',
                to: 'aditya.rudola@quokkalabs.com'
            )
        }
    }
}