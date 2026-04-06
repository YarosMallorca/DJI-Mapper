# Multi-stage Dockerfile for DJI-Mapper Web Production Build
# Stage 1: Build Flutter web app
FROM debian:bullseye-slim AS flutter-build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Download and install Flutter SDK
ARG FLUTTER_VERSION=3.27.5
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

# Pre-download Flutter dependencies
RUN flutter precache --web

# Set working directory
WORKDIR /app

# Copy project files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source code
COPY packages ./packages
COPY lib ./lib
COPY assets ./assets

# Build web app for production
RUN flutter build web --release --web-renderer canvaskit

# Stage 2: Production web server
FROM nginx:alpine

# Copy built web assets from build stage
COPY --from=flutter-build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
