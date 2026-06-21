# reading-pipeline

A weekly Claude Code routine that proposes additions to my to-read list, biased
toward expanding rather than reinforcing my current reading habits. Every Monday
it reads my taste profile and lists, searches the web for six books — three
highbrow (expansion) and three lowbrow (comfort) — appends them to the queue, and
publishes a digest page.

Live at <https://nihilisticiconoclast.github.io/reading-pipeline/>.

## The lists

- `reading.md` — books currently being read
- `read.md` — books read, with one-line verdicts where I have them
- `abandoned.md` — books started and given up on; a negative signal, never re-suggested
- `owned.md` — full bookshelf catalogue, used only to avoid re-suggesting owned books (not a taste signal — the library is shared)
- `to-read.md` — suggestions queue: "Suggested by pipeline" is auto-appended; "Manual additions" is edited by hand
- `reading-persona.md` — the taste profile that drives recommendations (the primary signal, not the physical shelves)
- `digest/YYYY-WW.html` — weekly digest pages (auto-generated)
- `index.html` — GitHub Pages home, listing every digest week

## How it runs

A remote Claude Code routine runs every Monday at 8am London time: it reads the
persona and lists, picks the six books, writes a digest, regenerates
`index.html`, and commits everything. Book covers are fetched separately in CI
(`.github/workflows/covers.yml`) on a GitHub-hosted runner with open internet and
committed back to `main` — the digest just references `assets/covers/<slug>.jpg`
and a placeholder fills the gap until the real cover lands.

## Design

The site uses the in-house **Tunnel** aesthetic (`tunnel-aesthetic`, from
[`cuddly-lamp`](https://github.com/nihilisticiconoclast/cuddly-lamp)): the locked
chart-paper palette and Fraunces / Public Sans / IBM Plex Mono type, hard edges,
no shadows or gradients, **linked from the CDN rather than inlined**, with the
fixed house mark and a per-page doodle. Page-specific layout lives in
`assets/style.css`. See [`CLAUDE.md`](CLAUDE.md) for the scaffold the weekly
routine must emit so new digests stay on-style.
