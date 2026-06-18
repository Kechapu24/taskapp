<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

	<div class="app-container">

		<aside class="sidebar">
			<div class="sidebar-brand">タスク管理</div>

			<ul class="sidebar-menu">
				<li class="menu-item"><a href="index.jsp">ダッシュボード</a></li>
				<li class="menu-item"><a href="projects.jsp">プロジェクト一覧</a></li>
				<li class="menu-item active"><a href="taskboard.jsp">タスクボード</a></li>
				<li class="menu-item"><a href="settings.jsp">設定</a></li>
				<li class="menu-item"><a href="mytasks.jsp">マイタスク</a></li>
				<li class="menu-item"><a href="notifications.jsp">通知センター</a></li>
				<li class="menu-item"><a href="logs.jsp">ログ</a></li>
			</ul>
		</aside>

		<main class="main-content">
			<header class="content-header">
				<h1 class="page-title">タスクボード</h1>
				<div class="main-search-box">
					<input type="text" class="search-input" placeholder="タスクを検索...">
				</div>
				<a href="account.jsp" class="account-button">アカウント情報</a>
			</header>

			<div class="content-body">

				<div class="task-board">

					<div class="task-column">
						<h2>未着手</h2>

						<%
			String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
			String user = "taskuser";
			String password = "taskpass";

			try {
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(url, user, password);

				String sql = "SELECT task_id, task_name, description, status, priority, start_date, due_date "
				           + "FROM task "
				           + "WHERE status = '未着手' "
				           + "ORDER BY due_date";

				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				while (rs.next()) {
			%>

						<div class="task-card">
							<h3><%= rs.getString("task_name") %></h3>
							<p><%= rs.getString("description") %></p>
							<p>
								優先度：<%= rs.getString("priority") %></p>
							<p>
								開始日：<%= rs.getDate("start_date") %></p>
							<p>
								期限：<%= rs.getDate("due_date") %></p>
						</div>

						<%
				}

				rs.close();
				stmt.close();
				conn.close();

			} catch (Exception e) {
			%>
						<p style="color: red;">
							エラー:
							<%= e.getMessage() %></p>
						<%
			}
			%>

					</div>

					<div class="task-column">
						<h2>進行中</h2>

						<%
			try {
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(url, user, password);

				String sql = "SELECT task_id, task_name, description, status, priority, start_date, due_date "
				           + "FROM task "
				           + "WHERE status = '進行中' "
				           + "ORDER BY due_date";

				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				while (rs.next()) {
			%>

						<div class="task-card">
							<h3><%= rs.getString("task_name") %></h3>
							<p><%= rs.getString("description") %></p>
							<p>
								優先度：<%= rs.getString("priority") %></p>
							<p>
								開始日：<%= rs.getDate("start_date") %></p>
							<p>
								期限：<%= rs.getDate("due_date") %></p>
						</div>

						<%
				}

				rs.close();
				stmt.close();
				conn.close();

			} catch (Exception e) {
			%>
						<p style="color: red;">
							エラー:
							<%= e.getMessage() %></p>
						<%
			}
			%>

					</div>

					<div class="task-column">
						<h2>完了</h2>

						<%
			try {
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(url, user, password);

				String sql = "SELECT task_id, task_name, description, status, priority, start_date, due_date "
				           + "FROM task "
				           + "WHERE status = '完了' "
				           + "ORDER BY due_date";

				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				while (rs.next()) {
			%>

						<div class="task-card">
							<h3><%= rs.getString("task_name") %></h3>
							<p><%= rs.getString("description") %></p>
							<p>
								優先度：<%= rs.getString("priority") %></p>
							<p>
								開始日：<%= rs.getDate("start_date") %></p>
							<p>
								期限：<%= rs.getDate("due_date") %></p>
						</div>

						<%
				}

				rs.close();
				stmt.close();
				conn.close();

			} catch (Exception e) {
			%>
						<p style="color: red;">
							エラー:
							<%= e.getMessage() %></p>
						<%
			}
			%>

					</div>

				</div>

			</div>

			<footer class="footer">

				<div class="footer-member">
					<a href="#" onclick="toggleMemberMenu()"> 開発メンバー ▼ </a>

					<ul class="member-submenu" id="memberSubmenu">
						<li><a href="member/Sakata.jsp">坂田</a></li>
						<li><a href="member/Shimizu.jsp">清水</a></li>
						<li><a href="member/Higashi/Higashi.jsp">東</a></li>
						<li><a href="member/Miyazaki.jsp">宮崎</a></li>
					</ul>
				</div>

				<script>
					function toggleMemberMenu() {
						const menu = document.getElementById("memberSubmenu");

						if (menu.style.display === "block") {
							menu.style.display = "none";
						} else {
							menu.style.display = "block";
						}
					}
				</script>

			</footer>
		</main>

	</div>


</body>
</html>