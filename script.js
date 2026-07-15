const header = document.querySelector(".site-header");
const tabs = document.querySelectorAll(".resource-tab");
const panels = document.querySelectorAll(".resource-panel");

function updateHeader() {
  header.classList.toggle("scrolled", window.scrollY > 40);
}

tabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    const target = tab.dataset.target;
    tabs.forEach((item) => item.classList.toggle("active", item === tab));
    panels.forEach((panel) => panel.classList.toggle("active", panel.id === target));
  });
});

window.addEventListener("scroll", updateHeader, { passive: true });
updateHeader();

const canvas = document.querySelector(".signal-field");
const ctx = canvas.getContext("2d");
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
let points = [];
let width = 0;
let height = 0;
let animationFrame = 0;

function resizeCanvas() {
  const scale = Math.min(window.devicePixelRatio || 1, 2);
  width = window.innerWidth;
  height = window.innerHeight;
  canvas.width = Math.floor(width * scale);
  canvas.height = Math.floor(height * scale);
  canvas.style.width = `${width}px`;
  canvas.style.height = `${height}px`;
  ctx.setTransform(scale, 0, 0, scale, 0, 0);

  const count = Math.max(42, Math.floor((width * height) / 22000));
  points = Array.from({ length: count }, (_, index) => ({
    x: (index * 137.5) % width,
    y: (index * 83.3) % height,
    vx: (Math.random() - 0.5) * 0.28,
    vy: (Math.random() - 0.5) * 0.28,
    radius: 1.1 + Math.random() * 1.8,
  }));
}

function drawNetwork() {
  ctx.clearRect(0, 0, width, height);

  for (const point of points) {
    if (!reduceMotion) {
      point.x += point.vx;
      point.y += point.vy;

      if (point.x < 0 || point.x > width) point.vx *= -1;
      if (point.y < 0 || point.y > height) point.vy *= -1;
    }

    ctx.beginPath();
    ctx.arc(point.x, point.y, point.radius, 0, Math.PI * 2);
    ctx.fillStyle = "rgba(34, 199, 221, 0.35)";
    ctx.fill();
  }

  for (let i = 0; i < points.length; i += 1) {
    for (let j = i + 1; j < points.length; j += 1) {
      const first = points[i];
      const second = points[j];
      const dx = first.x - second.x;
      const dy = first.y - second.y;
      const distance = Math.sqrt(dx * dx + dy * dy);

      if (distance < 145) {
        const opacity = (1 - distance / 145) * 0.14;
        ctx.beginPath();
        ctx.moveTo(first.x, first.y);
        ctx.lineTo(second.x, second.y);
        ctx.strokeStyle = `rgba(7, 16, 21, ${opacity})`;
        ctx.lineWidth = 1;
        ctx.stroke();
      }
    }
  }

  if (!reduceMotion) {
    animationFrame = requestAnimationFrame(drawNetwork);
  }
}

window.addEventListener("resize", () => {
  cancelAnimationFrame(animationFrame);
  resizeCanvas();
  drawNetwork();
});

resizeCanvas();
drawNetwork();
