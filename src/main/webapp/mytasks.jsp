<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.TaskDAO" %>
<%@ page import="model.TaskFilter" %>
<%@ include file="common/mode.jsp" %>
<jsp:include page="common/theme.jsp" />

<%!
    private String escapeHtml(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String formatTaskDate(Object value) {
        if (value == null) return "";

        String date = String.valueOf(value);

        if (date.length() >= 10) {
            return date.substring(0, 10).replace('-', '/');
        }

        return date;
    }
%>

<%
request.setCharacterEncoding("UTF-8");
request.setAttribute("pageTitle", "マイタスク");
request.setAttribute("currentPage", "mytasks");

final String personalDbUrl = "jdbc:postgresql://172.16.1.119:5432/taskapp";
final String personalDbUser = "taskuser";
final String personalDbPassword = "taskpass";
final int currentUserId = loginUserId;


// ==========================================
// 右側：個人タスクの非同期処理
// ==========================================

String action = request.getParameter("action");

if (action != null) {

    try {
        Class.forName("org.postgresql.Driver");

        try (Connection conn = DriverManager.getConnection(
                personalDbUrl, personalDbUser, personalDbPassword)) {

            // 個人タスク一覧
            if ("getPersonalTasks".equals(action)) {

                response.setContentType("text/html; charset=UTF-8");

                String sql =
                    "SELECT personal_task_id, task_name, status, "
                    + "TO_CHAR(due_date, 'YYYY-MM-DD') AS fmt_due_date "
                    + "FROM personal_task "
                    + "WHERE user_id = ? "
                    + "ORDER BY due_date ASC NULLS LAST, personal_task_id ASC";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

                    pstmt.setInt(1, currentUserId);

                    try (ResultSet rs = pstmt.executeQuery()) {

                        boolean hasTask = false;

                        while (rs.next()) {

                            hasTask = true;

                            int taskId = rs.getInt("personal_task_id");
                            String taskName = rs.getString("task_name");
                            String status = rs.getString("status");
                            String dueDate = rs.getString("fmt_due_date");

                            if (dueDate == null) dueDate = "";
                            if (status == null) status = "進行中";

                            String dateLabel = "";

                            if (!dueDate.isEmpty()) {

                                String[] parts = dueDate.split("-");

                                if (parts.length == 3) {
                                    dateLabel =
                                        Integer.parseInt(parts[1]) + "/"
                                        + Integer.parseInt(parts[2]);
                                }
                            }

                            boolean isCompleted = "完了".equals(status);
%>

<div class="personal-task-item">

    <div class="pti-left">

        <input
            type="checkbox"
            class="task-check"
            onchange="togglePersonalTask(<%= taskId %>, this.checked)"
            <%= isCompleted ? "checked" : "" %>
        >

        <span class="pti-name <%= isCompleted ? "completed-task" : "" %>">
            <%= escapeHtml(taskName) %>
        </span>

    </div>

    <div class="pti-right">

        <% if (!dateLabel.isEmpty()) { %>
            <span class="pti-info">
                📅 <%= escapeHtml(dateLabel) %>
            </span>
        <% } %>

        <button
            type="button"
            class="task-menu-trigger"
            onclick="toggleTaskMenu(this)"
            aria-label="タスクメニュー"
        >
            ⋮
        </button>

        <div class="task-dropdown-menu">

            <button
                type="button"
                class="dropdown-edit-item"
                data-task-id="<%= taskId %>"
                data-task-name="<%= escapeHtml(taskName) %>"
                data-due-date="<%= escapeHtml(dueDate) %>"
                onclick="openEditModal(this)"
            >
                編集
            </button>

            <button
                type="button"
                class="dropdown-delete-item"
                data-task-id="<%= taskId %>"
                data-task-name="<%= escapeHtml(taskName) %>"
                onclick="openDeleteModal(this)"
            >
                削除
            </button>

        </div>

    </div>

</div>

<%
                        }

                        if (!hasTask) {
%>

<div class="personal-task-empty">
    個人タスクはまだ登録されていません。
</div>

<%
                        }
                    }
                }
            }


            // 個人タスク追加
            else if ("addPersonalTask".equals(action)) {

                String taskName = request.getParameter("taskName");
                String dueDate = request.getParameter("dueDate");

                if (taskName == null || taskName.trim().isEmpty()) {
                    response.sendError(400, "タスク名を入力してください。");
                    return;
                }

                String sql =
                    "INSERT INTO personal_task "
                    + "(user_id, task_name, status, due_date) "
                    + "VALUES (?, ?, '進行中', NULLIF(?, '')::DATE)";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

                    pstmt.setInt(1, currentUserId);
                    pstmt.setString(2, taskName.trim());
                    pstmt.setString(3, dueDate == null ? "" : dueDate);

                    pstmt.executeUpdate();
                }
            }


            // 個人タスク編集
            else if ("editPersonalTask".equals(action)) {

                String taskIdText = request.getParameter("taskId");
                String taskName = request.getParameter("taskName");
                String dueDate = request.getParameter("dueDate");

                if (taskName == null || taskName.trim().isEmpty()) {
                    response.sendError(400, "タスク名を入力してください。");
                    return;
                }

                int taskId;

                try {
                    taskId = Integer.parseInt(taskIdText);
                } catch (Exception invalidId) {
                    response.sendError(400, "タスクIDが不正です。");
                    return;
                }

                String sql =
                    "UPDATE personal_task "
                    + "SET task_name = ?, "
                    + "due_date = NULLIF(?, '')::DATE "
                    + "WHERE personal_task_id = ? AND user_id = ?";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

                    pstmt.setString(1, taskName.trim());
                    pstmt.setString(2, dueDate == null ? "" : dueDate);
                    pstmt.setInt(3, taskId);
                    pstmt.setInt(4, currentUserId);

                    pstmt.executeUpdate();
                }
            }


            // 個人タスク完了状態変更
            else if ("togglePersonalTask".equals(action)) {

                String taskIdText = request.getParameter("taskId");

                boolean isChecked =
                    Boolean.parseBoolean(request.getParameter("isChecked"));

                int taskId;

                try {
                    taskId = Integer.parseInt(taskIdText);
                } catch (Exception invalidId) {
                    response.sendError(400, "タスクIDが不正です。");
                    return;
                }

                String sql =
                    "UPDATE personal_task SET status = ? "
                    + "WHERE personal_task_id = ? AND user_id = ?";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

                    pstmt.setString(1, isChecked ? "完了" : "進行中");
                    pstmt.setInt(2, taskId);
                    pstmt.setInt(3, currentUserId);

                    pstmt.executeUpdate();
                }
            }


            // 個人タスク削除
            else if ("deletePersonalTask".equals(action)) {

                String taskIdText = request.getParameter("taskId");

                int taskId;

                try {
                    taskId = Integer.parseInt(taskIdText);
                } catch (Exception invalidId) {
                    response.sendError(400, "タスクIDが不正です。");
                    return;
                }

                String sql =
                    "DELETE FROM personal_task "
                    + "WHERE personal_task_id = ? AND user_id = ?";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

                    pstmt.setInt(1, taskId);
                    pstmt.setInt(2, currentUserId);

                    pstmt.executeUpdate();
                }
            }

            else {
                response.sendError(400, "不明な操作です。");
                return;
            }
        }

        if (!"getPersonalTasks".equals(action)) {
            response.setStatus(204);
        }

    } catch (Exception e) {

        application.log("マイタスクの処理に失敗しました。", e);

        if (!response.isCommitted()) {
            response.sendError(500, "マイタスクの処理に失敗しました。");
        }
    }

    return;
}


