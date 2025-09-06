FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY index.html index.html
COPY images/ images/
EXPOSE 80
