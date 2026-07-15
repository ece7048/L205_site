import { mkdir, readdir } from "node:fs/promises";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const playwrightPackage = process.env.PLAYWRIGHT_IMPORT_PATH || "playwright";
const { chromium } = await import(playwrightPackage);

const root = resolve(".");
const slidesDir = resolve(root, "assets/agentic-video-slides");
const framesDir = resolve(root, "assets/agentic-video-frames");

await mkdir(framesDir, { recursive: true });

const launchOptions = { headless: true };

if (process.env.CHROME_PATH) {
  launchOptions.executablePath = process.env.CHROME_PATH;
}

const browser = await chromium.launch(launchOptions);
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: 1 });

const slides = (await readdir(slidesDir)).filter((name) => name.endsWith(".svg")).sort();

for (const slide of slides) {
  const slidePath = resolve(slidesDir, slide);
  const frameName = slide.replace(".svg", ".png");
  await page.goto(pathToFileURL(slidePath).href);
  await page.screenshot({ path: resolve(framesDir, frameName), fullPage: false });
}

await browser.close();
