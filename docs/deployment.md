# Deployment Runbook

This runbook follows the assignment sequence: containerize, push to ECR, configure Jenkins CI, deploy to EKS with Helm, monitor with CloudWatch, and optionally send ChatOps alerts.

## 1. Prerequisites

Install these on your workstation and Jenkins EC2 instance:

```bash
aws --version
docker --version
kubectl version --client
helm version
eksctl version
```

Configure AWS locally:

```bash
aws configure
export AWS_REGION=ap-south-1
export ECR_PREFIX=streamingapp
```

Required AWS permissions include ECR repository/image access, EKS cluster access, CloudWatch, IAM permissions for EKS setup, and SNS if using ChatOps.

## 2. Containerization

The repository contains Dockerfiles for all components:

- `frontend/Dockerfile`
- `backend/authService/Dockerfile`
- `backend/streamingService/Dockerfile`
- `backend/adminService/Dockerfile`
- `backend/chatService/Dockerfile`

Validate locally:

```bash
cp .env.example .env
docker compose build
docker compose up -d
docker compose ps
docker compose down
```

## 3. Push Images to Amazon ECR

Create ECR repositories and push images:

```bash
export AWS_REGION=ap-south-1
export ECR_PREFIX=streamingapp
export IMAGE_TAG=$(git rev-parse --short=12 HEAD)

./scripts/create-ecr-repos.sh
./scripts/build-and-push-ecr.sh
```

The script creates/pushes these repositories:

- `streamingapp/frontend`
- `streamingapp/auth`
- `streamingapp/streaming`
- `streamingapp/admin`
- `streamingapp/chat`

## 4. Jenkins CI

Install Jenkins on an EC2 instance that has Docker, AWS CLI, kubectl, and Helm installed. Add Jenkins to the `docker` group or run Docker through your approved build setup.

Install Jenkins plugins:

- Pipeline
- Git
- GitHub or GitLab integration, depending on your repository
- AWS Credentials
- Docker Pipeline

Create Jenkins credentials:

- ID: `aws-jenkins`
- Type: AWS credentials
- Permissions: ECR push, EKS deploy, SNS publish if ChatOps is enabled

Create a Pipeline job from SCM pointing to this repo and `Jenkinsfile`. Configure a webhook in your Git repository so new commits trigger builds.

The pipeline:

1. Checks out code.
2. Logs in to ECR.
3. Creates missing ECR repositories.
4. Builds and pushes all five images.
5. Deploys to EKS from `main`.
6. Publishes optional SNS success/failure messages if `SNS_TOPIC_ARN` is set.

## 5. EKS Cluster

Create a cluster:

```bash
eksctl create cluster \
  --name streamingapp \
  --region "$AWS_REGION" \
  --nodes 2 \
  --node-type t3.medium \
  --managed

aws eks update-kubeconfig --name streamingapp --region "$AWS_REGION"
```

Install the AWS Load Balancer Controller before using the default ALB ingress class. Also enable metrics-server if you want HPA scaling to work.

## 6. Deploy with Helm

For assignment/demo deployment with in-cluster MongoDB:

```bash
export IMAGE_TAG=$(git rev-parse --short=12 HEAD)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

helm upgrade --install streamingapp charts/streamingapp \
  --namespace streamingapp \
  --create-namespace \
  --set global.imageTag="$IMAGE_TAG" \
  --set services.frontend.image.repository="$ECR_REGISTRY/streamingapp/frontend" \
  --set services.auth.image.repository="$ECR_REGISTRY/streamingapp/auth" \
  --set services.streaming.image.repository="$ECR_REGISTRY/streamingapp/streaming" \
  --set services.admin.image.repository="$ECR_REGISTRY/streamingapp/admin" \
  --set services.chat.image.repository="$ECR_REGISTRY/streamingapp/chat" \
  --set secrets.jwtSecret="replace-with-a-strong-secret" \
  --set aws.region="$AWS_REGION" \
  --set aws.s3Bucket="your-s3-bucket" \
  --set clientUrls="https://your-domain.example"
```

For a managed database, disable the demo MongoDB and pass the URI as a secret value:

```bash
helm upgrade --install streamingapp charts/streamingapp \
  --namespace streamingapp \
  --create-namespace \
  --set mongodb.enabled=false \
  --set secrets.externalMongoUri="mongodb+srv://user:password@host/streamingapp"
```

Check rollout:

```bash
kubectl get pods -n streamingapp
kubectl get ingress -n streamingapp
kubectl rollout status deployment/streamingapp-streamingapp-frontend -n streamingapp
```

## 7. Monitoring and Logging

Enable CloudWatch Container Insights or the Amazon CloudWatch Observability add-on for EKS:

```bash
aws eks create-addon \
  --cluster-name streamingapp \
  --addon-name amazon-cloudwatch-observability \
  --region "$AWS_REGION"
```

Recommended alarms:

- ALB target 5xx count > 0 for 5 minutes
- Pod restart count > 3 in 10 minutes
- CPU > 70 percent for app deployments
- Memory > 80 percent for app deployments
- MongoDB PVC usage > 80 percent if using the demo in-cluster MongoDB

Useful commands:

```bash
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-auth
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-streaming
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-admin
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-chat
```

## 8. ChatOps Bonus

Create an SNS topic:

```bash
aws sns create-topic --name streamingapp-deployments --region "$AWS_REGION"
```

Set `SNS_TOPIC_ARN` in Jenkins. The included `Jenkinsfile` publishes deployment success/failure messages to that topic.

To send SNS messages to Slack, configure AWS Chatbot / Amazon Q Developer in chat applications:

1. Connect your Slack workspace.
2. Create a channel configuration.
3. Attach the `streamingapp-deployments` SNS topic.
4. Allow the channel role to read CloudWatch/SNS notifications.

## 9. Final Validation

After the ALB address is ready:

```bash
APP_URL="http://your-alb-dns-name"

curl "$APP_URL/api/auth/health"
curl "$APP_URL/api/streaming/health"
curl "$APP_URL/api/admin/health"
curl "$APP_URL/api/chat/health"
curl -I "$APP_URL"
```

Also validate in the browser:

- Register/login works.
- Browse page loads videos.
- Admin page can create/list videos.
- Chat connects on a video page.
- HPA objects exist with `kubectl get hpa -n streamingapp`.
