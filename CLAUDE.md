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

# Production build
rake build

# Clean generated site
rake clean

# Validate HTML with html-proofer (run after build)
rake proofer
```

## Architecture

- **Jekyll static site generator** with Ruby 3.2.1
- **Source directory**: `source/` contains all site content
  - `_posts/` - Blog posts organized by year subdirectories (e.g., `2017/`, `2021/`)
  - `_layouts/` - Page templates (default, post, page, compress)
  - `_includes/` - Reusable HTML partials
  - `_sass/` - SCSS stylesheets
- **Configuration**: `_config.yml` defines site settings, plugins, and CDN URLs
- **Output**: `_site/` (generated, not committed)

## Deployment

CI/CD via GitHub Actions (`.github/workflows/ci-cd.yml`):
1. Builds container image using `Containerfile`
2. Pushes to ghcr.io
3. Deploys to GitHub Pages on push to master

## Container

```bash
# Run locally with Podman/Docker
podman run --rm -p 50080:80 ghcr.io/juliaaano/juliaaano:latest
```
