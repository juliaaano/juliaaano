### BUILDER IMAGE ###
FROM docker.io/ruby:3.4.4-bookworm as builder

# Download Tailwind CLI
ARG TAILWIND_VERSION=4.1.18
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
        amd64) tailwind_arch="x64" ;; \
        arm64) tailwind_arch="arm64" ;; \
        *) echo "Unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    curl -sLO "https://github.com/tailwindlabs/tailwindcss/releases/download/v${TAILWIND_VERSION}/tailwindcss-linux-${tailwind_arch}"; \
    chmod +x "tailwindcss-linux-${tailwind_arch}"; \
    mv "tailwindcss-linux-${tailwind_arch}" /usr/local/bin/tailwindcss

RUN gem install bundler jekyll

COPY Gemfile Gemfile.lock _config.yml /build/

RUN cd build && bundle install

COPY source /build/source/

# Build Tailwind CSS then Jekyll
RUN cd build && tailwindcss -i source/assets/css/input.css -o source/assets/css/main.css --minify
RUN cd build && JEKYLL_ENV=production bundle exec jekyll build

### PRODUCTION IMAGE ###
FROM docker.io/nginx:1.28-alpine

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
