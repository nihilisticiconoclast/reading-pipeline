# Reading Pipeline

A weekly Claude Code routine that proposes book additions to `to-read.md`, biased toward expanding rather than reinforcing reading habits.

## Key files

- `reading.md` — books currently being read
- `read.md` — books read, with one-line verdicts
- `abandoned.md` — books started and given up on; read as a negative signal (never re-suggested; reasons steer picks away from similar books)
- `owned.md` — full bookshelf catalogue (~210 titles); used only to avoid suggesting owned books, NOT as a taste signal (the library is shared)
- `to-read.md` — suggestions queue; "Suggested by pipeline" section is auto-appended by the routine, "Manual additions" is edited by hand
- `reading-persona.md` — taste profile that drives recommendations; this is the primary signal, not the physical shelves
- `digest/YYYY-WW.html` — weekly digest pages (auto-generated)
- `index.html` — GitHub Pages home page, lists all digest weeks

## Routine

A remote Claude Code agent runs every Monday at 8am London time. It reads `reading-persona.md` and every list (`read.md`, `reading.md`, `abandoned.md`, `owned.md`, `to-read.md`), searches the web for 6 books split into 3 highbrow (expansion) and 3 lowbrow (comfort — saturated-territory ban lifted but invariants kept), appends them to `to-read.md`, writes a digest HTML page, regenerates `index.html`, and commits everything.

Routine ID: `trig_01QGVuLXj9W6EJCkWjBXtYcs`
Manage at: https://claude.ai/code/routines/trig_01QGVuLXj9W6EJCkWjBXtYcs

## Book covers

Each digest book shows a cover thumbnail from `assets/covers/<slug>.jpg`, with
`onerror` falling back to `assets/covers/placeholder.svg`. The digest/index
`<img>` tags should reference the real `<slug>.jpg` filename even before the
image exists — the placeholder fallback handles the gap, and the cover appears
automatically once fetched.

**Covers are fetched in CI, not in the Claude container.** The workflow
`.github/workflows/covers.yml` runs `scripts/fetch-covers.sh` on a
GitHub-hosted runner (which has unrestricted internet) and commits any new
covers straight back to `main`. It triggers on pushes that touch `digest/**`
or the script, on a Monday schedule just after the weekly routine, and via
manual `workflow_dispatch`. So the routine just needs to write the digest with
the right `<slug>.jpg` references; the cover appears within a minute or two.

`scripts/fetch-covers.sh` auto-discovers the books straight from the digest
pages (pairing each `assets/covers/<slug>.jpg` with the following
`<h3>Title — Author (Year)</h3>`), so there is no list to maintain. It tries
Open Library first, then Google Books, follows redirects, and skips covers
already present (safe to re-run). To fetch covers for a new digest, just push
the digest — CI does the rest. You can also trigger a run manually from the
Actions tab.

**Why CI and not the container:** the weekly routine runs in a
network-restricted container. Cover hosts redirect bytes through storage
backends that aren't on the egress allowlist
(`covers.openlibrary.org` → `archive.org` → `iaNNN.us.archive.org`, whose
shard hostnames vary per file), and the shared egress IP gets rate-limited
(HTTP 429). Chasing allowlist entries was a losing game (this is what kept
week 2026-25 stuck on placeholders); fetching where the network is open fixes
it for good.

## Page aesthetic (Tunnel)

`index.html` and every `digest/YYYY-WW.html` use the in-house **Tunnel** visual
identity. The locked layer (palette, type, hard edges, the signature figures) is
**linked from cuddly-lamp's CDN, never inlined**; page-specific layout lives in
`assets/style.css`. When the weekly routine writes a new digest it must emit the
same scaffold:

- In `<head>`, before `assets/style.css`:
  `<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/nihilisticiconoclast/cuddly-lamp@main/assets/tokens.css">`
- `<body data-seed="reading-pipeline-YYYY-WW">` and, at the top of `.container`,
  a `.masthead` holding `<span class="sig" id="sig"></span>` (the fixed house mark).
- A `<div class="doodle doodle--right doodle--bleed-right" id="doodle"></div>`
  between the last section and the `← All weeks` link.
- Before `</body>`, the CDN
  `assets/tunnel-figure.js` script plus the init that fills `#sig` with
  `variant: 'mark'` and `#doodle` with `variant: 'doodle'` (seeded from the page).

Never paste `tokens.css` or `tunnel-figure.js` into a page — link the one hosted
copy so a style change in cuddly-lamp propagates everywhere. See
`.claude/skills/tunnel-aesthetic/SKILL.md`.

## GitHub Pages

Live at: https://nihilisticiconoclast.github.io/reading-pipeline/

## Adding books manually

- To add to `to-read.md`: append under `## Manual additions`
- To log a finished book: add to `read.md` with year and one-line verdict matching existing style
- After editing, commit and push
