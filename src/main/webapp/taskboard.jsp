<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.temporal.ChronoUnit"%>
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

				<%
int todoCount = 0;
int doingCount = 0;
int doneCount = 0;

String countUrl = "jdbc:postgresql://172.16.1.94:5432/taskapp";
String countUser = "taskuser";
String countPassword = "taskpass";

try {
    Class.forName("org.postgresql.Driver");
    Connection countConn = DriverManager.getConnection(countUrl, countUser, countPassword);

    String countSql = "SELECT status, COUNT(*) AS task_count "
                    + "FROM task "
                    + "GROUP BY status";

    Statement countStmt = countConn.createStatement();
    ResultSet countRs = countStmt.executeQuery(countSql);

    while (countRs.next()) {
        String status = countRs.getString("status");
        int count = countRs.getInt("task_count");

        if ("未着手".equals(status)) {
            todoCount = count;
        } else if ("進行中".equals(status)) {
            doingCount = count;
        } else if ("完了".equals(status)) {
            doneCount = count;
        }
    }

    countRs.close();
    countStmt.close();
    countConn.close();

} catch (Exception e) {
%>
				<p style="color: red;">
					件数取得エラー:
					<%= e.getMessage() %></p>
				<%
}
%>

				<div class="task-board">

					<div class="task-column status-todo">
						<div class="column-header">
							<h2>
								未着手（<%= todoCount %>）
							</h2>
							<button class="add-task-btn-small"
								onclick="openAddTaskModal('未着手')">＋</button>
						</div>

						<%
			String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
			String user = "taskuser";
			String password = "taskpass";

			try {
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(url, user, password);

				String sql = "SELECT "
				           + "t.task_id, "
				           + "t.task_name, "
				           + "t.description, "
				           + "t.status, "
				           + "t.priority, "
				           + "t.start_date, "
				           + "t.due_date, "
				           + "p.project_name, "
				           + "COALESCE(string_agg(DISTINCT u.user_name, ', '), '未設定') AS assignees, "
				           + "COALESCE(string_agg(DISTINCT c.comment_text, '<br>'), 'コメントなし') AS comments, "
				           + "COALESCE(string_agg(DISTINCT a.file_name, '<br>'), '添付なし') AS files, "
				           + "COALESCE(MIN(tg.tag_id), 0) AS tag_id, "
				           + "COALESCE(string_agg(DISTINCT tg.tag_name, ', '), 'タグなし') AS tags "
				           + "FROM task t "
				           + "JOIN project p ON t.project_id = p.project_id "
				           + "LEFT JOIN task_assignee ta ON t.task_id = ta.task_id "
				           + "LEFT JOIN users u ON ta.user_id = u.user_id "
				           + "LEFT JOIN comment c ON t.task_id = c.task_id "
				           + "LEFT JOIN attachment a ON t.task_id = a.task_id "
				           + "LEFT JOIN task_tag tt ON t.task_id = tt.task_id "
				           + "LEFT JOIN tag tg ON tt.tag_id = tg.tag_id "
				           + "WHERE t.status = '未着手' "
				           + "GROUP BY t.task_id, t.task_name, t.description, t.status, t.priority, t.start_date, t.due_date, p.project_name "
				           + "ORDER BY t.due_date";

				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				while (rs.next()) {

				    String deadlineClass = "";

				    java.sql.Date dueDateSql = rs.getDate("due_date");

				    if (dueDateSql != null) {
				        LocalDate today = LocalDate.now();
				        LocalDate dueDate = dueDateSql.toLocalDate();

				        long daysLeft = ChronoUnit.DAYS.between(today, dueDate);

				        if (daysLeft < 0) {
				            deadlineClass = "overdue";
				        } else if (daysLeft <= 1) {
				            deadlineClass = "deadline-red";
				        } else if (daysLeft <= 3) {
				            deadlineClass = "deadline-yellow";
				        }
				    }
				%>

						<div class="task-card <%= deadlineClass %>">

							<div class="task-card-header">
								<h3><%= rs.getString("task_name") %></h3>

								<div class="task-menu">
									<button class="menu-button"
										onclick="toggleTaskMenu(event, 'menu-<%= rs.getInt("task_id") %>')">⋯</button>

									<div class="menu-dropdown"
										id="menu-<%= rs.getInt("task_id") %>">
										<button
											onclick="openModalFromElement('詳細', 'detail-<%= rs.getInt("task_id") %>')">詳細</button>
										<button
											onclick="openModalFromElement('編集', 'edit-<%= rs.getInt("task_id") %>')">編集</button>
									</div>
								</div>
							</div>

							<p>
								<%= rs.getString("project_name") %></p>
							<p>
								<%= rs.getString("assignees") %></p>
							<p>
								<%= rs.getDate("due_date") %></p>

							<div class="task-card-actions">
								<button class="icon-button"
									onclick="openModalFromElement('コメント', 'comment-<%= rs.getInt("task_id") %>')">
									💬 コメント</button>

								<button class="icon-button"
									onclick="openModalFromElement('添付ファイル', 'file-<%= rs.getInt("task_id") %>')">
									📎 添付</button>
							</div>

							<!-- 詳細ポップアップ用の中身 -->
							<div id="detail-<%= rs.getInt("task_id") %>"
								style="display: none;">
								<p>
									<strong>タスク名：</strong><%= rs.getString("task_name") %></p>
								<p>
									<strong>プロジェクト：</strong><%= rs.getString("project_name") %></p>
								<p>
									<strong>説明：</strong><%= rs.getString("description") %></p>
								<p>
									<strong>担当者：</strong><%= rs.getString("assignees") %></p>
								<p>
									<strong>タグ：</strong><%= rs.getString("tags") %></p>
								<p>
									<strong>状態：</strong><%= rs.getString("status") %></p>
								<p>
									<strong>優先度：</strong><%= rs.getString("priority") %></p>
								<p>
									<strong>開始日：</strong><%= rs.getDate("start_date") %></p>
								<p>
									<strong>期限：</strong><%= rs.getDate("due_date") %></p>
							</div>

							<!-- 編集ポップアップ用の中身 -->
							<div id="edit-<%= rs.getInt("task_id") %>" style="display: none;">
								<form class="edit-form" action="taskUpdate.jsp" method="post">

									<input type="hidden" name="task_id"
										value="<%= rs.getInt("task_id") %>"> <label>タスク名</label>
									<input type="text" name="task_name"
										value="<%= rs.getString("task_name") %>" required> <label>状態</label>
									<select name="status">
										<option value="未着手"
											<%= "未着手".equals(rs.getString("status")) ? "selected" : "" %>>未着手</option>
										<option value="進行中"
											<%= "進行中".equals(rs.getString("status")) ? "selected" : "" %>>進行中</option>
										<option value="完了"
											<%= "完了".equals(rs.getString("status")) ? "selected" : "" %>>完了</option>
									</select> <label>優先度</label> <select name="priority">
										<option value="低"
											<%= "低".equals(rs.getString("priority")) ? "selected" : "" %>>低</option>
										<option value="中"
											<%= "中".equals(rs.getString("priority")) ? "selected" : "" %>>中</option>
										<option value="高"
											<%= "高".equals(rs.getString("priority")) ? "selected" : "" %>>高</option>
									</select> <label>開始日</label> <input type="date" name="start_date"
										value="<%= rs.getDate("start_date") %>"><label>期限</label>
									<input type="date" name="due_date"
										value="<%= rs.getDate("due_date") %>"> <label>説明</label>
									<textarea name="description"><%= rs.getString("description") == null ? "" : rs.getString("description") %></textarea>

									<label>担当者</label> <select name="user_id">
										<option value="1">伊藤</option>
										<option value="2">高橋</option>
										<option value="3">中村</option>
										<option value="4">小林</option>
										<option value="5">加藤</option>
									</select> 

									<button type="submit" class="modal-submit-btn">保存</button>
								</form>
							</div>

							<!-- コメントポップアップ用の中身 -->
							<div id="comment-<%= rs.getInt("task_id") %>"
								style="display: none;">
								<p><%= rs.getString("comments") %></p>
							</div>

							<!-- 添付ファイルポップアップ用の中身 -->
							<div id="file-<%= rs.getInt("task_id") %>" style="display: none;">
								<p><%= rs.getString("files") %></p>
							</div>

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

					<div class="task-column status-doing">
						<div class="column-header">
							<h2>
								進行中（<%= doingCount %>）
							</h2>
							<button class="add-task-btn-small"
								onclick="openAddTaskModal('進行中')">＋</button>
						</div>

						<%
			try {
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(url, user, password);

				String sql = "SELECT "
				           + "t.task_id, "
				           + "t.task_name, "
				           + "t.description, "
				           + "t.status, "
				           + "t.priority, "
				           + "t.start_date, "
				           + "t.due_date, "
				           + "p.project_name, "
				           + "COALESCE(string_agg(DISTINCT u.user_name, ', '), '未設定') AS assignees, "
				           + "COALESCE(string_agg(DISTINCT c.comment_text, '<br>'), 'コメントなし') AS comments, "
				           + "COALESCE(string_agg(DISTINCT a.file_name, '<br>'), '添付なし') AS files, "
				           + "COALESCE(string_agg(DISTINCT tg.tag_name, ', '), 'タグなし') AS tags "
				           + "FROM task t "
				           + "JOIN project p ON t.project_id = p.project_id "
				           + "LEFT JOIN task_assignee ta ON t.task_id = ta.task_id "
				           + "LEFT JOIN users u ON ta.user_id = u.user_id "
				           + "LEFT JOIN comment c ON t.task_id = c.task_id "
				           + "LEFT JOIN attachment a ON t.task_id = a.task_id "
				           + "LEFT JOIN task_tag tt ON t.task_id = tt.task_id "
				           + "LEFT JOIN tag tg ON tt.tag_id = tg.tag_id "
				           + "WHERE t.status = '進行中' "
				           + "GROUP BY t.task_id, t.task_name, t.description, t.status, t.priority, t.start_date, t.due_date, p.project_name "
				           + "ORDER BY t.due_date";

				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				while (rs.next()) {

				    String deadlineClass = "";

				    java.sql.Date dueDateSql = rs.getDate("due_date");

				    if (dueDateSql != null) {
				        LocalDate today = LocalDate.now();
				        LocalDate dueDate = dueDateSql.toLocalDate();

				        long daysLeft = ChronoUnit.DAYS.between(today, dueDate);

				        if (daysLeft < 0) {
				            deadlineClass = "overdue";
				        } else if (daysLeft <= 1) {
				            deadlineClass = "deadline-red";
				        } else if (daysLeft <= 3) {
				            deadlineClass = "deadline-yellow";
				        }
				    }
				%>

						<div class="task-card <%= deadlineClass %>">

							<div class="task-card-header">
								<h3><%= rs.getString("task_name") %></h3>

								<div class="task-menu">
									<button class="menu-button"
										onclick="toggleTaskMenu(event, 'menu-<%= rs.getInt("task_id") %>')">⋯</button>

									<div class="menu-dropdown"
										id="menu-<%= rs.getInt("task_id") %>">
										<button
											onclick="openModalFromElement('詳細', 'detail-<%= rs.getInt("task_id") %>')">詳細</button>
										<button
											onclick="openModalFromElement('編集', 'edit-<%= rs.getInt("task_id") %>')">編集</button>
									</div>
								</div>
							</div>

							<p>
								<%= rs.getString("project_name") %></p>
							<p>
								<%= rs.getString("assignees") %></p>
							<p>
								<%= rs.getDate("due_date") %></p>

							<div class="task-card-actions">
								<button class="icon-button"
									onclick="openModalFromElement('コメント', 'comment-<%= rs.getInt("task_id") %>')">
									💬 コメント</button>

								<button class="icon-button"
									onclick="openModalFromElement('添付ファイル', 'file-<%= rs.getInt("task_id") %>')">
									📎 添付</button>
							</div>

							<!-- 詳細ポップアップ用の中身 -->
							<div id="detail-<%= rs.getInt("task_id") %>"
								style="display: none;">
								<p>
									<strong>タスク名：</strong><%= rs.getString("task_name") %></p>
								<p>
									<strong>プロジェクト：</strong><%= rs.getString("project_name") %></p>
								<p>
									<strong>説明：</strong><%= rs.getString("description") %></p>
								<p>
									<strong>担当者：</strong><%= rs.getString("assignees") %></p>
								<p>
									<strong>タグ：</strong><%= rs.getString("tags") %></p>
								<p>
									<strong>状態：</strong><%= rs.getString("status") %></p>
								<p>
									<strong>優先度：</strong><%= rs.getString("priority") %></p>
								<p>
									<strong>開始日：</strong><%= rs.getDate("start_date") %></p>
								<p>
									<strong>期限：</strong><%= rs.getDate("due_date") %></p>
							</div>

							<!-- 編集ポップアップ用の中身 -->
							<div id="edit-<%= rs.getInt("task_id") %>" style="display: none;">
								<form class="edit-form" action="taskUpdate.jsp" method="post">

									<input type="hidden" name="task_id"
										value="<%= rs.getInt("task_id") %>"> <label>タスク名</label>
									<input type="text" name="task_name"
										value="<%= rs.getString("task_name") %>" required> <label>状態</label>
									<select name="status">
										<option value="未着手"
											<%= "未着手".equals(rs.getString("status")) ? "selected" : "" %>>未着手</option>
										<option value="進行中"
											<%= "進行中".equals(rs.getString("status")) ? "selected" : "" %>>進行中</option>
										<option value="完了"
											<%= "完了".equals(rs.getString("status")) ? "selected" : "" %>>完了</option>
									</select> <label>優先度</label> <select name="priority">
										<option value="低"
											<%= "低".equals(rs.getString("priority")) ? "selected" : "" %>>低</option>
										<option value="中"
											<%= "中".equals(rs.getString("priority")) ? "selected" : "" %>>中</option>
										<option value="高"
											<%= "高".equals(rs.getString("priority")) ? "selected" : "" %>>高</option>
									</select> <label>開始日</label> <input type="date" name="start_date"
										value="<%= rs.getDate("start_date") %>"> <label>期限</label>
									<input type="date" name="due_date"
										value="<%= rs.getDate("due_date") %>"> <label>説明</label>
									<textarea name="description"><%= rs.getString("description") == null ? "" : rs.getString("description") %></textarea>

									<label>担当者</label> <select name="user_id">
										<option value="1">伊藤</option>
										<option value="2">高橋</option>
										<option value="3">中村</option>
										<option value="4">小林</option>
										<option value="5">加藤</option>
									</select>

									<button type="submit" class="modal-submit-btn">保存</button>
								</form>
							</div>

							<!-- コメントポップアップ用の中身 -->
							<div id="comment-<%= rs.getInt("task_id") %>"
								style="display: none;">
								<p><%= rs.getString("comments") %></p>
							</div>

							<!-- 添付ファイルポップアップ用の中身 -->
							<div id="file-<%= rs.getInt("task_id") %>" style="display: none;">
								<p><%= rs.getString("files") %></p>
							</div>

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

					<div class="task-column status-done">
						<div class="column-header">
							<h2>
								完了（<%= doneCount %>）
							</h2>
							<button class="add-task-btn-small"
								onclick="openAddTaskModal('完了')">＋</button>
						</div>

						<%
			try {
				Class.forName("org.postgresql.Driver");
				Connection conn = DriverManager.getConnection(url, user, password);

				String sql = "SELECT "
				           + "t.task_id, "
				           + "t.task_name, "
				           + "t.description, "
				           + "t.status, "
				           + "t.priority, "
				           + "t.start_date, "
				           + "t.due_date, "
				           + "p.project_name, "
				           + "COALESCE(string_agg(DISTINCT u.user_name, ', '), '未設定') AS assignees, "
				           + "COALESCE(string_agg(DISTINCT c.comment_text, '<br>'), 'コメントなし') AS comments, "
				           + "COALESCE(string_agg(DISTINCT a.file_name, '<br>'), '添付なし') AS files, "
				           + "COALESCE(string_agg(DISTINCT tg.tag_name, ', '), 'タグなし') AS tags "
				           + "FROM task t "
				           + "JOIN project p ON t.project_id = p.project_id "
				           + "LEFT JOIN task_assignee ta ON t.task_id = ta.task_id "
				           + "LEFT JOIN users u ON ta.user_id = u.user_id "
				           + "LEFT JOIN comment c ON t.task_id = c.task_id "
				           + "LEFT JOIN attachment a ON t.task_id = a.task_id "
				           + "LEFT JOIN task_tag tt ON t.task_id = tt.task_id "
				           + "LEFT JOIN tag tg ON tt.tag_id = tg.tag_id "
				           + "WHERE t.status = '完了' "
				           + "GROUP BY t.task_id, t.task_name, t.description, t.status, t.priority, t.start_date, t.due_date, p.project_name "
				           + "ORDER BY t.due_date";

				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				while (rs.next()) {

				    String deadlineClass = "";

				    java.sql.Date dueDateSql = rs.getDate("due_date");

				    if (dueDateSql != null) {
				        LocalDate today = LocalDate.now();
				        LocalDate dueDate = dueDateSql.toLocalDate();

				        long daysLeft = ChronoUnit.DAYS.between(today, dueDate);

				        if (daysLeft < 0) {
				            deadlineClass = "overdue";
				        } else if (daysLeft <= 1) {
				            deadlineClass = "deadline-red";
				        } else if (daysLeft <= 3) {
				            deadlineClass = "deadline-yellow";
				        }
				    }
				%>

						<div class="task-card <%= deadlineClass %>">

							<div class="task-card-header">
								<h3><%= rs.getString("task_name") %></h3>

								<div class="task-menu">
									<button class="menu-button"
										onclick="toggleTaskMenu(event, 'menu-<%= rs.getInt("task_id") %>')">⋯</button>

									<div class="menu-dropdown"
										id="menu-<%= rs.getInt("task_id") %>">
										<button
											onclick="openModalFromElement('詳細', 'detail-<%= rs.getInt("task_id") %>')">詳細</button>
										<button
											onclick="openModalFromElement('編集', 'edit-<%= rs.getInt("task_id") %>')">編集</button>
									</div>
								</div>
							</div>

							<p>
								<%= rs.getString("project_name") %></p>
							<p>
								<%= rs.getString("assignees") %></p>
							<p>
								<%= rs.getDate("due_date") %></p>

							<div class="task-card-actions">
								<button class="icon-button"
									onclick="openModalFromElement('コメント', 'comment-<%= rs.getInt("task_id") %>')">
									💬 コメント</button>

								<button class="icon-button"
									onclick="openModalFromElement('添付ファイル', 'file-<%= rs.getInt("task_id") %>')">
									📎 添付</button>
							</div>

							<!-- 詳細ポップアップ用の中身 -->
							<div id="detail-<%= rs.getInt("task_id") %>"
								style="display: none;">
								<p>
									<strong>タスク名：</strong><%= rs.getString("task_name") %></p>
								<p>
									<strong>プロジェクト：</strong><%= rs.getString("project_name") %></p>
								<p>
									<strong>説明：</strong><%= rs.getString("description") %></p>
								<p>
									<strong>担当者：</strong><%= rs.getString("assignees") %></p>
								<p>
									<strong>タグ：</strong><%= rs.getString("tags") %></p>
								<p>
									<strong>状態：</strong><%= rs.getString("status") %></p>
								<p>
									<strong>優先度：</strong><%= rs.getString("priority") %></p>
								<p>
									<strong>開始日：</strong><%= rs.getDate("start_date") %></p>
								<p>
									<strong>期限：</strong><%= rs.getDate("due_date") %></p>
							</div>

							<!-- 編集ポップアップ用の中身 -->
							<div id="edit-<%= rs.getInt("task_id") %>" style="display: none;">
								<form class="edit-form" action="taskUpdate.jsp" method="post">

									<input type="hidden" name="task_id"
										value="<%= rs.getInt("task_id") %>"> <label>タスク名</label>
									<input type="text" name="task_name"
										value="<%= rs.getString("task_name") %>" required> <label>状態</label>
									<select name="status">
										<option value="未着手"
											<%= "未着手".equals(rs.getString("status")) ? "selected" : "" %>>未着手</option>
										<option value="進行中"
											<%= "進行中".equals(rs.getString("status")) ? "selected" : "" %>>進行中</option>
										<option value="完了"
											<%= "完了".equals(rs.getString("status")) ? "selected" : "" %>>完了</option>
									</select> <label>優先度</label> <select name="priority">
										<option value="低"
											<%= "低".equals(rs.getString("priority")) ? "selected" : "" %>>低</option>
										<option value="中"
											<%= "中".equals(rs.getString("priority")) ? "selected" : "" %>>中</option>
										<option value="高"
											<%= "高".equals(rs.getString("priority")) ? "selected" : "" %>>高</option>
									</select> <label>開始日</label> <input type="date" name="start_date"
										value="<%= rs.getDate("start_date") %>"> <label>期限</label>
									<input type="date" name="due_date"
										value="<%= rs.getDate("due_date") %>"> <label>説明</label>
									<textarea name="description"><%= rs.getString("description") == null ? "" : rs.getString("description") %></textarea>

									<label>担当者</label> <select name="user_id">
										<option value="1">伊藤</option>
										<option value="2">高橋</option>
										<option value="3">中村</option>
										<option value="4">小林</option>
										<option value="5">加藤</option>
									</select>

									<button type="submit" class="modal-submit-btn">保存</button>
								</form>
							</div>

							<!-- コメントポップアップ用の中身 -->
							<div id="comment-<%= rs.getInt("task_id") %>"
								style="display: none;">
								<p><%= rs.getString("comments") %></p>
							</div>

							<!-- 添付ファイルポップアップ用の中身 -->
							<div id="file-<%= rs.getInt("task_id") %>" style="display: none;">
								<p><%= rs.getString("files") %></p>
							</div>

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
						<li><a href="member/Miyazaki/Miyazaki.jsp">宮崎</a></li>
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

				<script>
					function openModalFromElement(title, elementId) {
						const source = document.getElementById(elementId);
						const modalOverlay = document
								.getElementById("modalOverlay");
						const modalTitle = document
								.getElementById("modalTitle");
						const modalBody = document.getElementById("modalBody");

						modalTitle.textContent = title;
						modalBody.innerHTML = source.innerHTML;
						modalOverlay.style.display = "flex";

						closeAllTaskMenus();
					}

					function closeModal() {
						document.getElementById("modalOverlay").style.display = "none";
					}

					function toggleTaskMenu(event, menuId) {
						event.stopPropagation();

						closeAllTaskMenus();

						const menu = document.getElementById(menuId);
						menu.style.display = "block";
					}

					function closeAllTaskMenus() {
						const menus = document
								.querySelectorAll(".menu-dropdown");

						menus.forEach(function(menu) {
							menu.style.display = "none";
						});
					}

					window.addEventListener("click", function(event) {
						closeAllTaskMenus();

						const modalOverlay = document
								.getElementById("modalOverlay");

						if (event.target === modalOverlay) {
							closeModal();
						}
					});
				</script>

				<script>
					function openAddTaskModal(status) {
						const source = document.getElementById("task-add-form");
						const modalOverlay = document
								.getElementById("modalOverlay");
						const modalTitle = document
								.getElementById("modalTitle");
						const modalBody = document.getElementById("modalBody");

						modalTitle.textContent = "タスク追加";
						modalBody.innerHTML = source.innerHTML;
						modalOverlay.style.display = "flex";

						const statusInput = modalBody
								.querySelector("#addTaskStatus");
						statusInput.value = status;

						closeAllTaskMenus();
					}
				</script>

			</footer>
		</main>

	</div>

	<div class="modal-overlay" id="modalOverlay">
		<div class="modal-content">
			<div class="modal-header">
				<h2 id="modalTitle">タイトル</h2>
				<button class="modal-close" onclick="closeModal()">×</button>
			</div>

			<div class="modal-body" id="modalBody"></div>
		</div>
	</div>

	<div id="task-add-form" style="display: none;">
		<form class="edit-form" action="taskAdd.jsp" method="post">

			<input type="hidden" name="status" id="addTaskStatus"> <label>プロジェクト</label>
			<select name="project_id" required>
				<option value="1">販売管理システム</option>
				<option value="2">在庫管理システム</option>
				<option value="3">社内ポータルサイト</option>
				<option value="4">勤怠管理システム</option>
			</select> <label>タスク名</label> <input type="text" name="task_name" required>

			<label>説明</label>
			<textarea name="description"></textarea>

			<label>優先度</label> <select name="priority">
				<option value="低">低</option>
				<option value="中" selected>中</option>
				<option value="高">高</option>
			</select> <label>開始日</label> <input type="date" name="start_date"> <label>期限</label>
			<input type="date" name="due_date"> <label>担当者</label> <select
				name="user_id">
				<option value="1">伊藤</option>
				<option value="2">高橋</option>
				<option value="3">中村</option>
				<option value="4">小林</option>
				<option value="5">加藤</option>
			</select>

			<button type="submit" class="modal-submit-btn">追加</button>
		</form>
	</div>



</body>
</html>