
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="util.DBConnection" %>

<%@ include file="common/mode.jsp" %>

<%!
    // HTMLに表示する文字列をエスケープする
    private String escapeHtml(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    // メッセージ内の改行をHTML表示用に変換する
    private String formatMessage(Object value) {
        return escapeHtml(value)
            .replace("\r\n", "\n")
            .replace("\r", "\n")
            .replace("\n", "<br>");
    }

    // ファイル容量を読みやすい形式に変換する
    private String formatFileSize(Object value) {
        if (!(value instanceof Number)) return "";

        long size = ((Number) value).longValue();

        if (size < 1024) {
            return size + " B";
        }

        if (size < 1024 * 1024) {
            return String.format(
                java.util.Locale.JAPAN,
                "%.1f KB",
                size / 1024.0
            );
        }

        return String.format(
            java.util.Locale.JAPAN,
            "%.1f MB",
            size / (1024.0 * 1024.0)
        );
    }
%>

<%
request.setCharacterEncoding("UTF-8");

request.setAttribute("pageTitle", "チャット");
request.setAttribute("currentPage", "chat");

// ========================================
// チャットルーム情報を取得
// ========================================

Long activeRoomId = null;

Object roomIdValue =
    request.getAttribute("activeRoomId");

if (roomIdValue instanceof Number) {
    activeRoomId =
        ((Number) roomIdValue).longValue();
}

String activeRoomType = null;
Integer activeDirectUserId = null;
String activeDirectUserName = null;

String roomLoadError = null;

// Servletから渡されたメッセージ一覧
List<Map<String, Object>> messages =
    (List<Map<String, Object>>) request.getAttribute("messages");

if (messages == null) {
    messages = new ArrayList<>();
}

// ========================================
// 現在開いているチャットルームを確認
// ========================================

if (activeRoomId != null && !personalMode) {

    String roomSql =
        "SELECT r.room_type, " +
        "r.direct_user_low_id, " +
        "r.direct_user_high_id " +
        "FROM chat_room r " +
        "INNER JOIN chat_room_member rm " +
        "ON r.chat_room_id = rm.chat_room_id " +
        "WHERE r.chat_room_id = ? " +
        "AND rm.user_id = ? " +
        "AND r.org_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(roomSql)) {

        stmt.setLong(1, activeRoomId);
        stmt.setInt(2, loginUserId);
        stmt.setInt(3, activeOrgId);

        try (ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {

                activeRoomType =
                    rs.getString("room_type");

                // 個人チャットの場合、相手のユーザーIDを取得
                if ("direct".equals(activeRoomType)) {

                    int lowUserId =
                        rs.getInt("direct_user_low_id");

                    int highUserId =
                        rs.getInt("direct_user_high_id");

                    activeDirectUserId =
                        (lowUserId == loginUserId)
                            ? highUserId
                            : lowUserId;
                }

            } else {

                activeRoomId = null;
                messages = new ArrayList<>();

                roomLoadError =
                    "チャットルームを確認できませんでした。";
            }
        }

    } catch (Exception e) {

        application.log(
            "チャットルーム情報の取得に失敗しました。",
            e
        );

        activeRoomId = null;
        messages = new ArrayList<>();

        roomLoadError =
            "チャットルームの読み込みに失敗しました。";
    }
}

// ========================================
// 個人チャットの相手の名前を取得
// ========================================

if (activeDirectUserId != null) {

    String userSql =
        "SELECT user_name FROM users WHERE user_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(userSql)) {

        stmt.setInt(1, activeDirectUserId);

        try (ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                activeDirectUserName =
                    rs.getString("user_name");
            }
        }

    } catch (Exception e) {

        application.log(
            "チャット相手の名前の取得に失敗しました。",
            e
        );
    }

    if (activeDirectUserName == null) {
        activeDirectUserName = "ユーザー";
    }
}

// ========================================
// チャットヘッダーの表示情報
// ========================================

