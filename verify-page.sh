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
