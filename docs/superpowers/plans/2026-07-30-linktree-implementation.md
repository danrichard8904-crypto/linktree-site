# Personal Link Tree Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a single-page, self-hosted link tree (Astro static site) styled with Claude's DESIGN.md tokens, deployed free on GitHub Pages.

**Architecture:** One static Astro page, no backend, no client-side JS logic. Visual tokens hand-coded as scoped CSS matching the approved mockup. Four navigation links shipped as placeholder anchors, wired to real destinations later. Deployed via GitHub Actions to GitHub Pages.

**Tech Stack:** Astro (static output), plain CSS (Astro scoped `<style>`), GitHub Actions (`withastro/action` + `actions/deploy-pages`), GitHub Pages.

## Global Constraints

- Canvas color: `#faf9f5`
- Ink / CTA color: `#141413`
- Body text color: `#3d3d3a`
- Surface card color (avatar fill, badge background): `#efe9de`
- Hairline border color: `#e6dfd8`
- Muted-soft color (fine print): `#8e8b82`
- Display font stack: `Georgia, 'Tiempos Headline', 'Times New Roman', serif`
- Body/UI font stack: `Inter, -apple-system, 'Segoe UI', sans-serif`
- Required: `<meta name="viewport" content="width=device-width, initial-scale=1">`
- Links are `<a href="#">` tags styled as buttons — never `<button>` elements
- Exactly 4 links, in this order: Book an Appointment, Instagram, TikTok, Text Me
- Static site only — no backend, no server-rendered routes
- Project root: `C:\Users\Stati\linktree-site`
- Git default branch in this repo: `master` (already created, confirmed via `git log`)
- GitHub account: `danrichard8904-crypto` (CLI already authenticated, `repo`+`workflow` scopes)
- Target repo name: `linktree-site` (does not exist on GitHub yet — created in Task 3)
- Live URL once deployed: `https://danrichard8904-crypto.github.io/linktree-site/`

---

### Task 1: Scaffold Astro project and build the page

**Files:**
- Create: `package.json`
- Create: `astro.config.mjs`
- Create: `src/pages/index.astro`
- Create: `verify-page.sh`

**Interfaces:**
- Consumes: nothing (first task)
- Produces: `dist/index.html` (built output, consumed by Task 2's deploy workflow and Task 3's live-site verification). Produces npm scripts `dev`, `build`, `preview` in `package.json`, consumed by Task 2's GitHub Actions workflow (`withastro/action` runs `npm run build` internally by convention, but explicitly relies on a `build` script existing).

- [ ] **Step 1: Confirm Node and npm are available**

Run: `node --version && npm --version`
Expected: two version numbers printed (Node 18.17+ or 20.3+ required by Astro). If this fails, stop — Node must be installed before continuing.

- [ ] **Step 2: Initialize package.json**

Run (from `C:\Users\Stati\linktree-site`):
```bash
npm init -y
```
Expected: `package.json` created with default fields.

- [ ] **Step 3: Install Astro**

Run:
```bash
npm install astro
```
Expected: `astro` added to `dependencies` in `package.json`; `node_modules/` and `package-lock.json` created. No errors.

- [ ] **Step 4: Add npm scripts**

Run:
```bash
npm pkg set scripts.dev="astro dev" scripts.build="astro build" scripts.preview="astro preview"
```
Expected: `package.json`'s `"scripts"` block now contains `dev`, `build`, `preview` keys mapping to the commands above.

- [ ] **Step 5: Write the verification script (before the page exists — this must fail first)**

