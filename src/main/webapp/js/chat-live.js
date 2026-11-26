
(function () {
    "use strict";

    // 二重初期化を防止
    if (window.__chatLiveInitialized) {
        return;
    }

    const messageArea = document.getElementById("chatMessageArea");

    if (!messageArea) {
        return;
    }

    const roomId = messageArea.dataset.roomId;
    const latestUrl = messageArea.dataset.latestUrl;

    if (!roomId || !latestUrl) {
        return;
    }

    window.__chatLiveInitialized = true;

    let lastLatestMessageId = Number(
        messageArea.dataset.latestMessageId || 0
    );

    let lastDeletedCount = Number(
        messageArea.dataset.deletedCount || 0
    );

    let checking = false;
    let sending = false;

    const latestEndpoint = new URL(latestUrl, window.location.href);
    const contextPath = latestEndpoint.pathname.replace(/\/chatLatestMessage\/?$/, "");
    const chatMessageUrl = contextPath + "/chatMessage";

    // =========================================
    // スクロール位置
    // =========================================

    function isNearBottom() {
        const remaining =
            messageArea.scrollHeight
            - messageArea.scrollTop
            - messageArea.clientHeight;

        return remaining < 120;
    }

    function scrollToBottom(smooth) {
        requestAnimationFrame(function () {
            messageArea.scrollTo({
                top: messageArea.scrollHeight,
                behavior: smooth ? "smooth" : "auto"
            });
        });
    }

    // =========================================
    // メッセージ行の追加アニメーション
    // =========================================

    function addEnteringRow(list, sourceRow) {
        const row = sourceRow.cloneNode(true);
        row.classList.add("is-entering");

        list.appendChild(row);

        row.addEventListener("animationend", function () {
            row.classList.remove("is-entering");
        }, { once: true });

        return row;
    }

    // =========================================
    // サーバーから取得したHTMLを部分反映
    // 画面全体は再読み込みしない
    // =========================================

    function applyServerHtml(html, options) {
        options = options || {};

        const shouldScroll =
            options.scrollToBottom === true || isNearBottom();

        const parsedDocument = new DOMParser().parseFromString(
            html,
            "text/html"
        );

        const serverMessageArea =
            parsedDocument.getElementById("chatMessageArea");

        if (!serverMessageArea) {
            return false;
        }

        // 次回の比較に使う状態を更新
        if (serverMessageArea.dataset.latestMessageId !== undefined) {
            lastLatestMessageId = Number(
                serverMessageArea.dataset.latestMessageId || 0
            );
            messageArea.dataset.latestMessageId = String(lastLatestMessageId);
        }

        if (serverMessageArea.dataset.deletedCount !== undefined) {
            lastDeletedCount = Number(
                serverMessageArea.dataset.deletedCount || 0
            );
            messageArea.dataset.deletedCount = String(lastDeletedCount);
        }

        const serverRows = Array.from(
            serverMessageArea.querySelectorAll(
                ".chat-message-row[data-message-id]"
            )
        );

        const serverIds = new Set(
            serverRows.map(function (row) {
                return String(row.dataset.messageId);
            })
        );

        let currentList =
            messageArea.querySelector(".chat-message-list");

        const emptyState =
            serverMessageArea.querySelector(".chat-empty-state");

        // サーバー側にメッセージがある場合
        if (serverRows.length > 0) {

            // 空表示を解除してメッセージ一覧を用意
            messageArea.querySelectorAll(".chat-empty-state").forEach(
                function (element) {
                    element.remove();
                }
            );

            if (!currentList) {
                currentList = document.createElement("div");
                currentList.className = "chat-message-list";
                messageArea.appendChild(currentList);
            }

            const currentRows = Array.from(
                currentList.querySelectorAll(
                    ".chat-message-row[data-message-id]"
                )
            );

            const currentMap = new Map();

            currentRows.forEach(function (row) {
                currentMap.set(String(row.dataset.messageId), row);
            });

            // サーバーに存在しないメッセージだけを退場させる
            currentRows.forEach(function (row) {
                const id = String(row.dataset.messageId);

                if (!serverIds.has(id) && !row.classList.contains("is-removing")) {
                    row.classList.add("is-removing");

                    window.setTimeout(function () {
                        row.remove();
                    }, 130);
                }
            });

            // 新着メッセージだけを追加する
            serverRows.forEach(function (serverRow) {
                const id = String(serverRow.dataset.messageId);
                const currentRow = currentMap.get(id);

                if (currentRow) {
                    currentRow.classList.remove("is-removing");
                    return;
                }

                addEnteringRow(currentList, serverRow);
            });

        } else {
            // サーバー側にメッセージが1件もない場合
            if (currentList) {
                const currentRows = Array.from(
                    currentList.querySelectorAll(".chat-message-row")
                );

                currentRows.forEach(function (row) {
                    if (row.classList.contains("is-removing")) {
                        return;
                    }

                    row.classList.add("is-removing");

                    window.setTimeout(function () {
                        row.remove();
                    }, 120);
                });

                window.setTimeout(function () {
                    if (currentList.isConnected) {
                        currentList.remove();
                    }

                    if (
                        emptyState &&
                        !messageArea.querySelector(".chat-empty-state") &&
                        !messageArea.querySelector(".chat-message-list")
                    ) {
                        messageArea.appendChild(
                            emptyState.cloneNode(true)
                        );
                    }
                }, 130);
            } else if (
                emptyState &&
                !messageArea.querySelector(".chat-empty-state")
            ) {
                messageArea.appendChild(emptyState.cloneNode(true));
            }
        }

        if (shouldScroll) {
            scrollToBottom(options.scrollToBottom === true);
        }

        return true;
    }

    // メニュー用JavaScriptからも利用できるようにする
    window.ChatLive = {
        applyServerHtml: applyServerHtml
    };

    // =========================================
    // チャット画面だけを取得して差分反映
    // =========================================

    async function refreshChatMessages(options) {
        const url =
            chatMessageUrl
            + "?roomId="
            + encodeURIComponent(roomId)
            + "&_="
            + Date.now();

        const response = await fetch(url, {
            method: "GET",
            credentials: "same-origin",
            cache: "no-store",
            headers: {
                "X-Requested-With": "XMLHttpRequest"
            }
        });

        if (!response.ok) {
            throw new Error("チャット画面の取得に失敗しました。");
        }

        const html = await response.text();
        return applyServerHtml(html, options);
    }

    // =========================================
    // 新着・削除状態の確認
    // =========================================

    async function checkLatestMessage() {
        if (checking || document.visibilityState !== "visible") {
            return;
        }

        checking = true;

        try {
            const url =
                latestUrl
                + "?roomId="
                + encodeURIComponent(roomId)
                + "&_="
                + Date.now();

            const response = await fetch(url, {
                method: "GET",
                credentials: "same-origin",
                cache: "no-store"
            });

            if (!response.ok) {
                return;
            }

            const data = await response.json();
            const latestMessageId = Number(data.latestMessageId);
            const deletedCount = Number(data.deletedCount);

            const hasNewMessage =
                Number.isFinite(latestMessageId) &&
                latestMessageId !== lastLatestMessageId;

            const hasDeletedMessage =
                Number.isFinite(deletedCount) &&
                deletedCount !== lastDeletedCount;

            if (hasNewMessage || hasDeletedMessage) {
                await refreshChatMessages({
                    scrollToBottom: false
                });
            }

        } catch (error) {
            console.error(
                "チャットの自動更新に失敗しました。",
                error
            );
        } finally {
            checking = false;
        }
    }

    // =========================================
    // メッセージ送信を非同期化
    // =========================================

    const messageForm =
        document.getElementById("chatMessageForm");

    const messageInput =
        document.getElementById("chatMessageInput");

    const fileInput =
        document.getElementById("chatFileInput");

    const selectedFilesArea =
        document.getElementById("chatSelectedFiles");

    const sendButton =
        document.getElementById("chatSendButton");

    if (messageForm && messageInput && sendButton) {
        messageForm.addEventListener("submit", async function (event) {
            const hasText = messageInput.value.trim() !== "";
            const hasFiles =
                fileInput &&
                fileInput.files &&
                fileInput.files.length > 0;

            if (!hasText && !hasFiles) {
                event.preventDefault();
                messageInput.focus();
                return;
            }

            event.preventDefault();

            if (sending) {
                return;
            }

            sending = true;
            sendButton.disabled = true;
            sendButton.textContent = "送信中...";

            try {
                const response = await fetch(messageForm.action, {
                    method: "POST",
                    body: new FormData(messageForm),
                    credentials: "same-origin",
                    redirect: "follow",
                    headers: {
                        "X-Requested-With": "XMLHttpRequest"
                    }
                });

                const finalUrl = new URL(response.url, window.location.href);

                if (
                    !response.ok ||
                    !finalUrl.pathname.endsWith("/chatMessage")
                ) {
                    throw new Error(
                        "メッセージを送信できませんでした。HTTP "
                        + response.status
                    );
                }

                const html = await response.text();
                const applied = applyServerHtml(html, {
                    scrollToBottom: true
                });

                if (!applied) {
                    throw new Error(
                        "送信後のチャット表示を更新できませんでした。"
                    );
                }

                // 成功したときだけ入力内容を消す
                messageInput.value = "";

                if (fileInput) {
                    fileInput.value = "";
                }

                if (selectedFilesArea) {
                    selectedFilesArea.innerHTML = "";
                }

                messageInput.focus();

            } catch (error) {
                console.error(error);
                alert(
                    "メッセージを送信できませんでした。\n"
                    + "入力内容を確認して、もう一度お試しください。"
                );
            } finally {
                sending = false;
                sendButton.disabled = false;
                sendButton.textContent = "送信";
            }
        });
    }

    // =========================================
    // タブに戻ったときも確認
    // =========================================

    document.addEventListener("visibilitychange", function () {
        if (document.visibilityState === "visible") {
            checkLatestMessage();
        }
    });

    // 初回確認
    checkLatestMessage();

    // 4秒ごとに状態だけ確認し、変化時のみ差分反映
    window.setInterval(checkLatestMessage, 4000);

})();
