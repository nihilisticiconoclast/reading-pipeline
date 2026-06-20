#!/usr/bin/env bash
#
# Fetch book-cover images for the reading-pipeline digests.
#
# Covers come from the Open Library Covers API (free, no key, read-only):
#   search:  https://openlibrary.org/search.json
#   image:   https://covers.openlibrary.org/b/id/<cover_id>-L.jpg
#
# REQUIRES network egress to:  openlibrary.org  and  covers.openlibrary.org
# (add both to the environment's network egress allowlist). If a host is
# blocked the proxy returns 403 "host_not_allowed" and the cover is skipped,
# leaving the digest's placeholder.svg fallback in place.
#
# Usage:
#   scripts/fetch-covers.sh                 # fetch the built-in book list
#   scripts/fetch-covers.sh books.tsv       # fetch from a TSV: slug<TAB>title<TAB>author
#
# Already-present valid covers are skipped, so it is safe to re-run.

set -uo pipefail
cd "$(dirname "$0")/.."
DEST="assets/covers"
UA="reading-pipeline/1.0 (+https://github.com/nihilisticiconoclast/reading-pipeline)"
mkdir -p "$DEST"

# Built-in list: slug | title | author  (slug = cover filename without .jpg)
read -r -d '' BOOKS <<'EOF'
season-of-migration-to-the-north|Season of Migration to the North|Tayeb Salih
the-sixth-extinction|The Sixth Extinction An Unnatural History|Elizabeth Kolbert
the-enigma-of-reason|The Enigma of Reason|Hugo Mercier
small-gods|Small Gods|Terry Pratchett
the-big-sleep|The Big Sleep|Raymond Chandler
the-forever-war|The Forever War|Joe Haldeman
EOF

# If a TSV file is passed, use it instead (tabs -> the | separator we expect).
if [ "${1:-}" != "" ] && [ -f "$1" ]; then
  BOOKS="$(tr '\t' '|' < "$1")"
fi

urlencode() { jq -rn --arg s "$1" '$s|@uri'; }

is_valid_jpeg() {  # path -> 0 if a real, non-trivial JPEG
  [ -s "$1" ] || return 1
  [ "$(stat -c%s "$1")" -gt 2000 ] || return 1
  case "$(file -b --mime-type "$1")" in image/jpeg) return 0 ;; *) return 1 ;; esac
}

fail=0
while IFS='|' read -r slug title author; do
  [ -z "${slug:-}" ] && continue
  out="$DEST/$slug.jpg"
  if is_valid_jpeg "$out"; then
    echo "skip   $slug (already present)"; continue
  fi

  q="title=$(urlencode "$title")&author=$(urlencode "$author")&limit=1&fields=cover_i,isbn"
  meta=$(curl -fsS -m 30 -A "$UA" "https://openlibrary.org/search.json?$q" 2>/dev/null)
  if [ -z "$meta" ]; then
    echo "FAIL   $slug (search unreachable — is openlibrary.org allowlisted?)"; fail=1; continue
  fi

  cid=$(jq -r '.docs[0].cover_i // empty' <<<"$meta")
  isbn=$(jq -r '.docs[0].isbn[0] // empty' <<<"$meta")
  if [ -n "$cid" ]; then
    url="https://covers.openlibrary.org/b/id/${cid}-L.jpg"
  elif [ -n "$isbn" ]; then
    url="https://covers.openlibrary.org/b/isbn/${isbn}-L.jpg"
  else
    echo "FAIL   $slug (no cover found on Open Library)"; fail=1; continue
  fi

  curl -fsS -m 30 -A "$UA" "$url" -o "$out" 2>/dev/null
  if is_valid_jpeg "$out"; then
    echo "ok     $slug  ($(stat -c%s "$out") bytes)"
  else
    rm -f "$out"
    echo "FAIL   $slug (download blocked or empty — is covers.openlibrary.org allowlisted?)"; fail=1
  fi
done <<<"$BOOKS"

exit $fail
