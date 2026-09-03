<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// 文字化け防止
request.setCharacterEncoding("UTF-8");

// ==========================================
// 【新機能】タスクの裏側処理 (JavaScriptから非同期で呼ばれるAPI)
// ==========================================
String action = request.getParameter("action");
if (action != null) {
	String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
	String user = "taskuser";
	String password = "taskpass";
	
	try {
		Class.forName("org.postgresql.Driver");
		Connection conn = DriverManager.getConnection(url, user, password);
		
		// ① タスク一覧の取得（横並び表示用にカード形式で出力）
		if ("getTasks".equals(action)) {
			String pId = request.getParameter("projectId");
			String sql = "SELECT t.task_id, t.task_name, t.status, t.priority, TO_CHAR(t.due_date, 'MM/DD') as fmt_date, u.user_name " +
						 "FROM task t LEFT JOIN task_assignee ta ON t.task_id = ta.task_id LEFT JOIN users u ON ta.user_id = u.user_id " +
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
				String dateStr = rs.getString("fmt_date");
				String userName = rs.getString("user_name");
				
				if (dateStr == null) dateStr = "未設定";
				if (status == null) status = "未着手";
				if (priority == null) priority = "中";
				if (userName == null) userName = "未設定";
				
				boolean isChecked = "完了".equals(status);
				
				// 横並びのタスクカード
				out.print("<div class='horizontal-task-card'>");
				out.print("<div class='htc-left'>");
				out.print("<input type='checkbox' class='task-check' onchange='toggleTask(" + taskId + ", this.checked, \"" + pId + "\")' " + (isChecked ? "checked" : "") + ">");
				out.print("<span class='htc-name " + (isChecked ? "completed-task" : "") + "'>" + taskName + "</span>");
				out.print("</div>");
				
				out.print("<div class='htc-right'>");
				out.print("<span class='htc-badge status-" + status + "'>" + status + "</span>");
				out.print("<span class='htc-badge priority-" + priority + "'>優先:" + priority + "</span>");
				out.print("<span class='htc-info'>期限: " + dateStr + "</span>");
				out.print("<span class='htc-info'>担当: " + userName + "</span>");
				out.print("<button class='task-menu-trigger' onclick='toggleTaskMenu(this)'>⋮</button>");
				out.print("<div class='task-dropdown-menu'>");
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
			String sql = "DELETE FROM task WHERE task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(tId));
			pstmt.executeUpdate();
			pstmt.close();
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
		String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
		String user = "taskuser";
		String password = "taskpass";
		
		try {
			Class.forName("org.postgresql.Driver");
			Connection conn = DriverManager.getConnection(url, user, password);
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
	
	/* 上半分：プロジェクト一覧エリア（縦一列・コンパクト化） */
	.top-project-section {
		flex: 1;
		overflow-y: auto;
		padding: 10px 15px;
		border-bottom: 2px solid #ddd;
	}
	
	.project-list-vertical {
		display: flex;
		flex-direction: column;
		gap: 6px;
	}
	
	/* プロジェクトカードを小さく・横幅1列に */
	.project-card {
		cursor: pointer;
		transition: all 0.2s ease;
		border: 1px solid #ccc;
		border-radius: 4px;
		padding: 6px 12px;
		background: #fff;
		display: flex;
		align-items: center;
		justify-content: space-between;
		font-size: 13px;
	}
	.project-card:hover {
		border-color: #007bff;
		background-color: #f8fbff;
	}
	.project-card.active-project {
		border-color: #007bff;
		background-color: #eef5ff;
		font-weight: bold;
	}
	.project-card .project-info-block {
		width: 100%;
		display: flex;
		align-items: center;
		justify-content: space-between;
	}
	.project-card .project-title {
		font-size: 13px;
	}
	.project-card .progress-container {
		width: 120px;
		margin-left: 15px;
		margin-bottom: 0;
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
		background: #007bff;
	}
	.project-card .progress-text-inside {
		display: none; /* 小さくするため非表示 */
	}
	.project-percent-badge {
		font-size: 12px;
		color: #555;
		margin-left: 10px;
		min-width: 35px;
		text-align: right;
	}

	/* 下半分：選択されたプロジェクトのタスク表示エリア */
	.bottom-task-section {
		flex: 1;
		display: flex;
		flex-direction: column;
		background: #fff;
		overflow: hidden;
		box-shadow: 0 -4px 10px rgba(0,0,0,0.03);
	}
	
	.bottom-task-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 10px 20px;
		background: #f1f3f5;
		border-bottom: 1px solid #ddd;
	}
	
	.bottom-task-header h2 {
		margin: 0;
		font-size: 1.1rem;
		color: #333;
	}
	
	.bottom-task-body {
		flex: 1;
		overflow-y: auto;
		padding: 10px 20px;
		display: flex;
		flex-direction: column;
		gap: 8px;
	}
	
	/* 横向きタスクカードのスタイル */
	.horizontal-task-card {
		display: flex;
		align-items: center;
		justify-content: space-between;
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 6px;
		padding: 8px 12px;
		box-shadow: 0 1px 3px rgba(0,0,0,0.02);
	}
	.htc-left {
		display: flex;
		align-items: center;
		gap: 10px;
		flex: 1;
		min-width: 0;
	}
	.htc-name {
		font-size: 14px;
		color: #333;
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
		gap: 12px;
		flex-shrink: 0;
		position: relative;
	}
	.htc-badge {
		font-size: 11px;
		padding: 2px 6px;
		border-radius: 4px;
		font-weight: bold;
	}
	.status-未着手 { background: #f0f0f0; color: #555; }
	.status-進行中 { background: #cce5ff; color: #004085; }
	.status-完了 { background: #d4edda; color: #155724; }
	
	.priority-低 { background: #e2e3e5; color: #383d41; }
	.priority-中 { background: #fff3cd; color: #856404; }
	.priority-高 { background: #f8d7da; color: #721c24; }
	
	.htc-info {
		font-size: 12px;
		color: #666;
	}

	/* タスク内メニューボタンの調整 */
	.task-menu-trigger {
		background: none;
		border: none;
		cursor: pointer;
		font-size: 16px;
		color: #666;
		padding: 0 4px;
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
		min-width: 80px;
	}
	.task-dropdown-menu.open {
		display: block;
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

	/* モーダルのスタイル共通 */
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
					<button class="add-project-btn" onclick="addProject()" title="プロジェクトを追加">＋</button>
				</div>
				<div style="display: flex; align-items: center; gap: 15px;">
					<div class="main-search-box" style="margin: 0;">
						<input type="text" class="search-input" placeholder="タスクを検索...">
					</div>
					<a href="account.jsp" class="account-button">アカウント情報</a>
				</div>
			</header>

			<!-- 画面上下分割コンテナ -->
			<div class="split-container">
				<!-- 上半分：プロジェクト一覧（縦1列・コンパクト） -->
				<div class="top-project-section">
					<div class="project-list-vertical" id="projectList">
						<%
						String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
						String dbUser = "taskuser";
						String dbPassword = "taskpass";
						
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
								
								int percent = (totalTasks > 0) ? Math.round(((float)checkedTasks / totalTasks) * 100) : 0;
								String domId = "db_proj_" + dbProjectId;
								
								boolean activeClass = isFirst;
								if (isFirst) {
									isFirst = false;
								}
						%>
								<div class="project-card <%= activeClass ? "active-project" : "" %>" id="card_<%= dbProjectId %>" data-id="<%= domId %>" data-raw-id="<%= dbProjectId %>" onclick="selectProject('<%= dbProjectId %>', '<%= projectName.replace("'", "\\'") %>', this)">
									<div class="project-info-block">
										<span class="project-title"><%= projectName %></span>
										<div style="display: flex; align-items: center;">
											<div class="progress-container">
												<div class="progress-bar-bg">
													<div class="progress-bar-fill" id="fill_<%= domId %>" style="width: <%= percent %>%;"></div>
												</div>
											</div>
											<span class="project-percent-badge" id="badge_<%= domId %>"><%= percent %>%</span>
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

				<!-- 下半分：選択されたプロジェクトのタスク一覧表示エリア -->
				<div class="bottom-task-section">
					<div class="bottom-task-header">
						<h2 id="bottomProjectTitle">タスク一覧</h2>
						<button class="add-task-btn" onclick="addNewTask()" style="padding: 6px 14px; cursor: pointer; background: #007bff; color: #fff; border: none; border-radius: 4px; font-weight: bold; font-size: 13px;">＋ タスクを追加</button>
					</div>
					<div class="bottom-task-body" id="taskContainer">
						<!-- 非同期で横向きタスクカードが読み込まれます -->
					</div>
				</div>
			</div>
			
			<!-- タスク追加用モーダル -->
			<div id="taskModal" class="modal-overlay">
				<div class="modal-content">
					<h3>タスクの追加</h3>
					
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
						<button class="btn-save" onclick="submitNewTask()">保存</button>
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
			
			<script>
				let currentProjectCard = null;
				let currentRawProjectId = null;
				let targetTaskIdForDelete = null;

				// ページ読み込み時に一番上のプロジェクトを自動選択してタスクを表示する
				window.addEventListener('DOMContentLoaded', () => {
					const firstCard = document.querySelector('.project-card');
					if (firstCard) {
						const rawId = firstCard.getAttribute('data-raw-id');
						const title = firstCard.querySelector('.project-title').innerText;
						selectProject(rawId, title, firstCard);
					}
				});

				function addProject() {
					const projectName = prompt("新しいプロジェクト名を入力してください：");
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
					}
				}

				// プロジェクトをクリックした時の処理（下半分の表示を切り替え）
				function selectProject(rawProjectId, projectName, cardElement) {
					document.querySelectorAll('.project-card').forEach(c => c.classList.remove('active-project'));
					if (cardElement) {
						cardElement.classList.add('active-project');
						currentProjectCard = cardElement;
					}
					
					currentRawProjectId = rawProjectId;
					document.getElementById("bottomProjectTitle").innerText = projectName + " のタスク";
					document.getElementById("taskContainer").innerHTML = '<div style="padding: 20px; color: #777; text-align: center;">読み込み中...</div>';
					
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

				// --- 拡張モーダル制御関数 ---
				function addNewTask() {
					if (!currentRawProjectId) {
						alert("プロジェクトが選択されていません。");
						return;
					}
					document.getElementById("modalTaskName").value = "";
					document.getElementById("modalStatus").value = "未着手";
					document.getElementById("modalPriority").value = "中";
					document.getElementById("modalStartDate").value = "";
					document.getElementById("modalDueDate").value = "";
					document.getElementById("modalUserId").value = "";
					document.getElementById("modalDescription").value = "";
					
					document.getElementById("taskModal").style.display = "flex";
				}

				function closeTaskModal() {
					document.getElementById("taskModal").style.display = "none";
				}

				function submitNewTask() {
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
					params.append('action', 'addTask');
					params.append('projectId', currentRawProjectId);
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
				
				// --- 削除モーダル制御関数 ---
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
					document.querySelectorAll('.task-dropdown-menu').forEach(m => {
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
					
					const projectId = currentProjectCard.getAttribute("data-id");
					const taskContainer = document.getElementById("taskContainer");
					const checkboxes = taskContainer.querySelectorAll(".task-check");
					const totalTasks = checkboxes.length;
					
					let checkedTasks = 0;
					checkboxes.forEach(box => {
						if (box.checked) checkedTasks++;
					});
					
					const percent = totalTasks > 0 ? Math.round((checkedTasks / totalTasks) * 100) : 0;
					const barFill = document.getElementById('fill_' + projectId);
					const badgeText = document.getElementById('badge_' + projectId);
					
					if (barFill) {
						barFill.style.width = percent + '%'; 
						if (badgeText) {
							badgeText.innerText = percent + '%';
						}
					}
				}
			</script>
			
			<footer class="footer" style="flex-shrink: 0;">
				<div class="footer-member">
					<a href="#" onclick="toggleMemberMenu()"> 開発メンバー ▼ </a>
					<ul class="member-submenu" id="memberSubmenu">
						<li><a href="member/sakata/Sakata.jsp">坂田</a></li>
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