# StreamingApp Deployment with Kubernetes Orchestration and Auto Scaling

## About the Streaming App
Stream premium video content, host live watch parties, and manage your catalogue with a modern microservice architecture. The platform now ships with a production-ready admin portal, real-time chat, S3-backed adaptive streaming, and a redesigned cinematic frontend experience.

---

## Assignment Project Overview

This project demonstrates a complete end-to-end DevOps pipeline for a MERN (MongoDB, Express, React, Node.js) application, covering:

- Version Control with Git
- Containerization using Docker
- CI/CD with Jenkins
- Deployment on AWS EKS (Kubernetes)
- Monitoring & Logging with CloudWatch
- Optional ChatOps Integration

---

## Technology Stack

- Frontend: React
- Backend: Node.js, Express
- Database: MongoDB
- CI/CD: Jenkins
- Containerization: Docker
- Container Registry: Amazon ECR
- Orchestration: Kubernetes (EKS)
- Monitoring & Logging: AWS CloudWatch
- Cloud Provider: AWS

---

## Architecture

```mermaid
flowchart LR
  User["User Browser"] --> ALB["AWS Load Balancer / Ingress"]
  ALB --> FE["React Frontend (Nginx)"]
  ALB --> Auth["Auth Service"]
  ALB --> Stream["Streaming Service"]
  ALB --> Admin["Admin Service"]
  ALB --> Chat["Chat Service / Socket.IO"]

  Auth --> Mongo["MongoDB"]
  Stream --> Mongo
  Admin --> Mongo
  Chat --> Mongo

  Stream --> S3["Amazon S3 / CDN"]
  Admin --> S3

  Jenkins["Jenkins on EC2"] --> ECR["Amazon ECR"]
  Jenkins --> EKS["Amazon EKS"]
  ECR --> EKS
  EKS --> CloudWatch["CloudWatch Logs and Metrics"]
  Jenkins --> SNS["SNS Deployment Topic"]
  SNS --> Slack["Slack via AWS Chatbot / Amazon Q Developer"]
```
----

## Routing

The frontend image is built once and configured at runtime through `/env.js`.

In EKS, the ingress routes are:

- `/` -> frontend
- `/api/auth` -> auth
- `/api/streaming` -> streaming
- `/api/admin` -> admin
- `/api/chat` -> chat
- `/socket.io` -> chat websocket transport

----

## Runtime Configuration

Backend configuration is provided by a Helm ConfigMap and Secret. Frontend API URLs are runtime environment variables rendered by Nginx startup:

- `REACT_APP_AUTH_API_URL`
- `REACT_APP_STREAMING_API_URL`
- `REACT_APP_STREAMING_PUBLIC_URL`
- `REACT_APP_ADMIN_API_URL`
- `REACT_APP_CHAT_API_URL`
- `REACT_APP_CHAT_SOCKET_URL`

-----

## Scaling

- The Helm chart includes CPU-based `HorizontalPodAutoscalers` for the frontend and app services. 
- `MongoDB` is deployed as a single `StatefulSet` for assignment/demo use only.
- Used a managed database for production-grade availability.

----

# Deployment Steps

## Phase 1: Version Control with Git

### 🔹 1.1 Fork the Repository

- Go to the main repo: https://github.com/UnpredictablePrashant/StreamingApp/
- Click Fork

---

### 🔹 1.2 Clone Fork Locally

```bash
git clone https://github.com/Saima-Devops/StreamingApp.git
cd StreamingApp
```

---

### 🔹 1.3 Add Upstream (BEST PRACTICE)

This keeps the fork updated with the original repo.

```bash
git remote add upstream https://github.com/UnpredictablePrashant/StreamingApp.git
git remote -v
```

---

### 🔹 1.4 Sync Fork with Upstream

```bash
git fetch upstream
git checkout main # (if you are in other feature branch)
git merge upstream/main #if needed
git push origin main
```

> 💡 DevOps Tip: Do this regularly\
> Never work directly on main. Use feature branches.

---


