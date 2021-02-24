### BUILDER IMAGE ###
FROM ruby:2 as builder

COPY ./ ./build

RUN cd build \
	&& gem install bundler jekyll \
	&& bundle install \
	&& rake build

### PRODUCTION IMAGE ###
FROM nginx:alpine

COPY --from=builder build/_site /usr/share/nginx/html