// ==========================================
// 左側：担当タスクとタグ一覧を取得
// ==========================================

List<Map<String, Object>> assignedTasks = new ArrayList<>();
List<Map<String, Object>> tagOptions = new ArrayList<>();

String assignedTaskError = null;

try {

    TaskFilter myTaskFilter = new TaskFilter();
    myTaskFilter.setUserId(String.valueOf(loginUserId));

    TaskDAO taskDAO = new TaskDAO();

    assignedTasks = taskDAO.getTasksForBoard(
        loginUserId,
        activeOrgId,
        myTaskFilter
    );

    tagOptions = taskDAO.getTagOptionsForBoard(
        loginUserId,
        activeOrgId
    );

    request.setAttribute("tagOptions", tagOptions);

} catch (Exception e) {

    application.log("担当タスクの取得に失敗しました。", e);

    assignedTaskError =
        "担当タスクを読み込めませんでした。DB接続やサーバーログを確認してください。";
}

LocalDate todayForDeadline =
    LocalDate.now(ZoneId.of("Asia/Tokyo"));

%>


<!DOCTYPE html>
<html lang="ja">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>マイタスク - タスク管理アプリ</title>

<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet" href="css/mytasks.css">

</head>


<body
    class="${themeValue}-theme font-${themeFontSize}"
    style="--custom-bg-color: ${themeBgColor}; --custom-text-color: ${themeTextColor};"