## Phase 2: Prepare & Containerize MERN App

### Project Tech Stack:

- Frontend → React
- Backend → Node.js/Express
- Database → MongoDB (likely external or containerized)


<img width="1912" height="1079" alt="image" src="https://github.com/user-attachments/assets/9eef1e55-8452-4293-b531-4176f4dfe00f" />


---

### 🔹 2.1 Dockerfiles

**Inside /backend:**

There are 4 microservices:
   - adminService
   - authService
   - chatService
   - streamingService
     
> There must be separate Dockerfiles for each service with correct ports and endpoints.

-----

### Micro-Services Ports

| Service | Port | Description |
| --- | --- | --- |
| `authService` | 3001 | User authentication, registration, JWT issuance |
| `streamingService` | 3002 | Video catalogue, S3 playback endpoints, public APIs |
| `adminService` | 3003 | Dedicated admin microservice for asset management and uploads |
| `chatService` | 3004 | Websocket + REST chat for live watch parties |
| `frontend` | 3000 | React SPA with revamped UI and integrated chat |
| `mongo` | 27017 | Shared MongoDB instance |

> All backend services share common database models and utilities through `backend/common`.

------

### Containerization

The repository contains `Dockerfiles` for all components:

- `frontend/Dockerfile`
- `backend/authService/Dockerfile`
- `backend/streamingService/Dockerfile`
- `backend/adminService/Dockerfile`
- `backend/chatService/Dockerfile`

------

## 🔹 2.2 Environment Variables Configuration

Created an `.env` for each service. All services accept the standard AWS credentials for S3 access.

### Auth Service (`backend/authService/.env`)

```ini
PORT=3001
MONGO_URI=mongodb://localhost:27017/streamingapp
JWT_SECRET=changeme
CLIENT_URLS=http://localhost:3000
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=ap-south-1
AWS_S3_BUCKET=
```

> I have set up `.env` for each backend microservice, like the above, with my configurations & secrets with a specified port.

---

### 🔹 2.3 Frontend Dockerfile

**Inside /frontend:**

I have created `.env` with the following endpoints:

```ini
REACT_APP_AUTH_API_URL=http://localhost:3001/api
REACT_APP_STREAMING_API_URL=http://localhost:3002/api
REACT_APP_STREAMING_PUBLIC_URL=http://localhost:3002
REACT_APP_ADMIN_API_URL=http://localhost:3003/api/admin
REACT_APP_CHAT_API_URL=http://localhost:3004/api/chat
REACT_APP_CHAT_SOCKET_URL=http://localhost:3004
```

> Note: In frontend `localhost` can work, but in backend microservices, each should be communicated with the correct api so `localhost` will not work.

---

### 🔹 2.4 Test Locally with Docker

```bash
docker-compose up --build
```

<img width="1280" height="721" alt="Screenshot 2026-05-01 at 1 50 33 AM" src="https://github.com/user-attachments/assets/682f3592-a653-47e5-970b-dd182e76fd7f" />

<br>

<img width="1265" height="706" alt="Screenshot 2026-05-01 at 1 57 48 AM" src="https://github.com/user-attachments/assets/f99c346b-7c1b-47d4-b12e-2c6c15664fa1" />

<br>

`docker-compose` will build the images and run all the containers by reading each & every `Dockerfile` inside the app folder

------

**Access the App on port 3000/3005**

```bash
http://localhost:3000    # I mapped this on port 3005, because port 3000 was busy
```

<img width="1277" height="795" alt="Screenshot 2026-05-01 at 12 03 31 AM" src="https://github.com/user-attachments/assets/d81e8452-b113-4052-a159-e54ddda38a26" />

<br>

<img width="1236" height="458" alt="Screenshot 2026-05-01 at 1 55 10 AM" src="https://github.com/user-attachments/assets/b254c43b-42b0-4e38-8d2e-45ac0c137403" />
<br>

