<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="ja">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>タスク管理アプリ</title>

<link rel="stylesheet" href="css/style.css">
</head>

<body>

<<<<<<< HEAD
<div class="app-container">
=======
	<%
	request.setAttribute("pageTitle", "通知センター");
	request.setAttribute("currentPage", "notifications");
	%>

	<div class="app-container">
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
    <!-- サイドバー -->
    <aside class="sidebar">

        <div class="sidebar-brand">
            タスク管理
        </div>
=======
		<%@ include file="common/sidebar.jsp"%>

		<main class="main-content">

			<%@ include file="common/header.jsp"%>

			<div class="content-body">

				<div class="notification-item unread">
					<!-- 期限が近い通知 -->
					<div class="notification-item unread">
						<span class="notification-dot"></span>

						<div class="notification-content">

							<div class="notification-title">期限が近づいています</div>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
        <ul class="sidebar-menu">

            <li class="menu-item">
                <a href="index.jsp">ダッシュボード</a>
            </li>

            <li class="menu-item">
                <a href="projects.jsp">プロジェクト一覧</a>
            </li>

            <li class="menu-item">
                <a href="taskboard.jsp">タスクボード</a>
            </li>

            <li class="menu-item">
                <a href="settings.jsp">設定</a>
            </li>

            <li class="menu-item">
                <a href="mytasks.jsp">マイタスク</a>
            </li>

            <li class="menu-item active">
                <a href="notifications.jsp">通知センター</a>
            </li>

            <li class="menu-item">
                <a href="logs.jsp">ログ</a>
            </li>

        </ul>

    </aside>


    <!-- メイン -->
    <main class="main-content">

        <header class="content-header">

            <h1 class="page-title">
                通知センター
            </h1>

            <div class="main-search-box">
                <input
                    type="text"
                    class="search-input"
                    placeholder="タスクを検索...">
            </div>

            <a href="account.jsp" class="account-button">
                アカウント情報
            </a>

        </header>


        <!-- 通知一覧 -->
        <div class="content-body">


<%
String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
String user = "taskuser";
String password = "taskpass";

try {

    // PostgreSQLドライバ読み込み
    Class.forName("org.postgresql.Driver");

    // DB接続
    Connection conn =
        DriverManager.getConnection(url, user, password);


    /*
     * 期限が近い、または期限切れのタスクを取得
     *
     * 期限切れ
     * 今日
     * 明日
     * 2日後
     * 3日後
     */
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


    Statement stmt = conn.createStatement();

    ResultSet rs = stmt.executeQuery(sql);


    // 通知が存在するか
    boolean notificationExists = false;


    while (rs.next()) {

        notificationExists = true;

        int taskId = rs.getInt("task_id");

        String taskName =
            rs.getString("task_name");

        String projectName =
            rs.getString("project_name");

        Date dueDate =
            rs.getDate("due_date");

        int userId =
            rs.getInt("user_id");


        /*
         * 今日の日付
         */
        java.time.LocalDate today =
            java.time.LocalDate.now();


        /*
         * DBから取得した期限
         */
        java.time.LocalDate deadline =
            dueDate.toLocalDate();


        /*
         * 今日から期限までの日数
         */
        long days =
            java.time.temporal.ChronoUnit.DAYS.between(
                today,
                deadline
            );


        String notificationTitle;
        String notificationDetail;


        /*
         * 期限切れ
         */
        if (days < 0) {

            notificationTitle =
                "期限を過ぎています";

            notificationDetail =
                "このタスクは期限を過ぎています。"
                + "対応状況を確認してください。";

        }

        /*
         * 期限当日
         */
        else if (days == 0) {

            notificationTitle =
                "本日が期限です";

            notificationDetail =
                "このタスクは本日が期限です。"
                + "早めに対応してください。";

        }

        /*
         * 期限が近い
         */
        else {

            notificationTitle =
                "期限が近づいています";

            notificationDetail =
                "期限まであと"
                + days
                + "日です。"
                + "早めに対応してください。";
        }

%>


            <!-- 通知 -->
            <div class="notification-item unread">

                <span class="notification-dot"></span>

                <div class="notification-content">

                    <div class="notification-title">

                        <%= notificationTitle %>

                    </div>


                    <div class="notification-task">

                        タスク：
                        <%= taskName %>

                    </div>


                    <div class="notification-project">

                        プロジェクト：
                        <%= projectName %>

                    </div>


                    <div class="notification-detail">

                        <%= notificationDetail %>

                    </div>


                    <div class="notification-date">

                        期限：
                        <%= dueDate %>

                    </div>

                </div>

            </div>


<%

    }


    /*
     * 通知が1件もなかった場合
     */
    if (!notificationExists) {

%>

        <div class="notification-item">

            <div class="notification-content">

                <div class="notification-title">

                    現在、期限が近いタスクはありません

                </div>

            </div>

        </div>
=======
							<div class="notification-task">タスク：ログイン機能実装</div>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
<%
=======
							<div class="notification-project">プロジェクト：タスク管理アプリ</div>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
    }
=======
							<div class="notification-detail">期限まであと1日です。早めに対応してください。</div>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD

    rs.close();
    stmt.close();
    conn.close();


} catch (Exception e) {

%>

    <div class="notification-item">

        <div class="notification-content">

            <div class="notification-title">
                DB接続エラー
            </div>

            <div class="notification-detail"
                 style="color:red;">

                <%= e.getMessage() %>

            </div>

        </div>
=======
							<div class="notification-date">2026/06/17 09:00</div>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
    </div>

<%

}

