### BUILDER IMAGE ###
FROM ruby:2.5.3 as builder

COPY ./ ./build

RUN cd build \
	&& gem install jekyll bundler \
	&& bundle install \
	&& rake build

### PRODUCTION IMAGE ###
FROM nginx:alpine

COPY --from=builder build/_site /usr/share/nginx/html
