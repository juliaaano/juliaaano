### BUILDER IMAGE ###
FROM docker.io/ruby:2.7.4-bullseye as builder

RUN gem install bundler jekyll

COPY ./ ./build

RUN cd build && bundle install

RUN cd build && rake build

### PRODUCTION IMAGE ###
FROM docker.io/nginx:1.20.1-alpine

COPY --from=builder build/_site /usr/share/nginx/html
