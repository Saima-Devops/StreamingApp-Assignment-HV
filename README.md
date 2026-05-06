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

## Project workflow

**According to this given Project Context**:

This would be the flow of deployment:

- Docker build images
- Docker logs into ECR
- Docker push images
- Kubernetes (EKS) pull images

----

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

### 🔹 2.1 Backend Dockerfiles

**Inside /backend:**

- There are 4 microservices:
   - adminService
   - authService
   - chatService
   - streamingService
     
- There must be separate Dockerfiles for each service with correct ports and endpoints.

## Architecture

| Service | Port | Description |
| --- | --- | --- |
| `authService` | 3001 | User authentication, registration, JWT issuance |
| `streamingService` | 3002 | Video catalogue, S3 playback endpoints, public APIs |
| `adminService` | 3003 | Dedicated admin microservice for asset management and uploads |
| `chatService` | 3004 | Websocket + REST chat for live watch parties |
| `frontend` | 3000 | React SPA with revamped UI and integrated chat |
| `mongo` | 27017 | Shared MongoDB instance |

All backend services share common database models and utilities through `backend/common`.

---
## 🔹 2.2 Environment Configuration

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

> I have set up `.env` for each backend microservice, like the above with my configurations & secrets with a specified port.

---

### 🔹 2.2 Frontend Dockerfile

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

### 🔹 2.3 Test Locally with Docker

```bash
docker-compose up --build
```

<img width="1280" height="721" alt="Screenshot 2026-05-01 at 1 50 33 AM" src="https://github.com/user-attachments/assets/682f3592-a653-47e5-970b-dd182e76fd7f" />

<br>

<img width="1265" height="706" alt="Screenshot 2026-05-01 at 1 57 48 AM" src="https://github.com/user-attachments/assets/f99c346b-7c1b-47d4-b12e-2c6c15664fa1" />

<br>

`docker-compose` will build the images and run all the containers by reading each & every `Dockerfile` inside the app folder

------

**Access the App on port 3000**

```bash
http://localhost:3000
```

<img width="1277" height="795" alt="Screenshot 2026-05-01 at 12 03 31 AM" src="https://github.com/user-attachments/assets/d81e8452-b113-4052-a159-e54ddda38a26" />

<br>

<img width="1236" height="458" alt="Screenshot 2026-05-01 at 1 55 10 AM" src="https://github.com/user-attachments/assets/b254c43b-42b0-4e38-8d2e-45ac0c137403" />

----

### Local Development Setup for Testing without Docker

Install dependencies for each service:

```
# auth service
cd backend/authService && npm install

# streaming service
cd ../streamingService && npm install

# admin service
cd ../adminService && npm install

# chat service
cd ../chatService && npm install

# frontend
cd ../../frontend && npm install

```
----

Run the services (in separate terminals) after starting MongoDB:

```
cd backend/authService && npm run dev
cd backend/streamingService && npm run dev
cd backend/adminService && npm run dev
cd backend/chatService && npm run dev
cd frontend && npm start
```

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

----

## ☁️ Phase 3: Push Images to AWS ECR

### 🔹 3.1 Install AWS CLI & Configure

```bash
aws configure
```

**Enter:**

- Access Key (Grab from AWS IAM User)
- Secret Key (Grab from AWS IAM User)
- Region (for eg: ap-south-1)

-----

### 🔹 3.2 Create AWS ECR Repositories

I have written a clean shell script to push ALL services to AWS ECR.

nano `push-to-ecr.sh`

```
# ===============================
# 🔹 CONFIG
# ===============================
ACCOUNT_ID=123456789012
REGION=us-east-1
ECR_BASE=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# ===============================
# 🔹 LOGIN TO ECR
# ===============================
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ECR_BASE

# ===============================
# 🔹 CREATE REPOS (safe if already exist)
# ===============================
aws ecr create-repository --repository-name frontend || true
aws ecr create-repository --repository-name authservice || true
aws ecr create-repository --repository-name adminservice || true
aws ecr create-repository --repository-name streamingservice || true
aws ecr create-repository --repository-name chatservice || true

# ===============================
# 🔹 BUILD, TAG, PUSH
# ===============================

echo "🚀 Pushing FRONTEND..."
docker build -t frontend ./frontend
docker tag frontend:latest $ECR_BASE/frontend:latest
docker push $ECR_BASE/frontend:latest

echo "🚀 Pushing AUTHSERVICE..."
docker build -t authservice ./backend/authservice
docker tag authservice:latest $ECR_BASE/authservice:latest
docker push $ECR_BASE/authservice:latest

echo "🚀 Pushing ADMINSERVICE..."
docker build -t adminservice ./backend/adminservice
docker tag adminservice:latest $ECR_BASE/adminservice:latest
docker push $ECR_BASE/adminservice:latest

echo "🚀 Pushing STREAMINGSERVICE..."
docker build -t streamingservice ./backend/streamingservice
docker tag streamingservice:latest $ECR_BASE/streamingservice:latest
docker push $ECR_BASE/streamingservice:latest

echo "🚀 Pushing CHATSERVICE..."
docker build -t chatservice ./backend/chatservice
docker tag chatservice:latest $ECR_BASE/chatservice:latest
docker push $ECR_BASE/chatservice:latest

echo "✅ All images pushed successfully!"
```

### Make it executable

```
chmod +x push-to-ecr.sh
```

### Run the magic :)

```
./push-to-ecr.sh
```

---

### Verification

```
aws ecr describe-repositories
aws ecr describe-images --repository-name frontend
```

---

## Common Pitfalls

❌ AccessDeniedException → IAM user missing ECR permissions\
❌ no basic auth credentials → forgot login step\
❌ repository not found → repo name mismatch\
❌ wrong region → must match exactly

---

## What I have completed till here:

✔ Dockerized app\
✔ Built images\
✔ Pushed to Amazon ECR


## 👉 Next step: CI/CD with Jenkins

---

## 🔧 PHASE 4: Jenkins CI/CD

### 🔹 4.1  Install Jenkins on EC2

```
sudo apt update
sudo apt install openjdk-17-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo apt install jenkins -y
```

---

### 🔹 4.2 Install Plugins

- Docker Pipeline
- Git
- AWS Credentials

-----

### 🔹 4.3 Jenkins Pipeline

```




```






Now I have to deploy these images on Kubernetes (EKS) using Helm. Let's start!

---

## ☸️ PHASE 5: Deployment on Kubernetes

by **Amazon EKS**


### 🔹 5.1 Create cluster



### 🔹 5.2 Verify





### 🔹 5.3 Helm Deployment





### 🔹 5.4 Final Deploy





---

## 📊 PHASE 6: Monitoring & Logging

by **Amazon CloudWatch**

### Enable logging

- EKS → CloudWatch Logs
- EC2 → CloudWatch agent


----

### Metrics

- CPU
- Memory
- Pod scaling

------

## 📚 PHASE 7: Documentation







----

## ☑️ PHASE 8: Validation







----

## 🔔 PHASE 9: ChatOps

by **Amazon SNS (Simple Notification Service)**

Steps:
- Create SNS Topic
- Subscribe (Email / Slack Webhook)
- Trigger from Jenkins:




----

## ⚠️ Reality Check

- Skipping Docker testing locally
- Wrong ECR tagging
- Jenkins permission issues
- EKS IAM misconfig
- Helm values are misconfigured








-----

## License

MIT © StreamFlix Team
