# StreamingApp Deployment with Kubernetes Orchestration and Auto Scaling


Stream premium video content, host live watch parties, and manage your catalogue with a modern microservice architecture. The platform now ships with a production-ready admin portal, real-time chat, S3-backed adaptive streaming, and a redesigned cinematic frontend experience.

---

According to this given Project Assignment Context:

This is the flow:

- Docker builds image
- Docker logs into ECR
- Docker pushes image
- Kubernetes (EKS) pulls image

----

## Step 1: Version Control with Git

### 🔹 1.1 Fork the Repository

- Go to the main repo: https://github.com/UnpredictablePrashant/StreamingApp/
- Click Fork

---

### 🔹 1.2 Clone Fork Locally

```bash
git clone https://github.com/<your-username>/StreamingApp.git
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


## Step 2: Prepare & Containerize MERN App

### Project Tech Stack:

- Frontend → React
- Backend → Node.js/Express
- Database → MongoDB (likely external or containerized)


<img width="1912" height="1079" alt="image" src="https://github.com/user-attachments/assets/9eef1e55-8452-4293-b531-4176f4dfe00f" />


---

### 🔹 2.1 Backend Dockerfile

**Inside /backend:**\
There must be a Dockerfile for backend container, if not then create. In this assignment the Dockerfile is already provided.

---

### 🔹 2.2 Frontend Dockerfile

**Inside /frontend:**\
There must be a Dockerfile for frontend container, if not then create. In this assignment the Dockerfile is already provided.

---

### 🔹 2.3 Test Locally with Docker

```bash
docker build -t streaming-backend ./backend
docker build -t streaming-frontend ./frontend

docker run -p 5000:5000 streaming-backend
docker run -p 3000:80 streaming-frontend
```
------

Access the App on port 3000

```bash
http://localhost:3000
```



----

## ☁️ Step 3: Push Images to AWS ECR

### 🔹 3.1 Install AWS CLI & Configure

```bash
aws configure
```

**Enter:**

- Access Key (Grab from AWS IAM User)
- Secret Key (Grab from AWS IAM User)
- Region (for eg: ap-south-1)

-----

### 🔹 3.2 Create ECR Repositories

```bash
aws ecr create-repository --repository-name streaming-backend
aws ecr create-repository --repository-name streaming-frontend
```

<img width="1487" height="805" alt="ECR-2" src="https://github.com/user-attachments/assets/762f2b14-4379-4b1b-a665-3456215063a5" />


<img width="1907" height="946" alt="image" src="https://github.com/user-attachments/assets/b6c472aa-7f4d-4201-b104-6f67a8de99b7" />

----

### 🔹 3.3 Authenticate Docker to ECR

















------

## License

MIT © StreamFlix Team
