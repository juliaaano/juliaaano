FROM nginx:alpine

MAINTAINER Juliano Boesel Mohr <juliaaano@gmail.com>

COPY _site /usr/share/nginx/html
