<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="util.DBConnection" %>

<%@ include file="common/mode.jsp" %>

<%!
    // HTMLエスケープ
    private String escapeHtml(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    // メッセージの改行をHTML表示用に変換
    private String formatMessage(Object value) {
        return escapeHtml(value)
            .replace("\r\n", "\n")
            .replace("\r", "\n")
            .replace("\n", "<br>");
    }

    // ファイル容量の表示
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
// チャットルーム情報
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

// Servletから受け取ったメッセージ一覧
List<Map<String, Object>> messages =
    (List<Map<String, Object>>) request.getAttribute("messages");

if (messages == null) {
    messages = new ArrayList<>();
}

// 新着・削除状態
Object latestMessageIdValue =
    request.getAttribute("latestMessageId");

long latestMessageId =
    latestMessageIdValue instanceof Number
        ? ((Number) latestMessageIdValue).longValue()
        : 0;

Object deletedMessageCountValue =
    request.getAttribute("deletedMessageCount");

long deletedMessageCount =
    deletedMessageCountValue instanceof Number
        ? ((Number) deletedMessageCountValue).longValue()
        : 0;

// ========================================
// 現在のチャットルームを確認
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

                // 個人チャットの場合、相手のIDを取得
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
// 個人チャット相手の名前を取得
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
// グループチャットの未読確認
// ========================================

boolean groupHasUnread = false;

if (!personalMode) {

    String groupUnreadSql =
        "SELECT EXISTS (" +
        "SELECT 1 " +
        "FROM chat_room r " +
        "INNER JOIN chat_room_member rm " +
        "ON rm.chat_room_id = r.chat_room_id " +
        "WHERE r.org_id = ? " +
        "AND r.room_type = 'group' " +
        "AND rm.user_id = ? " +
        "AND EXISTS (" +
        "SELECT 1 FROM chat_message m " +
        "WHERE m.chat_room_id = r.chat_room_id " +
        "AND m.deleted_at IS NULL " +
        "AND m.sender_id IS DISTINCT FROM ? " +
        "AND (rm.last_read_at IS NULL " +
        "OR m.created_at > rm.last_read_at)" +
        ")" +
        ") AS has_unread";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt =
             conn.prepareStatement(groupUnreadSql)) {

        stmt.setInt(1, activeOrgId);
        stmt.setInt(2, loginUserId);
        stmt.setInt(3, loginUserId);

        try (ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                groupHasUnread =
                    rs.getBoolean("has_unread");
            }
        }

    } catch (Exception e) {

        application.log(
            "グループチャットの未読確認に失敗しました。",
            e
        );
    }
}

// ========================================
// 団体メンバー一覧と個人チャット未読確認
// ========================================

List<Map<String, Object>> chatMembers =
    new ArrayList<>();

String memberLoadError = null;

