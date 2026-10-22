
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="dao.NotificationDAO" %>
<%@ page import="model.Notification" %>
<%@ page import="java.util.List" %>
<jsp:include page="common/theme.jsp" />


<%
    request.setAttribute("pageTitle", "通知センター");
    request.setAttribute("currentPage", "notifications");
%>

<!DOCTYPE html>
<html lang="ja">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>タスク管理アプリ</title>

    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/notifications.css">
</head>

<body class="${themeValue}-theme font-${themeFontSize}"
      style="--custom-bg-color: ${themeBgColor};
             --custom-text-color: ${themeTextColor};">

<div class="app-container">

    <%@ include file="common/sidebar.jsp" %>

    <main class="main-content">

        <%@ include file="common/header.jsp" %>

        <div class="content-body">

            <h2>通知センター</h2>

            <%
                String url =
                    "jdbc:postgresql://172.16.1.119:5432/taskapp";

                String user = "taskuser";
                String password = "taskpass";

                boolean notificationExists = false;

                String sql =
                    "SELECT " +
                    "t.task_id, " +
                    "t.task_name, " +
                    "t.due_date, " +
                    "p.project_name, " +
                    "ta.user_id " +
                    "FROM task t " +
                    "JOIN project p " +
                    "ON t.project_id = p.project_id " +
                    "JOIN task_assignee ta " +
                    "ON t.task_id = ta.task_id " +
                    "WHERE t.due_date <= CURRENT_DATE + INTERVAL '3 days' " +
                    "ORDER BY t.due_date ASC";

                try {
                    Class.forName("org.postgresql.Driver");

                    try (
                        Connection conn =
                            DriverManager.getConnection(
                                url, user, password
                            );

                        PreparedStatement ps =
                            conn.prepareStatement(sql);

                        ResultSet rs = ps.executeQuery()
                    ) {

                        while (rs.next()) {

                            notificationExists = true;

                            String taskName =
                                rs.getString("task_name");

                            String projectName =
                                rs.getString("project_name");

                            Date dueDate =
                                rs.getDate("due_date");

                            // 期限までの日数を計算
                            java.time.LocalDate today =
                                java.time.LocalDate.now();

                            java.time.LocalDate deadline =
                                dueDate.toLocalDate();

                            long days =
                                java.time.temporal.ChronoUnit.DAYS.between(
                                    today, deadline
                                );

                            String notificationTitle;
                            String notificationDetail;

                            if (days < 0) {

                                notificationTitle =
                                    "期限を過ぎています";

                                notificationDetail =
                                    "このタスクは期限を過ぎています。" +
                                    "対応状況を確認してください。";

                            } else if (days == 0) {

                                notificationTitle =
                                    "本日が期限です";

                                notificationDetail =
                                    "このタスクは本日が期限です。" +
                                    "早めに対応してください。";

                            } else {

                                notificationTitle =
                                    "期限が近づいています";

                                notificationDetail =
                                    "期限まであと" + days +
                                    "日です。早めに対応してください。";
                            }
            %>

            <div class="notification-item unread">

                <span class="notification-dot"></span>

                <div class="notification-content">

                    <div class="notification-title">
                        <%= notificationTitle %>
                    </div>

                    <div class="notification-task">
                        タスク：<%= taskName %>
                    </div>

                    <div class="notification-project">
                        プロジェクト：<%= projectName %>
                    </div>

                    <div class="notification-detail">
                        <%= notificationDetail %>
                    </div>

                    <div class="notification-date">
                        期限：<%= dueDate %>
                    </div>

                </div>

            </div>

            <%
                        }

                    }

                } catch (Exception e) {
            %>

            <div class="notification-item">
                <div class="notification-content">

                    <div class="notification-title">
                        DB接続エラー
                    </div>

                    <div class="notification-detail" style="color:red;">
                        <%= e.getMessage() %>
                    </div>

                </div>
            </div>

<%
    // DAOから保存済みの通知を取得する
    // ログイン処理でsessionにuserIdが保存されている想定
    Object loginUserId = session.getAttribute("userId");

    if (loginUserId instanceof Number) {

        int loggedInUserId =
            ((Number) loginUserId).intValue();

        NotificationDAO notificationDAO =
            new NotificationDAO();

        List<Notification> savedNotifications =
            notificationDAO.getNotifications(loggedInUserId);

        for (Notification notification : savedNotifications) {

            notificationExists = true;

            String type = notification.getType();
            String title = "お知らせ";
            String icon = "🔔";

            // 通知の種類に応じてタイトルとアイコンを変更
            if ("TASK_CREATED".equals(type)) {
                title = "新しいタスクが作成されました";
                icon = "➕";

            } else if ("TASK_ASSIGNED".equals(type)) {
                title = "担当者になりました";
                icon = "👤";

            } else if ("STATUS_CHANGED".equals(type)) {
                title = "タスクの状態が変更されました";
                icon = "🔄";

            } else if ("TASK_COMPLETED".equals(type)) {
                title = "タスクが完了しました";
                icon = "✅";

            } else if ("COMMENT_ADDED".equals(type)) {
                title = "担当タスクにコメントが付きました";
                icon = "💬";

            } else if ("MENTION".equals(type)) {
                title = "メンションされました";
                icon = "📣";

            } else if ("COMMENT_REPLY".equals(type)) {
                title = "コメントに返信がありました";
                icon = "↩️";

            } else if ("PRIORITY_CHANGED".equals(type)) {
                title = "優先度が変更されました";
                icon = "⚡";

            } else if ("PROJECT_JOINED".equals(type)) {
                title = "プロジェクトに参加しました";
                icon = "👥";

            } else if ("FILE_ATTACHED".equals(type)) {
                title = "ファイルが添付されました";
                icon = "📎";

            } else if ("REVIEW_REQUESTED".equals(type)) {
                title = "レビューを依頼されました";
                icon = "📝";
            }

            String taskName = notification.getTaskName();
            String projectName = notification.getProjectName();
            String message = notification.getMessage();

            if (taskName == null) {
                taskName = "";
            }

            if (projectName == null) {
                projectName = "";
            }

            if (message == null) {
                message = "";
            }
%>

<div class="notification-item">

    <span class="notification-icon"><%= icon %></span>

    <div class="notification-content">

        <div class="notification-title">
            <%= title %>
        </div>

        <% if (!taskName.isEmpty()) { %>
        <div class="notification-task">
            タスク：<%= taskName %>
        </div>
        <% } %>

        <% if (!projectName.isEmpty()) { %>
        <div class="notification-project">
            プロジェクト：<%= projectName %>
        </div>
        <% } %>

        <div class="notification-detail">
            <%= message %>
        </div>

        <div class="notification-date">
            <%= notification.getCreatedAt() %>
        </div>

    </div>

</div>

<%
        }

    } else {
%>

<div class="notification-item">
    <div class="notification-content">
        <div class="notification-title">
            ログインユーザーを確認できません
        </div>
        <div class="notification-detail">
            セッションにuserIdが設定されているか確認してください。
        </div>
    </div>
</div>

<%
    }
%>

            <%
                }

                if (!notificationExists) {
            %>

            <div class="notification-item">
                <div class="notification-content">

                    <div class="notification-title">
                        現在、期限が近いタスクはありません
                    </div>

                </div>
            </div>

            <%
                }
            %>

        </div>

        <%@ include file="common/footer.jsp" %>

    </main>

</div>

<!-- トースト通知 -->
<div id="toastNotification" class="toast">
    新しい通知があります
</div>

<script>
function toggleMemberMenu() {
    const menu = document.getElementById("memberSubmenu");

    if (menu) {
        if (menu.style.display === "block") {
            menu.style.display = "none";
        } else {
            menu.style.display = "block";
        }
    }
}

function showNotification(message) {
    const toast = document.getElementById("toastNotification");

    if (!toast) {
        return;
    }

    toast.innerText = message;
    toast.style.display = "block";

    setTimeout(function() {
        toast.style.display = "none";
    }, 3000);
}
</script>

</body>
</html>
