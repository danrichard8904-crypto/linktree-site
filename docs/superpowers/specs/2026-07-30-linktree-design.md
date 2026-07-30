# Personal Link Tree — Design Spec

## Overview

A single-page personal link tree for a booth-renting hairstylist/barber, replacing a paid Linktree-style subscription with a self-owned, self-hosted page. Full ownership, no monthly fee, no watermark.

## Content & Structure

Single screen, no scroll on mobile:

1. Avatar circle (placeholder image slot)
2. Name (serif display)
3. Role badge — "Barber / Stylist" pill
4. One-line bio — e.g. "Booth renter · walk-ins by appointment only"
5. Four link buttons, stacked, in this order:
   - **Book an Appointment** (primary button)
   - **Instagram** (secondary button)
   - **TikTok** (secondary button)
   - **Text Me** (secondary button)

**All four are `<a href="#">` tags styled as buttons, not `<button>` elements** — the mockup used `<button>` for the static visual, but real navigation (opening Instagram, dialing a phone, linking to the booking app) requires anchor tags. Placeholder `href="#"` at launch. None of the real destinations (booking app URL, Instagram handle, TikTok handle, phone number) exist yet or were provided. Links are wired up incrementally, one at a time, as each destination becomes available — this is an explicit, intentional launch state, not a gap to fill before shipping.

## Visual Design

Sourced from `design-md/claude/DESIGN.md` (VoltAgent/awesome-design-md), with one deviation: the signature coral CTA is replaced with the system's own ink-black token, per user preference.

| Token | Value | Use |
|---|---|---|
| Canvas | `#faf9f5` | Page background (warm cream, not pure white) |
| Ink | `#141413` | Text color; **also used for the primary CTA background** (deviation from source coral `#cc785c`) |
| Body | `#3d3d3a` | Bio/secondary text |
| Surface card | `#efe9de` | Avatar placeholder fill, role badge background |
| Hairline | `#e6dfd8` | Secondary button borders |
| Muted soft | `#8e8b82` | Footer/fine-print text |

**Typography:**
- Display name: serif, weight 400, negative letter-spacing (`-0.3px`). Font stack: `Georgia, 'Tiempos Headline', 'Times New Roman', serif` (Copernicus/Tiempos are Anthropic-licensed, not public — this is the documented open substitute).
- Body/UI/buttons: `Inter, -apple-system, 'Segoe UI', sans-serif`, weight 400–500.

**Components:**
- Primary button: `#141413` background, white text, `8px` border radius, `44px` height.
- Secondary button: `#faf9f5` background, `#141413` text, `1px solid #e6dfd8` border, same radius/height as primary.
- Role badge: pill shape (`border-radius: 9999px`), `#efe9de` background, uppercase caption type.

Reference mockup: `docs/superpowers/specs/2026-07-30-linktree-mockup.html` (built and approved during brainstorming, phone-frame preview at 390×760 — open directly in a browser to view).

## Mobile Requirement

This is a phone-first page (that's how it'll actually be viewed — in a bio link). The page **must** include `<meta name="viewport" content="width=device-width, initial-scale=1">`. Without it, mobile browsers render at desktop width and the single-column layout breaks.

## Technical Approach

**Astro**, single static page, no backend, no server-side logic.

Chosen over plain static HTML/CSS (the simpler option for a page this size) because the user is also building a Next.js-based booking app with Stripe deposits. Astro supports React component islands, making it easier to later share the visual design tokens (or actual components) between this page and the booking app's frontend than starting from raw HTML would allow. This is the one deliberate complexity trade in an otherwise minimal-scope project — accepted for that specific future-sharing reason, not as a default preference.

## Hosting & Deployment

- **GitHub Pages**, free tier, no custom domain at launch.
- GitHub CLI is already authenticated (`danrichard8904-crypto`, `repo`+`workflow` scopes) — no new account setup needed.
- URL will be the default `github.io` subdomain (exact path TBD at implementation time based on repo name).
- Custom domain can be added later via GitHub Pages' custom-domain setting without any rebuild — deferred, not blocking.

## Out of Scope

- The booking app itself (separate project, separate design/build cycle).
- Real link destinations (Instagram handle, TikTok handle, phone number, booking URL) — added incrementally post-launch.
- Analytics / click tracking.
- Additional pages (portfolio gallery, etc.) — this spec covers one page only.
- Custom domain purchase/setup.

## Open Items For Implementation

None blocking. The four placeholder links are an accepted launch state per the user's explicit instruction ("just make it empty, we'll connect every endpoint as we go"), not a TODO to resolve before shipping.
