<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// 文字化け防止
request.setCharacterEncoding("UTF-8");

// データベース接続情報
String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
String dbUser = "taskuser";
String dbPassword = "taskpass";

// ==========================================
// 【新機能】タスク・プロジェクトの裏側処理 (JavaScriptから非同期で呼ばれるAPI)
// ==========================================
String action = request.getParameter("action");
if (action != null) {
	try {
		Class.forName("org.postgresql.Driver");
		Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
		
		// ① タスク一覧の取得（横並び表示用にカード形式で出力）
		if ("getTasks".equals(action)) {
			String pId = request.getParameter("projectId");
			String sql = "SELECT t.task_id, t.task_name, t.status, t.priority, TO_CHAR(t.start_date, 'YYYY-MM-DD') as fmt_start_date, TO_CHAR(t.due_date, 'YYYY-MM-DD') as fmt_due_date, t.description, ta.user_id " +
						 "FROM task t LEFT JOIN task_assignee ta ON t.task_id = ta.task_id " +
						 "WHERE t.project_id = ? ORDER BY t.task_id ASC";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(pId));
			ResultSet rs = pstmt.executeQuery();
			
			boolean hasTask = false;
			while (rs.next()) {
				hasTask = true;
				int taskId = rs.getInt("task_id");
				String taskName = rs.getString("task_name");
				String status = rs.getString("status");
				String priority = rs.getString("priority");
				String startDate = rs.getString("fmt_start_date");
				String dueDate = rs.getString("fmt_due_date");
				String description = rs.getString("description");
				int assigneeUserId = rs.getInt("user_id");
				
				if (startDate == null) startDate = "";
				if (dueDate == null) dueDate = "";
				if (description == null) description = "";
				if (status == null) status = "未着手";
				if (priority == null) priority = "中";
				
				String dateStr = dueDate;
				if (!dateStr.isEmpty()) {
					dateStr = dateStr.replace("-", "/");
				}
				
				boolean isChecked = "完了".equals(status);
				
				// 編集用にエスケープ処理
				String escapedTaskName = taskName.replace("\"", "&quot;").replace("'", "\\'");
				String escapedDesc = description.replace("\"", "&quot;").replace("\n", "\\n").replace("\r", "");
				
				out.print("<div class='horizontal-task-card'>");
				out.print("<div class='htc-left'>");
				out.print("<input type='checkbox' class='task-check' onchange='toggleTask(" + taskId + ", this.checked, \"" + pId + "\")' " + (isChecked ? "checked" : "") + ">");
				out.print("<span class='htc-name " + (isChecked ? "completed-task" : "") + "'>" + taskName + "</span>");
				out.print("</div>");
				
				out.print("<div class='htc-right'>");
				if (!dateStr.isEmpty()) {
					out.print("<span class='htc-info'>📅 " + dateStr + "</span>");
				}
				out.print("<button class='task-menu-trigger' onclick='toggleTaskMenu(this)'>⋮</button>");
				out.print("<div class='task-dropdown-menu'>");
				out.print("<button class='dropdown-edit-item' onclick='openEditTaskModal(" + taskId + ", \"" + escapedTaskName + "\", \"" + status + "\", \"" + priority + "\", \"" + startDate + "\", \"" + dueDate + "\", \"" + assigneeUserId + "\", \"" + escapedDesc + "\")'>編集</button>");
				out.print("<button class='dropdown-delete-item' onclick='openDeleteModal(" + taskId + ", \"" + taskName.replace("\"", "&quot;") + "\")'>削除</button>");
				out.print("</div>");
				out.print("</div>");
				
				out.print("</div>");
			}
			if (!hasTask) {
				out.print("<div style='padding: 20px; color: #777; text-align: center; width: 100%;'>タスクはまだ登録されていません。</div>");
			}
			rs.close(); pstmt.close();
		} 
		// ② タスクの追加
		else if ("addTask".equals(action)) {
			String pId = request.getParameter("projectId");
			String tName = request.getParameter("taskName");
			String status = request.getParameter("status");
			String priority = request.getParameter("priority");
			String startDate = request.getParameter("startDate");
			String dueDate = request.getParameter("dueDate");
			String description = request.getParameter("description");
			String userId = request.getParameter("userId");
			
			String sql = "INSERT INTO task (project_id, task_name, status, priority, start_date, due_date, description) VALUES (?, ?, ?, ?, NULLIF(?, '')::DATE, NULLIF(?, '')::DATE, ?)";
			PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			pstmt.setInt(1, Integer.parseInt(pId));
			pstmt.setString(2, tName);
			pstmt.setString(3, (status != null && !status.isEmpty()) ? status : "未着手");
			pstmt.setString(4, (priority != null && !priority.isEmpty()) ? priority : "中");
			pstmt.setString(5, startDate);
			pstmt.setString(6, dueDate);
			pstmt.setString(7, description);
			pstmt.executeUpdate();
			
			if (userId != null && !userId.isEmpty()) {
				ResultSet generatedKeys = pstmt.getGeneratedKeys();
				if (generatedKeys.next()) {
					int newTaskId = generatedKeys.getInt(1);
					String assigneeSql = "INSERT INTO task_assignee (task_id, user_id) VALUES (?, ?)";
					PreparedStatement aStmt = conn.prepareStatement(assigneeSql);
					aStmt.setInt(1, newTaskId);
					aStmt.setInt(2, Integer.parseInt(userId));
					aStmt.executeUpdate();
					aStmt.close();
				}
				generatedKeys.close();
			}
			pstmt.close();
		} 
		// ②-2 タスクの編集更新
		else if ("editTask".equals(action)) {
			String tId = request.getParameter("taskId");
			String tName = request.getParameter("taskName");
			String status = request.getParameter("status");
			String priority = request.getParameter("priority");
			String startDate = request.getParameter("startDate");
			String dueDate = request.getParameter("dueDate");
			String description = request.getParameter("description");
			String userId = request.getParameter("userId");
			
			int taskIdInt = Integer.parseInt(tId);
			
			String sql = "UPDATE task SET task_name = ?, status = ?, priority = ?, start_date = NULLIF(?, '')::DATE, due_date = NULLIF(?, '')::DATE, description = ? WHERE task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, tName);
			pstmt.setString(2, (status != null && !status.isEmpty()) ? status : "未着手");
			pstmt.setString(3, (priority != null && !priority.isEmpty()) ? priority : "中");
			pstmt.setString(4, startDate);
			pstmt.setString(5, dueDate);
			pstmt.setString(6, description);
			pstmt.setInt(7, taskIdInt);
			pstmt.executeUpdate();
			pstmt.close();
			
			// 担当者の更新 (一度削除して再登録)
			PreparedStatement delAssignee = conn.prepareStatement("DELETE FROM task_assignee WHERE task_id = ?");
			delAssignee.setInt(1, taskIdInt);
			delAssignee.executeUpdate();
			delAssignee.close();
			
			if (userId != null && !userId.isEmpty()) {
				String insAssignee = "INSERT INTO task_assignee (task_id, user_id) VALUES (?, ?)";
				PreparedStatement insStmt = conn.prepareStatement(insAssignee);
				insStmt.setInt(1, taskIdInt);
				insStmt.setInt(2, Integer.parseInt(userId));
				insStmt.executeUpdate();
				insStmt.close();
			}
		}
		// ③ タスクのチェック状態更新
		else if ("toggleTask".equals(action)) {
			String tId = request.getParameter("taskId");
			boolean isChecked = Boolean.parseBoolean(request.getParameter("isChecked"));
			String newStatus = isChecked ? "完了" : "未着手";
			
			String sql = "UPDATE task SET status = ? WHERE task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, newStatus);
			pstmt.setInt(2, Integer.parseInt(tId));
			pstmt.executeUpdate();
			pstmt.close();
		} 
		// ④ タスクの削除
		else if ("deleteTask".equals(action)) {
			String tId = request.getParameter("taskId");
			int taskIdInt = Integer.parseInt(tId);
			
			PreparedStatement delAssignee = conn.prepareStatement("DELETE FROM task_assignee WHERE task_id = ?");
			delAssignee.setInt(1, taskIdInt);
			delAssignee.executeUpdate();
			delAssignee.close();

			String sql = "DELETE FROM task WHERE task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, taskIdInt);
			pstmt.executeUpdate();
			pstmt.close();
		}
		// ⑤ プロジェクトの削除
		else if ("deleteProject".equals(action)) {
			String pId = request.getParameter("projectId");
			int projectId = Integer.parseInt(pId);
			
			PreparedStatement pstmtAssignee = conn.prepareStatement("DELETE FROM task_assignee WHERE task_id IN (SELECT task_id FROM task WHERE project_id = ?)");
			pstmtAssignee.setInt(1, projectId);
			pstmtAssignee.executeUpdate();
			pstmtAssignee.close();

			PreparedStatement pstmtTask = conn.prepareStatement("DELETE FROM task WHERE project_id = ?");
			pstmtTask.setInt(1, projectId);
			pstmtTask.executeUpdate();
			pstmtTask.close();

			PreparedStatement pstmtProj = conn.prepareStatement("DELETE FROM project WHERE project_id = ?");
			pstmtProj.setInt(1, projectId);
			pstmtProj.executeUpdate();
			pstmtProj.close();
		}
		conn.close();
	} catch (Exception e) {
		e.printStackTrace();
	}
	return; 
}