>

<div class="app-container">

    <%@ include file="common/sidebar.jsp" %>

    <main class="main-content">

        <%@ include file="common/header.jsp" %>


        <div class="mytasks-container">


            <!-- ==================================
                 左側：担当タスク
                 ================================== -->

            <section class="left-column">

                <h3 class="column-title">
                    担当タスク
                </h3>


                <div class="assigned-task-list">

                    <% if (assignedTaskError != null) { %>

                        <div class="assigned-task-error">
                            <%= escapeHtml(assignedTaskError) %>
                        </div>

                    <% } else if (assignedTasks.isEmpty()) { %>

                        <div class="assigned-task-empty">
                            現在、担当に設定されているタスクはありません。<br>
                            タスクボードで自分が担当者に設定されているか確認してください。
                        </div>

                    <% } else { %>


                        <% for (Map<String, Object> task : assignedTasks) {

                            int taskId =
                                ((Number) task.get("taskId")).intValue();

                            String taskName =
                                task.get("taskName") == null
                                ? "名称未設定"
                                : String.valueOf(task.get("taskName"));

                            String projectName =
                                task.get("projectName") == null
                                ? "プロジェクト未設定"
                                : String.valueOf(task.get("projectName"));

                            String description =
                                task.get("description") == null
                                ? ""
                                : String.valueOf(task.get("description"));

                            String status =
                                task.get("status") == null
                                ? "未設定"
                                : String.valueOf(task.get("status"));

                            String priority =
                                task.get("priority") == null
                                ? "未設定"
                                : String.valueOf(task.get("priority"));

                            String assignees =
                                task.get("assignees") == null
                                ? "未設定"
                                : String.valueOf(task.get("assignees"));

                            String tags =
                                task.get("tags") == null
                                ? "タグなし"
                                : String.valueOf(task.get("tags"));

                            String rawTagIds =
                                task.get("tagIds") == null
                                ? ""
                                : String.valueOf(task.get("tagIds"));

                            String commentsText =
                                task.get("comments") == null
                                ? "コメントなし"
                                : String.valueOf(task.get("comments")).replace("<br>", "\n");

                            String filesText =
                                task.get("files") == null
                                ? "添付なし"
                                : String.valueOf(task.get("files")).replace("<br>", "\n");

                            Object dueDateObject = task.get("dueDate");

                            String dueDateText =
                                formatTaskDate(dueDateObject);

                            String startDateValue =
                                task.get("startDate") == null
                                ? ""
                                : String.valueOf(task.get("startDate"));

                            String dueDateValue =
                                dueDateObject == null
                                ? ""
                                : String.valueOf(dueDateObject);


                            // 現在選択されているタグID
                            Set<Integer> selectedTagIds = new HashSet<>();

                            if (!rawTagIds.isEmpty()) {

                                for (String part : rawTagIds.split(",")) {

                                    try {
                                        selectedTagIds.add(Integer.parseInt(part));
                                    } catch (NumberFormatException e) {
                                        // 不正なタグIDは無視
                                    }
                                }
                            }


                            // 状態に応じたカード左端の色
                            String statusClass = "status-todo";

                            if ("進行中".equals(status)
                                    || "作業中".equals(status)) {

                                statusClass = "status-doing";

                            } else if ("完了".equals(status)) {

                                statusClass = "status-done";
                            }


                            // 期限表示
                            String deadlineClass = "";

                            String deadlineLabel =
                                dueDateText.isEmpty()
                                ? "期限未設定"
                                : "期限：" + dueDateText;

                            if (dueDateObject instanceof java.sql.Date
                                    && !"完了".equals(status)) {

                                LocalDate dueLocalDate =
                                    ((java.sql.Date) dueDateObject).toLocalDate();

                                if (dueLocalDate.isBefore(todayForDeadline)) {

                                    deadlineClass = "assigned-deadline-overdue";

                                    deadlineLabel = "期限切れ：" + dueDateText;

                                } else if (!dueLocalDate.isAfter(
                                        todayForDeadline.plusDays(2))) {

                                    deadlineClass = "assigned-deadline-soon";

                                    deadlineLabel = "期限間近：" + dueDateText;
                                }
                            }

                        %>


                        <!-- ==================================
                             担当タスクカード
                             ================================== -->

                        <article class="assigned-task-card <%= statusClass %>">


                            <!-- 上部：プロジェクト名と三点メニュー -->

                            <div class="assigned-task-card-header">

                                <div class="assigned-task-card-top">

                                    <span class="assigned-project-name">
                                        <%= escapeHtml(projectName) %>
                                    </span>


                                    <div class="assigned-task-menu">

                                        <button
                                            type="button"
                                            class="assigned-menu-button"
                                            onclick="toggleAssignedTaskMenu(event, 'assigned-menu-<%= taskId %>')"
                                            aria-label="タスクメニュー"
                                        >
                                            ⋯
                                        </button>


                                        <div
                                            class="assigned-menu-dropdown"
                                            id="assigned-menu-<%= taskId %>"
                                        >

                                            <button
                                                type="button"
                                                onclick="openAssignedTaskModal('詳細', 'assigned-detail-<%= taskId %>')"
                                            >
                                                詳細
                                            </button>

                                            <button
                                                type="button"
                                                onclick="openAssignedTaskModal('編集', 'assigned-edit-<%= taskId %>')"
                                            >
                                                編集
                                            </button>

                                            <button
                                                type="button"
                                                class="assigned-delete-menu-button"
                                                onclick="openAssignedTaskModal('タスク削除', 'assigned-delete-<%= taskId %>')"
                                            >
                                                削除
                                            </button>

                                        </div>

                                    </div>

                                </div>

                            </div>


                            <!-- タスク名 -->

                            <p class="assigned-task-name">
                                <%= escapeHtml(taskName) %>
                            </p>


                            <!-- 担当者 -->

                            <div class="assigned-task-assignees">
                                <%= escapeHtml(assignees) %>
                            </div>


                            <!-- 下部：期限・コメント・添付 -->

                            <div class="assigned-task-footer">

                                <span class="assigned-task-deadline <%= deadlineClass %>">
                                    <%= escapeHtml(deadlineLabel) %>
                                </span>


                                <div class="assigned-task-actions">

                                    <button
                                        type="button"
                                        class="assigned-icon-button"
                                        title="コメント"
                                        onclick="openAssignedTaskModal('コメント', 'assigned-comment-<%= taskId %>')"
                                    >
                                        💬
                                    </button>

                                    <button
                                        type="button"
                                        class="assigned-icon-button"
                                        title="添付ファイル"
                                        onclick="openAssignedTaskModal('添付ファイル', 'assigned-file-<%= taskId %>')"
                                    >
                                        📎
                                    </button>

                                </div>

                            </div>


                            <!-- ==================================
                                 詳細表示用データ
                                 ================================== -->

                            <div
                                id="assigned-detail-<%= taskId %>"
                                style="display:none;"
                            >

                                <p>
                                    <strong>タスク名：</strong>
                                    <%= escapeHtml(taskName) %>
                                </p>

                                <p>
                                    <strong>プロジェクト：</strong>
                                    <%= escapeHtml(projectName) %>
                                </p>

                                <p>
                                    <strong>説明：</strong>
                                    <%= escapeHtml(description) %>
                                </p>

                                <p>
                                    <strong>担当者：</strong>
                                    <%= escapeHtml(assignees) %>
                                </p>

                                <p>
                                    <strong>タグ：</strong>
                                    <%= escapeHtml(tags) %>
                                </p>

                                <p>
                                    <strong>状態：</strong>
                                    <%= escapeHtml(status) %>
                                </p>

                                <p>
                                    <strong>優先度：</strong>
                                    <%= escapeHtml(priority) %>
                                </p>

                                <p>
                                    <strong>開始日：</strong>
                                    <%= escapeHtml(startDateValue) %>
                                </p>

                                <p>
                                    <strong>期限：</strong>
                                    <%= escapeHtml(dueDateValue) %>
                                </p>

                            </div>


                            <!-- ==================================
                                 編集フォーム
                                 ================================== -->

                            <div
                                id="assigned-edit-<%= taskId %>"
                                style="display:none;"
                            >

                                <form
                                    class="edit-form"
                                    action="<%= request.getContextPath() %>/task/taskUpdate.jsp"
                                    method="post"
                                >

                                    <input
                                        type="hidden"
                                        name="task_id"
                                        value="<%= taskId %>"
                                    >

                                    <input
                                        type="hidden"
                                        name="return_to"
                                        value="mytasks"
                                    >


                                    <label>タスク名</label>

                                    <input
                                        type="text"
                                        name="task_name"
                                        value="<%= escapeHtml(taskName) %>"
                                        required
                                    >


                                    <label>状態</label>

                                    <select name="status">

                                        <option value="未着手"
                                            <%= "未着手".equals(status) ? "selected" : "" %>>
                                            未着手
                                        </option>

                                        <option value="進行中"
                                            <%= "進行中".equals(status) ? "selected" : "" %>>
                                            進行中
                                        </option>

                                        <option value="完了"
                                            <%= "完了".equals(status) ? "selected" : "" %>>
                                            完了
                                        </option>

                                    </select>


                                    <label>優先度</label>

                                    <select name="priority">

                                        <option value="低"
                                            <%= "低".equals(priority) ? "selected" : "" %>>
                                            低
                                        </option>

                                        <option value="中"
                                            <%= "中".equals(priority) ? "selected" : "" %>>
                                            中
                                        </option>

                                        <option value="高"
                                            <%= "高".equals(priority) ? "selected" : "" %>>
                                            高
                                        </option>

                                    </select>


                                    <label>開始日</label>

                                    <input
                                        type="date"
                                        name="start_date"
                                        value="<%= escapeHtml(startDateValue) %>"
                                    >


                                    <label>期限</label>

                                    <input
                                        type="date"
                                        name="due_date"
                                        value="<%= escapeHtml(dueDateValue) %>"
                                    >


                                    <label>説明</label>

                                    <textarea name="description"><%= escapeHtml(description) %></textarea>


                                    <label>担当者</label>

                                    <select name="user_id">

                                        <option value="1">伊藤</option>
                                        <option value="2">高橋</option>
                                        <option value="3">中村</option>
                                        <option value="4">小林</option>
                                        <option value="5">加藤</option>

                                    </select>


                                    <!-- タグ編集 -->

                                    <%
                                    request.setAttribute(
                                        "selectedTagIds",
                                        selectedTagIds
                                    );
                                    %>

                                    <jsp:include page="/task/tagEditor.jsp" />


                                    <button
                                        type="submit"
                                        class="modal-submit-btn custom-theme-accent"
                                    >
                                        保存
                                    </button>

                                </form>

                            </div>


                            <!-- ==================================
                                 削除確認
                                 ================================== -->

                            <div
                                id="assigned-delete-<%= taskId %>"
                                style="display:none;"
                            >

                                <p>
                                    <strong>
                                        <%= escapeHtml(taskName) %>
                                    </strong>
                                    を削除してもよろしいですか？
                                </p>

                                <p class="assigned-delete-warning">
                                    この操作は取り消せません。
                                </p>


                                <form
                                    action="<%= request.getContextPath() %>/task/taskDelete.jsp"
                                    method="post"
                                    class="delete-form"
                                >

                                    <input
                                        type="hidden"
                                        name="task_id"
                                        value="<%= taskId %>"
                                    >

                                    <input
                                        type="hidden"
                                        name="return_to"
                                        value="mytasks"
                                    >


                                    <div class="delete-actions">

                                        <button
                                            type="button"
                                            class="cancel-button"
                                            onclick="closeAssignedTaskModal()"
                                        >
                                            キャンセル
                                        </button>

                                        <button
                                            type="submit"
                                            class="delete-button"
                                        >
                                            削除する
                                        </button>

                                    </div>

                                </form>

                            </div>


<!-- コメント表示 -->
<div
    id="assigned-comment-<%= taskId %>"
    style="display:none;"
><div class="assigned-popup-text"><%= escapeHtml(commentsText) %></div></div>
                            <!-- ==================================
                                 添付ファイル表示
                                 ================================== -->

                            <div
                                id="assigned-file-<%= taskId %>"
                                style="display:none;"
                            >

                                <p class="assigned-popup-text">
                                    <%= escapeHtml(filesText) %>
                                </p>

                            </div>

                        </article>


                        <%
                        }
                        %>

                    <% } %>

                </div>

            </section>


            <!-- ==================================
                 右側：個人タスク
                 ================================== -->

            <section class="right-column">

                <h3 class="column-title">
                    個人タスク
                </h3>


                <div
                    class="personal-task-list"
                    id="personalTaskContainer"
                >

                    <div class="personal-task-empty">
                        読み込み中...
                    </div>

                </div>


                <button
                    type="button"
                    class="btn-add-personal custom-theme-accent"
                    onclick="openAddModal()"
                >
                    + 個人タスクを追加
                </button>

            </section>

        </div>


        <!-- ==================================
             個人タスク追加・編集モーダル
             ================================== -->

        <div id="personalTaskModal" class="modal-overlay">

            <div class="modal-content">

                <h3 id="modalTitle">
                    個人タスクの追加
                </h3>


                <div class="modal-form-group">

                    <label for="modalTaskName">
                        タスク名 <span style="color:red;">*</span>
                    </label>

                    <input
                        type="text"
                        id="modalTaskName"
                        placeholder="例：資料の収集と整理"
                        maxlength="100"
                    >

                </div>


                <div class="modal-form-group">

                    <label for="modalDueDate">
                        期限
                    </label>

                    <input
                        type="date"
                        id="modalDueDate"
                    >

                </div>


                <div class="modal-actions">

                    <button
                        type="button"
                        class="btn-cancel"
                        onclick="closeModal()"
                    >
                        キャンセル
                    </button>

                    <button
                        type="button"
                        class="btn-save custom-theme-accent"
                        onclick="submitModal()"
                    >
                        保存
                    </button>

                </div>

            </div>

        </div>


        <!-- ==================================
             個人タスク削除確認モーダル
             ================================== -->

        <div id="deleteModal" class="modal-overlay">

            <div class="modal-content delete-modal-content">

                <h3>タスクの削除</h3>

                <p
                    id="deleteMessage"
                    class="delete-message"
                ></p>


                <div class="modal-actions delete-modal-actions">

                    <button
                        type="button"
                        class="btn-cancel"
                        onclick="closeDeleteModal()"
                    >
                        キャンセル
                    </button>

                    <button
                        type="button"
                        class="btn-delete-confirm"
                        onclick="executeDelete()"
                    >
                        削除する
                    </button>

                </div>

            </div>

        </div>


        <!-- ==================================
             担当タスク用モーダル
             ================================== -->

        <div
            id="assignedTaskModalOverlay"
            class="assigned-task-modal-overlay"
        >

            <div class="assigned-task-modal-content">

                <div class="assigned-task-modal-header">

                    <h2 id="assignedTaskModalTitle">
                        タイトル
                    </h2>

                    <button
                        type="button"
                        class="assigned-task-modal-close"
                        onclick="closeAssignedTaskModal()"
                    >
                        ×
                    </button>

                </div>


                <div
                    class="assigned-task-modal-body"
                    id="assignedTaskModalBody"
                ></div>

            </div>

        </div>


        <!-- ==================================
             JavaScript
             ================================== -->

        <script>

            // ======================================
            // 個人タスク
            // ======================================

            let modalMode = 'add';
            let targetTaskId = null;

            window.addEventListener(
                'DOMContentLoaded',
                loadPersonalTasks
            );


            function loadPersonalTasks() {

                fetch('mytasks.jsp?action=getPersonalTasks')

                    .then(response => {

                        if (!response.ok) {
                            throw new Error('個人タスクの読み込みに失敗しました。');
                        }

                        return response.text();
                    })

                    .then(html => {

                        document.getElementById(
                            'personalTaskContainer'
                        ).innerHTML = html;

                    })

                    .catch(error => {

                        document.getElementById(
                            'personalTaskContainer'
                        ).innerHTML =
                            '<div class="personal-task-empty">'
                            + error.message
                            + '</div>';
                    });
            }


            function openAddModal() {

                modalMode = 'add';
                targetTaskId = null;

                document.getElementById('modalTitle').innerText =
                    '個人タスクの追加';

                document.getElementById('modalTaskName').value = '';
                document.getElementById('modalDueDate').value = '';

                document.getElementById(
                    'personalTaskModal'
                ).style.display = 'flex';
            }


            function openEditModal(button) {

                modalMode = 'edit';
                targetTaskId = button.dataset.taskId;

                document.getElementById('modalTitle').innerText =
                    '個人タスクの編集';

                document.getElementById('modalTaskName').value =
                    button.dataset.taskName || '';

                document.getElementById('modalDueDate').value =
                    button.dataset.dueDate || '';

                document.getElementById(
                    'personalTaskModal'
                ).style.display = 'flex';
            }


            function closeModal() {

                document.getElementById(
                    'personalTaskModal'
                ).style.display = 'none';
            }


            function submitModal() {

                const taskName =
                    document.getElementById('modalTaskName').value.trim();

                const dueDate =
                    document.getElementById('modalDueDate').value;


                if (!taskName) {

                    alert('タスク名を入力してください。');
                    return;
                }


                const params = new URLSearchParams();

                params.append(
                    'action',
                    modalMode === 'add'
                        ? 'addPersonalTask'
                        : 'editPersonalTask'
                );

                if (modalMode === 'edit') {
                    params.append('taskId', targetTaskId);
                }

                params.append('taskName', taskName);
                params.append('dueDate', dueDate);


                fetch('mytasks.jsp', {
                    method: 'POST',
                    body: params
                })

                    .then(response => {

                        if (!response.ok) {
                            throw new Error('保存に失敗しました。');
                        }

                        closeModal();
                        loadPersonalTasks();
                    })

                    .catch(error => {
                        alert(error.message);
                    });
            }


            function togglePersonalTask(taskId, isChecked) {

                const params = new URLSearchParams();

                params.append('action', 'togglePersonalTask');
                params.append('taskId', taskId);
                params.append('isChecked', isChecked);


                fetch('mytasks.jsp', {
                    method: 'POST',
                    body: params
                })

                    .then(response => {

                        if (!response.ok) {
                            throw new Error('状態の更新に失敗しました。');
                        }

                        loadPersonalTasks();
                    })

                    .catch(error => {
                        alert(error.message);
                    });
            }


            function openDeleteModal(button) {

                targetTaskId = button.dataset.taskId;

                document.getElementById('deleteMessage').innerText =
                    '「' + (button.dataset.taskName || '')
                    + '」を本当に削除しますか？';

                document.getElementById(
                    'deleteModal'
                ).style.display = 'flex';
            }


            function closeDeleteModal() {

                targetTaskId = null;

                document.getElementById(
                    'deleteModal'
                ).style.display = 'none';
            }


            function executeDelete() {

                if (!targetTaskId) return;

                const params = new URLSearchParams();

                params.append('action', 'deletePersonalTask');
                params.append('taskId', targetTaskId);


                fetch('mytasks.jsp', {
                    method: 'POST',
                    body: params
                })

                    .then(response => {

                        if (!response.ok) {
                            throw new Error('削除に失敗しました。');
                        }

                        closeDeleteModal();
                        loadPersonalTasks();
                    })

                    .catch(error => {
                        alert(error.message);
                    });
            }


            function toggleTaskMenu(buttonElement) {

                const menu = buttonElement.nextElementSibling;

                document.querySelectorAll('.task-dropdown-menu').forEach(
                    item => {

                        if (item !== menu) {
                            item.classList.remove('open');
                        }
                    }
                );

                menu.classList.toggle('open');
            }


            // ======================================
            // 担当タスク：詳細・編集・削除・コメント
            // ======================================

            function openAssignedTaskModal(title, elementId) {

                const source = document.getElementById(elementId);

                const overlay = document.getElementById(
                    'assignedTaskModalOverlay'
                );

                const modalTitle = document.getElementById(
                    'assignedTaskModalTitle'
                );

                const modalBody = document.getElementById(
                    'assignedTaskModalBody'
                );


                if (!source || !overlay || !modalTitle || !modalBody) {
                    return;
                }


                modalTitle.textContent = title;
                modalBody.innerHTML = source.innerHTML;

                overlay.style.display = 'flex';

                closeAllAssignedTaskMenus();
            }


            function closeAssignedTaskModal() {

                const overlay = document.getElementById(
                    'assignedTaskModalOverlay'
                );

                if (overlay) {
                    overlay.style.display = 'none';
                }
            }


            function toggleAssignedTaskMenu(event, menuId) {

                event.stopPropagation();

                closeAllAssignedTaskMenus();

                const menu = document.getElementById(menuId);

                if (menu) {
                    menu.style.display = 'block';
                }
            }


            function closeAllAssignedTaskMenus() {

                document.querySelectorAll(
                    '.assigned-menu-dropdown'
                ).forEach(menu => {

                    menu.style.display = 'none';

                });
            }


            // ======================================
            // タグ編集：タスクボードと同じ処理
            // ======================================

            function getTagEditor(element) {

                return element.closest('.tag-editor');
            }


            function openTagEditor(input) {

                const editor = getTagEditor(input);

                editor.querySelector(
                    '.tag-editor-menu'
                ).classList.add('open');
            }


            function toggleTagEditor(button) {

                const editor = getTagEditor(button);

                editor.querySelector(
                    '.tag-editor-menu'
                ).classList.toggle('open');
            }


            function filterTagEditor(input) {

                const editor = getTagEditor(input);

                const keyword = input.value.trim().toLowerCase();

                const options = editor.querySelectorAll(
                    '.tag-editor-option'
                );

                options.forEach(function(option) {

                    const name = option.textContent.trim().toLowerCase();

                    option.style.display =
                        keyword === '' || name.includes(keyword)
                        ? ''
                        : 'none';
                });

                editor.querySelector(
                    '.tag-editor-menu'
                ).classList.add('open');
            }


            function selectExistingTag(button) {

                const editor = getTagEditor(button);

                const tagId = button.dataset.tagId;
                const tagName = button.textContent.trim();
                const color = button.dataset.tagColor;

                const existing = editor.querySelector(
                    'input[name="tag_ids"][value="' + tagId + '"]'
                );

                if (existing) {
                    return;
                }

                createTagChip(
                    editor,
                    tagName,
                    color,
                    'tag_ids',
                    tagId
                );

                editor.querySelector(
                    '.tag-editor-search'
                ).value = '';

                editor.querySelector(
                    '.tag-editor-menu'
                ).classList.remove('open');
            }


            function addNewTag(button) {

                const editor = getTagEditor(button);

                const nameInput = editor.querySelector('.new-tag-name');
                const colorInput = editor.querySelector('.new-tag-color');

                const tagName = nameInput.value.trim();
                const color = colorInput.value;

                if (!tagName) {
                    return;
                }

                createNewTagChip(editor, tagName, color);

                nameInput.value = '';
            }


            function createNewTagChip(editor, tagName, color) {

                const chip = document.createElement('span');

                chip.className = 'selected-tag';
                chip.style.backgroundColor = color;

                chip.appendChild(
                    document.createTextNode(tagName + ' ')
                );


                const nameHidden = document.createElement('input');

                nameHidden.type = 'hidden';
                nameHidden.name = 'new_tag_names';
                nameHidden.value = tagName;

                chip.appendChild(nameHidden);


                const colorHidden = document.createElement('input');

                colorHidden.type = 'hidden';
                colorHidden.name = 'new_tag_colors';
                colorHidden.value = color;

                chip.appendChild(colorHidden);

                appendRemoveButton(chip);

                editor.querySelector(
                    '.selected-tags'
                ).appendChild(chip);
            }


            function createTagChip(
                editor,
                tagName,
                color,
                inputName,
                value
            ) {

                const chip = document.createElement('span');

                chip.className = 'selected-tag';
                chip.style.backgroundColor = color;

                chip.appendChild(
                    document.createTextNode(tagName + ' ')
                );


                const hidden = document.createElement('input');

                hidden.type = 'hidden';
                hidden.name = inputName;
                hidden.value = value;

                chip.appendChild(hidden);

                appendRemoveButton(chip);

                editor.querySelector(
                    '.selected-tags'
                ).appendChild(chip);
            }


            function appendRemoveButton(chip) {

                const remove = document.createElement('button');

                remove.type = 'button';
                remove.textContent = '×';

                remove.onclick = function() {
                    chip.remove();
                };

                chip.appendChild(remove);
            }


            function removeTagChip(button) {

                button.closest('.selected-tag').remove();
            }


            // ======================================
            // 画面外クリック時の処理
            // ======================================

            document.addEventListener('click', function(event) {

                if (!event.target.closest('.pti-right')) {

                    document.querySelectorAll(
                        '.task-dropdown-menu'
                    ).forEach(menu => {

                        menu.classList.remove('open');

                    });
                }


                if (!event.target.closest('.assigned-task-menu')) {
                    closeAllAssignedTaskMenus();
                }


                const assignedOverlay = document.getElementById(
                    'assignedTaskModalOverlay'
                );

                if (
                    assignedOverlay
                    && event.target === assignedOverlay
                ) {
                    closeAssignedTaskModal();
                }


                // タグ候補一覧の外側をクリックしたとき閉じる
                if (!event.target.closest('.tag-editor')) {

                    document.querySelectorAll(
                        '.tag-editor-menu'
                    ).forEach(menu => {

                        menu.classList.remove('open');

                    });
                }

            });

        </script>


        <%@ include file="common/footer.jsp" %>

    </main>

</div>

</body>
</html>