String activeHeaderName = "チャット";
String activeHeaderDescription =
    "チャットルームを選択してください";

String activeHeaderAvatar = "?";

if ("group".equals(activeRoomType)) {

    activeHeaderName = "団体全体";

    activeHeaderDescription =
        "団体メンバー全員のグループチャット";

    activeHeaderAvatar = "全";

} else if ("direct".equals(activeRoomType)) {

    activeHeaderName = activeDirectUserName;
    activeHeaderDescription = "個人チャット";

    activeHeaderAvatar =
        activeDirectUserName.isEmpty()
            ? "?"
            : activeDirectUserName.substring(0, 1);
}

// ========================================
// 現在の団体に所属するメンバー一覧
// ========================================

List<Map<String, Object>> chatMembers =
    new ArrayList<>();

String memberLoadError = null;

if (!personalMode) {

    String memberSql =
        "SELECT u.user_id, u.user_name " +
        "FROM org_member om " +
        "JOIN users u ON om.user_id = u.user_id " +
        "WHERE om.org_id = ? " +
        "AND u.user_id <> ? " +
        "ORDER BY u.user_name";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt =
             conn.prepareStatement(memberSql)) {

        stmt.setInt(1, activeOrgId);
        stmt.setInt(2, loginUserId);

        try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> member =
                    new HashMap<>();

                member.put(
                    "userId",
                    rs.getInt("user_id")
                );

                member.put(
                    "userName",
                    rs.getString("user_name")
                );

                chatMembers.add(member);
            }
        }

    } catch (Exception e) {

        application.log(
            "チャットメンバーの取得に失敗しました。",
            e
        );

        memberLoadError =
            "メンバー一覧を取得できませんでした。";
    }
}

// ========================================
// 表示用設定
// ========================================

SimpleDateFormat dateFormat =
    new SimpleDateFormat("yyyy/MM/dd HH:mm");

boolean hasActiveRoom =
    activeRoomId != null && activeRoomType != null;

%>

<jsp:include page="common/theme.jsp" />

<!DOCTYPE html>
<html lang="ja">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

    <title>チャット - タスク管理</title>

    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/chat.css">

</head>

<body
    class="${themeValue}-theme font-${themeFontSize} chat-page-body"
    style="--custom-bg-color: ${themeBgColor};
           --custom-text-color: ${themeTextColor};">

