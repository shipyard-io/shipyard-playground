FROM nginx:alpine
COPY public/index.html /usr/share/nginx/html/index.html
COPY public/status.json /usr/share/nginx/html/status.json
EXPOSE 80
