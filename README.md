# L205 AI-Driven Neuroscience Course Site

Static GitHub Pages website for **Principles of AI-Driven Neuroscience and Translational Biomedicine (L205 ACS Master)**.

The site is ready to upload to GitHub as a normal static website. GitHub Pages can serve it directly from the repository root because the main file is `index.html` and all website assets use relative paths.

## Publish With GitHub Pages

1. Open the repository on GitHub.
2. Go to **Settings**.
3. Go to **Pages**.
4. Under **Build and deployment**, set:
   - **Source:** Deploy from a branch
   - **Branch:** `main`
   - **Folder:** `/ (root)`
5. Click **Save**.

After GitHub finishes publishing, the site will normally be available at:

```text
https://YOUR-USERNAME.github.io/l205-ai-neuroscience-site/
```

## Site Files

- `index.html` - main website page.
- `styles.css` - visual design and responsive layout.
- `script.js` - tabs, header state, and animated background.
- `assets/` - images, videos, transcript, and SVG video slides.
- `tools/` - optional local scripts for regenerating the Agentic-AI video.

## Optional Video Regeneration

The generated videos are already included in `assets/`, so GitHub Pages does not need Node.js, Playwright, FFmpeg, or macOS voices.

Only use these steps if you want to regenerate the video later:

```bash
npm install
npx playwright install chromium
npm run video:render
npm run video:voiceover
```

For the current voiceover, the script defaults to the macOS `Moira` voice at rate `165`.
