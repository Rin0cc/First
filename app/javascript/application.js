import "@hotwired/turbo-rails";
import "./controllers";

document.addEventListener("turbo:load", function () {
  const toggle = document.getElementById("menu-toggle");
  const menu = document.getElementById("nav-menu");

  if (toggle && menu) {
    toggle.addEventListener("click", function () {
      menu.classList.toggle("active");
    });
  }

  let startTime;
  let elapsed = 0;
  let timerInterval;

  const timerDisplay = document.getElementById('timer');
  const startBtn = document.getElementById('start');
  const stopBtn = document.getElementById('stop');
  const recordBtn = document.getElementById('record');
  const records = document.getElementById('records');

  function updateTimerDisplay(ms) {
    const totalSeconds = Math.floor(ms / 1000);
    const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0');
    const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0');
    const seconds = String(totalSeconds % 60).padStart(2, '0');
    if (timerDisplay) {
      timerDisplay.textContent = `${hours}:${minutes}:${seconds}`;
    }
  }

  startBtn?.addEventListener('click', () => {
    if (!timerInterval) {
      startTime = Date.now() - elapsed;
      timerInterval = setInterval(() => {
        elapsed = Date.now() - startTime;
        updateTimerDisplay(elapsed);
      }, 100);
    }
  });

  stopBtn?.addEventListener('click', () => {
    clearInterval(timerInterval);
    timerInterval = null;
  });

  recordBtn?.addEventListener('click', () => {
    const currentTime = timerDisplay?.textContent || '00:00:00';
    const li = document.createElement('li');
    li.textContent = currentTime;
    records?.appendChild(li);
    showMessage("花が育ちました🌸", "/assets/images/Flowerseed.png");
  });

  // 🌸 Flashメッセージがあれば表示
  const flashDiv = document.getElementById("flower-message");
  if (flashDiv) {
    const text = flashDiv.dataset.flashMessage;
    const image = flashDiv.dataset.flashImage;
    if (text) {
      showMessage(text, image);
    }
  }

  // 🌸 メッセージ表示関数
  function showMessage(text, imagePath = null) {
    const messageDiv = document.getElementById("flower-message");

    if (messageDiv) {
      messageDiv.innerHTML = imagePath
        ? `${text}<br><img src="${imagePath}" alt="花が育つ" style="max-width: 120px; margin-top: 10px;">`
        : text;

      messageDiv.classList.remove("hidden");
      messageDiv.classList.add("show");

      setTimeout(() => {
        messageDiv.classList.remove("show");
      }, 3000);
    }
  }
});
document.addEventListener("DOMContentLoaded", function () {
showFlashIfNeeded();
});

document.addEventListener("turbo:load", function () {
showFlashIfNeeded();
});

function showFlashIfNeeded() {
const flashDiv = document.getElementById("flower-message");
if (flashDiv) {
const text = flashDiv.dataset.flashMessage;
const image = flashDiv.dataset.flashImage;
if (text) {
showMessage(text, image);
}
}
}
showMessage("テストメッセージ🌼", "/assets/images/Flowerseed.png");