<div class="app-container">

    <!-- 共通サイドメニュー -->

    <%@ include file="common/sidebar.jsp" %>

    <main class="main-content chat-main-content">

        <!-- 共通ヘッダー -->

        <%@ include file="common/header.jsp" %>

        <div class="chat-workspace">

            <!-- =================================
                 左側：チャット一覧
                 ================================= -->

            <aside class="chat-list-panel">

                <div class="chat-list-header">
                    <h2>チャット</h2>
                </div>

                <div class="chat-list-scroll">

                    <!-- グループチャット -->

                    <div class="chat-section-title">
                        グループチャット
                    </div>

                    <button
                        type="button"
                        class="chat-list-item <%= "group".equals(activeRoomType) ? "active" : "" %>"
                        data-chat-type="group"
                        data-chat-name="団体全体"
                        <%= personalMode ? "disabled" : "" %>>

                        <span class="chat-avatar group-avatar">
                            全
                        </span>

                        <span class="chat-item-info">

                            <span class="chat-item-name">
                                団体全体
                            </span>

                            <span class="chat-item-description">
                                団体メンバー全員
                            </span>

                        </span>

                    </button>

                    <!-- 個人チャット -->

                    <div class="chat-section-title">
                        個人チャット
                    </div>

                    <% if (personalMode) { %>

                        <div class="chat-list-message">

                            団体モードに切り替えると、
                            メンバーを選択できます。

                        </div>

                    <% } else if (memberLoadError != null) { %>

                        <div class="chat-list-message error">

                            <%= escapeHtml(memberLoadError) %>

                        </div>

                    <% } else if (chatMembers.isEmpty()) { %>

                        <div class="chat-list-message">

                            他のメンバーはいません。

                        </div>

                    <% } else { %>

                        <% for (Map<String, Object> member : chatMembers) {

                            int memberId =
                                ((Number) member.get("userId")).intValue();

                            String memberName =
                                String.valueOf(member.get("userName"));

                            String initial =
                                memberName.isEmpty()
                                    ? "?"
                                    : memberName.substring(0, 1);

                            boolean selectedMember =
                                activeDirectUserId != null &&
                                activeDirectUserId.intValue() == memberId;

                        %>

                            <button
                                type="button"
                                class="chat-list-item <%= selectedMember ? "active" : "" %>"
                                data-chat-type="direct"
                                data-user-id="<%= memberId %>"
                                data-chat-name="<%= escapeHtml(memberName) %>">

                                <span class="chat-avatar">
                                    <%= escapeHtml(initial) %>
                                </span>

                                <span class="chat-item-info">

                                    <span class="chat-item-name">
                                        <%= escapeHtml(memberName) %>
                                    </span>

                                    <span class="chat-item-description">
                                        個人チャット
                                    </span>

                                </span>

                            </button>

                        <% } %>

                    <% } %>

                </div>

            </aside>

            <!-- =================================
                 右側：チャット画面
                 ================================= -->

            <section class="chat-conversation-panel">

                <!-- チャット上部 -->

                <div class="chat-conversation-header">

                    <div
                        class="chat-header-avatar"
                        id="chatHeaderAvatar">

                        <%= escapeHtml(activeHeaderAvatar) %>

                    </div>

                    <div class="chat-header-info">

                        <h2 id="chatHeaderName">
                            <%= escapeHtml(activeHeaderName) %>
                        </h2>

                        <p id="chatHeaderDescription">
                            <%= escapeHtml(activeHeaderDescription) %>
                        </p>

                    </div>

                </div>

                <!-- =================================
                     メッセージ表示領域
                     ================================= -->

                <div class="chat-message-area" id="chatMessageArea">

                    <% if (personalMode) { %>

                        <div class="chat-empty-state">

                            <div class="chat-empty-icon">
                                💬
                            </div>

                            <h3>
                                団体モードを選択してください
                            </h3>

                            <p>
                                画面左下のユーザー情報から
                                団体を選択できます。
                            </p>

                        </div>

                    <% } else if (!hasActiveRoom) { %>

                        <div class="chat-empty-state">

                            <div class="chat-empty-icon">
                                💬
                            </div>

                            <h3>
                                <%= roomLoadError != null
                                    ? escapeHtml(roomLoadError)
                                    : "チャットを選択してください" %>
                            </h3>

                            <p>
                                左側から団体全体または
                                個人チャットの相手を選択してください。
                            </p>

                        </div>

                    <% } else if (messages.isEmpty()) { %>

                        <div class="chat-empty-state">

                            <div class="chat-empty-icon">
                                💬
                            </div>

                            <h3>
                                <%= escapeHtml(activeHeaderName) %>
                            </h3>

                            <p>
                                まだメッセージはありません。
                                最初のメッセージを送信してみましょう。
                            </p>

                        </div>

                    <% } else { %>

                        <div class="chat-message-list">

                            <% for (Map<String, Object> message : messages) {

                                Object senderIdValue =
                                    message.get("senderId");

                                boolean ownMessage =
                                    senderIdValue instanceof Number &&
                                    ((Number) senderIdValue).intValue()
                                        == loginUserId;

                                String senderName =
                                    String.valueOf(
                                        message.get("senderName")
                                    );

                                Object messageText =
                                    message.get("messageText");

                                Timestamp createdAt =
                                    (Timestamp) message.get("createdAt");

                                // 添付ファイル一覧
                                List<Map<String, Object>> attachments =
                                    (List<Map<String, Object>>)
                                        message.get("attachments");

                                if (attachments == null) {
                                    attachments = new ArrayList<>();
                                }

                            %>

                                <div class="chat-message-row <%= ownMessage ? "is-own" : "" %>">

                                    <div class="chat-message-meta">

                                        <span class="chat-message-sender">
                                            <%= escapeHtml(
                                                ownMessage
                                                    ? "自分"
                                                    : senderName
                                            ) %>
                                        </span>

                                        <span class="chat-message-time">
                                            <%= createdAt == null
                                                ? ""
                                                : dateFormat.format(createdAt) %>
                                        </span>

                                    </div>

                                    <!-- メッセージ本文 -->

                                    <% if (messageText != null &&
                                            !String.valueOf(messageText).isEmpty()) { %>

                                        <div class="chat-message-bubble">
                                            <%= formatMessage(messageText) %>
                                        </div>

                                    <% } %>

                                    <!-- =================================
                                         添付ファイル表示
                                         ================================= -->

                                    <% if (!attachments.isEmpty()) { %>

                                        <div class="chat-attachment-list">

                                            <% for (
                                                Map<String, Object> attachment
                                                : attachments
                                            ) {

                                                Object attachmentId =
                                                    attachment.get("attachmentId");

                                                Object fileName =
                                                    attachment.get("originalFileName");

                                                Object fileSize =
                                                    attachment.get("fileSize");

                                                String attachmentContentType =
                                                    String.valueOf(
                                                        attachment.get("contentType")
                                                    );

                                                // 画像ファイルか判定
                                                boolean imageAttachment =
                                                    attachmentContentType.startsWith("image/");

                                                String attachmentUrl =
                                                    request.getContextPath()
                                                    + "/chatAttachment?attachmentId="
                                                    + attachmentId;

                                            %>

                                                <% if (imageAttachment) { %>

                                                    <!-- 画像用の小型カード -->

                                                    <div
                                                        class="chat-attachment-card has-image"
                                                        style="
                                                            display: flex !important;
                                                            flex-direction: row !important;
                                                            align-items: center !important;
                                                            gap: 10px !important;
                                                            width: fit-content !important;
                                                            max-width: 100% !important;
                                                            margin-top: 8px !important;
                                                            padding: 8px !important;
                                                            border-radius: 8px !important;
                                                        ">

                                                        <!-- 96×72pxの画像サムネイル -->

                                                        <a
                                                            href="<%= attachmentUrl %>&amp;view=inline"
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            title="画像を大きく表示"
                                                            style="
                                                                display: block !important;
                                                                flex: 0 0 96px !important;
                                                                width: 96px !important;
                                                                height: 72px !important;
                                                                max-width: 96px !important;
                                                                overflow: hidden !important;
                                                                border-radius: 6px !important;
                                                                line-height: 0 !important;
                                                            ">

                                                            <img
                                                                src="<%= attachmentUrl %>&amp;view=inline"
                                                                alt="<%= escapeHtml(fileName) %>"
                                                                loading="lazy"
                                                                width="96"
                                                                height="72"
                                                                style="
                                                                    display: block !important;
                                                                    width: 96px !important;
                                                                    height: 72px !important;
                                                                    min-width: 96px !important;
                                                                    min-height: 72px !important;
                                                                    max-width: 96px !important;
                                                                    max-height: 72px !important;
                                                                    object-fit: cover !important;
                                                                    border-radius: 6px !important;
                                                                ">

                                                        </a>

                                                        <!-- 画像のファイル情報 -->

                                                        <div
                                                            class="chat-attachment-info"
                                                            style="
                                                                min-width: 0 !important;
                                                                flex: 1 1 auto !important;
                                                            ">

                                                            <div class="chat-attachment-name"
                                                                 style="
                                                                    overflow-wrap: anywhere;
                                                                 ">

                                                                <%= escapeHtml(fileName) %>

                                                            </div>

                                                            <div class="chat-attachment-size">

                                                                <%= escapeHtml(
                                                                    formatFileSize(fileSize)
                                                                ) %>

                                                            </div>

                                                            <a
                                                                class="chat-attachment-link"
                                                                href="<%= attachmentUrl %>">

                                                                ダウンロード

                                                            </a>

                                                        </div>

                                                    </div>

                                                <% } else { %>

                                                    <!-- 画像以外の添付ファイル -->

                                                    <div class="chat-attachment-card">

                                                        <span class="chat-attachment-icon">
                                                            📎
                                                        </span>

                                                        <div class="chat-attachment-info">

                                                            <div class="chat-attachment-name">

                                                                <%= escapeHtml(fileName) %>

                                                            </div>

                                                            <div class="chat-attachment-size">

                                                                <%= escapeHtml(
                                                                    formatFileSize(fileSize)
                                                                ) %>

                                                            </div>

                                                            <a
                                                                class="chat-attachment-link"
                                                                href="<%= attachmentUrl %>">

                                                                ダウンロード

                                                            </a>

                                                        </div>

                                                    </div>

                                                <% } %>

                                            <% } %>

                                        </div>

                                    <% } %>

                                </div>

                            <% } %>

                        </div>

                    <% } %>

                </div>

                <!-- =================================
                     メッセージ入力・添付欄
                     ================================= -->

                <div class="chat-input-area">

                    <% if (hasActiveRoom) { %>

                        <form
                            id="chatMessageForm"
                            class="chat-input-wrapper"
                            method="post"
                            enctype="multipart/form-data"
                            action="<%= request.getContextPath() %>/chatMessage">

                            <input
                                type="hidden"
                                name="roomId"
                                value="<%= activeRoomId %>">

                            <!-- ファイル選択ボタン -->

                            <label
    for="chatFileInput"
    class="chat-attach-button"
    data-tooltip="ファイルを添付"
    aria-label="ファイルを添付"
    tabindex="0">

    📎

</label>

                            <input
                                type="file"
                                id="chatFileInput"
                                name="files"
                                class="chat-file-input"
                                multiple
                                accept=".png,.jpg,.jpeg,.gif,.webp,.pdf,.txt,.csv,.docx,.xlsx,.pptx">

                            <!-- メッセージ入力 -->

                            <textarea
                                id="chatMessageInput"
                                name="messageText"
                                class="chat-message-input"
                                placeholder="メッセージを入力..."
                                maxlength="2000"></textarea>

                            <button
                                type="submit"
                                class="chat-send-button"
                                id="chatSendButton">

                                送信

                            </button>

                        </form>

                        <!-- 選択したファイルの表示 -->

                        <div
                            id="chatSelectedFiles"
                            class="chat-selected-files"
                            aria-live="polite">
                        </div>

                        <p class="chat-input-note">

                            Enterで送信、Shift + Enterで改行できます。
                            最大5ファイル・1ファイル10MBまで。

                        </p>

                    <% } else { %>

                        <div class="chat-input-wrapper">

                            <textarea
                                class="chat-message-input"
                                placeholder="チャットルームを選択してください"
                                disabled></textarea>

                            <button
                                type="button"
                                class="chat-send-button"
                                disabled>

                                送信

                            </button>

                        </div>

                        <p class="chat-input-note">

                            チャットルームを選択すると
                            メッセージを送信できます。

                        </p>

                    <% } %>

                </div>

            </section>

        </div>

        <!-- 共通フッター -->

        <%@ include file="common/footer.jsp" %>

    </main>

