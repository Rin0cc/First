import "@hotwired/turbo-rails";
import "./controllers";

// showMessage 関数を document.addEventListener("turbo:load", の外に定義
// これで、どこからでもアクセスできるようになります。
function showMessage(text, imageName = null) { // 引数名をimageUrlからimageNameに変更
  const flashDiv = document.getElementById("flower-message");
  // HTMLに画像パスを埋め込んだ要素のIDを取得
  const imageDataElement = document.getElementById("flower-message"); // flower-message要素自体にデータ属性を追加した場合

  if (flashDiv && imageDataElement) {
    let imageUrl = null;

    if (imageName) {
      // data属性から対応するURLを取得
      // 例: "Flowerseeds.png" -> data-flowerseeds-url
      // ここで、Railsのimage_urlヘルパーで生成された正しいパスを取得します。
      // data属性のキーはハイフンケースになるので、それに合わせます。
      const key = imageName.replace(/\.png$/, '').replace(/([A-Z])/g, '-$1').toLowerCase(); // "Flowerseeds.png" -> "flowerseeds", "FullBloom1.png" -> "full-bloom1"
      imageUrl = imageDataElement.dataset[`${key}Url`];

      // FullBloom1.pngやFullBloom2.pngのように数字を含む場合も正しく処理されるように、
      // datasetのキー名を微調整する必要があるかもしれません。
      // もし `data.image` が "FullBloom1.png" のように返ってくる場合、
      // datasetのキーは "fullbloom1Url" になるはずです。
      // なので、keyの変換をより汎用的にします。
      const normalizedKey = imageName.toLowerCase().replace(/\.png$/, '').replace(/(\d)/, '-$1'); // 例: "flowerseeds", "fullbloom-1"
      imageUrl = imageDataElement.dataset[`${normalizedKey.replace(/-/g, '')}Url`] || // ハイフンなしで試す（flowerseedsUrl）
                 imageDataElement.dataset[`${normalizedKey}Url`]; // ハイフンありで試す（fullbloom-1Url）
                                                                  // もしそれでも取得できない場合は、Rails側でdata属性の名前を合わせる必要があります。
                                                                  // 例: data-fullbloom-1-url にするなど。

      // もし `data.image` が既に `/assets/xxx-hash.png` のような完全なパスの場合（Rails側の設定による）
      // その場合は、以下のように直接使うことも可能です
      if (!imageUrl && imageName.startsWith('/assets/')) { // image_urlヘルパーを使わない場合
        imageUrl = imageName;
      }

      console.log(`Debug: imageName=${imageName}, key=${key}, normalizedKey=${normalizedKey}, resolvedImageUrl=${imageUrl}`); // デバッグログ
    }

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
    console.error("#flower-message または関連要素が見つかりません！");
  }
}

document.addEventListener("turbo:load", () => {
  // ▼ メニューの表示・非表示 (変更なし)
  const toggle = document.getElementById("menu-toggle");
  const menu = document.getElementById("nav-menu");

  if (toggle && menu) {
    toggle.addEventListener("click", () => {
      menu.classList.toggle("active");
    });
  }

  // ▼ タイマーの設定 (変更なし)
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

  // ▼ 記録ボタンの処理 (showMessageの引数のみ変更)
  const recordButton = document.getElementById("record");
  const flowerId = document.getElementById("timer-section")?.dataset.flowerId;

  recordButton?.addEventListener("click", () => {
    const taskName = document.querySelector("input[name='record[task_name]']")?.value || "";
    const time = Math.floor(elapsed / 1000); // 秒単位に変換
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
          const imageName = data.image; // /assets/ を付けず、画像の名前だけを渡す
          showMessage(data.message, imageName); // showMessageに画像名を渡す
        } else if (data.status === "short_time") {
          showMessage(data.message);
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