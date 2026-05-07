FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

FROM nginx:1.27-alpine AS production

COPY --from=build /app/build /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/env.template.js /usr/share/nginx/html/env.template.js

ENV REACT_APP_AUTH_API_URL=/api/auth
ENV REACT_APP_STREAMING_API_URL=/api
ENV REACT_APP_STREAMING_PUBLIC_URL=/
ENV REACT_APP_ADMIN_API_URL=/api/admin
ENV REACT_APP_CHAT_API_URL=/api/chat
ENV REACT_APP_CHAT_SOCKET_URL=/

EXPOSE 80
CMD ["/bin/sh", "-c", "envsubst < /usr/share/nginx/html/env.template.js > /usr/share/nginx/html/env.js && nginx -g 'daemon off;'"]
