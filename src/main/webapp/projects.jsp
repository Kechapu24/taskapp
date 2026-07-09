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
	String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
	String user = "taskuser";
	String password = "taskpass";
	
	try {
		Class.forName("org.postgresql.Driver");
		Connection conn = DriverManager.getConnection(url, user, password);
		
		// ① タスク一覧の取得
		if ("getTasks".equals(action)) {
			String pId = request.getParameter("projectId");
			// status と due_date を取得するように変更
			String sql = "SELECT task_id, task_name, status, TO_CHAR(due_date, 'MM/DD') as fmt_date FROM task WHERE project_id = ? ORDER BY task_id ASC";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(pId));
			ResultSet rs = pstmt.executeQuery();
			
			// 取得したタスクをHTML（<li>タグ）にして画面に返す
			while (rs.next()) {
				int taskId = rs.getInt("task_id");
				String taskName = rs.getString("task_name");
				String status = rs.getString("status");
				String dateStr = rs.getString("fmt_date");
				
				// 期限が未設定(NULL)の場合の対応
				if (dateStr == null) {
					dateStr = "未設定";
				}
				
				// DBのstatusが「完了」だったらチェック状態にする
				boolean isChecked = "完了".equals(status);
				
				out.print("<li class='task-li'>");
				out.print("<input type='checkbox' class='task-check' onchange='toggleTask(" + taskId + ", this.checked, \"" + pId + "\")' " + (isChecked ? "checked" : "") + "> ");
				out.print("<div class='task-content-text'>");
				out.print("<span>" + taskName + "</span>");
				out.print("<span class='task-date'>期限: " + dateStr + "</span>");
				out.print("</div>");
				out.print("<button class='task-menu-trigger' onclick='toggleTaskMenu(this)'>⋮</button>");
				out.print("<div class='task-dropdown-menu'>");
				out.print("<button class='dropdown-delete-item' onclick='deleteTask(" + taskId + ", \"" + pId + "\")'>削除</button>");
				out.print("</div>");
				out.print("</li>");
			}
			rs.close(); pstmt.close();
		} 
		// ② タスクの追加
		else if ("addTask".equals(action)) {
			String pId = request.getParameter("projectId");
			String tName = request.getParameter("taskName");
			// 新規追加時は '未着手' として登録
			String sql = "INSERT INTO task (project_id, task_name, status) VALUES (?, ?, '未着手')";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(pId));
			pstmt.setString(2, tName);
			pstmt.executeUpdate();
			pstmt.close();
		} 
		// ③ タスクのチェック状態更新（statusの変更）
		else if ("toggleTask".equals(action)) {
			String tId = request.getParameter("taskId");
			boolean isChecked = Boolean.parseBoolean(request.getParameter("isChecked"));
			// チェックされたら「完了」、外されたら「未着手」にする
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
	// タスクAPI処理が終わったら、ページ全体のHTMLを出力せずにここで終了する
	return; 
}