Create `verify-page.sh`:
```bash
#!/usr/bin/env bash
set -e
FILE="dist/index.html"
test -f "$FILE" || { echo "FAIL: $FILE does not exist"; exit 1; }
grep -q 'name="viewport"' "$FILE" || { echo "FAIL: missing viewport meta"; exit 1; }
grep -q '#141413' "$FILE" || { echo "FAIL: missing ink/CTA color"; exit 1; }
grep -q '#faf9f5' "$FILE" || { echo "FAIL: missing cream canvas color"; exit 1; }
if grep -q '<button' "$FILE"; then echo "FAIL: found <button> element, links must be <a> tags"; exit 1; fi
LINK_COUNT=$(grep -o 'href="#"' "$FILE" | wc -l)
[ "$LINK_COUNT" -eq 4 ] || { echo "FAIL: expected 4 placeholder links, found $LINK_COUNT"; exit 1; }
grep -q "Book an Appointment" "$FILE" || { echo "FAIL: missing Book an Appointment"; exit 1; }
grep -q "Instagram" "$FILE" || { echo "FAIL: missing Instagram"; exit 1; }
grep -q "TikTok" "$FILE" || { echo "FAIL: missing TikTok"; exit 1; }
grep -q "Text Me" "$FILE" || { echo "FAIL: missing Text Me"; exit 1; }
echo "PASS: all checks passed"
```

- [ ] **Step 6: Run verification to confirm it fails (no page built yet)**

Run: `bash verify-page.sh`
Expected: `FAIL: dist/index.html does not exist` (exit code 1). This confirms the check actually exercises something real before we write the page.

- [ ] **Step 7: Create astro.config.mjs**

```javascript
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://danrichard8904-crypto.github.io',
  base: '/linktree-site',
});
```

- [ ] **Step 8: Create src/pages/index.astro**

```astro
---
---
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Dan — Barber / Stylist</title>
  </head>
  <body>
    <main class="card">
      <div class="avatar"></div>
      <h1 class="name">Dan</h1>
      <span class="badge">Barber / Stylist</span>
      <p class="bio">Booth renter · walk-ins by appointment only</p>
      <nav class="links">
        <a href="#" class="btn btn-primary">Book an Appointment</a>
        <a href="#" class="btn btn-secondary">Instagram</a>
        <a href="#" class="btn btn-secondary">TikTok</a>
        <a href="#" class="btn btn-secondary">Text Me</a>
      </nav>
    </main>
  </body>
</html>

<style>
  :global(body) {
    margin: 0;
    background: #faf9f5;
    font-family: Inter, -apple-system, 'Segoe UI', sans-serif;
    display: flex;
    justify-content: center;
  }
  .card {
    width: 100%;
    max-width: 420px;
    min-height: 100vh;
    padding: 48px 28px 32px;
    display: flex;
    flex-direction: column;
    align-items: center;
    box-sizing: border-box;
  }
  .avatar {
    width: 88px;
    height: 88px;
    border-radius: 50%;
    background: #efe9de;
    border: 1px solid #e6dfd8;
    margin-bottom: 16px;
  }
  .name {
    font-family: Georgia, 'Tiempos Headline', 'Times New Roman', serif;
    font-size: 28px;
    font-weight: 400;
    letter-spacing: -0.3px;
    color: #141413;
    margin: 0;
    text-align: center;
  }
  .badge {
    margin-top: 8px;
    padding: 4px 12px;
    background: #efe9de;
    color: #141413;
    font-size: 12px;
    font-weight: 500;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    border-radius: 9999px;
  }
  .bio {
    margin-top: 14px;
    font-size: 14px;
    line-height: 1.55;
    color: #3d3d3a;
    text-align: center;
  }
  .links {
    width: 100%;
    margin-top: 28px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  .btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 44px;
    border-radius: 8px;
    font-family: Inter, sans-serif;
    font-size: 14px;
    font-weight: 500;
    text-decoration: none;
    box-sizing: border-box;
  }
  .btn-primary {
    background: #141413;
    color: #fff;
  }
  .btn-secondary {
    background: #faf9f5;
    color: #141413;
    border: 1px solid #e6dfd8;
  }
</style>
```

- [ ] **Step 9: Build the site**

Run: `npm run build`
Expected: exits 0, prints an Astro build summary, creates `dist/index.html`.

- [ ] **Step 10: Run verification to confirm it now passes**

Run: `bash verify-page.sh`
Expected: `PASS: all checks passed` (exit code 0).

- [ ] **Step 11: Commit**

```bash
git add package.json package-lock.json astro.config.mjs src/pages/index.astro verify-page.sh
git commit -m "Add Astro link tree page with placeholder links"
```

