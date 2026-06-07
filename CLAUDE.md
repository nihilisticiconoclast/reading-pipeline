# Reading Pipeline

A weekly Claude Code routine that proposes book additions to `to-read.md`, biased toward expanding rather than reinforcing reading habits.

## Key files

- `reading.md` — books currently being read
- `read.md` — books read, with one-line verdicts
- `owned.md` — full bookshelf catalogue (~210 titles)
- `to-read.md` — suggestions queue; "Suggested by pipeline" section is auto-appended by the routine, "Manual additions" is edited by hand
- `reading-persona.md` — taste profile that drives recommendations; this is the primary signal, not the physical shelves
- `digest/YYYY-WW.html` — weekly digest pages (auto-generated)
- `index.html` — GitHub Pages home page, lists all digest weeks

## Routine

A remote Claude Code agent runs every Monday at 8am London time. It reads `reading-persona.md`, `read.md`, and `to-read.md`, searches the web for 3 books, appends them to `to-read.md`, writes a digest HTML page, regenerates `index.html`, and commits everything.

Routine ID: `trig_01QGVuLXj9W6EJCkWjBXtYcs`
Manage at: https://claude.ai/code/routines/trig_01QGVuLXj9W6EJCkWjBXtYcs

## GitHub Pages

Live at: https://nihilisticiconoclast.github.io/reading-pipeline/

## Adding books manually

- To add to `to-read.md`: append under `## Manual additions`
- To log a finished book: add to `read.md` with year and one-line verdict matching existing style
- After editing, commit and push