<img width="1276" height="658" alt="Screenshot 2026-05-06 at 9 54 51 PM" src="https://github.com/user-attachments/assets/2e08240b-5a90-4ade-b4ba-dd3103e80d32" />
<br>
<img width="1265" height="670" alt="Screenshot 2026-05-06 at 9 57 39 PM" src="https://github.com/user-attachments/assets/c2c47198-dbf2-4db6-a3d4-1ec2ee9c8d36" />
<br>
<img width="1280" height="656" alt="Screenshot 2026-05-06 at 9 58 06 PM" src="https://github.com/user-attachments/assets/0688a604-39c9-45a4-adf0-c808dda31fbf" />

---

## Troubleshooting:

### Frontend Errors

```
Browser → F12 key → Console
```

### Backend Errors

**Check backend logs**

```
docker-compose logs authservice
```

Check for:

❌ Mongo connection error\
❌ Port already in use\
❌ Missing env variables

---

### Port is already allocated (0.0.0.0:3000)

Solution:

**1. What is using port 3000**

```
lsof -i :3000
```

Copy the process id (PID) and kill that process if the process is not necessary.


**2. Kill the process**

```
kill -9 <pid>
```
---

### If it's an old container:

```
docker ps 
```

- Copy the container id or name

- Stop the container and delete:

```
docker stop <container_id>
docker rm <container_id>
```
---

Build again after all changes:

```
docker-compose down
docker-compose up --build
```

---

Each Microservice should use the following format to communicate with mongodb, localhost will not work

```
MONGO_URI=mongodb://mongo:27017/streamingapp
```

After fixing everything:

- Containers started ✔️
- Backend connected to Mongo ✔️
- Frontend loaded properly ✔️
- APIs responded ✔️

---

## ✅ Expected Results:


- Frontend → http://localhost:3000
- Auth API → http://localhost:3001
- Streaming API → http://localhost:3002


Local Testing Done! 👍

<img width="1269" height="710" alt="Screenshot 2026-05-06 at 2 36 58 PM" src="https://github.com/user-attachments/assets/2ca883c1-5312-4d9b-a257-b2f6c47e0e43" />

<img width="1257" height="725" alt="Screenshot 2026-05-06 at 2 39 18 PM" src="https://github.com/user-attachments/assets/f119c388-81d6-4df5-af3e-ebe15fb96d85" />

<br>

**Removed the Resources after local Testing:**

<img width="1078" height="553" alt="Screenshot 2026-05-06 at 10 03 34 PM" src="https://github.com/user-attachments/assets/b7a97f2c-47fd-4567-aada-c008367707dc" />


----

## ☁️ Phase 3: Install AWS CLI & Configure

```bash
aws configure
```

**Enter:**

- Access Key (Grab from AWS IAM User)
- Secret Key (Grab from AWS IAM User)
- Region (for eg: ap-south-1)

-----

### 🔹 3.1 Build, Tag and push Docker images to ECR using Jenkins jobs

I have written some clean shell scripts to push ALL services to AWS ECR, which will be executed through Jenkins Jibs.

- scripts/build-and-push-ecr.sh
- scripts/create-ecr-repos.sh
- scripts/deploy-eks.sh


### Make them executable

```
chmod +x build-and-push-ecr.sh
chmod +x create-ecr-repos.sh
chmod +x deploy-eks.sh
```
---


#### Every Changes were tested in staging branch before the final deployment


<img width="2560" height="1122" alt="image" src="https://github.com/user-attachments/assets/49cfc414-a837-4b4c-b775-fa06e6a389ad" />


<img width="1235" height="469" alt="Screenshot 2026-05-07 at 12 34 48 PM" src="https://github.com/user-attachments/assets/bc7a9a69-b296-45e7-af36-35dd52769fd7" />


<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/58bdb571-4898-47bb-b148-391df425cbd3" />

<img width="2394" height="1236" alt="image" src="https://github.com/user-attachments/assets/53e7e36e-0e4d-466e-ad7d-57fe3b54e935" />

-----

## 🔧 PHASE 4: Jenkins CI/CD

### 🔹 4.1  Install Jenkins on EC2 or any cloud-based Jenkins

