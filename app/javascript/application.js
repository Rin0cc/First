import "@hotwired/turbo-rails";
import "./controllers";
import "./analytics";

// --- モーダル関連の関数 ---

// エラーメッセージ用のカスタムモーダルを表示する関数
function showModal(title, message) {
  // 既存のモーダルがあれば削除
  const existingModal = document.querySelector('.modal-container');
  if (existingModal) {
    existingModal.remove();
  }

  // モーダルのHTML要素をJavaScriptで作成
  const modalContainer = document.createElement('div');
  // fixed: 画面に固定, inset-0: 全画面に広げる, z-[9999]: 最前面, flex/items-center/justify-center: 中央揃え, bg-gray-900: 暗い背景, bg-opacity-50: 半透明
  modalContainer.className = 'fixed inset-0 z-[9999] flex items-center justify-center bg-gray-900 bg-opacity-50 transition-opacity duration-300 ease-in-out modal-container is-visible';
  
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
    modalElement.classList.remove('is-visible');
    
    // アニメーション完了後にDOMから要素を削除
    modalElement.addEventListener('transitionend', () => {
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

// ToDoリストのイベントリスナーをセットアップする関数
const setupTodoListeners = () => {
  const todoList = document.querySelector('.todo-list');
  
  if (todoList) {
    // 編集ボタンと削除ボタンのイベントリスナーを、親要素に委譲して設定
    todoList.addEventListener('click', (event) => {
      const target = event.target;
      
      // 削除ボタンの処理
      if (target.classList.contains('btn-delete-todo')) {
        event.preventDefault(); // デフォルトの動作をキャンセル
        const todoItem = target.closest('.todo-list-item');
        if (todoItem) {
          todoItem.remove(); // DOMから要素を削除
        }
      }
      
      // 編集ボタンの処理 (モーダル表示)
      if (target.classList.contains('btn-edit-todo')) {
        event.preventDefault();
        const todoItem = target.closest('.todo-list-item');
        if (todoItem) {
          const taskNameElement = todoItem.querySelector('.task-name');
          const currentTaskName = taskNameElement.textContent.trim();
          
          // モーダルを表示して、現在のタスク名を入力フォームに設定
          showModal('タスクを編集', '新しいタスク名を入力してください');
          const modalContent = document.querySelector('.modal-content');
          const input = document.createElement('input');
          input.type = 'text';
          input.value = currentTaskName;
          input.classList.add('form-input', 'mb-4');
          modalContent.insertBefore(input, modalContent.querySelector('#modal-ok-button'));

          const okButton = modalContent.querySelector('#modal-ok-button');
          okButton.textContent = '更新';
          okButton.addEventListener('click', () => {
            const newTaskName = input.value;
            if (newTaskName.trim() !== '') {
              taskNameElement.textContent = newTaskName; // タスク名を更新
              closeModal(document.querySelector('.modal-container'));
            } else {
              showModal('エラー', 'タスク名は空にできません。');
            }
          });
        }
      }
      
      // チェックボックスの処理
      if (target.classList.contains('todo-checkbox')) {
        const taskNameElement = target.closest('.todo-item-content').querySelector('.task-name');
        if (target.checked) {
          taskNameElement.classList.add('task-completed');
        } else {
          taskNameElement.classList.remove('task-completed');
        }
      }
    });
  }
};

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
  
  // Turbo:loadイベント時にToDoのイベントリスナーを再設定
  setupTodoListeners();
});

document.addEventListener("turbo:render", () => {
  const flashDiv = document.getElementById("flower-message");
  if (flashDiv && flashDiv.dataset.flashMessage) {
    showMessage(flashDiv.dataset.flashMessage, flashDiv.dataset.flashImage);
  }
});