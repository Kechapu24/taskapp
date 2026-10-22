<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<jsp:include page="common/theme.jsp" />


<%

// 文字化け防止
request.setCharacterEncoding("UTF-8");

// データベース接続情報
String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
String dbUser = "taskuser";
String dbPassword = "taskpass";

// 仮のユーザーID
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
	String sql = "SELECT personal_task_id, task_name, status, TO_CHAR(due_date, 'YYYY-MM-DD') as fmt_due_date "
			+ "FROM personal_task WHERE user_id = ? ORDER BY personal_task_id ASC";
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

		if (dueDate == null)
			dueDate = "";
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
		out.print("<input type='checkbox' class='task-check' onchange='togglePersonalTask(" + taskId
				+ ", this.checked)' " + (isChecked ? "checked" : "") + ">");
		out.print("<span class='pti-name " + (isChecked ? "completed-task" : "") + "'>" + taskName + "</span>");
		out.print("</div>");

		out.print("<div class='pti-right'>");
		if (!dateStr.isEmpty()) {
			out.print("<span class='pti-info'>📅 " + dateStr + "</span>");
		}
		out.print("<button class='task-menu-trigger' onclick='toggleTaskMenu(this)'>⋮</button>");
		out.print("<div class='task-dropdown-menu'>");
		out.print("<button class='dropdown-edit-item' onclick='openEditModal(" + taskId + ", \""
				+ escapedTaskName + "\", \"" + dueDate + "\", \"" + status + "\")'>編集</button>");
		out.print("<button class='dropdown-delete-item' onclick='openDeleteModal(" + taskId + ", \""
				+ taskName.replace("\"", "&quot;") + "\")'>削除</button>");
		out.print("</div>");
		out.print("</div>");

		out.print("</div>");
	}
	if (!hasTask) {
		out.print(
				"<div style='padding: 20px; color: #777; text-align: center; width: 100%;'>個人タスクはまだ登録されていません。</div>");
	}
	rs.close();
	pstmt.close();
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
	} catch (Exception e) {
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
<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet" href="css/mytasks.css">
</head>
<body class="${themeValue}-theme font-${themeFontSize}"
      style="--custom-bg-color: ${themeBgColor};
             --custom-text-color: ${themeTextColor};">

	<%
	request.setAttribute("pageTitle", "マイタスク");
	request.setAttribute("currentPage", "mytasks");
	%>

	<div class="app-container">

		<%@ include file="common/sidebar.jsp" %>

		<main class="main-content">
		
			<%@ include file="common/header.jsp" %>

			<!-- メインコンテンツエリア（2カラム） -->
			<div class="mytasks-container">
				<!-- 左側：担当で絞り込みスペース -->
				<div class="left-column">
					<h3 class="column-title" style="opacity: 0.8;">担当で絞り込み (準備中)</h3>
					<p>将来的にログイン機能と連動して担当タスクがここに表示されます。</p>
				</div>

				<!-- 右側：個人タスクエリア -->
				<div class="right-column">
					<h3 class="column-title">個人タスク</h3>

					<div class="personal-task-list" id="personalTaskContainer">
						<!-- 非同期で個人タスクが読み込まれます -->
					</div>

					<button class="btn-add-personal custom-theme-accent" onclick="openAddModal()">+
						個人タスクを追加</button>
				</div>
			</div>

			<!-- 追加・編集用モーダル -->
			<div id="personalTaskModal" class="modal-overlay">
				<div class="modal-content">
					<h3 id="modalTitle">個人タスクの追加</h3>

					<div class="modal-form-group">
						<label>タスク名 <span style="color: red;">*</span></label> <input
							type="text" id="modalTaskName" placeholder="例：資料の収集と整理">
					</div>

					<div class="modal-form-group">
						<label>期限</label> <input type="date" id="modalDueDate">
					</div>

					<div class="modal-actions">
						<button class="btn-cancel" onclick="closeModal()">キャンセル</button>
						<button class="btn-save custom-theme-accent" onclick="submitModal()">保存</button>
					</div>
				</div>
			</div>

			<!-- 削除確認用モーダル -->
			<div id="deleteModal" class="modal-overlay">
				<div class="modal-content delete-modal-content">
					<h3>タスクの削除</h3>
					<p id="deleteMessage" style="margin: 15px 0 25px 0;"></p>
					<div class="modal-actions"
						style="text-align: center; border-top: none; padding-top: 0; margin-top: 0;">
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

			<%@ include file="common/footer.jsp" %>
			
		</main>

	</div>

</body>
</html>