---

### Task 2: GitHub Pages deployment workflow

**Files:**
- Create: `.github/workflows/deploy.yml`

**Interfaces:**
- Consumes: `package.json`'s `build` script and `dist/` output from Task 1 (the `withastro/action` step runs the build internally using these).
- Produces: a GitHub Actions workflow triggered on push to `master`, consumed by Task 3 (pushing to `master` fires this workflow, which must succeed for the live site to exist).

- [ ] **Step 1: Create the workflow file**

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [master]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Install, build, and upload your site
        uses: withastro/action@v3

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 2: Structural sanity check**

Run:
```bash
grep -q "^on:" .github/workflows/deploy.yml && \
grep -q "^jobs:" .github/workflows/deploy.yml && \
grep -q "^permissions:" .github/workflows/deploy.yml && \
grep -q "withastro/action" .github/workflows/deploy.yml && \
grep -q "actions/deploy-pages" .github/workflows/deploy.yml && \
echo "STRUCTURE OK"
```
Expected: `STRUCTURE OK`. This is a lightweight sanity check for required top-level keys and actions, not full YAML validation — no YAML parser is installed in this project and adding one solely for this check would be unjustified scope. The real, authoritative validation happens in Task 3 Step 4, where GitHub Actions parses this file for real and fails loudly if it's malformed.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Pages deployment workflow"
```

---

### Task 3: Create the GitHub repo, enable Pages, deploy, and verify live

**Files:**
- None created locally — this task operates on GitHub's API/remote state via `gh`.

**Interfaces:**
- Consumes: the full committed repo from Tasks 1-2 (`git log` on `master` must contain both prior commits).
- Produces: a live URL (`https://danrichard8904-crypto.github.io/linktree-site/`) serving the built `dist/index.html` content — the final deliverable of this plan.

- [ ] **Step 1: Create the GitHub repo and add it as remote**

Run (from `C:\Users\Stati\linktree-site`):
```bash
gh repo create linktree-site --public --source=. --remote=origin
```
Expected: prints the new repo URL `https://github.com/danrichard8904-crypto/linktree-site`, adds `origin` remote.

- [ ] **Step 2: Push to GitHub**

Run:
```bash
git push -u origin master
```
Expected: pushes all 3 local commits (spec, spec fix, Task 1 commit — plus Task 2's commit once made) to `origin/master`. No errors.

- [ ] **Step 3: Enable GitHub Pages with GitHub Actions as the build source**

Run:
```bash
gh api -X POST repos/danrichard8904-crypto/linktree-site/pages -f build_type=workflow
```
Expected: JSON response describing the new Pages site, `"build_type": "workflow"`. (If this returns a 409/"already exists" error, Pages is already enabled — that's fine, continue.)

- [ ] **Step 4: Watch the deployment workflow run to completion**

Run:
```bash
gh run list --limit 1
```
Note the run ID from the output, then:
```bash
gh run watch <run-id>
```
Expected: workflow reaches `completed success`. If it fails, run `gh run view <run-id> --log-failed` to see the exact error before proceeding — do not continue to Step 5 on a failed run.

- [ ] **Step 5: Verify the live site**

Run:
```bash
curl -s https://danrichard8904-crypto.github.io/linktree-site/ -o live-check.html
grep -q "Book an Appointment" live-check.html && grep -q "#141413" live-check.html && grep -q 'name="viewport"' live-check.html && echo "LIVE SITE VERIFIED" || echo "LIVE SITE CHECK FAILED"
rm live-check.html
```
Expected: prints `LIVE SITE VERIFIED`. If GitHub Pages hasn't finished propagating yet (can take 1-2 minutes after a successful workflow run), wait and retry rather than treating an immediate 404 as a failure.

---

## Post-Plan Note

All four links remain `href="#"` after this plan completes — this is the intended shipped state per the spec, not a follow-up task. Wiring each link to its real destination (booking app URL, Instagram handle, TikTok handle, phone number) happens incrementally later, one small edit + commit + push at a time, as each destination becomes available.