// ==========================================
// プロジェクトの追加（DBへのINSERT）処理
// ==========================================
if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("newProjectName") != null) {
	String newProjectName = request.getParameter("newProjectName");
	if (!newProjectName.trim().isEmpty()) {
		try {
			Class.forName("org.postgresql.Driver");
			Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
			String sql = "INSERT INTO project (project_name, description) VALUES (?, ?)";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, newProjectName);
			pstmt.setString(2, "");
			pstmt.executeUpdate();
			pstmt.close(); conn.close();
		} catch (Exception e) { e.printStackTrace(); }
		
		response.sendRedirect("projects.jsp");
		return;
	}
}
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ - プロジェクト一覧</title>
<link rel="stylesheet" href="css/style.css">
<style>
	.main-content { position: relative; display: flex; flex-direction: column; height: 100vh; box-sizing: border-box; overflow: hidden; }
	.content-header { flex-shrink: 0; }
	
	.split-container {
		display: flex;
		flex-direction: column;
		flex: 1;
		overflow: hidden;
		background-color: #f8f9fa;
	}
	
	/* 上半分：プロジェクト進捗一覧エリア */
	.top-project-section {
		height: 45%; /* 初期高さ */
		min-height: 100px;
		overflow-y: auto;
		padding: 12px 20px;
		background: #fff;
		display: flex;
		flex-direction: column;
		flex-shrink: 0;
	}

	/* 上下リサイズ用スプリッターバー */
	.splitter {
		height: 8px;
		background-color: #eaeaea;
		cursor: row-resize;
		position: relative;
		transition: background-color 0.2s;
		flex-shrink: 0;
	}
	.splitter:hover, .splitter.dragging {
		background-color: #1b6ef3;
	}
	.splitter::after {
		content: "";
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		width: 30px;
		height: 3px;
		background-color: #ccc;
		border-radius: 2px;
	}
	.splitter:hover::after, .splitter.dragging::after {
		background-color: #fff;
	}

	.top-section-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 10px;
	}

	.top-section-title {
		font-size: 1.05rem;
		font-weight: bold;
		color: #333;
		margin: 0;
	}

	.sort-container {
		font-size: 13px;
		color: #555;
		display: flex;
		align-items: center;
		gap: 6px;
	}

	.sort-select {
		padding: 4px 8px;
		border: 1px solid #dcdcdc;
		border-radius: 4px;
		background: #fff;
		font-size: 13px;
		cursor: pointer;
	}
	
	.project-list-vertical {
		display: flex;
		flex-direction: column;
		gap: 8px;
	}
	
	.project-card {
		cursor: pointer;
		transition: all 0.2s ease;
		border: 1px solid #eaeaea;
		border-radius: 8px;
		padding: 10px 16px;
		background: #fff;
		display: flex;
		align-items: center;
		justify-content: space-between;
		font-size: 14px;
		box-shadow: 0 1px 2px rgba(0,0,0,0.01);
	}
	.project-card:hover {
		border-color: #bce8ff;
		background-color: #fcfdff;
	}
	.project-card.active-project {
		border-color: #1b6ef3;
		background-color: #f4f8ff;
	}
	
	/* 進捗100%のプロジェクトを薄くするスタイル */
	.project-card.completed-project {
		opacity: 0.5;
		background-color: #f8f9fa;
		border-color: #e9ecef;
	}
	.project-card.completed-project:hover {
		background-color: #f1f3f5;
		border-color: #dee2e6;
	}

	.project-card .project-info-block {
		width: 100%;
		display: flex;
		align-items: center;
		justify-content: space-between;
	}
	.project-left-group {
		display: flex;
		align-items: center;
		gap: 12px;
		min-width: 180px;
	}
	.project-folder-icon {
		color: #6c757d;
		font-size: 16px;
	}
	.project-card .project-title {
		font-size: 14px;
		font-weight: 500;
		color: #333;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
	.project-card .progress-container {
		flex: 1;
		max-width: 350px;
		margin: 0 20px;
	}
	.project-card .progress-bar-bg {
		height: 8px;
		border-radius: 4px;
		background: #e9ecef;
		position: relative;
		overflow: hidden;
	}
	.project-card .progress-bar-fill {
		height: 100%;
		background: #1b6ef3;
		border-radius: 4px;
	}
	.project-right-group {
		display: flex;
		align-items: center;
		gap: 16px;
		flex-shrink: 0;
		position: relative;
	}
	.project-percent-badge {
		font-size: 13px;
		font-weight: 600;
		color: #333;
		min-width: 38px;
		text-align: right;
	}
	
	.status-badge {
		font-size: 12px;
		padding: 2px 10px;
		border-radius: 12px;
		font-weight: 500;
	}
	.status-badge.in-progress {
		background: #e6f0ff;
		color: #1b6ef3;
	}
	.status-badge.not-started {
		background: #f1f3f5;
		color: #6c757d;
	}
	.status-badge.completed {
		background: #e3fafc;
		color: #0b7285;
	}

	.project-menu-trigger {
		background: none;
		border: none;
		cursor: pointer;
		font-size: 18px;
		color: #6c757d;
		padding: 0 4px;
	}
	.project-menu-trigger:hover {
		color: #333;
	}

	.project-dropdown-menu {
		display: none;
		position: absolute;
		right: 0;
		top: 25px;
		background: #fff;
		border: 1px solid #ccc;
		border-radius: 4px;
		box-shadow: 0 4px 8px rgba(0,0,0,0.1);
		z-index: 100;
		min-width: 90px;
	}
	.project-dropdown-menu.open {
		display: block;
	}

	/* 下半分：選択されたプロジェクトのタスク表示エリア */
	.bottom-task-section {
		flex: 1;
		display: flex;
		flex-direction: column;
		background: #fff;
		overflow: hidden;
		min-height: 100px;
	}
	
	.bottom-task-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 12px 20px;
		background: #fff;
		border-bottom: 1px solid #eaeaea;
		flex-shrink: 0;
	}
	
	.bottom-task-header h2 {
		margin: 0;
		font-size: 1.1rem;
		color: #333;
	}
	
	.bottom-header-actions {
		display: flex;
		gap: 10px;
		align-items: center;
	}

	.btn-primary-custom {
		padding: 6px 14px;
		cursor: pointer;
		background: #1b6ef3;
		color: #fff;
		border: none;
		border-radius: 6px;
		font-weight: bold;
		font-size: 13px;
		display: flex;
		align-items: center;
		gap: 4px;
	}
	.btn-primary-custom:hover {
		background: #0f5bc4;
	}

	.btn-secondary-custom {
		padding: 6px 14px;
		cursor: pointer;
		background: #fff;
		color: #333;
		border: 1px solid #dcdcdc;
		border-radius: 6px;
		font-weight: 500;
		font-size: 13px;
		display: flex;
		align-items: center;
		gap: 4px;
	}
	.btn-secondary-custom:hover {
		background: #f8f9fa;
	}

	.bottom-task-body {
		flex: 1;
		overflow-y: auto;
		padding: 15px 20px;
		display: flex;
		flex-wrap: wrap;
		gap: 10px;
		align-content: flex-start;
	}
	
	.horizontal-task-card {
		display: flex;
		align-items: center;
		justify-content: space-between;
		background: #fff;
		border: 1px solid #eaeaea;
		border-radius: 8px;
		padding: 10px 16px;
		box-shadow: 0 1px 2px rgba(0,0,0,0.01);
		width: calc(50% - 5px);
		box-sizing: border-box;
		height: fit-content;
	}

	.htc-left {
		display: flex;
		align-items: center;
		gap: 12px;
		flex: 1;
		min-width: 0;
	}
	.task-check {
		width: 16px;
		height: 16px;
		cursor: pointer;
		accent-color: #1b6ef3;
	}
	.htc-name {
		font-size: 14px;
		color: #333;
		font-weight: 500;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
	.completed-task {
		text-decoration: line-through;
		color: #888;
	}
	.htc-right {
		display: flex;
		align-items: center;
		gap: 24px;
		flex-shrink: 0;
		position: relative;
	}
	.htc-info {
		font-size: 13px;
		color: #6c757d;
	}

	.task-menu-trigger {
		background: none;
		border: none;
		cursor: pointer;
		font-size: 18px;
		color: #6c757d;
		padding: 0 4px;
	}
	.task-menu-trigger:hover {
		color: #333;
	}
	.task-dropdown-menu {
		display: none;
		position: absolute;
		right: 0;
		top: 25px;
		background: #fff;
		border: 1px solid #ccc;
		border-radius: 4px;
		box-shadow: 0 4px 8px rgba(0,0,0,0.1);
		z-index: 100;
		min-width: 90px;
	}
	.task-dropdown-menu.open {
		display: block;
	}
	.dropdown-edit-item {
		width: 100%;
		padding: 6px 12px;
		background: none;
		border: none;
		color: #333;
		text-align: left;
		cursor: pointer;
		font-size: 13px;
		border-bottom: 1px solid #f0f2f5;
	}
	.dropdown-edit-item:hover {
		background: #f8f9fa;
	}
	.dropdown-delete-item {
		width: 100%;
		padding: 6px 12px;
		background: none;
		border: none;
		color: #d9534f;
		text-align: left;
		cursor: pointer;
		font-size: 13px;
	}
	.dropdown-delete-item:hover {
		background: #f8d7da;
	}

	/* モーダル共通 */
	.modal-overlay {
		display: none;
		position: fixed;
		top: 0; left: 0;
		width: 100%; height: 100%;
		background-color: rgba(0, 0, 0, 0.5);
		z-index: 2000;
		justify-content: center;
		align-items: center;
	}
	.modal-content {
		background: #fff;
		padding: 30px;
		border-radius: 10px;
		width: 550px;
		max-width: 95%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 8px 20px rgba(0,0,0,0.2);
	}
	.modal-content h3 {
		margin-top: 0;
		margin-bottom: 20px;
		font-size: 1.3rem;
		border-bottom: 2px solid #f0f2f5;
		padding-bottom: 10px;
	}
	.modal-form-group {
		margin-bottom: 16px;
	}
	.modal-form-group label {
		display: block;
		margin-bottom: 6px;
		font-size: 14px;
		font-weight: bold;
		color: #333;
	}
	.modal-form-group input[type="text"],
	.modal-form-group input[type="date"],
	.modal-form-group select,
	.modal-form-group textarea {
		width: 100%;
		padding: 10px;
		box-sizing: border-box;
		border: 1px solid #ccc;
		border-radius: 6px;
		font-size: 14px;
	}
	.modal-form-group textarea {
		resize: vertical;
	}
	.modal-row {
		display: flex;
		gap: 15px;
	}
	.modal-row .modal-form-group {
		flex: 1;
	}
	.modal-actions {
		text-align: right;
		margin-top: 25px;
		border-top: 1px solid #f0f2f5;
		padding-top: 15px;
	}
	.modal-actions button {
		padding: 10px 20px;
		margin-left: 10px;
		cursor: pointer;
		border: none;
		border-radius: 6px;
		font-size: 14px;
		font-weight: bold;
	}
	.btn-cancel {
		background-color: #e0e0e0;
		color: #333;
	}
	.btn-cancel:hover {
		background-color: #d0d0d0;
	}
	.btn-save {
		background-color: #007bff;
		color: white;
	}
	.btn-save:hover {
		background-color: #0056b3;
	}
	.delete-modal-content {
		width: 400px;
		text-align: center;
	}
	.delete-modal-content h3 {
		color: #d9534f;
		border-bottom: none;
	}
	.btn-delete-confirm {
		background-color: #d9534f;
		color: white;
	}
	.btn-delete-confirm:hover {
		background-color: #c9302c;
	}
</style>
</head>
<body>

	<div class="app-container">
		<aside class="sidebar">
			<div class="sidebar-brand">タスク管理</div>
			<ul class="sidebar-menu">
				<li class="menu-item"><a href="index.jsp">ダッシュボード</a></li>
				<li class="menu-item active"><a href="projects.jsp">プロジェクト一覧</a></li>
				<li class="menu-item"><a href="taskboard.jsp">タスクボード</a></li>
				<li class="menu-item"><a href="settings.jsp">設定</a></li>
				<li class="menu-item"><a href="mytasks.jsp">マイタスク</a></li>
				<li class="menu-item"><a href="notifications.jsp">通知センター</a></li>
				<li class="menu-item"><a href="logs.jsp">ログ</a></li>
			</ul>
		</aside>

		<main class="main-content">
			<header class="content-header" style="display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 12px 20px; background: #fff; border-bottom: 1px solid #ddd;">
				<div class="title-with-btn">
					<h1 class="page-title" style="margin: 0; font-size: 1.3rem;">プロジェクト一覧</h1>
					<button class="add-project-btn" onclick="openProjectModal()" title="プロジェクトを追加">＋</button>
				</div>
				<div style="display: flex; align-items: center; gap: 15px;">
					<div class="main-search-box" style="margin: 0;">
						<input type="text" class="search-input" placeholder="タスクを検索...">
					</div>
					<a href="account.jsp" class="account-button">アカウント情報</a>
				</div>
			</header>

			<!-- 画面上下分割コンテナ -->
			<div class="split-container" id="splitContainer">
				<!-- 上半分：プロジェクトの進捗一覧 -->
				<div class="top-project-section" id="topSection">
					<div class="top-section-header">
						<h2 class="top-section-title">プロジェクトの進捗一覧</h2>
						<div class="sort-container">
							<span>並び替え：</span>
							<select class="sort-select" id="sortSelect" onchange="sortProjects()">
								<option value="newest">更新日 (新しい順)</option>
								<option value="name">プロジェクト名</option>
								<option value="progressDesc">進捗率の高い順</option>
							</select>
						</div>
					</div>

					<div class="project-list-vertical" id="projectList">
						<%
						boolean isFirst = true;
						
						try {
							Class.forName("org.postgresql.Driver");
							Connection connSelect = DriverManager.getConnection(url, dbUser, dbPassword);
							
							String sqlSelect = 
								"SELECT p.project_id, p.project_name, " +
								"COUNT(t.task_id) AS total_tasks, " +
								"SUM(CASE WHEN t.status = '完了' THEN 1 ELSE 0 END) AS checked_tasks " +
								"FROM project p " +
								"LEFT JOIN task t ON p.project_id = t.project_id " +
								"GROUP BY p.project_id, p.project_name " +
								"ORDER BY p.project_id DESC";
								
							Statement stmtSelect = connSelect.createStatement();
							ResultSet rs = stmtSelect.executeQuery(sqlSelect);

							while(rs.next()) {
								int dbProjectId = rs.getInt("project_id");
								String projectName = rs.getString("project_name");
								int totalTasks = rs.getInt("total_tasks");
								int checkedTasks = rs.getInt("checked_tasks");
								
								int percent = (totalTasks > 0) ? (int)Math.round(((double)checkedTasks / totalTasks) * 100.0) : 0;
								
								String statusText = "未着手";
								String statusClass = "not-started";
								if (percent == 100) {
									statusText = "完了";
									statusClass = "completed";
								} else if (percent > 0) {
									statusText = "進行中";
									statusClass = "in-progress";
								}
								
								String domId = "db_proj_" + dbProjectId;
								boolean activeClass = isFirst;
								if (isFirst) {
									isFirst = false;
								}
						%>
								<div class="project-card <%= activeClass ? "active-project" : "" %> <%= (percent == 100) ? "completed-project" : "" %>" 
									 id="card_<%= dbProjectId %>" 
									 data-id="<%= domId %>" 
									 data-raw-id="<%= dbProjectId %>" 
									 data-name="<%= projectName %>"
									 data-progress="<%= percent %>"
									 onclick="selectProject('<%= dbProjectId %>', '<%= projectName.replace("'", "\\'") %>', this)">
									<div class="project-info-block">
										<div class="project-left-group">
											<span class="project-folder-icon">📁</span>
											<span class="project-title"><%= projectName %></span>
										</div>
										<div class="progress-container">
											<div class="progress-bar-bg">
												<div class="progress-bar-fill" id="fill_<%= domId %>" style="width: <%= percent %>%;"></div>
											</div>
										</div>
										<div class="project-right-group">
											<span class="project-percent-badge" id="badge_<%= domId %>"><%= percent %>%</span>
											<span class="status-badge <%= statusClass %>" id="badge_status_<%= domId %>"><%= statusText %></span>
											<button class="project-menu-trigger" onclick="event.stopPropagation(); toggleProjectMenu(this);">⋮</button>
											<div class="project-dropdown-menu">
												<button class="dropdown-delete-item" onclick="event.stopPropagation(); openProjectDeleteModal('<%= dbProjectId %>', '<%= projectName.replace("'", "\\'") %>')">削除</button>
											</div>
										</div>
									</div>
								</div>
						<%
							}
							rs.close(); stmtSelect.close(); connSelect.close();
						} catch (Exception e) {
							out.println("<p style='color:red; font-weight:bold;'>DBエラー：" + e.getMessage() + "</p>");
						}
						%>
					</div>
				</div>

				<!-- 上下リサイズ用のバー -->
				<div class="splitter" id="splitter"></div>

				<!-- 下半分：選択されたプロジェクトのタスク一覧表示エリア -->
				<div class="bottom-task-section">
					<div class="bottom-task-header">
						<h2 id="bottomProjectTitle">タスク一覧</h2>
						<div class="bottom-header-actions">
							<button class="btn-primary-custom" onclick="addNewTask()">+ タスクを追加</button>
							<button class="btn-secondary-custom" onclick="alert('マイタスクに追加機能')">+ マイタスクに追加</button>
						</div>
					</div>
					<div class="bottom-task-body" id="taskContainer">
						<!-- 非同期で横2列のタスクカードが読み込まれます -->
					</div>
				</div>
			</div>
			
			<!-- プロジェクト追加用モーダル -->
			<div id="projectModal" class="modal-overlay">
				<div class="modal-content" style="width: 450px;">
					<h3>プロジェクトの追加</h3>
					
					<div class="modal-form-group">
						<label>プロジェクト名 <span style="color:red;">*</span></label>
						<input type="text" id="modalProjectName" placeholder="例：新システム開発プロジェクト">
					</div>
					
					<div class="modal-actions">
						<button class="btn-cancel" onclick="closeProjectModal()">キャンセル</button>
						<button class="btn-save" onclick="submitNewProject()">保存</button>
					</div>
				</div>
			</div>

			<!-- タスク追加・編集用モーダル -->
			<div id="taskModal" class="modal-overlay">
				<div class="modal-content">
					<h3 id="taskModalTitle">タスクの追加</h3>
					
					<div class="modal-form-group">
						<label>タスク名 <span style="color:red;">*</span></label>
						<input type="text" id="modalTaskName" placeholder="例：要件定義書の作成">
					</div>
					
					<div class="modal-row">
						<div class="modal-form-group">
							<label>状態</label>
							<select id="modalStatus">
								<option value="未着手">未着手</option>
								<option value="進行中">進行中</option>
								<option value="完了">完了</option>
							</select>
						</div>
						<div class="modal-form-group">
							<label>優先度</label>
							<select id="modalPriority">
								<option value="低">低</option>
								<option value="中" selected>中</option>
								<option value="高">高</option>
							</select>
						</div>
					</div>
					
					<div class="modal-row">
						<div class="modal-form-group">
							<label>開始日</label>
							<input type="date" id="modalStartDate">
						</div>
						<div class="modal-form-group">
							<label>期限</label>
							<input type="date" id="modalDueDate">
						</div>
					</div>
					
					<div class="modal-form-group">
						<label>担当者</label>
						<select id="modalUserId">
							<option value="">未設定</option>
							<%
							try {
								Class.forName("org.postgresql.Driver");
								Connection userConn = DriverManager.getConnection(url, dbUser, dbPassword);
								Statement userStmt = userConn.createStatement();
								ResultSet userRs = userStmt.executeQuery("SELECT user_id, user_name FROM users ORDER BY user_id");
								while(userRs.next()) {
							%>
								<option value="<%= userRs.getInt("user_id") %>"><%= userRs.getString("user_name") %></option>
							<%
								}
								userRs.close(); userStmt.close(); userConn.close();
							} catch(Exception e) {}
							%>
						</select>
					</div>
					
					<div class="modal-form-group">
						<label>説明</label>
						<textarea id="modalDescription" rows="4" placeholder="タスクの詳細や備考を入力..."></textarea>
					</div>
					
					<div class="modal-actions">
						<button class="btn-cancel" onclick="closeTaskModal()">キャンセル</button>
						<button class="btn-save" onclick="submitTaskModal()">保存</button>
					</div>
				</div>
			</div>

			<!-- タスク削除確認用モーダル -->
			<div id="deleteModal" class="modal-overlay">
				<div class="modal-content delete-modal-content">
					<h3>タスクの削除</h3>
					<p id="deleteMessage" style="margin: 15px 0 25px 0; color: #555;"></p>
					<div class="modal-actions" style="text-align: center; border-top: none; padding-top: 0; margin-top: 0;">
						<button class="btn-cancel" onclick="closeDeleteModal()">キャンセル</button>
						<button class="btn-delete-confirm" onclick="executeDeleteTask()">削除する</button>
					</div>
				</div>
			</div>

			<!-- プロジェクト削除確認用モーダル -->
			<div id="projectDeleteModal" class="modal-overlay">
				<div class="modal-content delete-modal-content">
					<h3>プロジェクトの削除</h3>
					<p id="projectDeleteMessage" style="margin: 15px 0 25px 0; color: #555;"></p>
					<div class="modal-actions" style="text-align: center; border-top: none; padding-top: 0; margin-top: 0;">
						<button class="btn-cancel" onclick="closeProjectDeleteModal()">キャンセル</button>
						<button class="btn-delete-confirm" onclick="executeDeleteProject()">削除する</button>
					</div>
				</div>
			</div>
			
			<script>
				let currentProjectCard = null;
				let currentRawProjectId = null;
				let targetTaskIdForDelete = null;
				let targetProjectIdForDelete = null;
				let taskModalMode = 'add'; // 'add' または 'edit'
				let targetTaskIdForEdit = null;

				// 上下リサイズ機能
				const splitter = document.getElementById('splitter');
				const topSection = document.getElementById('topSection');
				const splitContainer = document.getElementById('splitContainer');
				let isDragging = false;

				splitter.addEventListener('mousedown', (e) => {
					isDragging = true;
					splitter.classList.add('dragging');
					document.body.style.cursor = 'row-resize';
					e.preventDefault();
				});

				window.addEventListener('mousemove', (e) => {
					if (!isDragging) return;
					const containerRect = splitContainer.getBoundingClientRect();
					const newHeight = e.clientY - containerRect.top;
					const totalHeight = containerRect.height;
					
					if (newHeight > 100 && newHeight < totalHeight - 100) {
						const percentage = (newHeight / totalHeight) * 100;
						topSection.style.height = percentage + '%';
					}
				});

				window.addEventListener('mouseup', () => {
					if (isDragging) {
						isDragging = false;
						splitter.classList.remove('dragging');
						document.body.style.cursor = 'default';
					}
				});

				window.addEventListener('DOMContentLoaded', () => {
					const firstCard = document.querySelector('.project-card');
					if (firstCard) {
						const rawId = firstCard.getAttribute('data-raw-id');
						const title = firstCard.getAttribute('data-name');
						selectProject(rawId, title, firstCard);
					}
					
					document.querySelectorAll('.project-card').forEach(card => {
						if (card.getAttribute("data-progress") === "100") {
							card.classList.add("completed-project");
							const listContainer = document.getElementById("projectList");
							if (!card.hasAttribute("data-original-index")) {
								const cards = Array.from(listContainer.children);
								card.setAttribute("data-original-index", cards.indexOf(card));
							}
							listContainer.appendChild(card);
						}
					});
				});

				function openProjectModal() {
					document.getElementById("modalProjectName").value = "";
					document.getElementById("projectModal").style.display = "flex";
				}

				function closeProjectModal() {
					document.getElementById("projectModal").style.display = "none";
				}

				function submitNewProject() {
					const projectName = document.getElementById("modalProjectName").value;
					if (projectName && projectName.trim() !== "") {
						const form = document.createElement("form");
						form.method = "POST";
						form.action = "projects.jsp";
						const input = document.createElement("input");
						input.type = "hidden";
						input.name = "newProjectName";
						input.value = projectName;
						form.appendChild(input);
						document.body.appendChild(form);
						form.submit();
					} else {
						alert("プロジェクト名を入力してください。");
					}
				}

				function sortProjects() {
					const sortType = document.getElementById("sortSelect").value;
					const listContainer = document.getElementById("projectList");
					const cards = Array.from(listContainer.getElementsByClassName("project-card"));

					const activeCards = cards.filter(c => c.getAttribute("data-progress") !== "100");
					const completedCards = cards.filter(c => c.getAttribute("data-progress") === "100");

					activeCards.sort((a, b) => {
						if (sortType === "newest") {
							return parseInt(b.getAttribute("data-raw-id")) - parseInt(a.getAttribute("data-raw-id"));
						} else if (sortType === "name") {
							const nameA = a.getAttribute("data-name");
							const nameB = b.getAttribute("data-name");
							return nameA.localeCompare(nameB, 'ja');
						} else if (sortType === "progressDesc") {
							return parseInt(b.getAttribute("data-progress")) - parseInt(a.getAttribute("data-progress"));
						}
						return 0;
					});

					activeCards.forEach(card => listContainer.appendChild(card));
					completedCards.forEach(card => listContainer.appendChild(card));
				}

				function selectProject(rawProjectId, projectName, cardElement) {
					document.querySelectorAll('.project-card').forEach(c => c.classList.remove('active-project'));
					if (cardElement) {
						cardElement.classList.add('active-project');
						currentProjectCard = cardElement;
					}
					
					currentRawProjectId = rawProjectId;
					document.getElementById("bottomProjectTitle").innerText = projectName + "のタスク";
					document.getElementById("taskContainer").innerHTML = '<div style="padding: 20px; color: #777; text-align: center; width: 100%;">読み込み中...</div>';
					
					loadTasksFromDB();
				}

				function loadTasksFromDB() {
					if (!currentRawProjectId) return;
					
					fetch('projects.jsp?action=getTasks&projectId=' + currentRawProjectId)
						.then(response => response.text())
						.then(html => {
							document.getElementById("taskContainer").innerHTML = html;
							calculateProgressLocal();
						});
				}

				function addNewTask() {
					if (!currentRawProjectId) {
						alert("プロジェクトが選択されていません。");
						return;
					}
					taskModalMode = 'add';
					targetTaskIdForEdit = null;
					document.getElementById("taskModalTitle").innerText = "タスクの追加";
					document.getElementById("modalTaskName").value = "";
					document.getElementById("modalStatus").value = "未着手";
					document.getElementById("modalPriority").value = "中";
					document.getElementById("modalStartDate").value = "";
					document.getElementById("modalDueDate").value = "";
					document.getElementById("modalUserId").value = "";
					document.getElementById("modalDescription").value = "";
					
					document.getElementById("taskModal").style.display = "flex";
				}

				function openEditTaskModal(taskId, taskName, status, priority, startDate, dueDate, userId, description) {
					taskModalMode = 'edit';
					targetTaskIdForEdit = taskId;
					document.getElementById("taskModalTitle").innerText = "タスクの編集";
					document.getElementById("modalTaskName").value = taskName;
					document.getElementById("modalStatus").value = status;
					document.getElementById("modalPriority").value = priority;
					document.getElementById("modalStartDate").value = startDate;
					document.getElementById("modalDueDate").value = dueDate;
					document.getElementById("modalUserId").value = (userId === "0" || userId === "null") ? "" : userId;
					document.getElementById("modalDescription").value = description;
					
					document.getElementById("taskModal").style.display = "flex";
				}

				function closeTaskModal() {
					document.getElementById("taskModal").style.display = "none";
				}

				function submitTaskModal() {
					const taskName = document.getElementById("modalTaskName").value;
					const status = document.getElementById("modalStatus").value;
					const priority = document.getElementById("modalPriority").value;
					const startDate = document.getElementById("modalStartDate").value;
					const dueDate = document.getElementById("modalDueDate").value;
					const userId = document.getElementById("modalUserId").value;
					const description = document.getElementById("modalDescription").value;
					
					if (!taskName || taskName.trim() === "") {
						alert("タスク名を入力してください。");
						return;
					}

					const params = new URLSearchParams();
					if (taskModalMode === 'add') {
						params.append('action', 'addTask');
						params.append('projectId', currentRawProjectId);
					} else {
						params.append('action', 'editTask');
						params.append('taskId', targetTaskIdForEdit);
					}
					params.append('taskName', taskName);
					params.append('status', status);
					params.append('priority', priority);
					params.append('startDate', startDate);
					params.append('dueDate', dueDate);
					params.append('userId', userId);
					params.append('description', description);
					
					fetch('projects.jsp', {
						method: 'POST',
						body: params
					}).then(() => {
						closeTaskModal();
						loadTasksFromDB();
					});
				}
				
				function openDeleteModal(taskId, taskName) {
					targetTaskIdForDelete = taskId;
					document.getElementById("deleteMessage").innerText = "「" + taskName + "」を本当に削除しますか？";
					document.getElementById("deleteModal").style.display = "flex";
				}

				function closeDeleteModal() {
					targetTaskIdForDelete = null;
					document.getElementById("deleteModal").style.display = "none";
				}

				function executeDeleteTask() {
					if (!targetTaskIdForDelete) return;
					
					const params = new URLSearchParams();
					params.append('action', 'deleteTask');
					params.append('taskId', targetTaskIdForDelete);
					
					fetch('projects.jsp', {
						method: 'POST',
						body: params
					}).then(() => {
						closeDeleteModal();
						loadTasksFromDB();
					});
				}

				function openProjectDeleteModal(projectId, projectName) {
					targetProjectIdForDelete = projectId;
					document.getElementById("projectDeleteMessage").innerText = "プロジェクト「" + projectName + "」および含まれるすべてのタスクを本当に削除しますか？";
					document.getElementById("projectDeleteModal").style.display = "flex";
				}

				function closeProjectDeleteModal() {
					targetProjectIdForDelete = null;
					document.getElementById("projectDeleteModal").style.display = "none";
				}

				function executeDeleteProject() {
					if (!targetProjectIdForDelete) return;

					const params = new URLSearchParams();
					params.append('action', 'deleteProject');
					params.append('projectId', targetProjectIdForDelete);

					fetch('projects.jsp', {
						method: 'POST',
						body: params
					}).then(() => {
						location.reload();
					});
				}
				
				function toggleTask(taskId, isChecked, projectId) {
					const params = new URLSearchParams();
					params.append('action', 'toggleTask');
					params.append('taskId', taskId);
					params.append('isChecked', isChecked);
					
					fetch('projects.jsp', {
						method: 'POST',
						body: params
					}).then(() => {
						loadTasksFromDB();
					});
				}

				function toggleTaskMenu(buttonElement) {
					const menu = buttonElement.nextElementSibling;
					document.querySelectorAll('.task-dropdown-menu, .project-dropdown-menu').forEach(m => {
						if (m !== menu) m.classList.remove('open');
					});
					menu.classList.toggle('open');
					setTimeout(() => {
						window.addEventListener('click', function closeMenu(e) {
							if (!menu.contains(e.target) && e.target !== buttonElement) {
								menu.classList.remove('open');
								window.removeEventListener('click', closeMenu);
							}
						});
					}, 0);
				}

				function toggleProjectMenu(buttonElement) {
					const menu = buttonElement.nextElementSibling;
					document.querySelectorAll('.task-dropdown-menu, .project-dropdown-menu').forEach(m => {
						if (m !== menu) m.classList.remove('open');
					});
					menu.classList.toggle('open');
					setTimeout(() => {
						window.addEventListener('click', function closeMenu(e) {
							if (!menu.contains(e.target) && e.target !== buttonElement) {
								menu.classList.remove('open');
								window.removeEventListener('click', closeMenu);
							}
						});
					}, 0);
				}

				function calculateProgressLocal() {
					if(!currentProjectCard) return;
					
					const domId = currentProjectCard.getAttribute("data-id");
					const taskContainer = document.getElementById("taskContainer");
					const checkboxes = taskContainer.querySelectorAll(".task-check");
					const totalTasks = checkboxes.length;
					
					let checkedTasks = 0;
					checkboxes.forEach(box => {
						if (box.checked) checkedTasks++;
					});
					
					const percent = totalTasks > 0 ? Math.round((checkedTasks / totalTasks) * 100) : 0;
					const barFill = document.getElementById('fill_' + domId);
					const badgeText = document.getElementById('badge_' + domId);
					const statusBadge = document.getElementById('badge_status_' + domId);
					
					if (barFill) {
						barFill.style.width = percent + '%'; 
						if (badgeText) {
							badgeText.innerText = percent + '%';
						}
						currentProjectCard.setAttribute("data-progress", percent);

						if (statusBadge) {
							statusBadge.className = "status-badge";
							if (percent === 100) {
								statusBadge.innerText = "完了";
								statusBadge.classList.add("completed");
							} else if (percent > 0) {
								statusBadge.innerText = "進行中";
								statusBadge.classList.add("in-progress");
							} else {
								statusBadge.innerText = "未着手";
								statusBadge.classList.add("not-started");
							}
						}

						const listContainer = document.getElementById("projectList");
						if (percent === 100) {
							currentProjectCard.classList.add("completed-project");
							if (!currentProjectCard.hasAttribute("data-original-index")) {
								const cards = Array.from(listContainer.children);
								currentProjectCard.setAttribute("data-original-index", cards.indexOf(currentProjectCard));
							}
							listContainer.appendChild(currentProjectCard);
						} else {
							currentProjectCard.classList.remove("completed-project");
							if (currentProjectCard.hasAttribute("data-original-index")) {
								const originalIndex = parseInt(currentProjectCard.getAttribute("data-original-index"));
								const cards = Array.from(listContainer.children);
								let targetNode = dataOriginalIndexSearch(cards, originalIndex);
								if (targetNode) {
									listContainer.insertBefore(currentProjectCard, targetNode);
								} else {
									listContainer.appendChild(currentProjectCard);
								}
							}
						}
					}
				}

				function dataOriginalIndexSearch(cards, originalIndex) {
					for (let i = 0; i < cards.length; i++) {
						let idx = parseInt(cards[i].getAttribute("data-original-index"));
						if (!isNaN(idx) && idx > originalIndex) {
							return cards[i];
						}
					}
					return null;
				}
			</script>
			
			<footer class="footer" style="flex-shrink: 0;">
				<div class="footer-member">
					<a href="#" onclick="toggleMemberMenu()"> 開発メンバー ▼ </a>
					<ul class="member-submenu" id="memberSubmenu">
						<li><a href="member/sakata/Sakata.jsp">Samata</a></li>
						<li><a href="member/Shimizu.jsp">清水</a></li>
						<li><a href="member/Higashi/Higashi.jsp">東</a></li>
						<li><a href="member/Miyazaki.jsp">宮崎</a></li>
					</ul>
				</div>
				<script>
					function toggleMemberMenu() {
						const menu = document.getElementById("memberSubmenu");
						menu.style.display = (menu.style.display === "block") ? "none" : "block";
					}
				</script>
			</footer>
		</main>
	</div>
</body>
</html>