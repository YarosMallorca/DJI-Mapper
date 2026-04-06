FROM nginx:alpine

COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Run with: docker run -d -p 8090:80 --name dji-mapper dji-mapper:latest

CMD ["nginx", "-g", "daemon off;"]