if (!personalMode) {

    String memberSql =
        "SELECT u.user_id, " +
        "u.user_name, " +

        "EXISTS (" +
        "SELECT 1 " +
        "FROM chat_room r " +
        "INNER JOIN chat_room_member rm " +
        "ON rm.chat_room_id = r.chat_room_id " +
        "AND rm.user_id = ? " +

        "WHERE r.org_id = ? " +
        "AND r.room_type = 'direct' " +

        "AND r.direct_user_low_id = LEAST(?, u.user_id) " +
        "AND r.direct_user_high_id = GREATEST(?, u.user_id) " +

        "AND EXISTS (" +
        "SELECT 1 FROM chat_message m " +
        "WHERE m.chat_room_id = r.chat_room_id " +
        "AND m.deleted_at IS NULL " +
        "AND m.sender_id IS DISTINCT FROM ? " +
        "AND (rm.last_read_at IS NULL " +
        "OR m.created_at > rm.last_read_at)" +
        ")" +
        ") AS has_unread " +

        "FROM org_member om " +
        "JOIN users u ON om.user_id = u.user_id " +
        "WHERE om.org_id = ? " +
        "AND u.user_id <> ? " +
        "ORDER BY u.user_name";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt =
             conn.prepareStatement(memberSql)) {

        stmt.setInt(1, loginUserId);
        stmt.setInt(2, activeOrgId);
        stmt.setInt(3, loginUserId);
        stmt.setInt(4, loginUserId);
        stmt.setInt(5, loginUserId);
        stmt.setInt(6, activeOrgId);
        stmt.setInt(7, loginUserId);

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

                member.put(
                    "hasUnread",
                    rs.getBoolean("has_unread")
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

                        <% if (groupHasUnread) { %>

                            <span
                                class="chat-unread-dot"
                                title="新着メッセージがあります"
                                aria-label="未読メッセージあり">
                            </span>

                        <% } %>

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

                            boolean memberHasUnread =
                                Boolean.TRUE.equals(member.get("hasUnread"));

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

                                <% if (memberHasUnread) { %>

                                    <span
                                        class="chat-unread-dot"
                                        title="新着メッセージがあります"
                                        aria-label="未読メッセージあり">
                                    </span>

                                <% } %>

                            </button>

                        <% } %>

                    <% } %>

                </div>

            </aside>

            <!-- =================================
                 右側：会話画面
                 ================================= -->

            <section class="chat-conversation-panel">

                <!-- チャットヘッダー -->

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

                <div
                    class="chat-message-area"
                    id="chatMessageArea"
                    data-room-id="<%= hasActiveRoom ? activeRoomId : "" %>"
                    data-latest-message-id="<%= latestMessageId %>"
                    data-deleted-count="<%= deletedMessageCount %>"
                    data-latest-url="<%= request.getContextPath() %>/chatLatestMessage">

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

                                // 既読人数
                                Object readCountValue =
                                    message.get("readCount");

                                long readCount =
                                    readCountValue instanceof Number
                                        ? ((Number) readCountValue).longValue()
                                        : 0;

                                // 既読対象人数
                                Object recipientCountValue =
                                    message.get("recipientCount");

                                long recipientCount =
                                    recipientCountValue instanceof Number
                                        ? ((Number) recipientCountValue).longValue()
                                        : 0;

                                // 既読ラベル
                                // 未読の場合は空文字
                                String readLabel = "";

                                if (ownMessage) {

                                    if ("direct".equals(activeRoomType)) {

                                        if (recipientCount > 0 &&
                                                readCount >= recipientCount) {

                                            readLabel = "既読";
                                        }

                                    } else if ("group".equals(activeRoomType)) {

                                        if (readCount > 0) {
                                            readLabel = "既読 " + readCount;
                                        }
                                    }
                                }

                                // 添付ファイル一覧
                                List<Map<String, Object>> attachments =
                                    (List<Map<String, Object>>)
                                        message.get("attachments");

                                if (attachments == null) {
                                    attachments = new ArrayList<>();
                                }

                            %>

                                <div
                                    class="chat-message-row <%= ownMessage ? "is-own" : "" %>"
                                    data-message-id="<%= message.get("messageId") %>">

                                    <!-- 送信者名・時刻 -->

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

                                    <!-- =================================
                                         本文と既読表示
                                         ================================= -->

                                    <div class="chat-message-content-row">

                                        <% if (ownMessage) { %>

                                            <span
                                                class="chat-read-status"
                                                data-message-id="<%= message.get("messageId") %>"
                                                style="<%= readLabel.isEmpty()
                                                    ? "display:none;"
                                                    : "display:inline-block;" %>">

                                                <%= escapeHtml(readLabel) %>

                                            </span>

                                        <% } %>

                                        <% if (messageText != null &&
                                                !String.valueOf(messageText).isEmpty()) { %>

                                            <div class="chat-message-bubble">
                                                <%= formatMessage(messageText) %>
                                            </div>

                                        <% } %>

                                    </div>

                                    <!-- =================================
                                         添付ファイル
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

                                                boolean imageAttachment =
                                                    attachmentContentType.startsWith("image/");

                                                String attachmentUrl =
                                                    request.getContextPath()
                                                    + "/chatAttachment?attachmentId="
                                                    + attachmentId;

                                            %>

                                                <% if (imageAttachment) { %>

                                                    <!-- 画像サムネイル -->

                                                    <div
                                                        class="chat-attachment-card has-image"
                                                        style="
                                                            display:flex !important;
                                                            flex-direction:row !important;
                                                            align-items:center !important;
                                                            gap:10px !important;
                                                            width:fit-content !important;
                                                            max-width:100% !important;
                                                            margin-top:8px !important;
                                                            padding:8px !important;
                                                            border-radius:8px !important;
                                                        ">

                                                        <a
                                                            href="<%= attachmentUrl %>&amp;view=inline"
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            title="画像を大きく表示"
                                                            style="
                                                                display:block !important;
                                                                flex:0 0 96px !important;
                                                                width:96px !important;
                                                                height:72px !important;
                                                                max-width:96px !important;
                                                                overflow:hidden !important;
                                                                border-radius:6px !important;
                                                                line-height:0 !important;
                                                            ">

                                                            <img
                                                                src="<%= attachmentUrl %>&amp;view=inline"
                                                                alt="<%= escapeHtml(fileName) %>"
                                                                loading="lazy"
                                                                width="96"
                                                                height="72"
                                                                style="
                                                                    display:block !important;
                                                                    width:96px !important;
                                                                    height:72px !important;
                                                                    min-width:96px !important;
                                                                    min-height:72px !important;
                                                                    max-width:96px !important;
                                                                    max-height:72px !important;
                                                                    object-fit:cover !important;
                                                                    border-radius:6px !important;
                                                                ">

                                                        </a>

                                                        <div
                                                            class="chat-attachment-info"
                                                            style="
                                                                min-width:0 !important;
                                                                flex:1 1 auto !important;
                                                            ">

                                                            <div
                                                                class="chat-attachment-name"
                                                                style="overflow-wrap:anywhere;">

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

                                                    <!-- 画像以外のファイル -->

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

                                    <!-- =================================
                                         自分のメッセージ削除ボタン
                                         ================================= -->

                                    <% if (ownMessage) { %>

                                        <form
                                            method="post"
                                            action="<%= request.getContextPath() %>/chatDeleteMessage"
                                            style="margin-top:5px; align-self:flex-end;"
                                            onsubmit="return confirm('このメッセージを削除しますか？');">

                                            <input
                                                type="hidden"
                                                name="roomId"
                                                value="<%= activeRoomId %>">

                                            <input
                                                type="hidden"
                                                name="messageId"
                                                value="<%= message.get("messageId") %>">

                                            <button
                                                type="submit"
                                                style="
                                                    border:1px solid #d9534f;
                                                    border-radius:5px;
                                                    background:transparent;
                                                    color:#d9534f;
                                                    padding:3px 9px;
                                                    font-size:11px;
                                                    cursor:pointer;
                                                ">

                                                削除

                                            </button>

                                        </form>

                                    <% } %>

                                </div>

                            <% } %>

                        </div>

                    <% } %>

                </div>

                <!-- =================================
                     メッセージ入力欄
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

                            <!-- 添付ボタン -->

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

                        <!-- 選択したファイル -->

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

        <%@ include file="common/footer.jsp" %>

    </main>