// ==========================================
// プロジェクトの追加（DBへのINSERT）処理
// ==========================================
if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("newProjectName") != null) {
	String newProjectName = request.getParameter("newProjectName");
	if (!newProjectName.trim().isEmpty()) {
		String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
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
	.main-content { position: relative; }
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
			<header class="content-header" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
				<div class="title-with-btn">
					<h1 class="page-title" style="margin: 0;">プロジェクト一覧</h1>
					<button class="add-project-btn" onclick="addProject()" title="プロジェクトを追加">＋</button>
				</div>
				<div style="display: flex; align-items: center; gap: 15px;">
					<div class="main-search-box" style="margin: 0;">
						<input type="text" class="search-input" placeholder="タスクを検索...">
					</div>
					<a href="account.jsp" class="account-button">アカウント情報</a>
				</div>
			</header>

			<div class="content-body">
				<div class="project-list" id="projectList">
					<%
					// ==========================================
					// DBからプロジェクト一覧 ＋ 各プロジェクトのタスク進捗を取得
					// ==========================================
					String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
					String dbUser = "taskuser";
					String dbPassword = "taskpass";
					
					try {
						Class.forName("org.postgresql.Driver");
						Connection connSelect = DriverManager.getConnection(url, dbUser, dbPassword);
						
						// 【修正】is_checkedではなく、status = '完了' の数をカウントする
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
							
							// 進捗（パーセンテージ）を計算
							int percent = (totalTasks > 0) ? Math.round(((float)checkedTasks / totalTasks) * 100) : 0;
							String domId = "db_proj_" + dbProjectId;
					%>
							<div class="project-card" data-id="<%= domId %>" data-raw-id="<%= dbProjectId %>">
								<div class="project-info-block">
									<div>
										<span class="project-title"><%= projectName %></span>
										<span class="project-percent-badge" id="badge_<%= domId %>"><%= percent %>%</span>
									</div>
									<div class="progress-container">
										<div class="progress-bar-bg">
											<div class="progress-bar-fill" id="fill_<%= domId %>" style="width: <%= percent %>%;"></div>
											<div class="progress-text-inside" id="text_<%= domId %>"><%= percent %>%</div>
										</div>
									</div>
								</div>
								<button class="open-box-btn" onclick="showPanel('<%= projectName %>', '<%= domId %>', '<%= dbProjectId %>')">＋</button>
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
			
			<div class="task-panel-overlay" id="taskOverlay">
				<div class="task-panel">
					<div class="panel-header">
						<button class="close-arrow-btn" onclick="hidePanel()">←</button>
						<h2 class="panel-title" id="panelProjectTitle">プロジェクト名</h2>
						<button class="add-task-btn" onclick="addNewTask()">＋</button>
					</div>
					<div class="panel-body">
						<ul class="task-ul" id="taskUl"></ul>
					</div>
				</div>
			</div>
			
			<script>
				let currentProjectCard = null;
				let currentRawProjectId = null;

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

				function showPanel(projectName, domId, rawProjectId) {
					currentProjectCard = document.querySelector('[data-id="' + domId + '"]');
					currentRawProjectId = rawProjectId;
					
					document.getElementById("panelProjectTitle").innerText = projectName;
					document.getElementById("taskUl").innerHTML = '<li>読み込み中...</li>';
					document.getElementById("taskOverlay").classList.add("show");
					
					loadTasksFromDB();
				}

				function loadTasksFromDB() {
					fetch('projects.jsp?action=getTasks&projectId=' + currentRawProjectId)
						.then(response => response.text())
						.then(html => {
							document.getElementById("taskUl").innerHTML = html;
							calculateProgressLocal();
						});
				}

				function hidePanel() {
					document.getElementById("taskOverlay").classList.remove("show");
				}

				function addNewTask() {
					const taskText = prompt("新しいタスク内容を入力してください：");
					if (taskText && taskText.trim() !== "") {
						const params = new URLSearchParams();
						params.append('action', 'addTask');
						params.append('projectId', currentRawProjectId);
						params.append('taskName', taskText);
						
						fetch('projects.jsp', {
							method: 'POST',
							body: params
						}).then(() => {
							loadTasksFromDB();
						});
					}
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
						calculateProgressLocal();
					});
				}

				function deleteTask(taskId, projectId) {
					if(!confirm("本当に削除しますか？")) return;
					
					const params = new URLSearchParams();
					params.append('action', 'deleteTask');
					params.append('taskId', taskId);
					
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
					const taskUl = document.getElementById("taskUl");
					const checkboxes = taskUl.querySelectorAll(".task-check");
					const totalTasks = checkboxes.length;
					
					let checkedTasks = 0;
					checkboxes.forEach(box => {
						if (box.checked) checkedTasks++;
					});
					
					const percent = totalTasks > 0 ? Math.round((checkedTasks / totalTasks) * 100) : 0;
					const barFill = document.getElementById('fill_' + projectId);
					const barText = document.getElementById('text_' + projectId);
					const badgeText = document.getElementById('badge_' + projectId);
					
					if (barFill && barText) {
						barFill.style.width = percent + '%'; 
						barText.innerText = percent + '%';    
						if (badgeText) {
							badgeText.innerText = percent + '%';
						}
					}
				}
			</script>
			
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
						menu.style.display = (menu.style.display === "block") ? "none" : "block";
					}
				</script>
			</footer>
		</main>
	</div>
</body>
</html>