- Install Jenkins on an EC2 instance that has Docker, AWS CLI, kubectl, and Helm installed.
  
```
sudo apt update
sudo apt install openjdk-17-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo apt install jenkins -y
```

---

### 🔹 4.2 Install Jenkins Plugins

- Pipeline
- Git
- GitHub
- AWS Credentials
- Docker Pipeline

**Verify:**

```
aws --version
docker --version
kubectl version --client
helm version
eksctl version
```

-----

### 🔹 4.3 Create Jenkins credentials:

- ID: aws-jenkins
- Type: AWS credentials
- Permissions: ECR push, EKS deploy, SNS publish if ChatOps is enabled

-----

### 🔹 4.4 Jenkins Pipeline

- Created a Pipeline job from SCM pointing to the repo "https://github.com/Saima-Devops/StreamingApp-Assignment-HV.git.
- Jenkinsfile is present on the root.
- Configured a webhook in your Git repository so new commits trigger builds.

**What does the pipeline do:**

- Checks out code.
- Logs in to ECR.
- Creates missing ECR repositories.
- Builds and pushes all five images.
- Deploys to EKS from main.
- Publishes optional SNS success/failure messages if SNS_TOPIC_ARN is set.

-------

### 🔹 4.5 Create AWS EKS Cluster

**Configure AWS locally:**
```
aws configure
export AWS_REGION=ap-south-1
export ECR_PREFIX=streamingapp
```


```
eksctl create cluster \
  --name streamingapp \
  --region "$AWS_REGION" \
  --nodes 2 \
  --node-type t2.medium \
  --managed
```

#### Configure kubectl

```
aws eks update-kubeconfig --name streamingapp --region "$AWS_REGION"
kubectl get nodes
```

**NOTE:** 
- Install the AWS Load Balancer Controller before using the default ALB ingress class. 
- Enable metrics-server if HPA scaling is desired.

------

### 🔹 4.6 Jenkins Pipeline (Build Now)


<img width="2524" height="446" alt="image" src="https://github.com/user-attachments/assets/8846dba0-563d-458a-b074-0d450fa2f97b" />


<img width="1253" height="222" alt="Screenshot 2026-05-09 at 1 27 48 AM" src="https://github.com/user-attachments/assets/37179e48-7fa1-4cab-a5cd-d7b86d098780" />


<img width="1270" height="703" alt="Screenshot 2026-05-07 at 2 39 15 PM" src="https://github.com/user-attachments/assets/ec646b3b-3ed5-497f-9c32-fb6f94ad24e5" />


<img width="2482" height="964" alt="image" src="https://github.com/user-attachments/assets/c056e924-4716-4b70-81d8-1c20c692c51c" />


<img width="2476" height="1212" alt="image" src="https://github.com/user-attachments/assets/a88e5722-1245-4a00-a4bd-0854214eaceb" />


<img width="1246" height="596" alt="Screenshot 2026-05-07 at 4 32 06 PM" src="https://github.com/user-attachments/assets/a468a9f3-3292-4031-91a4-4d7a0b9b6a1f" />

------

## 🏆 Finally, the Pipeline has been PASSED


After so much **Troubleshooting** got the cleanest CI/CD Pipeline finally:

<br>

<img width="2438" height="1350" alt="image" src="https://github.com/user-attachments/assets/c98c1221-3305-4826-804f-f06414f23093" />

<img width="2478" height="1400" alt="image" src="https://github.com/user-attachments/assets/b18f6292-686d-4fab-89ee-b2d47111dabe" />

------

### Common Pitfalls

❌ AccessDeniedException → IAM user missing ECR permissions\
❌ no basic auth credentials → forgot login step\
❌ repository not found → repo name mismatch\
❌ Depreciated Versions of dependencies, mismatch with the latest runtime


---

Now I have to deploy these images on Kubernetes (EKS) using Helm. Let's start!

---

## ☸️ PHASE 5: Deployment on Kubernetes (AWS EKS) with Helm

