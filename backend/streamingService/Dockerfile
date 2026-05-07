FROM node:20-alpine AS base

WORKDIR /app/streamingService

COPY streamingService/package*.json ./
RUN npm ci --omit=dev

COPY streamingService/. ./
ENV NODE_ENV=production
EXPOSE 3002

USER node

CMD ["npm", "start"]
