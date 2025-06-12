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

document.getElementById('start')?.addEventListener('click', () => {
if (!timerInterval) {
startTime = Date.now() - elapsed;
timerInterval = setInterval(() => {
elapsed = Date.now() - startTime;
updateTimerDisplay(elapsed);
}, 100);
}
});

document.getElementById('stop')?.addEventListener('click', () => {
clearInterval(timerInterval);
timerInterval = null;
});

document.getElementById('record')?.addEventListener('click', () => {
const currentTime = document.getElementById('timer').textContent;

// 記録リストに追加
const li = document.createElement('li');
li.textContent = currentTime;
document.getElementById('records').appendChild(li);

// メッセージと画像を表示
const message = document.getElementById('message');
message.innerHTML = `
🌱 花の種を獲得しました！（${currentTime}）<br>
<img src="/images/Flowerseeds.png" alt="花の種" style="width: 100px; margin-top: 10px;" />
`;
message.classList.remove('hidden');
message.classList.add('show');

setTimeout(() => {
message.classList.remove('show');
}, 3000);
});
});