### 🔹 5.1 Create an EKS Cluster

```
eksctl create cluster \
  --streamingapp \
  --region ap-south-1 \
  --nodegroup-name streamingapp \
  --node-type t2.medium \
  --nodes 2
```


#### Verify Cluster Access

**Check nodes:**

```
kubectl get nodes
```

**This will:**

- Create EKS control plane
- Create worker nodes
- Configure networking
- Update kubeconfig automatically

-----

### 🔹 5.2 Create/Updat Helm Charts

```
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
  --set aws.s3Bucket="sam-s3-bucket" \
  --set clientUrls=""
```

**Edit if needed:**

- values.yaml
- deployment.yaml
- service.yaml

> Check the names of ECR images. Verify all names and values are correct

```
helm repo update
kubectl get pods
```
<br>

#### Helm does:

- Install the applications on Kubernetes in few commands
- Manage releases
- Upgrade/rollback apps

> For the Infrastructure setup automation, we can use `Terraform`

----

<img width="2480" height="1346" alt="image" src="https://github.com/user-attachments/assets/4711d1a8-36dc-4a21-8cd3-112c8dc77bb4" />

<img width="2472" height="1328" alt="image" src="https://github.com/user-attachments/assets/7555ce6d-699d-4a1d-8e2c-5c1ee85ee71c" />


<img width="1240" height="673" alt="Screenshot 2026-05-10 at 11 42 26 AM" src="https://github.com/user-attachments/assets/245eec90-d508-4098-9370-fd1c2fd69da7" />

<img width="2560" height="1372" alt="image" src="https://github.com/user-attachments/assets/dca82ceb-3e30-418e-8a4e-bc8ff69fc533" />

<img width="2492" height="1188" alt="image" src="https://github.com/user-attachments/assets/c74f292d-e4fb-464f-acf6-b15869a248be" />


<img width="2452" height="1136" alt="image" src="https://github.com/user-attachments/assets/48e4b3e5-73b7-4381-a820-fbb660df192e" />


<img width="2464" height="918" alt="image" src="https://github.com/user-attachments/assets/56e78771-29b6-4e89-8d1f-c19f2a3152eb" />



<img width="2544" height="1364" alt="image" src="https://github.com/user-attachments/assets/e949baff-4d3c-4647-91ed-26bc8abf65d8" />


<img width="2548" height="1378" alt="image" src="https://github.com/user-attachments/assets/4f8d5e44-e08a-47d9-9b6b-a00b130473a0" />



<img width="2550" height="1294" alt="image" src="https://github.com/user-attachments/assets/1647f8b1-727f-47c5-8c03-67fb8a76875f" />


<img width="2526" height="1370" alt="image" src="https://github.com/user-attachments/assets/2a67a153-d525-44d6-8862-3a394d7bc182" />



<img width="2498" height="1364" alt="image" src="https://github.com/user-attachments/assets/b262b910-ad56-4f4b-9ac3-41189d094f8f" />


<img width="2386" height="1026" alt="image" src="https://github.com/user-attachments/assets/529bb95a-de56-4d45-8958-93cbb23b7426" />

----

### 🔹 5.2 S3 Storage

<img width="1227" height="652" alt="Screenshot 2026-05-10 at 11 45 10 AM" src="https://github.com/user-attachments/assets/262417e0-0650-47f6-a5ef-b9c45d60bd24" />

<img width="1192" height="462" alt="image" src="https://github.com/user-attachments/assets/e488f00b-d215-4cfd-8e48-398f101bb3cd" />

<img width="1147" height="523" alt="image" src="https://github.com/user-attachments/assets/4c15c144-3e56-4f1e-88c3-e07232a16d47" />

----

### 🔹 5.3 Check Rollout

```
kubectl get pods -n streamingapp
kubectl get ingress -n streamingapp
kubectl rollout status deployment/streamingapp-streamingapp-frontend -n streamingapp
```
-----


## 📊 PHASE 6: Monitoring & Logging

by **Amazon CloudWatch**

