---
name: website-builder
description: Build and refine websites from user briefs received via ailang messages. Use when the website-builder inbox has unread messages, or when the user asks to build/update a website.
---

# Website Builder Skill

You build real HTML/CSS websites from structured briefs sent by the Website Builder portal via `ailang messages`.

## Quick Start

```bash
# Check for build requests
ailang messages list --inbox website-builder --unread

# Read a specific message
ailang messages read <MSG_ID>

# After building, send response
ailang messages send portal '{"status":"complete","files":["index.html","about.html","style.css"]}' \
  --title "Build complete" --from website-builder
```

## Build Brief Format

The portal sends a JSON brief with pre-extracted content:

```json
{
  "id": "brief-...",
  "user": "<user-id>",
  "siteName": "<site-name>",
  "description": "What the website is for",
  "style": {
    "id": "warm|clean|bold|elegant|fun|auto",
    "direction": "Full style description",
    "customNotes": "User's additional style preferences"
  },
  "content": {
    "text": [{"label": "...", "text": "..."}],
    "images": [{"filename": "...", "description": "AI-generated description", "stagingPath": "staging/..."}],
    "documents": [{"filename": "...", "extractedText": "DocParse-extracted text", "stagingPath": "staging/..."}]
  },
  "outputDir": "sites/<user>/<site>"
}
```

## Build Workflow

1. **Read the brief** from the ailang message (JSON in message body)
2. **Read uploaded files** from staging paths if you need more context:
   - Images: Read directly (you have multimodal vision)
   - PDFs: Read directly (built-in PDF support)
   - DOCX/PPTX/XLSX: Run `docparse <file>` CLI to extract structured text
3. **Create the website** in `sites/<user>/<site>/`:
   - `index.html` (home page — always required)
   - Additional pages: `about.html`, `gallery.html`, `services.html`, `contact.html` etc.
   - `style.css` (shared stylesheet, linked from each page)
   - `images/` directory — copy relevant images from staging
4. **Validate every HTML file** (if validator available):
   ```bash
   ailang run --entry main --caps IO,Env \
     scripts/validate.ail \
     sites/<user>/<site>/index.html
   ```
   If the validator script is not found, skip validation — the portal will validate on preview.
5. **Git commit** on a working branch:
   ```bash
   git checkout -b build/<user>/<site>
   git add sites/<user>/<site>/
   git commit -m "Build: <siteName> for <user>"
   ```
6. **Send response** to portal:
   ```bash
   ailang messages send portal '{"status":"complete","briefId":"...","files":["index.html","about.html","style.css"],"branch":"build/<user>/<site>"}' \
     --title "Build complete: <siteName>" --from website-builder
   ```

## Feedback Workflow

The portal sends feedback briefs when the user wants changes:

```json
{
  "briefId": "brief-...",
  "feedback": "Make the header bigger and more purple",
  "targetPage": "home",
  "targetElement": {"area": "Hero section", "text": "..."},
  "addedContent": [],
  "outputDir": "sites/<user>/<site>"
}
```

1. Read the feedback
2. Read the current HTML files in the output directory
3. Apply the requested changes (edit specific files, don't regenerate everything unless needed)
4. If `targetPage` is set, focus on that page
5. If `targetElement` is set, focus on that specific element/section
6. Validate changed files
7. Git commit and send response

## Design Conventions

- **Mobile-first responsive**: 1-column base, 2-column at 768px, 3-column at 1024px
- **Google Fonts**: Load via `<link>` in `<head>`, use font families from the style brief
- **CSS custom properties**: `--primary`, `--secondary`, `--accent`, `--bg`, `--text` from palette
- **Semantic HTML5**: `<header>`, `<nav>`, `<main>`, `<section>`, `<footer>`
- **Accessibility**: alt text on all images, ARIA labels on nav, lang attribute, viewport meta
- **CSS hamburger nav**: Pure CSS toggle (no JS frameworks). Checkbox hack or details/summary.
- **Images**: Use relative paths (`images/bouquet.jpg`), copy from staging to `images/`
- **No JavaScript frameworks**: Plain HTML + CSS. Minimal JS only for nav toggle.
- **No external dependencies** beyond Google Fonts (safe for static hosting)

### CSS File Convention (IMPORTANT)

The portal inlines local CSS when loading sites for preview. Follow these rules:

- **Single shared stylesheet**: `style.css` in the site root — all CSS in one file
- **Every page links it the same way**: `<link rel="stylesheet" href="style.css" />`
- **No nested CSS paths**: Don't use `css/style.css` or `assets/main.css` — always `style.css` at the same level as the HTML files
- **Google Fonts are external links** and will be kept as-is: `<link rel="stylesheet" href="https://fonts.googleapis.com/...">`
- **No inline `<style>` blocks** in the HTML — keep all CSS in `style.css`
- **No `@import` in CSS** — everything in one file for simplicity

## Safety Rules

NEVER include in generated websites:
- `eval()`, `Function()`, `new Function`
- `document.write`, `document.cookie`
- `innerHTML` (use `textContent` if JS needed)
- `XMLHttpRequest`, `fetch` to external URLs
- `importScripts`, `crypto.subtle`, `navigator.sendBeacon`
- Any tracking scripts, analytics, or third-party embeds
- Any form actions pointing to external URLs

These are checked by the AILANG validator and will cause the page to be blocked.

## File Paths

All paths are relative to the workspace root (the cloned `sunholo-websites` repo):

- **Staging**: `staging/<user>/<site>/`
- **Output**: `sites/<user>/<site>/`
- **Validator**: `scripts/validate.ail` (if present in workspace)
- **DocParse CLI**: `docparse` (if installed, otherwise skip document extraction)
