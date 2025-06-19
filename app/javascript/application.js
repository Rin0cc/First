import "@hotwired/turbo-rails";
import "./controllers";

function showMessage(text, imageUrl = null) {
  const flashDiv = document.getElementById("flower-message");

  if (flashDiv) {
    flashDiv.innerHTML = imageUrl
      ? `${text}<br><img src="${imageUrl}" alt="花の画像" style="max-width: 120px; margin-top: 10px;">`
      : text;

    flashDiv.classList.remove("hidden");
    flashDiv.classList.add("show");

    setTimeout(() => {
      flashDiv.classList.remove("show");
      flashDiv.classList.add("hidden");
    }, 3000);
  } else {
    console.error("#flower-message 要素が見つかりません！");
  }
}

let startTime;
let elapsed = 0;
let timerInterval;

const updateTimerDisplay = (ms) => {
  const totalSeconds = Math.floor(ms / 1000);
  const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, "0");
  const minutes = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, "0");
  const seconds = String(totalSeconds % 60).padStart(2, "0");
  document.getElementById("timer").textContent = `${hours}:${minutes}:${seconds}`;
};

document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("menu-toggle");
  const menu = document.getElementById("nav-menu");

  if (toggle && menu) {
    toggle.addEventListener("click", () => {
      menu.classList.toggle("active");
    });
  }

  const startButton = document.getElementById("start");
  const stopButton = document.getElementById("stop");

  startButton?.addEventListener("click", () => {
    if (!timerInterval) {
      startTime = Date.now() - elapsed;
      timerInterval = setInterval(() => {
        elapsed = Date.now() - startTime;
        updateTimerDisplay(elapsed);
      }, 100);
    }
  });

  stopButton?.addEventListener("click", () => {
    clearInterval(timerInterval);
    timerInterval = null;
  });

  const recordButton = document.getElementById("record");
  const flowerId = document.getElementById("timer-section")?.dataset.flowerId;

  recordButton?.addEventListener("click", () => {
    const taskName = document.querySelector("input[name='record[task_name]']")?.value || "";
    const time = Math.floor(elapsed / 1000);
    const url = flowerId ? `/user_flowers/${flowerId}/records` : "/records";

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
      },
      body: JSON.stringify({
        record: { task_name: taskName },
        time: time
      })
    })
      .then((response) => {
        if (!response.ok) {
          console.error("HTTPエラー:", response.status, response.statusText);
          return response.text().then(text => { throw new Error(text); });
        }
        return response.json();
      })
      .then((data) => {
        console.log("🎉 レスポンスデータ:", data);

        if (data.status === "success") {
          const imageUrl = data.image;
          showMessage(data.message, imageUrl);
        } else if (data.status === "short_time") {
          // ✨ ここを修正！ short_time の場合も画像URLを渡す ✨
          const imageUrl = data.image;
          showMessage(data.message, imageUrl);
        } else {
          showMessage("⚠️ 記録に失敗しました: " + (data.message || "不明なエラー"));
        }
      })
      .catch((error) => {
        console.error("fetchエラー:", error);
        showMessage("⚠️ 通信エラーが発生しました。詳細: " + error.message);
      });
  });
});