</div>

<!-- =================================
     チャット一覧・送信処理
     ================================= -->

<script>

(function() {

    const contextPath =
        "<%= request.getContextPath() %>";

    // =================================
    // グループチャット
    // =================================

    const groupItem =
        document.querySelector(
            '.chat-list-item[data-chat-type="group"]'
        );

    if (groupItem && !groupItem.disabled) {

        groupItem.addEventListener("click", function() {

            window.location.href =
                contextPath + "/chatRoom";

        });
    }

    // =================================
    // 個人チャット
    // =================================

    const directItems =
        document.querySelectorAll(
            '.chat-list-item[data-chat-type="direct"]'
        );

    directItems.forEach(function(item) {

        item.addEventListener("click", function() {

            const userId = item.dataset.userId;

            if (!userId) {
                return;
            }

            window.location.href =
                contextPath
                + "/chatRoom?userId="
                + encodeURIComponent(userId);

        });

    });

    // =================================
    // メッセージ表示位置
    // =================================

    const messageArea =
        document.getElementById("chatMessageArea");

    if (messageArea) {

        messageArea.scrollTop =
            messageArea.scrollHeight;

    }

    // =================================
    // 添付ファイル選択・表示
    // =================================

    const fileInput =
        document.getElementById("chatFileInput");

    const selectedFilesArea =
        document.getElementById("chatSelectedFiles");

    // ファイル容量を表示用に変換
    function formatSize(size) {

        if (size < 1024) {
            return size + " B";
        }

        if (size < 1024 * 1024) {
            return (size / 1024).toFixed(1) + " KB";
        }

        return (size / (1024 * 1024)).toFixed(1) + " MB";
    }

    // 選択されたファイル一覧を表示
    function showSelectedFiles() {

        if (!fileInput || !selectedFilesArea) {
            return;
        }

        selectedFilesArea.innerHTML = "";

        const files = Array.from(fileInput.files);

        if (files.length === 0) {
            return;
        }

        files.forEach(function(file) {

            const item = document.createElement("div");
            item.className = "chat-file-preview";

            const name = document.createElement("span");
            name.className = "chat-file-preview-name";

            name.textContent =
                file.name + " (" + formatSize(file.size) + ")";

            item.appendChild(name);
            selectedFilesArea.appendChild(item);

        });

        // 合計容量を確認
        const totalSize = files.reduce(
            function(total, file) {
                return total + file.size;
            },
            0
        );

        if (files.length > 5) {

            alert("添付できるファイルは最大5個です。");

            fileInput.value = "";
            selectedFilesArea.innerHTML = "";

            return;
        }

        if (files.some(function(file) {
            return file.size > 10 * 1024 * 1024;
        })) {

            alert("1つのファイルは10MB以下にしてください。");

            fileInput.value = "";
            selectedFilesArea.innerHTML = "";

            return;
        }

        if (totalSize > 30 * 1024 * 1024) {

            alert("添付ファイルの合計容量は30MB以下にしてください。");

            fileInput.value = "";
            selectedFilesArea.innerHTML = "";
        }
    }

    if (fileInput) {

        fileInput.addEventListener(
            "change",
            showSelectedFiles
        );

    }

    // =================================
    // メッセージ送信
    // =================================

    const messageForm =
        document.getElementById("chatMessageForm");

    const messageInput =
        document.getElementById("chatMessageInput");

    const sendButton =
        document.getElementById("chatSendButton");

    if (messageForm && messageInput && sendButton) {

        messageForm.addEventListener("submit", function(event) {

            const hasText =
                messageInput.value.trim() !== "";

            const hasFiles =
                fileInput &&
                fileInput.files.length > 0;

            // 本文もファイルもない場合は送信しない
            if (!hasText && !hasFiles) {

                event.preventDefault();

                messageInput.focus();

                return;
            }

            // 二重送信を防ぐ
            sendButton.disabled = true;
            sendButton.textContent = "送信中...";

        });

        // Enterで送信、Shift + Enterで改行
        messageInput.addEventListener("keydown", function(event) {

            if (
                event.key === "Enter" &&
                !event.shiftKey &&
                !event.isComposing
            ) {

                event.preventDefault();

                const hasText =
                    messageInput.value.trim() !== "";

                const hasFiles =
                    fileInput &&
                    fileInput.files.length > 0;

                if (hasText || hasFiles) {
                    messageForm.requestSubmit();
                }

            }

        });

    }

})();

</script>

</body>
</html>
