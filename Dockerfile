# Production Dockerfile for DJI-Mapper Web
# This assumes the web app has been built locally with: flutter build web --release
FROM nginx:alpine

# Install wget for health check
RUN apk add --no-cache wget

# Copy built web assets
COPY build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
