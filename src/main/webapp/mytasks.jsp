<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// 文字化け防止
request.setCharacterEncoding("UTF-8");

// データベース接続情報
String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
String dbUser = "taskuser";
String dbPassword = "taskpass";

// 仮のユーザーID（ログイン機能実装までの固定値）
int currentUserId = 1;

// ==========================================
// 非同期処理（API）
// ==========================================
String action = request.getParameter("action");
if (action != null) {
	try {
		Class.forName("org.postgresql.Driver");
		Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
		
		// ① 個人タスク一覧の取得
		if ("getPersonalTasks".equals(action)) {
			String sql = "SELECT personal_task_id, task_name, status, TO_CHAR(due_date, 'YYYY-MM-DD') as fmt_due_date " +
						 "FROM personal_task WHERE user_id = ? ORDER BY personal_task_id ASC";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, currentUserId);
			ResultSet rs = pstmt.executeQuery();
			
			boolean hasTask = false;
			while (rs.next()) {
				hasTask = true;
				int taskId = rs.getInt("personal_task_id");
				String taskName = rs.getString("task_name");
				String status = rs.getString("status");
				String dueDate = rs.getString("fmt_due_date");
				
				if (dueDate == null) dueDate = "";
				String dateStr = dueDate;
				if (!dateStr.isEmpty()) {
					String[] parts = dateStr.split("-");
					if (parts.length == 3) {
						dateStr = Integer.parseInt(parts[1]) + "/" + Integer.parseInt(parts[2]);
					}
				}
				
				boolean isChecked = "完了".equals(status);
				String escapedTaskName = taskName.replace("\"", "&quot;").replace("'", "\\'");
				
				out.print("<div class='personal-task-item'>");
				out.print("<div class='pti-left'>");
				out.print("<input type='checkbox' class='task-check' onchange='togglePersonalTask(" + taskId + ", this.checked)' " + (isChecked ? "checked" : "") + ">");
				out.print("<span class='pti-name " + (isChecked ? "completed-task" : "") + "'>" + taskName + "</span>");
				out.print("</div>");
				
				out.print("<div class='pti-right'>");
				if (!dateStr.isEmpty()) {
					out.print("<span class='pti-info'>📅 " + dateStr + "</span>");
				}
				out.print("<button class='task-menu-trigger' onclick='toggleTaskMenu(this)'>⋮</button>");
				out.print("<div class='task-dropdown-menu'>");
				out.print("<button class='dropdown-edit-item' onclick='openEditModal(" + taskId + ", \"" + escapedTaskName + "\", \"" + dueDate + "\", \"" + status + "\")'>編集</button>");
				out.print("<button class='dropdown-delete-item' onclick='openDeleteModal(" + taskId + ", \"" + taskName.replace("\"", "&quot;") + "\")'>削除</button>");
				out.print("</div>");
				out.print("</div>");
				
				out.print("</div>");
			}
			if (!hasTask) {
				out.print("<div style='padding: 20px; color: #777; text-align: center; width: 100%;'>個人タスクはまだ登録されていません。</div>");
			}
			rs.close(); pstmt.close();
		}
		// ② 個人タスクの追加
		else if ("addPersonalTask".equals(action)) {
			String taskName = request.getParameter("taskName");
			String dueDate = request.getParameter("dueDate");
			String status = request.getParameter("status");
			
			String sql = "INSERT INTO personal_task (user_id, task_name, status, due_date) VALUES (?, ?, ?, NULLIF(?, '')::DATE)";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, currentUserId);
			pstmt.setString(2, taskName);
			pstmt.setString(3, (status != null && !status.isEmpty()) ? status : "進行中");
			pstmt.setString(4, dueDate);
			pstmt.executeUpdate();
			pstmt.close();
		}
		// ③ 個人タスクの編集更新
		else if ("editPersonalTask".equals(action)) {
			String taskId = request.getParameter("taskId");
			String taskName = request.getParameter("taskName");
			String dueDate = request.getParameter("dueDate");
			String status = request.getParameter("status");
			
			String sql = "UPDATE personal_task SET task_name = ?, due_date = NULLIF(?, '')::DATE, status = ? WHERE personal_task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, taskName);
			pstmt.setString(2, dueDate);
			pstmt.setString(3, (status != null && !status.isEmpty()) ? status : "進行中");
			pstmt.setInt(4, Integer.parseInt(taskId));
			pstmt.executeUpdate();
			pstmt.close();
		}
		// ④ チェック状態の更新
		else if ("togglePersonalTask".equals(action)) {
			String taskId = request.getParameter("taskId");
			boolean isChecked = Boolean.parseBoolean(request.getParameter("isChecked"));
			String newStatus = isChecked ? "完了" : "進行中";
			
			String sql = "UPDATE personal_task SET status = ? WHERE personal_task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, newStatus);
			pstmt.setInt(2, Integer.parseInt(taskId));
			pstmt.executeUpdate();
			pstmt.close();
		}
		// ⑤ 削除
		else if ("deletePersonalTask".equals(action)) {
			String taskId = request.getParameter("taskId");
			String sql = "DELETE FROM personal_task WHERE personal_task_id = ?";
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(taskId));
			pstmt.executeUpdate();
			pstmt.close();
		}
		
		conn.close();
	} catch(Exception e) {
		e.printStackTrace();
	}
	return;
}
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>マイタスク - タスク管理アプリ</title>
<link rel="stylesheet" href="css/style.css">
<style>
	.main-content { position: relative; display: flex; flex-direction: column; height: 100vh; box-sizing: border-box; overflow: hidden; }
	.content-header { flex-shrink: 0; }
	
	.mytasks-container {
		display: flex;
		gap: 20px;
		flex: 1;
		padding: 20px;
		background-color: #f8f9fa;
		overflow-y: auto;
		box-sizing: border-box;
	}
	
	.left-column {
		width: 45%;
		background: #fff;
		border: 1px solid #eaeaea;
		border-radius: 10px;
		padding: 20px;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
		color: #888;
		font-size: 14px;
	}
	
	.right-column {
		width: 55%;
		background: #fff;
		border: 1px solid #eaeaea;
		border-radius: 10px;
		padding: 20px;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
		box-shadow: 0 1px 3px rgba(0,0,0,0.02);
	}
	
	.column-title {
		font-size: 1.1rem;
		font-weight: bold;
		color: #333;
		margin-top: 0;
		margin-bottom: 20px;
	}
	
	.personal-task-list {
		display: flex;
		flex-direction: column;
		gap: 10px;
		flex: 1;
		overflow-y: auto;
		margin-bottom: 15px;
	}
	
	.personal-task-item {
		display: flex;
		align-items: center;
		justify-content: space-between;
		background: #fff;
		border: 1px solid #eaeaea;
		border-radius: 8px;
		padding: 12px 16px;
		box-shadow: 0 1px 2px rgba(0,0,0,0.01);
	}
	
	.pti-left {
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
	
	.pti-name {
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
	
	.pti-right {
		display: flex;
		align-items: center;
		gap: 16px;
		flex-shrink: 0;
		position: relative;
	}
	
	.pti-info {
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

	.btn-add-personal {
		width: 100%;
		padding: 12px;
		background: #1b6ef3;
		color: #fff;
		border: none;
		border-radius: 8px;
		font-weight: bold;
		font-size: 14px;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 6px;
		margin-top: auto;
	}
	.btn-add-personal:hover {
		background: #0f5bc4;
	}

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
		width: 450px;
		max-width: 95%;
		box-shadow: 0 8px 20px rgba(0,0,0,0.2);
	}
	.modal-content h3 {
		margin-top: 0;
		margin-bottom: 20px;
		font-size: 1.2rem;
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
	.modal-form-group select {
		width: 100%;
		padding: 10px;
		box-sizing: border-box;
		border: 1px solid #ccc;
		border-radius: 6px;
		font-size: 14px;
	}
	.modal-actions {
		text-align: right;
		margin-top: 25px;
		border-top: 1px solid #f0f2f5;
		padding-top: 15px;
	}
	.modal-actions button {
		padding: 8px 16px;
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
		background-color: #1b6ef3;
		color: white;
	}
	.btn-save:hover {
		background-color: #0f5bc4;
	}
	.delete-modal-content {
		width: 380px;
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
				<li class="menu-item"><a href="projects.jsp">プロジェクト一覧</a></li>
				<li class="menu-item"><a href="taskboard.jsp">タスクボード</a></li>
				<li class="menu-item"><a href="settings.jsp">設定</a></li>
				<li class="menu-item active"><a href="mytasks.jsp">マイタスク</a></li>
				<li class="menu-item"><a href="notifications.jsp">通知センター</a></li>
				<li class="menu-item"><a href="logs.jsp">ログ</a></li>
			</ul>
		</aside>

		<main class="main-content">
			<header class="content-header" style="display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 12px 20px; background: #fff; border-bottom: 1px solid #ddd;">
				<h1 class="page-title" style="margin: 0; font-size: 1.3rem;">マイタスク</h1>
				<div style="display: flex; align-items: center; gap: 10px;">
					<div class="main-search-box" style="margin: 0;">
						<input type="text" class="search-input" placeholder="タスクを検索...">
					</div>
					<a href="account.jsp" class="account-button">アカウント情報</a>
				</div>
			</header>

			<!-- メインコンテンツエリア（2カラム） -->
			<div class="mytasks-container">
				<!-- 左側：担当で絞り込みスペース -->
				<div class="left-column">
					<h3 class="column-title" style="color: #6c757d;">担当で絞り込み (準備中)</h3>
					<p>将来的にログイン機能と連動して担当タスクがここに表示されます。</p>
				</div>

				<!-- 右側：個人タスクエリア -->
				<div class="right-column">
					<h3 class="column-title">個人タスク</h3>
					
					<div class="personal-task-list" id="personalTaskContainer">
						<!-- 非同期で個人タスクが読み込まれます -->
					</div>

					<button class="btn-add-personal" onclick="openAddModal()">+ 個人タスクを追加</button>
				</div>
			</div>

			<!-- 追加・編集用モーダル -->
			<div id="personalTaskModal" class="modal-overlay">
				<div class="modal-content">
					<h3 id="modalTitle">個人タスクの追加</h3>
					
					<div class="modal-form-group">
						<label>タスク名 <span style="color:red;">*</span></label>
						<input type="text" id="modalTaskName" placeholder="例：資料の収集と整理">
					</div>
					
					<div class="modal-form-group">
						<label>期限</label>
						<input type="date" id="modalDueDate">
					</div>
					
					<div class="modal-actions">
						<button class="btn-cancel" onclick="closeModal()">キャンセル</button>
						<button class="btn-save" onclick="submitModal()">保存</button>
					</div>
				</div>
			</div>

			<!-- 削除確認用モーダル -->
			<div id="deleteModal" class="modal-overlay">
				<div class="modal-content delete-modal-content">
					<h3>タスクの削除</h3>
					<p id="deleteMessage" style="margin: 15px 0 25px 0; color: #555;"></p>
					<div class="modal-actions" style="text-align: center; border-top: none; padding-top: 0; margin-top: 0;">
						<button class="btn-cancel" onclick="closeDeleteModal()">キャンセル</button>
						<button class="btn-delete-confirm" onclick="executeDelete()">削除する</button>
					</div>
				</div>
			</div>
			
			<script>
				let modalMode = 'add';
				let targetTaskId = null;

				window.addEventListener('DOMContentLoaded', () => {
					loadPersonalTasks();
				});

				function loadPersonalTasks() {
					fetch('mytasks.jsp?action=getPersonalTasks')
						.then(response => response.text())
						.then(html => {
							document.getElementById("personalTaskContainer").innerHTML = html;
						});
				}

				function openAddModal() {
					modalMode = 'add';
					targetTaskId = null;
					document.getElementById("modalTitle").innerText = "個人タスクの追加";
					document.getElementById("modalTaskName").value = "";
					document.getElementById("modalDueDate").value = "";
					document.getElementById("personalTaskModal").style.display = "flex";
				}

				function openEditModal(taskId, taskName, dueDate) {
					modalMode = 'edit';
					targetTaskId = taskId;
					document.getElementById("modalTitle").innerText = "個人タスクの編集";
					document.getElementById("modalTaskName").value = taskName;
					document.getElementById("modalDueDate").value = dueDate;
					document.getElementById("personalTaskModal").style.display = "flex";
				}

				function closeModal() {
					document.getElementById("personalTaskModal").style.display = "none";
				}

				function submitModal() {
					const taskName = document.getElementById("modalTaskName").value;
					const dueDate = document.getElementById("modalDueDate").value;
					
					if (!taskName || taskName.trim() === "") {
						alert("タスク名を入力してください。");
						return;
					}

					const params = new URLSearchParams();
					if (modalMode === 'add') {
						params.append('action', 'addPersonalTask');
					} else {
						params.append('action', 'editPersonalTask');
						params.append('taskId', targetTaskId);
					}
					params.append('taskName', taskName);
					params.append('dueDate', dueDate);
					
					fetch('mytasks.jsp', {
						method: 'POST',
						body: params
					}).then(() => {
						closeModal();
						loadPersonalTasks();
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
					}).then(() => {
						loadPersonalTasks();
					});
				}

				function openDeleteModal(taskId, taskName) {
					targetTaskId = taskId;
					document.getElementById("deleteMessage").innerText = "「" + taskName + "」を本当に削除しますか？";
					document.getElementById("deleteModal").style.display = "flex";
				}

				function closeDeleteModal() {
					targetTaskId = null;
					document.getElementById("deleteModal").style.display = "none";
				}

				function executeDelete() {
					if (!targetTaskId) return;
					
					const params = new URLSearchParams();
					params.append('action', 'deletePersonalTask');
					params.append('taskId', targetTaskId);
					
					fetch('mytasks.jsp', {
						method: 'POST',
						body: params
					}).then(() => {
						closeDeleteModal();
						loadPersonalTasks();
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
			</script>

			<footer class="footer" style="flex-shrink: 0;">
				<div class="footer-member">
					<a href="#" onclick="toggleMemberMenu()"> 開発メンバー ▼ </a>
					<ul class="member-submenu" id="memberSubmenu">
						<li><a href="member/sakata/Sakata.jsp">坂田</a></li>
						<li><a href="member/Shimizu.jsp">清水</a></li>
						<li><a href="member/Higashi/Higashi.jsp">東</a></li>
						<li><a href="member/Miyazaki/Miyazaki.jsp">宮崎</a></li>
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