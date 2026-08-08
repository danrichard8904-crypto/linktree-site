#!/usr/bin/env bash
#
# verify-page.sh — BUILD-ARTIFACT gate for danrichard8904-crypto/linktree-site
#
# INSTALL TO: <repo-root>/verify-page.sh   (replaces the existing file verbatim)
#
# SCOPE — read this before trusting a PASS:
#   This script verifies the LOCAL build only. `dist/` is gitignored
#   (.gitignore line 3) and is NEVER the deployed artifact. A PASS here means
#   "the thing I just built is not obviously broken". It does NOT mean the live
#   site changed. The deploy Definition of Done is verify-live.sh.
#
# NEVER edit this file to make it pass. If the gate is red, the tree is wrong,
# not the gate. (Self-check: `./verify-page.sh --sha` prints this file's
# sha256 so a caller outside the agent's write roots can pin it.)
#
# WHAT CHANGED vs the previous version, and why (all measured 2026-08-07):
#   1. `-eq 3` -> `-le "${MAX_PLACEHOLDERS:-1}"`.
#      Measured: dist/index.html and the LIVE page each contain exactly 1
#      `href="#"`. The old assert failed on CORRECT work and rewarded a model
#      for ADDING two dead links back to turn the gate green.
#      Default is 1 (the measured current value), NOT 3. A ceiling of 3 against
#      a measured 1 hands back two units of free regression.
#   2. `rm -rf dist && npm run build` moved INSIDE the gate.
#      The old gate graded whatever dist/ happened to be on disk. Edit src/,
#      skip the build, gate greps the PREVIOUS build and passes. That is the
#      L-005 lying-SLI shape: the criterion is graded against input the change
#      never touched.
#   3. `dist/portfolio/index.html` is now asserted.
#      /linktree-site/portfolio/ is live (measured http=200). The old gate could
#      not see it: a model could delete the portfolio page and read "PASS".
#   4. `grep -o` -> `grep -oa`.
#      Astro emits single-line minified HTML. If grep binary-detects the file,
#      `grep -o | wc -l` returns 1 regardless of the true count — a silently
#      wrong number inside the gate's own arithmetic.
#   5. Required labels "Book an Appointment" and "Text Me" REMOVED from the
#      default set. Measured: both are absent from dist/index.html AND absent
#      from the LIVE deployed page. The gate was asserting a design the site no
#      longer implements, so it demanded the model re-add deleted content.
#      Re-add them via REQUIRED_LABELS when the site actually ships them.
#   6. Minimum byte floor on dist/index.html — kills the "empty artifact passes
#      every grep-absence check" class.
#   7. PATH hardened for ~/.local/bin (measured: node v22.22.2 / npm 10.9.7 live
#      at /home/aistation1/.local/bin on the WSL host, NOT on a non-login PATH).
#
# ENV OVERRIDES (ratchets — tighten freely, loosening requires a change record):
#   MAX_PLACEHOLDERS   default 1     max allowed `href="#"` in dist/index.html
#   REQUIRED_LABELS    default 'Instagram|TikTok|Hair Portfolio'   pipe-delimited
#   MIN_INDEX_BYTES    default 1000
#
# EXIT CODES: 0 = pass. 1 = a content/build assertion failed. Any other code
# comes from bash itself and must be treated as a FAILURE, never as a pass.

set -euo pipefail

# --- environment ------------------------------------------------------------
# `npm: command not found` under `set -e` aborts with 127, which an unwary
# caller reads as "some error" rather than "the gate never ran".
export PATH="$HOME/.local/bin:$PATH"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

if [ "${1:-}" = "--sha" ]; then
  sha256sum "${BASH_SOURCE[0]}"
  exit 0
fi

MAX_PLACEHOLDERS="${MAX_PLACEHOLDERS:-1}"
MIN_INDEX_BYTES="${MIN_INDEX_BYTES:-1000}"
REQUIRED_LABELS="${REQUIRED_LABELS:-Instagram|TikTok|Hair Portfolio}"

INDEX="dist/index.html"
PORTFOLIO="dist/portfolio/index.html"

fail() { echo "FAIL: $*" >&2; exit 1; }

command -v npm >/dev/null 2>&1 \
  || fail "npm not on PATH (looked in \$HOME/.local/bin and \$PATH). The gate did not run — this is NOT a pass."

