# Architecture

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

## Routing

The frontend image is built once and configured at runtime through `/env.js`.

In EKS, the ingress routes are:

- `/` -> frontend
- `/api/auth` -> auth
- `/api/streaming` -> streaming
- `/api/admin` -> admin
- `/api/chat` -> chat
- `/socket.io` -> chat websocket transport

## Runtime Configuration

Backend configuration is provided by a Helm ConfigMap and Secret. Frontend API URLs are runtime environment variables rendered by Nginx startup:

- `REACT_APP_AUTH_API_URL`
- `REACT_APP_STREAMING_API_URL`
- `REACT_APP_STREAMING_PUBLIC_URL`
- `REACT_APP_ADMIN_API_URL`
- `REACT_APP_CHAT_API_URL`
- `REACT_APP_CHAT_SOCKET_URL`

## Scaling

The Helm chart includes CPU-based HorizontalPodAutoscalers for the frontend and app services. MongoDB is deployed as a single StatefulSet for assignment/demo use only. Use a managed database for production-grade availability.