### Enable logging

Enable CloudWatch Container Insights or the Amazon CloudWatch Observability add-on for EKS:

- EKS → CloudWatch Logs
- EC2 → CloudWatch agent

```
aws eks create-addon \
  --cluster-name streamingapp \
  --addon-name amazon-cloudwatch-observability \
  --region "$AWS_REGION"
```

----

### Metrics

- CPU
- Memory
- Pod scaling

----

### Recommended alarms:

- ALB target 5xx count > 0 for 5 minutes
- Pod restart count > 3 in 10 minutes
- CPU > 70 percent for app deployments
- Memory > 80 percent for app deployments
- MongoDB PVC usage > 80 percent if using the demo in-cluster MongoDB


### Useful commands:
```
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-auth
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-streaming
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-admin
kubectl logs -n streamingapp deploy/streamingapp-streamingapp-chat
```

**All Jenkins Jobs (CI/CD) are done successfully!!** 👍


<img width="1795" height="440" alt="image" src="https://github.com/user-attachments/assets/a417bafe-aa47-42d3-a8c2-9c88dfee5dc1" />


----


## 🔔 PHASE 7: ChatOps

by **Amazon SNS (Simple Notification Service)**

Steps:
- Create SNS Topic
- Subscribe (Email / Slack Webhook)
- Trigger from Jenkins:

```
post {
    success {
      sh '''
        if [ -n "${SNS_TOPIC_ARN:-}" ]; then
          aws sns publish --topic-arn "$SNS_TOPIC_ARN" --message "Streaming app deployment succeeded: $JOB_NAME #$BUILD_NUMBER ($IMAGE_TAG)"
        fi
      '''
    }
    failure {
      sh '''
        if [ -n "${SNS_TOPIC_ARN:-}" ]; then
          aws sns publish --topic-arn "$SNS_TOPIC_ARN" --message "Streaming app deployment failed: $JOB_NAME #$BUILD_NUMBER"
        fi
      '''
    }
```

<br>

**Create an SNS topic:**

```
aws sns create-topic --name streamingapp-deployments --region "$AWS_REGION"
```


Set `SNS_TOPIC_ARN` in Jenkins. The included `Jenkinsfile` publishes deployment success/failure messages to that topic.

<br>

To send SNS messages to `Slack`, configure `AWS Chatbot` / Amazon Q Developer in chat applications:

---

### Slack Integration

**Steps:**

1. Connect your Slack workspace.
2. Create a channel configuration.
3. Attach the `streamingapp-deployments` SNS topic.
4. Allow the channel role to read CloudWatch/SNS notifications.

<img width="1882" height="606" alt="Screenshot 2026-05-08 225922" src="https://github.com/user-attachments/assets/af77a9f1-3cdd-4d41-bf04-2db8a0472a38" />

<img width="1918" height="863" alt="SNS-2" src="https://github.com/user-attachments/assets/beba9e09-e255-4685-9f92-52ca460cb5b7" />


----

## ✅ PHASE 8: Final Validation

**After the ALB address is ready:**

<img width="1610" height="368" alt="image" src="https://github.com/user-attachments/assets/0204948c-aeb2-4749-88e8-3d382899fe8f" />

<img width="1795" height="440" alt="image" src="https://github.com/user-attachments/assets/a417bafe-aa47-42d3-a8c2-9c88dfee5dc1" />

----

**Also validate in the browser:**

- Register/login works.
- Browse page loads videos.
- Admin page can create/list videos.
- Chat connects on a video page.
- HPA objects exist with kubectl get hpa -n streamingapp.

----

### ⚠️ Reality Checks for Troubleshooting during the whole process

- Skipping Docker testing locally
- Wrong ECR tagging
- Jenkins permission issues
- EKS IAM misconfig
- Helm values are misconfigured


-----

## License

MIT © StreamFlix Team

-----

## Credits:

**Source Code:** UnpredictablePrashant/StreamingApp

**Demo Deployment:** by **Saima Usman**\
Student of PPMCAD-15

-----
