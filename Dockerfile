# From：https://github.com/lookscanned/lookscanned.io

# 阶段 1：构建前端
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install -g pnpm && pnpm install && pnpm run build

# 阶段 2：运行静态服务
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html

# 支持 Vue Router history 模式，避免刷新 404
COPY <<'NGINX' /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|svg|woff|woff2|ico)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
}
NGINX

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
