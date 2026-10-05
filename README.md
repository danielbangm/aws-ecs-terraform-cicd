# DevOps Tech Challenge – Node.js Deployment on AWS ECS

## Overview

This project demonstrates a complete CI/CD deployment of a React frontend and Express.js backend to AWS ECS Fargate.

The application is containerized with Docker, infrastructure is provisioned using Terraform, and deployments are automated using Jenkins.

An alternative GitOps deployment using GitHub Actions is also implemented on the `gitops` branch.

## Architecture

```text
                         Internet
                            |
                            v
                Application Load Balancer
                     /              \
                    /                \
                   /api/*             /*
                    |                  |
                    v                  v
             Backend ECS          Frontend ECS
             Fargate Task         Fargate Task
             Port 8080            Port 80
                    \                /
                     \              /
                      Amazon ECR
                          ^
                          |
                       Jenkins
                          ^
                          |
                        GitHub
```

The Application Load Balancer routes:

- `/` and frontend traffic to the React frontend service.
- `/api/*` to the Express backend service.

Both applications run as Docker containers using AWS ECS Fargate.

## Technologies

- AWS ECS Fargate
- Amazon ECR
- Application Load Balancer
- AWS IAM
- Terraform
- Docker
- Jenkins
- GitHub Actions
- React
- Node.js / Express
- Git

## Repository Structure

```text
.
├── backend/
│   ├── Dockerfile
│   ├── config.js
│   ├── index.js
│   └── package.json
│
├── frontend/
│   ├── Dockerfile
│   ├── src/
│   └── package.json
│
├── terraform/
│   ├── alb.tf
│   ├── autoscaling.tf
│   ├── ecr.tf
│   ├── ecs.tf
│   ├── iam.tf
│   ├── network.tf
│   ├── provider.tf
│   └── security-groups.tf
│
├── Jenkinsfile
└── README.md
```

## Local Application

The application was tested with Node.js 16.

### Backend

```bash
cd backend
npm ci
npm start
```

The backend runs on:

```text
http://localhost:8080
```

### Frontend

Open another terminal:

```bash
cd frontend
npm ci
npm start
```

The frontend development server runs on:

```text
http://localhost:3000
```

## Docker

### Build Backend

```bash
docker build -t challenge-backend ./backend
```

### Build Frontend

```bash
docker build -t challenge-frontend ./frontend
```

The production frontend is built using Node.js and served by Nginx.

## Infrastructure Deployment

All application infrastructure is provisioned using Terraform.

Terraform creates:

- VPC
- Two public subnets in separate Availability Zones
- Internet Gateway
- Route table
- Security groups
- Application Load Balancer
- Frontend and backend target groups
- Amazon ECR repositories
- ECS cluster
- ECS task definitions
- ECS services
- IAM ECS task execution role
- ECS Service Auto Scaling

Initialize Terraform:

```bash
cd terraform
terraform init
```

Format and validate:

```bash
terraform fmt
terraform validate
```

Review the infrastructure:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

## ECS Configuration

Both ECS services use AWS Fargate.

Each task is configured with:

```text
CPU:            512 units (0.5 vCPU)
Memory:         1024 MB (1 GB)
Minimum tasks:  1
Desired tasks:  1
Maximum tasks:  4
```

Target tracking auto scaling maintains approximately:

```text
50% average CPU utilization
```

for both the frontend and backend services.

## Load Balancer Routing

A single public Application Load Balancer exposes the application.

```text
ALB
 |
 +---- /api/* ----> Backend Target Group ----> ECS :8080
 |
 +---- /* --------> Frontend Target Group ---> ECS :80
```

The frontend uses `/api/` for backend requests. This allows the browser to communicate with both services through the same Application Load Balancer.

## Jenkins CI/CD Pipeline

Jenkins runs on a dedicated EC2 instance.

The Jenkins server was configured manually because the challenge only requires the application infrastructure to be provisioned with Terraform.

The EC2 instance uses an IAM instance role rather than static AWS credentials.

The Jenkins pipeline performs:

```text
GitHub
   |
   v
Checkout Source Code
   |
   v
Build Docker Images
   |
   v
Authenticate to Amazon ECR
   |
   v
Push Images to ECR
   |
   v
Force New ECS Deployment
   |
   v
Wait for ECS Services
   |
   v
Deployment Complete
```

The pipeline is defined in:

```text
Jenkinsfile
```

### Jenkins Pipeline Stages

1. Checkout repository
2. Build frontend and backend Docker images
3. Authenticate to Amazon ECR
4. Push both images to ECR
5. Trigger new ECS deployments
6. Wait until both ECS services become stable

AWS permissions are provided to Jenkins using an EC2 IAM role.

No AWS access keys are stored in the repository.

## GitOps Alternative – GitHub Actions

An alternative CI/CD implementation is available on the:

```text
gitops
```

branch.

The workflow is located at:

```text
.github/workflows/deploy.yml
```

A push to the `gitops` branch triggers:

```text
Git Push
   |
   v
GitHub Actions
   |
   v
Build Docker Images
   |
   v
Push Images to Amazon ECR
   |
   v
Update ECS Services
   |
   v
Wait for ECS Services
   |
   v
Deployment Complete
```

AWS credentials used by GitHub Actions are stored using GitHub Actions Secrets and are never committed to source control.

## Security

Several security practices are used in this project:

- AWS credentials are not committed to Git.
- Jenkins uses an EC2 IAM role for AWS access.
- GitHub Actions credentials are stored as encrypted repository secrets.
- ECS tasks accept application traffic only from the Application Load Balancer security group.
- ECR repositories are private.
- SSH/private key files and Terraform state are excluded using `.gitignore`.
- The source repository used for evaluation is private.

## Application URL

Frontend:

```text
http://devops-challenge-alb-1316839665.us-east-1.elb.amazonaws.com
```

A successful deployment displays:

```text
SUCCESS <backend-generated-guid>
```

This confirms that the React frontend can successfully communicate with the backend running as a separate ECS service.

## CI/CD Implementations

Two deployment approaches are included:

| Branch | CI/CD System | Deployment |
|---|---|---|
| `main` | Jenkins | Docker → ECR → ECS |
| `gitops` | GitHub Actions | Docker → ECR → ECS |

## Cleanup

To avoid unnecessary AWS charges, resources can be removed after evaluation.

First terminate manually created Jenkins resources, then remove Terraform-managed infrastructure:

```bash
cd terraform
terraform destroy
```

ECR repositories may need to be emptied before Terraform can delete them.

## Author

Daniel BM