%>


        </div>


        <!-- フッター -->
        <footer class="footer">

            <div class="footer-member">

                <a href="#"
                   onclick="toggleMemberMenu()">

                    開発メンバー ▼

                </a>


                <ul class="member-submenu"
                    id="memberSubmenu">

                    <li>
                        <a href="member/sakata/Sakata.jsp">
                            坂田
                        </a>
                    </li>

                    <li>
                        <a href="member/Shimizu.jsp">
                            清水
                        </a>
                    </li>

                    <li>
                        <a href="member/Higashi/Higashi.jsp">
                            東
                        </a>
                    </li>

                    <li>
                        <a href="member/Miyazaki/Miyazaki.jsp">
                            宮崎
                        </a>
                    </li>

                </ul>

            </div>

        </footer>

    </main>

</div>
=======
						</div>
					</div>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git


<<<<<<< HEAD
<!-- トースト通知 -->
<div id="toastNotification"
     class="toast">
=======
					<!-- 期限切れ通知 -->
					<div class="notification-item unread">
						<span class="notification-dot"></span>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
    新しい通知があります
=======
						<div class="notification-content">
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

<<<<<<< HEAD
</div>
=======
							<div class="notification-title">期限を過ぎています</div>

							<div class="notification-task">タスク：データベース設計</div>

							<div class="notification-project">プロジェクト：タスク管理アプリ</div>

							<div class="notification-detail">
								このタスクは期限を過ぎています。対応状況を確認してください。</div>

							<div class="notification-date">2026/06/17 08:30</div>

						</div>
					</div>
					<span class="notification-dot"></span>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git


<script>

function toggleMemberMenu() {

    const menu =
        document.getElementById("memberSubmenu");

    if (menu.style.display === "block") {

        menu.style.display = "none";

<<<<<<< HEAD
    } else {

        menu.style.display = "block";

    }

}

=======
			<%@ include file="common/footer.jsp"%>
			
			<script>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git

function showNotification(message) {

    const toast =
        document.getElementById("toastNotification");

    toast.innerText = message;

    toast.style.display = "block";

    setTimeout(() => {

        toast.style.display = "none";

    }, 3000);

}

</script>
<<<<<<< HEAD
=======

		</main>
>>>>>>> branch 'main' of https://github.com/Kechapu24/taskapp.git


</body>
</html>