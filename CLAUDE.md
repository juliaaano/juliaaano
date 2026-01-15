# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog and website (www.juliaaano.com) built with Jekyll and hosted on GitHub Pages.

## Common Commands

All commands use Rake tasks defined in `Rakefile`:

```bash
# Install dependencies
bundle install

# Local development server with drafts and live reload
rake serve

# Build Tailwind CSS only
rake tailwind_build

# Clean generated site
rake clean

# Validate HTML with html-proofer (run after build)
rake proofer
```

## Architecture

- **Jekyll static site generator** with Ruby 3.4.4
- **Tailwind CSS v4** for styling - compiled from `source/assets/css/input.css` to `main.css`
- **Source directory**: `source/` contains all site content
  - `_posts/` - Blog posts organized by year subdirectories (e.g., `2017/`, `2021/`)
  - `_layouts/` - Page templates (default → compress for HTML minification)
  - `_includes/` - Reusable HTML partials and SVG icons
- **Configuration**: `_config.yml` defines site settings, plugins, and CDN URLs
- **Output**: `_site/` (generated, not committed)

## Build Pipeline

`rake serve` runs Tailwind watcher in background while Jekyll serves with live reload. The Tailwind CLI is auto-downloaded on first run based on platform.

## Deployment

CI/CD via GitHub Actions (`.github/workflows/ci-cd.yml`):
1. Builds multi-arch (amd64/arm64) container image using `Containerfile`
2. Pushes to ghcr.io
3. Deploys to GitHub Pages on push to master

## Container

```bash
# Run locally with Podman/Docker
podman run --rm -p 50080:80 ghcr.io/juliaaano/juliaaano:latest
```

## Documentation References

Always use context7 for referencing library and sources documentation.
