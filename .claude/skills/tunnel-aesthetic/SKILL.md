---
name: tunnel-aesthetic
description: >-
  Apply the in-house "Tunnel" visual identity to ANY web/visual deliverable
  (HTML pages, React/Vue/Svelte components, landing pages, dashboards, static
  sites, HTML reports). Cartography × phase-space: a locked palette, Fraunces /
  Public Sans / IBM Plex Mono type, hard edges, a fixed house logo and a seeded
  per-page doodle (a contour map with a route tunnelling through a barrier
  ridge). This is the THIN, portable copy — it links the shared assets from the
  CDN and defers to the canonical brief. Use whenever a frontend or visual
  artifact is requested, even if the style is not named. NOT for backend code,
  data pipelines, SQL, or non-visual output.
---

# Tunnel — house web aesthetic (portable skill)

This is the thin, copy-anywhere version of the Tunnel design system. The single
source of truth lives in `nihilisticiconoclast/cuddly-lamp`; this file only
restates the non-negotiables and tells you to **link the shared assets, never
inline them**.

## Source of truth (read for full detail)

- Full brief: https://cdn.jsdelivr.net/gh/nihilisticiconoclast/cuddly-lamp@main/SKILL.md
- Assets (link, do not copy): the two CDN URLs below.

Fetch the full brief when you need the complete rules, the figure variants in
depth, or the worked example. If you cannot reach the network, the essentials
below are enough to stay on-system.

## The rule that matters most: link, never inline

Do **not** paste `tokens.css` or `tunnel-figure.js` into the page or the repo.
Reference the one hosted copy so a style update propagates everywhere:

```html
<!-- in <head> -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/gh/nihilisticiconoclast/cuddly-lamp@main/assets/tokens.css">

<!-- the fixed house logo + a per-page doodle -->
<span class="sig" id="sig"></span>
<div class="doodle" id="doodle"></div>

<!-- before </body> -->
<script src="https://cdn.jsdelivr.net/gh/nihilisticiconoclast/cuddly-lamp@main/assets/tunnel-figure.js"></script>
<script>
  document.getElementById('sig').innerHTML =
    TunnelFigure.tunnelFigureSVG(null, { variant: 'mark' });           // fixed logo
  var seed = document.body.dataset.seed || location.pathname || document.title;
  document.getElementById('doodle').innerHTML =
    TunnelFigure.tunnelFigureSVG(seed, { variant: 'doodle' });         // per-page, deterministic
  TunnelFigure.placeDoodle(document.getElementById('doodle'));         // random edge slot, never fixed
</script>
```

(React: `import { tunnelFigureSVG } from` the CDN URL or a local re-export, and
set it via `dangerouslySetInnerHTML`. Load `tokens.css` once at the app root.)

## The locked layer — never substitute

**Palette (exact hex):** `--paper #EDE7D3`, `--ink #4A3823`, `--contour #7A5C3E`,
`--index #5A4225`, `--incident #3E7C8C` (teal links/data), `--amber #E0922B`
(only where a scalar field runs high), `--route #C0432B` (the single red line).

**Type:** display **Fraunces** (~560, tight); body **Public Sans**; data/labels
**IBM Plex Mono**. No other families.

**Form:** hard edges (`border-radius: 0`); no shadows, glows or gradients;
dividers are hairline rules that read as isolines; exactly **one** red `--route`
element per view; amber only in the figure; real labels, never lorem.

Deliberately NOT the default AI look: not cream-with-coral, not near-black-with-
acid, not a rounded SaaS hero.

## The signature — a fixed logo AND a per-page doodle

- `mark` (default): the FIXED house logo — same picture on every page (seed
  ignored). Masthead/footer brand.
- `doodle`: a DIFFERENT little scribble per page (seeded; stable on reload).
  Small, off-centre, between sections — never boxed, never captioned, never its
  own section. Its POSITION must vary too: mount it with
  `TunnelFigure.placeDoodle(el)`, which drops it into one of six edge slots
  ({left,right} × {top,middle,bottom}) bleeding into the gutter, behind the
  content — random, never a fixed spot, and never behind the text.
- `background`: seeded contours-only watermark, faint but visible (use `.sig-bg`).
- `full`: the explanatory figure (route + WKB inset + survey labels). Only on
  pages genuinely about terrain / sampling / optimisation / tunnelling.

Pick at most one per-page figure (doodle *or* watermark); the fixed logo can sit
alongside either. Seed `doodle`/`background`/`full` from the page slug/path/title
— never `Math.random()`, never a constant.

## Self-check before shipping

- Background `--paper`, text `--ink`; no white cards, no shadows.
- Fonts are Fraunces / Public Sans / IBM Plex Mono only.
- Exactly one red `--route` element; amber only in the figure; square corners.
- Fixed `mark` logo in a corner/footer; any `doodle` small, off-centre, behind
  content. Its position is set by `placeDoodle` (a random edge slot), never a
  fixed corner, never directly behind the text.
- Assets are **linked from the CDN, not inlined**.
- No self-describing caption / physics labels on a content page (`full` only
  where the topic warrants it); labels real, copy precise.
