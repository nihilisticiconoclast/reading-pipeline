#!/usr/bin/env bash
#
# Fetch book-cover images for the reading-pipeline digests.
#
# WHERE THIS RUNS
# ---------------
# This is designed to run in GitHub Actions (.github/workflows/covers.yml),
# where the runner has unrestricted outbound internet and its own IP. Running
# it inside the network-restricted Claude container is unreliable: cover hosts
# redirect to per-shard storage backends that are not on the egress allowlist
# (covers.openlibrary.org -> archive.org -> iaNNN.us.archive.org), and the
# shared egress IP gets rate-limited (HTTP 429). Let CI fetch the covers and
# commit them back; the digest's placeholder.svg fallback covers the gap until
# the image lands.
#
# WHAT IT FETCHES
# ---------------
# By default it AUTO-DISCOVERS the books from the digest pages: every
#   <img ... src=".../assets/covers/<slug>.jpg" ...>
# is paired with the <h3>Title — Author (Year)</h3> that follows it. So adding
# a book to a digest is all that's needed — no list to maintain here.
#
# Sources (first hit wins, with redirects followed):
#   1. Open Library  https://openlibrary.org/search.json  -> covers.openlibrary.org
#   2. Google Books  https://www.googleapis.com/books/v1/volumes -> books.google.com
#
# Already-present valid covers are skipped, so it is safe to re-run.
#
# Usage:
#   scripts/fetch-covers.sh                 # auto-discover from digest/*.html
#   scripts/fetch-covers.sh books.tsv       # override: slug<TAB>title<TAB>author

set -uo pipefail
cd "$(dirname "$0")/.."
DEST="assets/covers"
UA="reading-pipeline/1.0 (+https://github.com/nihilisticiconoclast/reading-pipeline)"
mkdir -p "$DEST"

urlencode() { jq -rn --arg s "$1" '$s|@uri'; }

is_valid_jpeg() {  # path -> 0 if a real, non-trivial JPEG
  [ -s "$1" ] || return 1
  [ "$(stat -c%s "$1")" -gt 2000 ] || return 1
  case "$(file -b --mime-type "$1")" in image/jpeg) return 0 ;; *) return 1 ;; esac
}

# Parse the digest pages into a "slug<TAB>title<TAB>author" stream.
discover_books() {
  awk '
    /assets\/covers\// {
      if (match($0, /assets\/covers\/[^"]+\.jpg/)) {
        slug = substr($0, RSTART, RLENGTH)
        sub(/.*\//, "", slug); sub(/\.jpg$/, "", slug)
      }
      next
    }
    /<h3>/ && slug != "" {
      line = $0
      sub(/.*<h3>/, "", line); sub(/<\/h3>.*/, "", line)
      gsub(/&amp;/, "\\&", line)
      title = line; author = ""
      if (match(line, / — /)) {            # split "Title — Author (Year)"
        title  = substr(line, 1, RSTART-1)
        author = substr(line, RSTART+RLENGTH)
      }
      sub(/ *\([0-9]+\) *$/, "", author)   # drop trailing (Year)
      sub(/ +&.*/, "", author)             # keep first author only
      gsub(/^ +/, "", title);  gsub(/ +$/, "", title)
      gsub(/^ +/, "", author); gsub(/ +$/, "", author)
      print slug "\t" title "\t" author
      slug = ""
    }
  ' digest/*.html | sort -u
}

# Resolve a cover image URL from Open Library. Tries progressively looser
# queries — exact title+author, then with the subtitle dropped, then a single
# combined free-text query — so subtitles and transliterated authors don't
# cause a miss. First query that yields a cover id or ISBN wins.
url_openlibrary() {
  local title="$1" author="$2" bare="${1%%:*}" q meta cid isbn
  for q in \
    "title=$(urlencode "$title")&author=$(urlencode "$author")" \
    "title=$(urlencode "$bare")&author=$(urlencode "$author")" \
    "q=$(urlencode "$title $author")"; do
    meta=$(curl -fsSL -m 30 -A "$UA" \
      "https://openlibrary.org/search.json?$q&limit=1&fields=cover_i,isbn" 2>/dev/null) || continue
    cid=$(jq -r '.docs[0].cover_i // empty' <<<"$meta")
    isbn=$(jq -r '.docs[0].isbn[0] // empty' <<<"$meta")
    if   [ -n "$cid"  ]; then echo "https://covers.openlibrary.org/b/id/${cid}-L.jpg"; return
    elif [ -n "$isbn" ]; then echo "https://covers.openlibrary.org/b/isbn/${isbn}-L.jpg"; return
    fi
  done
}

# Resolve a cover image URL from Google Books. Tries a structured
# intitle/inauthor query (subtitle dropped) then a combined free-text query.
url_googlebooks() {
  local title="$1" author="$2" bare="${1%%:*}" q meta url
  for q in \
    "$(urlencode "intitle:$bare inauthor:$author")" \
    "$(urlencode "$title $author")"; do
    meta=$(curl -fsSL -m 30 -A "$UA" \
      "https://www.googleapis.com/books/v1/volumes?q=$q&maxResults=1&country=US" 2>/dev/null) || continue
    url=$(jq -r '.items[0].volumeInfo.imageLinks.thumbnail
              // .items[0].volumeInfo.imageLinks.smallThumbnail // empty' <<<"$meta")
    [ -n "$url" ] && { echo "${url/http:/https:}"; return; }   # force https
  done
}

BOOKS="$(discover_books)"
if [ "${1:-}" != "" ] && [ -f "$1" ]; then
  BOOKS="$(cat "$1")"   # TSV override (slug<TAB>title<TAB>author)
fi

fail=0
while IFS=$'\t' read -r slug title author; do
  [ -z "${slug:-}" ] && continue
  out="$DEST/$slug.jpg"
  if is_valid_jpeg "$out"; then
    echo "skip   $slug (already present)"; continue
  fi

  got=""
  for src in url_openlibrary url_googlebooks; do
    url="$($src "$title" "$author")" || true
    [ -z "$url" ] && continue
    curl -fsSL -m 30 -A "$UA" "$url" -o "$out" 2>/dev/null || true
    if is_valid_jpeg "$out"; then
      echo "ok     $slug  ($(stat -c%s "$out") bytes, via ${src#url_})"
      got=1; break
    fi
    rm -f "$out"
  done

  if [ -z "$got" ]; then
    echo "FAIL   $slug (no cover from Open Library or Google Books)"; fail=1
  fi
done <<<"$BOOKS"

exit $fail
