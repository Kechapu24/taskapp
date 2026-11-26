
(function () {
    "use strict";

    const messageArea =
        document.getElementById("chatMessageArea");

    if (!messageArea) {
        return;
    }

    // =====================================
    // 削除メニューを閉じる
    // =====================================

    function closeAllMenus() {
        const openedRows =
            messageArea.querySelectorAll(
                ".chat-message-row.is-actions-open"
            );

        openedRows.forEach(function (row) {
            row.classList.remove("is-actions-open");
        });
    }

    // =====================================
    // 削除メニューを開く
    // =====================================

    function openMenu(row) {
        closeAllMenus();
        row.classList.add("is-actions-open");
    }

    function toggleMenu(row) {
        const isOpen =
            row.classList.contains("is-actions-open");

        closeAllMenus();

        if (!isOpen) {
            row.classList.add("is-actions-open");
        }
    }

    // =====================================
    // メッセージクリック
    // =====================================

    messageArea.addEventListener("click", function (event) {

        // 削除フォームの操作中は何もしない
        if (
            event.target.closest(
                'form[action*="/chatDeleteMessage"]'
            )
        ) {
            return;
        }

        // 自分のメッセージ行を取得
        const row = event.target.closest(
            ".chat-message-row.is-own"
        );

        // 自分のメッセージ以外をクリック
        if (!row) {
            closeAllMenus();
            return;
        }

        // 本文または添付ファイルをクリック
        const clickedMessage = event.target.closest(
            ".chat-message-bubble, .chat-attachment-list"
        );

        if (clickedMessage && row.contains(clickedMessage)) {
            toggleMenu(row);
        }
    });

    // =====================================
    // 右クリック
    // =====================================

    messageArea.addEventListener("contextmenu", function (event) {

        const row = event.target.closest(
            ".chat-message-row.is-own"
        );

        // 自分のメッセージ以外は対象外
        if (!row) {
            return;
        }

        // ブラウザ標準の右クリックメニューを無効化
        event.preventDefault();

        openMenu(row);
    });

    // =====================================
    // メッセージ以外をクリック
    // =====================================

    document.addEventListener("click", function (event) {

        if (
            event.target.closest(
                ".chat-message-row.is-own"
            )
        ) {
            return;
        }

        closeAllMenus();
    });

    // =====================================
    // Escapeキー
    // =====================================

    document.addEventListener("keydown", function (event) {

        if (event.key === "Escape") {
            closeAllMenus();
        }
    });

    // =====================================
    // 削除確認モーダル
    // =====================================

    let targetForm = null;

    const backdrop =
        document.createElement("div");

    backdrop.className =
        "chat-delete-modal-backdrop";

    backdrop.setAttribute("aria-hidden", "true");

    const modal =
        document.createElement("div");

    modal.className = "chat-delete-modal";

    modal.setAttribute("role", "dialog");
    modal.setAttribute("aria-modal", "true");
    modal.setAttribute(
        "aria-labelledby",
        "chatDeleteModalTitle"
    );
    modal.setAttribute("tabindex", "-1");

    const icon =
        document.createElement("div");

    icon.className = "chat-delete-modal-icon";
    icon.textContent = "🗑";

    const title =
        document.createElement("h3");

    title.id = "chatDeleteModalTitle";
    title.className = "chat-delete-modal-title";

    title.textContent =
        "メッセージを削除しますか？";

    const description =
        document.createElement("p");

    description.className =
        "chat-delete-modal-description";

    description.textContent =
        "このメッセージを削除します。";

    const actions =
        document.createElement("div");

    actions.className =
        "chat-delete-modal-actions";

    const cancelButton =
        document.createElement("button");

    cancelButton.type = "button";
    cancelButton.className =
        "chat-delete-modal-cancel";

    cancelButton.textContent = "キャンセル";

    const deleteButton =
        document.createElement("button");

    deleteButton.type = "button";
    deleteButton.className =
        "chat-delete-modal-confirm";

    deleteButton.textContent = "削除する";

    actions.appendChild(cancelButton);
    actions.appendChild(deleteButton);

    modal.appendChild(icon);
    modal.appendChild(title);
    modal.appendChild(description);
    modal.appendChild(actions);

    backdrop.appendChild(modal);
    document.body.appendChild(backdrop);

    // =====================================
    // モーダルを開く
    // =====================================

    function openModal(form) {

        targetForm = form;

        deleteButton.disabled = false;
        deleteButton.textContent = "削除する";

        description.textContent =
            "このメッセージを削除します。";

        backdrop.classList.add("is-open");

        backdrop.setAttribute(
            "aria-hidden",
            "false"
        );

        modal.focus();
    }

    // =====================================
    // モーダルを閉じる
    // =====================================

    function closeModal() {

        backdrop.classList.remove("is-open");

        backdrop.setAttribute(
            "aria-hidden",
            "true"
        );

        targetForm = null;

        deleteButton.disabled = false;
        deleteButton.textContent = "削除する";
    }

    // キャンセルボタン
    cancelButton.addEventListener(
        "click",
        closeModal
    );

    // 背景クリック
    backdrop.addEventListener("click", function (event) {

        if (event.target === backdrop) {
            closeModal();
        }
    });

    // =====================================
    // Escapeキーでモーダルを閉じる
    // =====================================

    document.addEventListener("keydown", function (event) {

        if (
            event.key === "Escape" &&
            backdrop.classList.contains("is-open")
        ) {
            closeModal();
        }
    });

    // =====================================
    // 削除フォームをモーダルに接続
    // =====================================

    document.addEventListener(
        "submit",
        function (event) {

            const form = event.target;

            if (!(form instanceof HTMLFormElement)) {
                return;
            }

            if (
                !form.matches(
                    'form[action*="/chatDeleteMessage"]'
                )
            ) {
                return;
            }

            if (!messageArea.contains(form)) {
                return;
            }

            // JSPに設定されている標準confirmを解除
            form.removeAttribute("onsubmit");

            // 通常のフォーム送信を止める
            event.preventDefault();

            // モーダルを開く
            openModal(form);
        },
        true
    );

    // =====================================
    // 削除を非同期で実行
    // =====================================

    deleteButton.addEventListener(
        "click",
        function () {

            if (!targetForm) {
                return;
            }

            const form = targetForm;

            const row =
                form.closest(".chat-message-row");

            deleteButton.disabled = true;
            deleteButton.textContent = "削除中...";

            description.textContent =
                "メッセージを削除しています。";

            // =====================================
            // フォームの値を取得
            // =====================================

            const formData = new FormData(form);
            const params = new URLSearchParams();

            formData.forEach(function (value, key) {

                if (typeof value === "string") {
                    params.append(key, value);
                }
            });

            // =====================================
            // 削除ServletへPOST送信
            // =====================================

            fetch(form.action, {
                method: "POST",
                body: params,
                credentials: "same-origin",
                redirect: "follow",
                headers: {
                    "X-Requested-With": "XMLHttpRequest"
                }
            })

            .then(function (response) {

                const finalUrl =
                    new URL(
                        response.url,
                        window.location.href
                    );

                // 削除処理が成功したか確認
                if (
                    !response.ok ||
                    !finalUrl.pathname.endsWith("/chatMessage")
                ) {
                    throw new Error(
                        "メッセージの削除に失敗しました。HTTP "
                        + response.status
                    );
                }

                return response.text();
            })

            .then(function (html) {

                // モーダルを閉じる
                closeModal();

                // 開いている削除メニューを閉じる
                closeAllMenus();

                // =====================================
                // チャット部分だけを更新
                // =====================================

                if (
                    window.ChatLive &&
                    typeof window.ChatLive.applyServerHtml === "function"
                ) {

                    window.ChatLive.applyServerHtml(
                        html,
                        {
                            scrollToBottom: false
                        }
                    );

                } else if (row) {

                    // 自動更新機能がない場合の代替処理
                    row.classList.add("is-removing");

                    window.setTimeout(function () {
                        row.remove();
                    }, 130);
                }
            })

            .catch(function (error) {

                console.error(
                    "メッセージ削除エラー:",
                    error
                );

                description.textContent =
                    "削除できませんでした。通信状態を確認して、もう一度お試しください。";

                deleteButton.disabled = false;
                deleteButton.textContent = "もう一度試す";
            });
        }
    );

})();
