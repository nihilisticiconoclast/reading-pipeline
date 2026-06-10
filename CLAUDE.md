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

## GitHub Pages

Live at: https://nihilisticiconoclast.github.io/reading-pipeline/

## Adding books manually

- To add to `to-read.md`: append under `## Manual additions`
- To log a finished book: add to `read.md` with year and one-line verdict matching existing style
- After editing, commit and push
