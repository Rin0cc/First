import "@hotwired/turbo-rails";
import "./controllers";
import "./analytics"

// showMessage 関数はそのまま
function showMessage(text, imageUrl = null) {
  const flashDiv = document.getElementById("flower-message");
  const displayMessage = text || "メッセージがありません";

  if (flashDiv) {
    // 「すでにログインしています」メッセージを除外
    if (displayMessage === "You are already signed in." || displayMessage === "すでにログインしています。") {
      return; // 何も表示しない
    }
    
    flashDiv.innerHTML = imageUrl
      ? `${displayMessage}<br><img src="${imageUrl}" alt="花の画像" style="max-width: 120px; margin-top: 10px;">`
      : displayMessage;

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
  // --- トップページのアニメーションをトリガーするコード ---
  const topContent = document.querySelector('.top-content.initial-hidden');
  if (topContent) {
    // ページロード直後に実行されるように少し遅延させる
    // これにより、CSSの初期スタイル（opacity: 0;）がブラウザに適用されてから、
    // アニメーションが開始される時間を確保できます。
    setTimeout(() => {
      topContent.classList.remove('initial-hidden'); // 初期非表示クラスを削除
      topContent.classList.add('fade-in-active');   // アニメーション開始クラスを追加
    }, 100); // 100ミリ秒 (0.1秒) 程度のわずかな遅延
  }
  // ------------------------------------------------------------------

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

  const recordTimeSubmitButton = document.getElementById("record_time_submit");
  const recordTimeField = document.getElementById("record_time_field");
  const timeRecordForm = document.getElementById("time_record_form");

  if (recordTimeSubmitButton && recordTimeField && timeRecordForm) {
    recordTimeSubmitButton.addEventListener("click", (event) => {
      event.preventDefault();

      const timeInSeconds = Math.floor(elapsed / 1000);
      recordTimeField.value = timeInSeconds;

      timeRecordForm.submit();
    });
  }

  const flashDiv = document.getElementById("flower-message");
  if (flashDiv) {
    const flashMessage = flashDiv.dataset.flashMessage;
    const flashImage = flashDiv.dataset.flashImage;
    if (flashMessage) {
      showMessage(flashMessage, flashImage);
    }
  }

  // ToDo完了チェックボックスのイベントリスナー
  document.querySelectorAll('input[type="checkbox"][data-remote="true"]').forEach(checkbox => {
    checkbox.addEventListener('change', (event) => {
      const url = event.target.dataset.url;
      const method = event.target.dataset.method;

      const formData = new FormData();
      formData.append('record[completed]', event.target.checked ? 'true' : 'false');

      fetch(url, {
        method: method,
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        },
        body: formData
      })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.error("HTTPエラー:", response.status, response.statusText);
          return response.json()
            .catch(() => response.text())
            .then(errorBody => {
              throw new Error(`Server Error (${response.status}): ${errorBody}`);
            });
        }
      })
      .then(data => {
        console.log("ToDo更新成功:", data);
        const listItem = event.target.closest('li');
        if (listItem) {
          const taskNameSpan = listItem.querySelector('.task-name');
          if (taskNameSpan) {
            if (event.target.checked) {
              taskNameSpan.classList.add('task-completed');
            } else {
              taskNameSpan.classList.remove('task-completed');
            }
          }
        }
      })
      .catch(error => {
        console.error("ToDo更新エラー:", error);
        alert("ToDoの更新に失敗しました。");
        if (error.message && error.message.startsWith("Server Error")) {
            alert(`ToDoの更新に失敗しました。\n${error.message}`);
        } else {
            alert(`ToDoの更新に失敗しました。原因不明のエラーです。\n${error}`);
        }
      });
    });
  });
});