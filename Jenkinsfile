pipeline {
    agent any

    // options {
    //     timestamps()
    //     buildDiscarder(logRotator(numToKeepStr: '10'))
    // }

    environment {
        ACR_REGISTRY = "demojenkinsacr.azurecr.io"
        IMAGE_NAME = "react-app"
        RESOURCE_GROUP = "aditya"
        ACI_NAME = "reactappcontainer"
    }

    stages {

        stage('Approve Build') {
            steps {
                input message: 'Proceed with deployment?', ok: 'Deploy'
            }
        }

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Adityarrudola/reactapp-jenkins-cicd.git', branch: 'main'
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                set -e
                echo "Building Docker image..."

                docker build \
                  -t $ACR_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER \
                  -t $ACR_REGISTRY/$IMAGE_NAME:latest \
                  .
                '''
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
                    sh '''
                    set -e
                    echo "Logging into Azure..."

                    az login --service-principal -u $AZ_CLIENT -p $AZ_SECRET --tenant $AZ_TENANT
                    az acr login --name demojenkinsacr

                    echo "Pushing image..."

                    docker push $ACR_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER
                    docker push $ACR_REGISTRY/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Delete Old Container') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'azure-sp',
                    subscriptionIdVariable: 'AZ_SUB',
                    clientIdVariable: 'AZ_CLIENT',
                    clientSecretVariable: 'AZ_SECRET',
                    tenantIdVariable: 'AZ_TENANT'
                )]) {
                    sh '''
                    set -e
                    echo "Deleting old container (if exists)..."

                    az login --service-principal -u $AZ_CLIENT -p $AZ_SECRET --tenant $AZ_TENANT
                    az account set --subscription $AZ_SUB

                    az container delete \
                      --resource-group $RESOURCE_GROUP \
                      --name $ACI_NAME \
                      --yes || true
                    '''
                }
            }
        }

        stage('Deploy to ACI') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: 'azure-sp',
                    subscriptionIdVariable: 'AZ_SUB',
                    clientIdVariable: 'AZ_CLIENT',
                    clientSecretVariable: 'AZ_SECRET',
                    tenantIdVariable: 'AZ_TENANT'
                )]) {
                    sh '''
                    set -e
                    echo "Deploying to Azure Container Instances..."

                    az login --service-principal -u $AZ_CLIENT -p $AZ_SECRET --tenant $AZ_TENANT
                    az account set --subscription $AZ_SUB

                    az container create \
                      --resource-group $RESOURCE_GROUP \
                      --name $ACI_NAME \
                      --image $ACR_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER \
                      --registry-login-server $ACR_REGISTRY \
                      --registry-username $AZ_CLIENT \
                      --registry-password $AZ_SECRET \
                      --dns-name-label react-app-$BUILD_NUMBER \
                      --ports 80 \
                      --os-type Linux \
                      --cpu 1 \
                      --memory 1.5 \
                      --restart-policy Always
                    '''
                }
            }
        }

        stage('Cleanup Docker') {
            steps {
                sh '''
                echo "Cleaning Docker..."
                docker system prune -af || true
                '''
            }
        }
    }

    post {
        success {
            emailext(
                subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <h2 style="color:green;">Build SUCCESS</h2>
                    <p><b>Job:</b> ${env.JOB_NAME}</p>
                    <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>Image:</b> ${ACR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}</p>
                """,
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