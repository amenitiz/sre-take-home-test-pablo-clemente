# Production Dockerfile Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the starter Rails Dockerfile with a production-oriented image while keeping runtime startup simple.

**Architecture:** The Dockerfile uses a shared Ruby base, a build stage with compiler dependencies, and a runtime stage with only runtime packages. Bundler installs production gems only, Rails assets are precompiled with a dummy secret, and the final container runs Puma as a non-root `app` user.

**Tech Stack:** Docker, Ruby 3.3.6 slim image, Rails, Bundler, Propshaft, Puma.

---

## Retrospective Status

Implemented locally but not yet committed.

## File Structure

- Modify: `status-page/Dockerfile`: multi-stage production image.
- Create: `status-page/.dockerignore`: reduce Docker build context and avoid local/env files.

### Task 1: Define Dockerfile Contract

- [x] **Step 1: Verify old Dockerfile lacks production properties**

Run:

```bash
ruby -e 's = File.read("status-page/Dockerfile"); checks = {"multi-stage" => s.include?(" AS "), "non-root user" => s.match?(/USER\s+/), "production env" => s.include?("RAILS_ENV=production"), "asset precompile" => s.include?("assets:precompile")}; failed = checks.select { |_k, v| !v }; abort("missing: #{failed.keys.join(", ")}") unless failed.empty?'
```

Expected before implementation:

```text
missing: multi-stage, non-root user, production env, asset precompile
```

### Task 2: Replace Dockerfile

- [x] **Step 1: Add shared base stage**

Use:

```dockerfile
ARG RUBY_VERSION=3.3.6
FROM ruby:${RUBY_VERSION}-slim AS base
ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1
WORKDIR /app
```

- [x] **Step 2: Add build stage**

Install build dependencies, run `bundle install`, copy app files, and run:

```dockerfile
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
```

- [x] **Step 3: Add runtime stage**

Install only `curl` and `libpq5`, create `app` user, copy app and gems from build stage, and set:

```dockerfile
USER app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

### Task 3: Add Dockerignore

- [x] **Step 1: Exclude local-only paths**

Create `status-page/.dockerignore` with:

```text
.bundle
.env
.env.*
.git
log/*
tmp/*
!.keep
node_modules
storage/*
coverage
```

### Task 4: Verify

- [x] **Step 1: Run Dockerfile contract check**

Confirm multi-stage build, non-root user, production env, asset precompile, and unchanged Puma command.

- [x] **Step 2: Build image**

Run:

```bash
docker build -t status-page:dockerfile-check status-page
```

Expected: build completes and writes precompiled assets.

- [x] **Step 3: Inspect runtime user**

Run:

```bash
docker image inspect status-page:dockerfile-check --format '{{.Config.User}}'
docker run --rm --entrypoint id status-page:dockerfile-check -un
```

Expected:

```text
app
app
```

- [x] **Step 4: Inspect runtime env**

Run:

```bash
docker run --rm --entrypoint ruby status-page:dockerfile-check -e 'puts ENV.values_at("RAILS_ENV", "BUNDLE_WITHOUT", "RAILS_SERVE_STATIC_FILES").join(" ")'
```

Expected:

```text
production development:test 1
```

