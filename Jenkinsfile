pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'

        FRONTEND_REPOSITORY = 'devops-challenge-frontend'
        BACKEND_REPOSITORY  = 'devops-challenge-backend'

        ECS_CLUSTER          = 'devops-challenge-cluster'
        FRONTEND_SERVICE     = 'devops-challenge-frontend-service'
        BACKEND_SERVICE      = 'devops-challenge-backend-service'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    docker build -t challenge-frontend ./frontend
                    docker build -t challenge-backend ./backend
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                sh '''
                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                    ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

                    aws ecr get-login-password --region "$AWS_REGION" | \
                    docker login --username AWS --password-stdin "$ECR_REGISTRY"

                    docker tag challenge-frontend:latest \
                      "$ECR_REGISTRY/$FRONTEND_REPOSITORY:latest"

                    docker tag challenge-backend:latest \
                      "$ECR_REGISTRY/$BACKEND_REPOSITORY:latest"

                    docker push "$ECR_REGISTRY/$FRONTEND_REPOSITORY:latest"
                    docker push "$ECR_REGISTRY/$BACKEND_REPOSITORY:latest"
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                    aws ecs update-service \
                      --cluster "$ECS_CLUSTER" \
                      --service "$FRONTEND_SERVICE" \
                      --force-new-deployment \
                      --region "$AWS_REGION" \
                      --no-cli-pager

                    aws ecs update-service \
                      --cluster "$ECS_CLUSTER" \
                      --service "$BACKEND_SERVICE" \
                      --force-new-deployment \
                      --region "$AWS_REGION" \
                      --no-cli-pager
                '''
            }
        }

        stage('Wait for ECS') {
            steps {
                sh '''
                    aws ecs wait services-stable \
                      --cluster "$ECS_CLUSTER" \
                      --services "$FRONTEND_SERVICE" "$BACKEND_SERVICE" \
                      --region "$AWS_REGION"
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }

        failure {
            echo 'Deployment failed. Check the Jenkins console output.'
        }
    }
}