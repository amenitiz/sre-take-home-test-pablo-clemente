# Rails Test Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the known Rails test issue called out in the challenge.

**Architecture:** Reproduce the failing Rails test suite against local PostgreSQL, identify whether the failure is in test or application behavior, then make the smallest correction. The schema and migration define `services.status` default as `operational`, so the test assertion is corrected to match the intended default.

**Tech Stack:** Rails 8.1, Minitest, PostgreSQL via Docker Compose.

---

## Retrospective Status

Implemented in commit `b68d4d8`.

## File Structure

- Modify: `status-page/test/models/service_test.rb`: align default status expectation with schema.
- Read: `status-page/db/migrate/20250101000001_create_services.rb`: source of intended DB default.
- Read: `status-page/db/schema.rb`: generated schema confirming default.

### Task 1: Reproduce Failure

- [x] **Step 1: Start PostgreSQL**

Run:

```bash
cd status-page
docker compose up -d db
```

- [x] **Step 2: Prepare database**

Run:

```bash
bin/rails db:prepare
```

- [x] **Step 3: Run tests**

Run:

```bash
bin/rails test
```

Expected before fix:

```text
ServiceTest#test_default_status_is_operational
Expected: "maintenance"
Actual: "operational"
```

### Task 2: Confirm Root Cause

- [x] **Step 1: Inspect migration**

Confirm:

```ruby
t.string :status, null: false, default: "operational"
```

- [x] **Step 2: Inspect schema**

Confirm:

```ruby
t.string "status", default: "operational", null: false
```

### Task 3: Fix Test

- [x] **Step 1: Update assertion**

Change:

```ruby
assert_equal "maintenance", service.status
```

To:

```ruby
assert_equal "operational", service.status
```

### Task 4: Verify

- [x] **Step 1: Run Rails test suite**

Run:

```bash
cd status-page
bin/rails test
```

Expected after fix:

```text
17 runs, 38 assertions, 0 failures, 0 errors, 0 skips
```