# --- 1. FRESHNESS: the artifact must be built from the tree as it is NOW -----
rm -rf dist
BUILD_LOG="$(mktemp)"
if ! npm run build >"$BUILD_LOG" 2>&1; then
  echo "----- npm run build, last 40 lines -----" >&2
  tail -40 "$BUILD_LOG" >&2
  rm -f "$BUILD_LOG"
  fail "npm run build exited non-zero — there is no artifact to verify."
fi
rm -f "$BUILD_LOG"

# --- 2. EXISTENCE ------------------------------------------------------------
test -f "$INDEX"     || fail "$INDEX does not exist after a successful build."
test -f "$PORTFOLIO" || fail "$PORTFOLIO missing from build — the portfolio page is LIVE (http 200) and must not disappear."

INDEX_BYTES=$(wc -c <"$INDEX" | tr -d ' ')
PORTFOLIO_BYTES=$(wc -c <"$PORTFOLIO" | tr -d ' ')

# An empty artifact satisfies every "must NOT contain" check for free.
[ "$INDEX_BYTES" -ge "$MIN_INDEX_BYTES" ] \
  || fail "$INDEX is $INDEX_BYTES bytes (floor $MIN_INDEX_BYTES). A near-empty build must not pass."
[ "$PORTFOLIO_BYTES" -ge "$MIN_INDEX_BYTES" ] \
  || fail "$PORTFOLIO is $PORTFOLIO_BYTES bytes (floor $MIN_INDEX_BYTES)."

# --- 3. STRUCTURE ------------------------------------------------------------
grep -qa 'name="viewport"' "$INDEX"     || fail "missing viewport meta in $INDEX"
grep -qa 'name="viewport"' "$PORTFOLIO" || fail "missing viewport meta in $PORTFOLIO"
grep -qa '#141413' "$INDEX"             || fail "missing ink/CTA color #141413"
grep -qa '#faf9f5' "$INDEX"             || fail "missing cream canvas color #faf9f5"

if grep -qa '<button' "$INDEX"; then
  fail "found <button> in $INDEX — links must be <a> tags"
fi

# --- 4. PLACEHOLDER RATCHET (monotonic, never exact) -------------------------
# Must fail on REGRESSION, never on PROGRESS. Wiring a placeholder is correct
# work and must not turn the gate red.
PLACEHOLDER_COUNT=$(grep -oa 'href="#"' "$INDEX" | wc -l | tr -d ' ')
[ "$PLACEHOLDER_COUNT" -le "$MAX_PLACEHOLDERS" ] \
  || fail "placeholder links rose to $PLACEHOLDER_COUNT (ceiling $MAX_PLACEHOLDERS). Adding dead href=\"#\" links to satisfy a gate is a regression, not a fix."

# --- 5. CONTENT --------------------------------------------------------------
grep -qa 'href="https://www.instagram.com/Reppstory/"' "$INDEX" \
  || fail "Instagram link not wired to https://www.instagram.com/Reppstory/"

MISSING_LABELS=""
IFS='|' read -r -a _LABELS <<<"$REQUIRED_LABELS"
for label in "${_LABELS[@]}"; do
  [ -n "$label" ] || continue
  grep -qa -- "$label" "$INDEX" || MISSING_LABELS="${MISSING_LABELS}${label}; "
done
[ -z "$MISSING_LABELS" ] || fail "required labels missing from $INDEX: ${MISSING_LABELS%; }"

# --- 6. PASS -----------------------------------------------------------------
# Print the measured numbers. A gate that prints only "PASS" cannot be audited
# after the fact, and cannot be distinguished from a gate that skipped its body.
echo "PASS: verify-page.sh"
echo "  index=$INDEX ${INDEX_BYTES}B  portfolio=$PORTFOLIO ${PORTFOLIO_BYTES}B"
echo "  placeholders=$PLACEHOLDER_COUNT/${MAX_PLACEHOLDERS}  labels_ok=${REQUIRED_LABELS}"
echo "  index_sha256=$(sha256sum "$INDEX" | cut -c1-16)"
echo "  NOTE: this graded a LOCAL build. The live site has NOT been verified."
echo "        Deploy DoD = ./verify-live.sh <canary> <base-gh-pages-sha> <base-live-sha256>"
exit 0