</div>

<!-- =================================
     チャット一覧・送信・既読更新
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

    function formatSize(size) {

        if (size < 1024) {
            return size + " B";
        }

        if (size < 1024 * 1024) {
            return (size / 1024).toFixed(1) + " KB";
        }

        return (size / (1024 * 1024)).toFixed(1) + " MB";
    }

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

            if (!hasText && !hasFiles) {

                event.preventDefault();
                messageInput.focus();

                return;
            }

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

    // =================================
    // 既読状況の自動更新
    // =================================

    const activeRoomId =
        <%= hasActiveRoom ? activeRoomId.toString() : "null" %>;

    const activeRoomType =
        "<%= activeRoomType == null ? "" : activeRoomType %>";

    async function refreshReadStatuses() {

        if (!activeRoomId) {
            return;
        }

        // 別タブを表示している間は通信しない
        if (document.visibilityState !== "visible") {
            return;
        }

        try {

            const response = await fetch(
                contextPath
                + "/chatReadStatus?roomId="
                + encodeURIComponent(activeRoomId),
                {
                    method: "GET",
                    credentials: "same-origin",
                    cache: "no-store"
                }
            );

            if (!response.ok) {
                return;
            }

            const statuses = await response.json();

            statuses.forEach(function(status) {

                const messageId =
                    Number(status.messageId);

                const readCount =
                    Number(status.readCount);

                const recipientCount =
                    Number(status.recipientCount);

                const element = document.querySelector(
                    '.chat-read-status[data-message-id="'
                    + messageId
                    + '"]'
                );

                if (!element) {
                    return;
                }

                let label = "";

                // 個人チャット
                if (activeRoomType === "direct") {

                    if (
                        recipientCount > 0 &&
                        readCount >= recipientCount
                    ) {
                        label = "既読";
                    }

                // グループチャット
                } else if (activeRoomType === "group") {

                    if (readCount > 0) {
                        label = "既読 " + readCount;
                    }
                }

                element.textContent = label;

                // 未読なら非表示、既読なら表示
                element.style.display =
                    label === ""
                        ? "none"
                        : "inline-block";

            });

        } catch (error) {

            console.error(
                "既読状況の更新に失敗しました。",
                error
            );
        }
    }

    // 初回取得
    refreshReadStatuses();

    // 4秒ごとに更新
    window.setInterval(
        refreshReadStatuses,
        4000
    );

    // タブに戻った際にも更新
    document.addEventListener(
        "visibilitychange",
        function() {

            if (document.visibilityState === "visible") {
                refreshReadStatuses();
            }
        }
    );

})();
</script>

<!-- 新着・削除確認用JavaScript -->
<script src="<%= request.getContextPath() %>/js/chat-live.js"></script>
<script src="<%= request.getContextPath() %>/js/chat-message-menu.js"></script>
</body>
</html>