import "@hotwired/turbo-rails";
import "./controllers";
import "./analytics";

// エラーメッセージ用のカスタムモーダルを表示する関数
function showModal(title, message) {
  // 既存のモーダルがあれば削除する
  const existingModal = document.querySelector('.custom-modal');
  if (existingModal) {
    existingModal.remove();
  }

  // モーダルのHTML要素をJavaScriptで作成
  const modalContainer = document.createElement('div');
  modalContainer.className = 'fixed inset-0 z-50 flex items-center justify-center bg-gray-900 bg-opacity-50 transition-opacity duration-300 ease-in-out custom-modal fade-in';
  
  modalContainer.innerHTML = `
    <div class="bg-white rounded-xl shadow-2xl p-6 m-4 w-full max-w-sm transform transition-all duration-300 ease-in-out modal-content scale-in">
        <h3 class="text-xl font-bold mb-2 text-center text-gray-800">${title}</h3>
        <p class="mb-4 text-center text-gray-600">${message}</p>
        <button id="modal-ok-button" class="w-full bg-blue-600 text-white font-semibold py-3 px-6 rounded-lg hover:bg-blue-700 transition-colors duration-200 shadow-md transform hover:scale-105">
            OK
        </button>
    </div>
  `;
  
  // bodyの一番最後にモーダルを追加
  document.body.appendChild(modalContainer);

  // モーダルを閉じるためのイベントリスナーを設定
  const modalOkButton = document.getElementById('modal-ok-button');
  modalOkButton.addEventListener('click', () => {
    closeModal(modalContainer);
  });
  // 背景クリックでも閉じられるように設定
  modalContainer.addEventListener('click', (e) => {
    if (e.target === modalContainer) {
      closeModal(modalContainer);
    }
  });
}

// モーダルを閉じる関数
function closeModal(modalElement) {
    modalElement.classList.remove('fade-in');
    modalElement.classList.add('fade-out');
    
    // アニメーション完了後にDOMから要素を削除
    modalElement.addEventListener('animationend', () => {
        modalElement.remove();
    }, { once: true });
}

// showMessage 関数はそのまま
function showMessage(text, imageUrl = null) {
  const flashDiv = document.getElementById("flower-message");
  const displayMessage = text || "メッセージがありません";

  if (flashDiv) {
    if (displayMessage === "You are already signed in." || displayMessage === "すでにログインしています。") {
      return;
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

// ToDo完了チェックボックスのイベントリスナー登録を関数として切り出す
function initializeTodoCheckboxes() {
  document.querySelectorAll('input[type="checkbox"][data-remote="true"]').forEach(checkbox => {
    // 既にイベントリスナーが登録されていないかチェックする（重複登録防止）
    if (!checkbox.dataset.listenerAttached) {
      checkbox.addEventListener('change', (event) => {
        const url = event.target.dataset.url;
        const method = event.target.dataset.method;

        fetch(url, {
          method: method,
          credentials: "same-origin",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
          },
          body: JSON.stringify({
            record: {
              completed: event.target.checked
            }
          })
        })
        .then(response => {
          if (response.ok) {
            return response.json();
          } else {
            return response.json()
              .catch(() => response.text())
              .then(errorBody => {
                const errorMessage = `ToDoの更新に失敗しました。サーバーエラー: ${response.status}`;
                throw new Error(errorMessage);
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
          // showModalを使って、エラーメッセージを優しく表示
          showModal("エラー", "ToDoの更新に失敗しました。");
        });
      });
      checkbox.dataset.listenerAttached = 'true'; // イベントリスナーがアタッチされたことを記録
    }
  });
}

document.addEventListener("turbo:load", () => {
  // --- トップページのアニメーションをトリガーするコード ---
  const topContent = document.querySelector('.top-content.initial-hidden');
  if (topContent) {
    setTimeout(() => {
      topContent.classList.remove('initial-hidden');
      topContent.classList.add('fade-in-active');
    }, 100);
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

  const recordButton = document.getElementById("record_time_submit");
  const recordTimeField = document.getElementById("record_time_field");
  const timeRecordForm = document.getElementById("time_record_form");

  if (recordButton && recordTimeField && timeRecordForm) {
    recordButton.addEventListener("click", (event) => {
      event.preventDefault(); // デフォルトのフォーム送信を停止

      const timeInSeconds = Math.floor(elapsed / 1000);
      recordTimeField.value = timeInSeconds; // 隠しフィールドに時間をセット

      timeRecordForm.submit(); // フォームをプログラム的に送信する！
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

  // ToDo完了チェックボックスのイベントリスナーを初期化
  initializeTodoCheckboxes();
});

document.addEventListener("turbo:render", () => {
  initializeTodoCheckboxes();
  const flashDiv = document.getElementById("flower-message");
  if (flashDiv && flashDiv.dataset.flashMessage) {
    showMessage(flashDiv.dataset.flashMessage, flashDiv.dataset.flashImage);
  }
});
