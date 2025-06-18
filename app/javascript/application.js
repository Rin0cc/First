import "@hotwired/turbo-rails";
import "./controllers/application";
import "./controllers";

document.addEventListener("turbo:load", () => {
// 🍔 メニュー
const toggle = document.getElementById("menu-toggle");
const menu = document.getElementById("nav-menu");
toggle?.addEventListener("click", () => menu?.classList.toggle("active"));

// ⏱️ タイマー
let elapsed = 0, timerInterval, startTime;
const timerDisplay = document.getElementById("timer");
document.getElementById("start")?.addEventListener("click", () => {
if (timerInterval) return;
startTime = Date.now() - elapsed;
timerInterval = setInterval(() => {
elapsed = Date.now() - startTime;
const sec = Math.floor(elapsed / 1000);
timerDisplay.textContent = [Math.floor(sec/3600), Math.floor(sec/60)%60, sec%60]
.map(n => String(n).padStart(2,'0')).join(":");
}, 100);
});
document.getElementById("stop")?.addEventListener("click", () => {
clearInterval(timerInterval); timerInterval = null;
});

// 🌸 記録（非同期POST）
document.addEventListener("click", async (e) => {
if (e.target.id !== "record") return;
const [hh, mm, ss] = timerDisplay.textContent.split(":").map(Number);
const payload = {
time: hh*3600 + mm*60 + ss,
record: { task_name: document.getElementById("task_name")?.value }
};
const url = e.target.dataset.url;
if (!url) return console.warn("⚠️ data-url missing");

try {
const res = await fetch(url, {
method: "POST",
headers: {
"Content-Type":"application/json",
"X-CSRF-Token": document.querySelector("[name='csrf-token']").content
},
body: JSON.stringify(payload)
});
const { status, message, image } = await res.json();
if (["success", "short_time", "error"].includes(status)) {
const div = document.getElementById("flower-message");
div.innerHTML = image
? `${message}<br><img src="/assets/${image}" style="max-width:120px;">`
: message;
div.classList.remove("hidden");
div.classList.add("show");
setTimeout(() => div.classList.remove("show"), 3000);
}
} catch (err) {
console.error(err);
alert("通信エラーが発生しました");
}
});
});