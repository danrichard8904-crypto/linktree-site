# Link Tree Redesign — Design Spec

## Overview

A visual redesign of both live pages (home link-tree, portfolio) for Dan (@Reppstory), pulling the site's design tokens from a wider slice of the same source system already in use (`VoltAgent/awesome-design-md`, `design-md/claude/DESIGN.md`) instead of the narrow cream/black subset adopted at launch. Two moodboard references supplied the specific ideas cherry-picked below: a dark link-in-bio with a lime CTA and social icon row, and a Canva template with a photo-bleed background behind the phone frame. Both pages keep their current HTML/CSS/JS mechanics (Astro pages, dual-buffer video crossfade, stagger-in animations, 3D hard-shadow button press) — this spec changes color, layout hierarchy, and per-page theme, not the underlying implementation approach.

**Explicit direction from the user:** the two pages should look "a little bit different" from each other, not identical reskins — home page stays light, portfolio page goes dark. One accent color threads both pages together as the same brand.

## Visual Design

### Extended token set

Adds to the existing subset (canvas, ink, body, surface-card, hairline, muted-soft — unchanged, still used on the home page) from the same source doc:

| Token | Value | Use |
|---|---|---|
| `accent-amber` | `#e8a55a` | New brand accent — primary CTA fill, icon-row hover ring, portfolio tag borders |
| `surface-dark` | `#181715` | Portfolio page background |
| `surface-dark-elevated` | `#252320` | Portfolio bio-section card background |
| `surface-dark-soft` | `#1f1e1b` | Portfolio grid gap/tile background (replaces `surface-card` on that page only) |
| `on-dark` | `#faf9f5` | Portfolio page primary text (name, bio) |
| `on-dark-soft` | `#a09d96` | Portfolio page secondary text (subtitle, handle, footer link) |

No other tokens from the source doc (teal, success/warning/error, the dark-mode-only component variants not listed above) are adopted — out of scope, unused by either page's content.

### Home page (`index.astro`) — stays light

**Hero band:** a portfolio photo (implementation picks which one — not a design decision) sits behind the avatar/name/badge/bio as a background image, blurred and dimmed (dark scrim overlay, ~55-65% opacity ink) so the existing cream-canvas text remains legible on top of it. The hero band's bottom edge fades into flat `canvas` (`#faf9f5`) via a gradient mask, so the button stack below still sits on the plain cream background exactly as today.

**Avatar/name/badge/bio:** unchanged content and typography, now rendered over the hero band instead of flat cream.

**Social row (new):** Instagram and TikTok drop from full-width pill buttons to small circular icon buttons (36-40px, matching the source doc's `button-icon-circular` component), laid out in a horizontal row under the bio. Default state: `canvas` background, `ink` icon. Hover: `accent-amber` ring/border appears around the circle.

**Primary CTA:** "Hair Portfolio" is the only full-width pill button remaining. Fill changes from `ink` black to `accent-amber`, text changes from white to `ink` black (for contrast on the amber fill). Keeps the existing hard-shadow 3D press mechanic (`translate` + `box-shadow` offset on hover/active) — shadow color changes from the current warm-brown/black pairing to solid `ink` (`#141413`), which reads cleanly against the amber fill.

**Desktop preview panel:** unchanged mechanically (2×2 photo/video grid, ≥860px breakpoint) — no redesign requested for that panel specifically, it inherits the page's light theme as-is.

### Portfolio page (`portfolio.astro`) — switches to dark

**Page background:** `surface-dark` (`#181715`) replaces `canvas` for the whole page.

**Header:** back-link and name/subtitle text recolor to `on-dark` / `on-dark-soft`. "Book" button switches from `ink`-black fill to `accent-amber` fill with `ink` text — same CTA treatment as the home page button, this is the visual thread tying the two pages together.

**Grid:** same 3×2 layout, same dual-buffer crossfade loop script and stagger pop-in animation — untouched mechanically. Tile background and grid gap color change from `surface-card` (cream) to `surface-dark-soft`, so photos/videos read against near-black instead of cream.

**Bio section:** card background becomes `surface-dark-elevated`. Avatar placeholder circle gets an `accent-amber` border ring (currently a plain hairline border). Name/handle/body text recolor to `on-dark` / `on-dark-soft`. The four tag pills (Fades, Tapers, etc.) switch from cream-fill/hairline-border to transparent-fill/`accent-amber`-border with `on-dark` text.

**Footer:** "Book an Appointment" full-width button switches to the same `accent-amber` fill / `ink` text / hard-shadow treatment as the home page CTA. "@Reppstory on Instagram" link recolors to `on-dark-soft`, hover `on-dark`.

## Components carried over unchanged

- Hard-shadow 3D button press (translate + offset box-shadow on hover/active) — mechanic stays, only fill/shadow colors change per the sections above.
- Dual-buffer video crossfade loop (two stacked `<video>` elements per slot, hidden twin absorbs the seek) — no changes, this is the working fix from the prior session.
- CSS-only stagger-in animations on both pages (`rise` on home, `pop-in` on portfolio) — no changes.
- Astro page structure, GitHub Pages deployment, `/linktree-site` base path — no changes.

## Out of Scope

- Cursive/signature name treatment (considered, explicitly rejected — keeping the serif).
- Full adoption of every token in the source `claude/DESIGN.md` (teal/success/warning/error colors, dark-mode component variants beyond what's listed above) — unused by either page.
- Any change to the booking-app project or its own design spec — separate project, not touched by this redesign.
- Choosing the specific photo for the home page hero bleed — implementation-time asset decision, any current portfolio photo works.
- Analytics, new pages, or new content sections beyond the visual/theme changes above.

## Open Items

None blocking. All decisions above were confirmed during brainstorming (accent color, name treatment, hero background, button hierarchy, portfolio theme, CTA boldness).
