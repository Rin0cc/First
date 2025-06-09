// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("DOMContentLoaded", function () {
  const toggle = document.getElementById("menu-toggle");
  const menu = document.getElementById("nav-menu");

  if (toggle && menu) {
    toggle.addEventListener("click", function () {
      menu.classList.toggle("active");
    });
  }
});

let startTime;
let elapsed = 0;
let timerInterval;

function updateTimerDisplay(ms) {
  const totalSeconds = Math.floor(ms / 1000);
  const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0');
  const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0');
  const seconds = String(totalSeconds % 60).padStart(2, '0');
  document.getElementById('timer').textContent = `${hours}:${minutes}:${seconds}`;
}

document.getElementById('start').addEventListener('click', () => {
  if (!timerInterval) {
    startTime = Date.now() - elapsed;
    timerInterval = setInterval(() => {
      elapsed = Date.now() - startTime;
      updateTimerDisplay(elapsed);
    }, 100);
  }
});

document.getElementById('stop').addEventListener('click', () => {
  clearInterval(timerInterval);
  timerInterval = null;
});

document.getElementById('record').addEventListener('click', () => {
  const li = document.createElement('li');
  li.textContent = document.getElementById('timer').textContent;
  document.getElementById('records').appendChild(li);
});
