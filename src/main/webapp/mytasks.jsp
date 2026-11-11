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
    // JSPに表示する文字列をHTMLエスケープする。
    private String escapeHtml(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    // java.sql.Dateなどの日付を yyyy/MM/dd 形式にする。
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

// 個人タスク用DB接続。所有者IDには必ずログイン中のユーザーIDを使用する。
final String personalDbUrl = "jdbc:postgresql://172.16.1.119:5432/taskapp";
final String personalDbUser = "taskuser";
final String personalDbPassword = "taskpass";
final int currentUserId = loginUserId;

// 個人タスクの非同期処理（右側の既存機能）
String action = request.getParameter("action");
if (action != null) {
    try {
        Class.forName("org.postgresql.Driver");

        try (Connection conn = DriverManager.getConnection(
                personalDbUrl, personalDbUser, personalDbPassword)) {

            // ① 個人タスク一覧の取得
            if ("getPersonalTasks".equals(action)) {
                response.setContentType("text/html; charset=UTF-8");

                String sql = "SELECT personal_task_id, task_name, status, "
                    + "TO_CHAR(due_date, 'YYYY-MM-DD') AS fmt_due_date "
                    + "FROM personal_task WHERE user_id = ? "
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
                                    dateLabel = Integer.parseInt(parts[1]) + "/" + Integer.parseInt(parts[2]);
                                }
                            }

                            boolean isCompleted = "完了".equals(status);
%>
<div class="personal-task-item">
    <div class="pti-left">
        <input type="checkbox" class="task-check"
               onchange="togglePersonalTask(<%= taskId %>, this.checked)"
               <%= isCompleted ? "checked" : "" %>>
        <span class="pti-name <%= isCompleted ? "completed-task" : "" %>"><%= escapeHtml(taskName) %></span>
    </div>
    <div class="pti-right">
        <% if (!dateLabel.isEmpty()) { %>
            <span class="pti-info">📅 <%= escapeHtml(dateLabel) %></span>
        <% } %>
        <button type="button" class="task-menu-trigger" onclick="toggleTaskMenu(this)" aria-label="タスクメニュー">⋮</button>
        <div class="task-dropdown-menu">
            <button type="button" class="dropdown-edit-item"
                    data-task-id="<%= taskId %>"
                    data-task-name="<%= escapeHtml(taskName) %>"
                    data-due-date="<%= escapeHtml(dueDate) %>"
                    onclick="openEditModal(this)">編集</button>
            <button type="button" class="dropdown-delete-item"
                    data-task-id="<%= taskId %>"
                    data-task-name="<%= escapeHtml(taskName) %>"
                    onclick="openDeleteModal(this)">削除</button>
        </div>
    </div>
</div>
<%
                        }

                        if (!hasTask) {
%>
<div class="personal-task-empty">個人タスクはまだ登録されていません。</div>
<%
                        }
                    }
                }
            }
            // ② 個人タスクの追加
            else if ("addPersonalTask".equals(action)) {
                String taskName = request.getParameter("taskName");
                String dueDate = request.getParameter("dueDate");

                if (taskName == null || taskName.trim().isEmpty()) {
                    response.sendError(400, "タスク名を入力してください。");
                    return;
                }

                String sql = "INSERT INTO personal_task (user_id, task_name, status, due_date) "
                    + "VALUES (?, ?, '進行中', NULLIF(?, '')::DATE)";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, currentUserId);
                    pstmt.setString(2, taskName.trim());
                    pstmt.setString(3, dueDate == null ? "" : dueDate);
                    pstmt.executeUpdate();
                }
            }
            // ③ 個人タスクの編集（ログインユーザー本人のタスクだけ更新）
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

                String sql = "UPDATE personal_task SET task_name = ?, "
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
            // ④ 完了チェックの更新（ログインユーザー本人のタスクだけ更新）
            else if ("togglePersonalTask".equals(action)) {
                String taskIdText = request.getParameter("taskId");
                boolean isChecked = Boolean.parseBoolean(request.getParameter("isChecked"));
                int taskId;
                try {
                    taskId = Integer.parseInt(taskIdText);
                } catch (Exception invalidId) {
                    response.sendError(400, "タスクIDが不正です。");
                    return;
                }

                String sql = "UPDATE personal_task SET status = ? "
                    + "WHERE personal_task_id = ? AND user_id = ?";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, isChecked ? "完了" : "進行中");
                    pstmt.setInt(2, taskId);
                    pstmt.setInt(3, currentUserId);
                    pstmt.executeUpdate();
                }
            }
            // ⑤ 削除（ログインユーザー本人のタスクだけ削除）
            else if ("deletePersonalTask".equals(action)) {
                String taskIdText = request.getParameter("taskId");
                int taskId;
                try {
                    taskId = Integer.parseInt(taskIdText);
                } catch (Exception invalidId) {
                    response.sendError(400, "タスクIDが不正です。");
                    return;
                }

                String sql = "DELETE FROM personal_task "
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

// 左側：ログイン中のユーザーが担当者に設定されているタスクを取得する。
// TaskDAO側で個人モード／団体モードのプロジェクト範囲も適用される。
List<Map<String, Object>> assignedTasks = new ArrayList<>();
String assignedTaskError = null;
try {
    TaskFilter myTaskFilter = new TaskFilter();
    myTaskFilter.setUserId(String.valueOf(loginUserId));
    TaskDAO taskDAO = new TaskDAO();
    assignedTasks = taskDAO.getTasksForBoard(loginUserId, activeOrgId, myTaskFilter);
} catch (Exception e) {
    application.log("担当タスクの取得に失敗しました。", e);
    assignedTaskError = "担当タスクを読み込めませんでした。DB接続やサーバーログを確認してください。";
}

String currentUserName = loginUser.getUserName() == null ? "ユーザー" : loginUser.getUserName();
String currentUserEmail = loginUser.getEmail() == null ? "" : loginUser.getEmail();
String userInitial = currentUserName.isEmpty() ? "U" : currentUserName.substring(0, 1);
LocalDate todayForDeadline = LocalDate.now(ZoneId.of("Asia/Tokyo"));
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>マイタスク - タスク管理アプリ</title>
<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet" href="css/mytasks.css">
<style>
/* 左側：ログインユーザーと担当タスク */
.mytasks-user-card {
    display: flex; align-items: center; gap: 12px;
    padding: 14px; margin-bottom: 18px;
    border: 1px solid #e5eaf0; border-radius: 10px; background: #f8fafc;
}
.mytasks-user-avatar {
    width: 48px; height: 48px; flex: 0 0 48px;
    display: flex; align-items: center; justify-content: center;
    overflow: hidden; border-radius: 50%; background: #dbeafe;
    color: #1d4ed8; font-size: 20px; font-weight: 700;
}
.mytasks-user-avatar img { width: 100%; height: 100%; object-fit: cover; }
.mytasks-user-info { min-width: 0; flex: 1; }
.mytasks-user-name { margin: 0 0 3px; color: #253047; font-size: 16px; font-weight: 700; }
.mytasks-user-email { overflow-wrap: anywhere; color: #718096; font-size: 12px; }
.mytasks-scope-label {
    display: inline-block; flex: 0 0 auto; padding: 4px 8px;
    border-radius: 14px; background: #e8f0fe; color: #1b6ef3;
    font-size: 11px; font-weight: 700; white-space: nowrap;
}
.assigned-task-heading {
    display: flex; align-items: center; justify-content: space-between;
    gap: 8px; margin: 4px 0 12px;
}
.assigned-task-count {
    min-width: 24px; padding: 3px 8px; border-radius: 14px;
    background: #eef2f7; color: #475569; font-size: 12px; font-weight: 700; text-align: center;
}
.assigned-task-list { display: flex; flex: 1; flex-direction: column; gap: 10px; overflow-y: auto; min-height: 0; }
.assigned-task-card {
    padding: 12px 13px; border: 1px solid #e5eaf0; border-radius: 9px;
    background: #fff; box-shadow: 0 1px 2px rgba(0,0,0,.03);
}
.assigned-task-card-top { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 8px; }
.assigned-project-name { min-width: 0; overflow: hidden; color: #64748b; font-size: 11px; text-overflow: ellipsis; white-space: nowrap; }
.assigned-task-name { margin: 0 0 9px; color: #263246; font-size: 14px; font-weight: 700; line-height: 1.5; overflow-wrap: anywhere; }
.assigned-task-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; }
.assigned-pill { display: inline-flex; align-items: center; padding: 4px 7px; border-radius: 5px; background: #f1f5f9; color: #475569; font-size: 11px; }
.assigned-status-complete { background: #e8f5ed; color: #247344; }
.assigned-status-progress { background: #fff4df; color: #98620a; }
.assigned-status-todo { background: #eef2f7; color: #536174; }
.assigned-priority-high { background: #fff0f0; color: #c0392b; }
.assigned-priority-medium { background: #fff7e8; color: #996515; }
.assigned-priority-low { background: #edf6ff; color: #2865a8; }
.assigned-deadline-overdue { background: #272b33; color: #fff; }
.assigned-deadline-soon { background: #fff0f0; color: #c0392b; }
.assigned-task-empty, .assigned-task-error {
    padding: 24px 12px; border: 1px dashed #cbd5e1; border-radius: 9px;
    color: #718096; font-size: 13px; line-height: 1.7; text-align: center;
}
.assigned-task-error { border-color: #e7b4b4; background: #fff8f8; color: #a33; }
.left-column { flex: 0 0 45%; width: auto; min-width: 0; color: #333; overflow: hidden; }
.right-column { flex: 1 1 0; width: auto; min-width: 0; }
body.dark-theme .mytasks-user-card, body.dark-theme .assigned-task-card {
    background: var(--ui-card); border-color: var(--ui-border); color: var(--ui-text);
}
body.dark-theme .mytasks-user-name, body.dark-theme .assigned-task-name { color: var(--ui-text); }
body.dark-theme .mytasks-user-email, body.dark-theme .assigned-project-name { color: var(--ui-muted); }
body.dark-theme .assigned-task-count, body.dark-theme .assigned-pill { background: var(--ui-column); color: var(--ui-text); }
body.dark-theme .mytasks-scope-label { background: var(--ui-hover); color: var(--ui-text); }
body.dark-theme .assigned-task-empty { border-color: var(--ui-border); color: var(--ui-muted); }
@media (max-width: 900px) {
    .mytasks-container { flex-direction: column; }
    .left-column, .right-column { flex: 0 0 auto; width: 100%; }
    .left-column { min-height: 320px; }
}
</style>
</head>
<body class="${themeValue}-theme font-${themeFontSize}"
      style="--custom-bg-color: ${themeBgColor}; --custom-text-color: ${themeTextColor};">

<div class="app-container">
    <%@ include file="common/sidebar.jsp" %>

    <main class="main-content">
        <%@ include file="common/header.jsp" %>

        <div class="mytasks-container">
            <!-- 左側：ログインユーザーと、そのユーザーが担当するプロジェクトタスク -->
            <section class="left-column">
                <h3 class="column-title">担当タスク</h3>

                <div class="mytasks-user-card">
                    <div class="mytasks-user-avatar">
                        <% if (loginUser.isIconSet()) { %>
                            <img src="<%= request.getContextPath() %>/icon?userId=<%= loginUserId %>" alt="ユーザーアイコン">
                        <% } else { %>
                            <%= escapeHtml(userInitial) %>
                        <% } %>
                    </div>
                    <div class="mytasks-user-info">
                        <p class="mytasks-user-name"><%= escapeHtml(currentUserName) %></p>
                        <div class="mytasks-user-email"><%= escapeHtml(currentUserEmail) %></div>
                    </div>
                    <span class="mytasks-scope-label"><%= personalMode ? "個人モード" : "団体モード" %></span>
                </div>

                <div class="assigned-task-heading">
                    <strong>自分が担当するタスク</strong>
                    <span class="assigned-task-count"><%= assignedTasks.size() %>件</span>
                </div>

                <div class="assigned-task-list">
                    <% if (assignedTaskError != null) { %>
                        <div class="assigned-task-error"><%= escapeHtml(assignedTaskError) %></div>
                    <% } else if (assignedTasks.isEmpty()) { %>
                        <div class="assigned-task-empty">
                            現在、担当に設定されているタスクはありません。<br>
                            タスクボードで自分が担当者に設定されているか確認してください。
                        </div>
                    <% } else { %>
                        <% for (Map<String, Object> task : assignedTasks) {
                            String taskName = task.get("taskName") == null ? "名称未設定" : String.valueOf(task.get("taskName"));
                            String projectName = task.get("projectName") == null ? "プロジェクト未設定" : String.valueOf(task.get("projectName"));
                            String status = task.get("status") == null ? "未設定" : String.valueOf(task.get("status"));
                            String priority = task.get("priority") == null ? "未設定" : String.valueOf(task.get("priority"));
                            Object dueDateObject = task.get("dueDate");
                            String dueDateText = formatTaskDate(dueDateObject);

                            String statusClass = "assigned-status-todo";
                            if ("完了".equals(status)) statusClass = "assigned-status-complete";
                            else if ("進行中".equals(status) || "作業中".equals(status)) statusClass = "assigned-status-progress";

                            String priorityClass = "";
                            if ("高".equals(priority)) priorityClass = "assigned-priority-high";
                            else if ("中".equals(priority)) priorityClass = "assigned-priority-medium";
                            else if ("低".equals(priority)) priorityClass = "assigned-priority-low";

                            String deadlineClass = "";
                            String deadlineLabel = dueDateText.isEmpty() ? "期限未設定" : "期限：" + dueDateText;
                            if (dueDateObject instanceof java.sql.Date && !"完了".equals(status)) {
                                LocalDate dueLocalDate = ((java.sql.Date) dueDateObject).toLocalDate();
                                if (dueLocalDate.isBefore(todayForDeadline)) {
                                    deadlineClass = "assigned-deadline-overdue";
                                    deadlineLabel = "期限切れ：" + dueDateText;
                                } else if (!dueLocalDate.isAfter(todayForDeadline.plusDays(2))) {
                                    deadlineClass = "assigned-deadline-soon";
                                    deadlineLabel = "期限間近：" + dueDateText;
                                }
                            }
                        %>
                            <article class="assigned-task-card">
                                <div class="assigned-task-card-top">
                                    <span class="assigned-project-name"><%= escapeHtml(projectName) %></span>
                                    <span class="assigned-pill <%= statusClass %>"><%= escapeHtml(status) %></span>
                                </div>
                                <p class="assigned-task-name"><%= escapeHtml(taskName) %></p>
                                <div class="assigned-task-meta">
                                    <span class="assigned-pill <%= priorityClass %>">優先度：<%= escapeHtml(priority) %></span>
                                    <span class="assigned-pill <%= deadlineClass %>"><%= escapeHtml(deadlineLabel) %></span>
                                </div>
                            </article>
                        <% } %>
                    <% } %>
                </div>
            </section>

            <!-- 右側：既存の個人タスク機能 -->
            <section class="right-column">
                <h3 class="column-title">個人タスク</h3>
                <div class="personal-task-list" id="personalTaskContainer">
                    <div class="personal-task-empty">読み込み中...</div>
                </div>
                <button type="button" class="btn-add-personal custom-theme-accent" onclick="openAddModal()">+ 個人タスクを追加</button>
            </section>
        </div>

        <!-- 個人タスク追加・編集モーダル -->
        <div id="personalTaskModal" class="modal-overlay">
            <div class="modal-content">
                <h3 id="modalTitle">個人タスクの追加</h3>
                <div class="modal-form-group">
                    <label for="modalTaskName">タスク名 <span style="color: red;">*</span></label>
                    <input type="text" id="modalTaskName" placeholder="例：資料の収集と整理" maxlength="100">
                </div>
                <div class="modal-form-group">
                    <label for="modalDueDate">期限</label>
                    <input type="date" id="modalDueDate">
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeModal()">キャンセル</button>
                    <button type="button" class="btn-save custom-theme-accent" onclick="submitModal()">保存</button>
                </div>
            </div>
        </div>

        <!-- 個人タスク削除確認モーダル -->
        <div id="deleteModal" class="modal-overlay">
            <div class="modal-content delete-modal-content">
                <h3>タスクの削除</h3>
                <p id="deleteMessage" style="margin: 15px 0 25px 0;"></p>
                <div class="modal-actions" style="text-align: center; border-top: none; padding-top: 0; margin-top: 0;">
                    <button type="button" class="btn-cancel" onclick="closeDeleteModal()">キャンセル</button>
                    <button type="button" class="btn-delete-confirm" onclick="executeDelete()">削除する</button>
                </div>
            </div>
        </div>

        <script>
            let modalMode = 'add';
            let targetTaskId = null;

            window.addEventListener('DOMContentLoaded', loadPersonalTasks);

            function loadPersonalTasks() {
                fetch('mytasks.jsp?action=getPersonalTasks')
                    .then(response => {
                        if (!response.ok) throw new Error('個人タスクの読み込みに失敗しました。');
                        return response.text();
                    })
                    .then(html => {
                        document.getElementById('personalTaskContainer').innerHTML = html;
                    })
                    .catch(error => {
                        document.getElementById('personalTaskContainer').innerHTML =
                            '<div class="personal-task-empty">' + error.message + '</div>';
                    });
            }

            function openAddModal() {
                modalMode = 'add';
                targetTaskId = null;
                document.getElementById('modalTitle').innerText = '個人タスクの追加';
                document.getElementById('modalTaskName').value = '';
                document.getElementById('modalDueDate').value = '';
                document.getElementById('personalTaskModal').style.display = 'flex';
            }

            function openEditModal(button) {
                modalMode = 'edit';
                targetTaskId = button.dataset.taskId;
                document.getElementById('modalTitle').innerText = '個人タスクの編集';
                document.getElementById('modalTaskName').value = button.dataset.taskName || '';
                document.getElementById('modalDueDate').value = button.dataset.dueDate || '';
                document.getElementById('personalTaskModal').style.display = 'flex';
            }

            function closeModal() {
                document.getElementById('personalTaskModal').style.display = 'none';
            }

            function submitModal() {
                const taskName = document.getElementById('modalTaskName').value.trim();
                const dueDate = document.getElementById('modalDueDate').value;

                if (!taskName) {
                    alert('タスク名を入力してください。');
                    return;
                }

                const params = new URLSearchParams();
                params.append('action', modalMode === 'add' ? 'addPersonalTask' : 'editPersonalTask');
                if (modalMode === 'edit') params.append('taskId', targetTaskId);
                params.append('taskName', taskName);
                params.append('dueDate', dueDate);

                fetch('mytasks.jsp', { method: 'POST', body: params })
                    .then(response => {
                        if (!response.ok) throw new Error('保存に失敗しました。');
                        closeModal();
                        loadPersonalTasks();
                    })
                    .catch(error => alert(error.message));
            }

            function togglePersonalTask(taskId, isChecked) {
                const params = new URLSearchParams();
                params.append('action', 'togglePersonalTask');
                params.append('taskId', taskId);
                params.append('isChecked', isChecked);

                fetch('mytasks.jsp', { method: 'POST', body: params })
                    .then(response => {
                        if (!response.ok) throw new Error('状態の更新に失敗しました。');
                        loadPersonalTasks();
                    })
                    .catch(error => alert(error.message));
            }

            function openDeleteModal(button) {
                targetTaskId = button.dataset.taskId;
                document.getElementById('deleteMessage').innerText =
                    '「' + (button.dataset.taskName || '') + '」を本当に削除しますか？';
                document.getElementById('deleteModal').style.display = 'flex';
            }

            function closeDeleteModal() {
                targetTaskId = null;
                document.getElementById('deleteModal').style.display = 'none';
            }

            function executeDelete() {
                if (!targetTaskId) return;
                const params = new URLSearchParams();
                params.append('action', 'deletePersonalTask');
                params.append('taskId', targetTaskId);

                fetch('mytasks.jsp', { method: 'POST', body: params })
                    .then(response => {
                        if (!response.ok) throw new Error('削除に失敗しました。');
                        closeDeleteModal();
                        loadPersonalTasks();
                    })
                    .catch(error => alert(error.message));
            }

            function toggleTaskMenu(buttonElement) {
                const menu = buttonElement.nextElementSibling;
                document.querySelectorAll('.task-dropdown-menu').forEach(item => {
                    if (item !== menu) item.classList.remove('open');
                });
                menu.classList.toggle('open');
            }

            document.addEventListener('click', function(event) {
                if (!event.target.closest('.pti-right')) {
                    document.querySelectorAll('.task-dropdown-menu').forEach(menu => menu.classList.remove('open'));
                }
            });
        </script>

        <%@ include file="common/footer.jsp" %>
    </main>
</div>
</body>
</html>
