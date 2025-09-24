FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:stable-alpine

# Install certbot
RUN apk add --no-cache certbot certbot-nginx

# Copy built files and nginx configuration
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.prod.conf /etc/nginx/conf.d/default.conf

# Create directory for Let's Encrypt certificates
RUN mkdir -p /etc/letsencrypt

EXPOSE 80 443

# Start script to handle certificate renewal and nginx
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]