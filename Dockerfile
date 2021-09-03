### BUILDER IMAGE ###
FROM docker.io/ruby:2.7.4-bullseye as builder

RUN gem install bundler jekyll

COPY Gemfile Gemfile.lock _config.yml /build/

RUN cd build && bundle install

COPY source /build/source/

RUN cd build && JEKYLL_ENV=production bundle exec jekyll build

### PRODUCTION IMAGE ###
FROM docker.io/nginx:1.20.1-alpine

ARG CREATED_AT=none
ARG GITHUB_SHA=none

LABEL org.opencontainers.image.created="$CREATED_AT"
LABEL org.opencontainers.image.revision="$GITHUB_SHA"

LABEL org.opencontainers.image.title="J Website"
LABEL org.opencontainers.image.description="Juliano's personal website and blog served by Nginx."
LABEL org.opencontainers.image.url="https://www.juliaaano.com"
LABEL org.opencontainers.image.source="git@github.com:juliaaano/juliaaano"
LABEL org.opencontainers.image.documentation="https://github/juliaaano/juliaaano"
LABEL org.opencontainers.image.authors="juliaaano"
LABEL org.opencontainers.image.vendor="juliaaano"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="1.0.0"

COPY --from=builder build/_site /usr/share/nginx/html
