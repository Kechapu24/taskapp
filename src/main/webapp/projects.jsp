<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>プロジェクト・タスク管理</title>
	<style>
		/* ==========================================================
		   テーマ定義 (CSS Variables)
		   ========================================================== */
		:root {
			--bg-color: #f4f6f9;
			--card-bg: #ffffff;
			--text-color: #333333;
			--text-muted: #777777;
			--border-color: #e0e0e0;
			--primary-color: #007bff;
			--primary-hover: #0056b3;
			--danger-color: #dc3545;
			--modal-bg: #ffffff;
			--overlay-bg: rgba(0, 0, 0, 0.5);
			--dropdown-bg: #ffffff;
			--dropdown-hover: #f0f0f0;
			--input-bg: #ffffff;
			--input-border: #ccc;
			--shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
			--header-bg: #ffffff;
			
			/* ステータスカラー */
			--status-completed-bg: #d4edda;
			--status-completed-text: #155724;
			--status-inprogress-bg: #fff3cd;
			--status-inprogress-text: #856404;
			--status-notstarted-bg: #e2e3e5;
			--status-notstarted-text: #383d41;
		}

		/* ダークモードの設定 */
		[data-theme="dark"] {
			--bg-color: #121212;
			--card-bg: #1e1e1e;
			--text-color: #e0e0e0;
			--text-muted: #aaaaaa;
			--border-color: #333333;
			--primary-color: #3b82f6;
			--primary-hover: #2563eb;
			--danger-color: #ef4444;
			--modal-bg: #242424;
			--overlay-bg: rgba(0, 0, 0, 0.75);
			--dropdown-bg: #2a2a2a;
			--dropdown-hover: #3a3a3a;
			--input-bg: #2a2a2a;
			--input-border: #444444;
			--shadow: 0 4px 6px rgba(0, 0, 0, 0.5);
			--header-bg: #1e1e1e;

			/* ステータスカラー（ダーク用） */
			--status-completed-bg: #1b4332;
			--status-completed-text: #75e6da;
			--status-inprogress-bg: #5c4d10;
			--status-inprogress-text: #ffe066;
			--status-notstarted-bg: #333333;
			--status-notstarted-text: #cccccc;
		}

		/* ==========================================================
		   ベーススタイル
		   ========================================================== */
		* {
			box-sizing: border-box;
			transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;
		}

		body {
			margin: 0;
			font-family: 'Helvetica Neue', Arial, sans-serif;
			background-color: var(--bg-color);
			color: var(--text-color);
			display: flex;
			flex-direction: column;
			min-height: 100vh;
		}

		.app-container {
			display: flex;
			flex-direction: column;
			flex: 1;
		}

		header {
			background-color: var(--header-bg);
			padding: 15px 30px;
			display: flex;
			justify-content: space-between;
			align-items: center;
			border-bottom: 1px solid var(--border-color);
			box-shadow: var(--shadow);
		}

		.header-title {
			font-size: 1.5rem;
			font-weight: bold;
		}

		.theme-toggle-btn {
			background-color: transparent;
			border: 1px solid var(--border-color);
			color: var(--text-color);
			padding: 8px 16px;
			border-radius: 20px;
			cursor: pointer;
			font-size: 0.9rem;
			display: flex;
			align-items: center;
			gap: 6px;
		}

		.theme-toggle-btn:hover {
			background-color: var(--dropdown-hover);
		}

		main {
			padding: 20px 30px;
			flex: 1;
			display: flex;
			flex-direction: column;
			gap: 25px;
		}

		/* ==========================================================
		   カード & コントロール表示
		   ========================================================== */
		.controls-section {
			display: flex;
			justify-content: space-between;
			align-items: center;
			gap: 15px;
			flex-wrap: wrap;
		}

		.project-input-group {
			display: flex;
			gap: 10px;
		}

		input[type="text"], input[type="date"], select, textarea {
			background-color: var(--input-bg);
			color: var(--text-color);
			border: 1px solid var(--input-border);
			padding: 8px 12px;
			border-radius: 6px;
			outline: none;
		}

		input[type="text"]:focus, select:focus, textarea:focus {
			border-color: var(--primary-color);
		}

		button.btn {
			background-color: var(--primary-color);
			color: #fff;
			border: none;
			padding: 8px 16px;
			border-radius: 6px;
			cursor: pointer;
			font-weight: bold;
		}

		button.btn:hover {
			background-color: var(--primary-hover);
		}

		button.btn-danger {
			background-color: var(--danger-color);
		}

		.project-list {
			display: grid;
			grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
			gap: 20px;
		}

		.project-card {
			background-color: var(--card-bg);
			border: 1px solid var(--border-color);
			border-radius: 10px;
			padding: 16px;
			box-shadow: var(--shadow);
			position: relative;
			cursor: pointer;
		}

		.project-card.active-project {
			border: 2px solid var(--primary-color);
		}

		.project-card-header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			margin-bottom: 12px;
		}

		.progress-bar-container {
			background-color: var(--border-color);
			height: 8px;
			border-radius: 4px;
			overflow: hidden;
			margin: 10px 0;
		}

		.progress-bar-fill {
			background-color: var(--primary-color);
			height: 100%;
			width: 0%;
			transition: width 0.3s ease;
		}

		.status-badge {
			padding: 4px 8px;
			border-radius: 12px;
			font-size: 0.75rem;
			font-weight: bold;
		}

		.status-badge.completed { background-color: var(--status-completed-bg); color: var(--status-completed-text); }
		.status-badge.in-progress { background-color: var(--status-inprogress-bg); color: var(--status-inprogress-text); }
		.status-badge.not-started { background-color: var(--status-notstarted-bg); color: var(--status-notstarted-text); }

		/* ==========================================================
		   ドロップダウンメニュー
		   ========================================================== */
		.menu-btn {
			background: none;
			border: none;
			color: var(--text-color);
			font-size: 1.2rem;
			cursor: pointer;
		}

		.project-dropdown-menu, .task-dropdown-menu {
			display: none;
			position: absolute;
			right: 10px;
			top: 35px;
			background-color: var(--dropdown-bg);
			border: 1px solid var(--border-color);
			border-radius: 6px;
			box-shadow: var(--shadow);
			z-index: 100;
			overflow: hidden;
		}

		.project-dropdown-menu.open, .task-dropdown-menu.open {
			display: block;
		}

		.project-dropdown-menu a, .task-dropdown-menu a {
			display: block;
			padding: 8px 16px;
			color: var(--text-color);
			text-decoration: none;
			font-size: 0.85rem;
		}

		.project-dropdown-menu a:hover, .task-dropdown-menu a:hover {
			background-color: var(--dropdown-hover);
		}

		/* ==========================================================
		   モーダル
		   ========================================================== */
		.modal-overlay {
			display: none;
			position: fixed;
			top: 0; left: 0; right: 0; bottom: 0;
			background-color: var(--overlay-bg);
			align-items: center;
			justify-content: center;
			z-index: 1000;
		}

		.modal-content {
			background-color: var(--modal-bg);
			color: var(--text-color);
			border: 1px solid var(--border-color);
			padding: 24px;
			border-radius: 10px;
			width: 100%;
			max-width: 480px;
			box-shadow: var(--shadow);
		}

		.modal-form-group {
			margin-bottom: 15px;
			display: flex;
			flex-direction: column;
			gap: 5px;
		}

		.modal-actions {
			display: flex;
			justify-content: flex-end;
			gap: 10px;
			margin-top: 20px;
		}

		/* ==========================================================
		   フッター
		   ========================================================== */
		.footer {
			background-color: var(--header-bg);
			border-top: 1px solid var(--border-color);
			padding: 15px 30px;
			text-align: center;
			position: relative;
		}

		.footer-member {
			position: relative;
			display: inline-block;
		}

		.footer-member a {
			color: var(--text-color);
			text-decoration: none;
		}

		.member-submenu {
			display: none;
			position: absolute;
			bottom: 100%;
			left: 50%;
			transform: translateX(-50%);
			background-color: var(--dropdown-bg);
			border: 1px solid var(--border-color);
			list-style: none;
			padding: 8px 0;
			margin: 0 0 8px 0;
			border-radius: 6px;
			box-shadow: var(--shadow);
			min-width: 120px;
		}

		.member-submenu li a {
			display: block;
			padding: 6px 16px;
			font-size: 0.85rem;
		}

		.member-submenu li a:hover {
			background-color: var(--dropdown-hover);
		}
	</style>
</head>
<body>

	<div class="app-container">
		<!-- ヘッダー (テーマ切り替えボタン配置) -->
		<header>
			<div class="header-title">プロジェクト & タスク管理</div>
			<button class="theme-toggle-btn" id="themeToggleBtn" onclick="toggleTheme()">
				🌙 ダークモード
			</button>
		</header>

		<main>
			<!-- プロジェクトコントロール -->
			<div class="controls-section">
				<div class="project-input-group">
					<input type="text" id="newProjectName" placeholder="新しいプロジェクト名">
					<button class="btn" onclick="createProject()">追加</button>
				</div>
				<div>
					<label for="sortSelect">並び替え: </label>
					<select id="sortSelect" onchange="sortProjects()">
						<option value="newest">作成順（新しい順）</option>
						<option value="name">名前順</option>
						<option value="progressDesc">進捗率順</option>
					</select>
				</div>
			</div>

			<!-- プロジェクト一覧 -->
			<div class="project-list" id="projectList">
				<!-- サンプルカード（Java / JSPループで生成する領域） -->
				<div class="project-card" data-raw-id="1" data-id="p1" data-name="Webシステム構築" data-progress="0" onclick="selectProject('1', 'Webシステム構築', this)">
					<div class="project-card-header">
						<strong>Webシステム構築</strong>
						<div>
							<button class="menu-btn" onclick="event.stopPropagation(); toggleProjectMenu(this)">⋮</button>
							<div class="project-dropdown-menu">
								<a href="#" onclick="openProjectDeleteModal('1', 'Webシステム構築')">削除</a>
							</div>
						</div>
					</div>
					<div class="progress-bar-container">
						<div class="progress-bar-fill" id="fill_p1"></div>
					</div>
					<div style="display:flex; justify-content:space-between; font-size:0.8rem;">
						<span class="status-badge not-started" id="badge_status_p1">未着手</span>
						<span id="badge_p1">0%</span>
					</div>
				</div>
			</div>

			<hr style="border: 0; border-top: 1px solid var(--border-color); margin: 20px 0;">

			<!-- タスク管理セクション -->
			<div>
				<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
					<h2 id="bottomProjectTitle" style="margin:0;">プロジェクトを選択してください</h2>
					<button class="btn" onclick="addNewTask()">+ タスクを追加</button>
				</div>
				<div id="taskContainer" style="min-height: 100px;">
					<div style="padding: 20px; color: var(--text-muted); text-align: center; width: 100%;">
						プロジェクトカードを選択するとタスクが表示されます。
					</div>
				</div>
			</div>

			<!-- タスク追加 / 編集モーダル -->
			<div class="modal-overlay" id="taskModal">
				<div class="modal-content">
					<h3 id="taskModalTitle" style="margin-top:0;">タスクの追加</h3>
					<div class="modal-form-group">
						<label>タスク名</label>
						<input type="text" id="modalTaskName">
					</div>
					<div class="modal-form-group">
						<label>ステータス</label>
						<select id="modalStatus">
							<option value="未着手">未着手</option>
							<option value="進行中">進行中</option>
							<option value="完了">完了</option>
						</select>
					</div>
					<div class="modal-form-group">
						<label>優先度</label>
						<select id="modalPriority">
							<option value="高">高</option>
							<option value="中" selected>中</option>
							<option value="低">低</option>
						</select>
					</div>
					<div class="modal-form-group">
						<label>開始日</label>
						<input type="date" id="modalStartDate">
					</div>
					<div class="modal-form-group">
						<label>期日</label>
						<input type="date" id="modalDueDate">
					</div>
					<div class="modal-form-group">
						<label>担当者ID</label>
						<input type="text" id="modalUserId">
					</div>
					<div class="modal-form-group">
						<label>詳細・メモ</label>
						<textarea id="modalDescription" rows="3"></textarea>
					</div>
					<div class="modal-actions">
						<button class="btn" style="background-color: var(--text-muted);" onclick="closeTaskModal()">キャンセル</button>
						<button class="btn" onclick="submitTaskModal()">保存</button>
					</div>
				</div>
			</div>

			<!-- タスク削除確認モーダル -->
			<div class="modal-overlay" id="deleteModal">
				<div class="modal-content">
					<h3>タスクの削除</h3>
					<p id="deleteMessage">本当に削除しますか？</p>
					<div class="modal-actions">
						<button class="btn" style="background-color: var(--text-muted);" onclick="closeDeleteModal()">キャンセル</button>
						<button class="btn btn-danger" onclick="executeDeleteTask()">削除</button>
					</div>
				</div>
			</div>

			<!-- プロジェクト削除確認モーダル -->
			<div class="modal-overlay" id="projectDeleteModal">
				<div class="modal-content">
					<h3>プロジェクトの削除</h3>
					<p id="projectDeleteMessage">本当に関連タスク含め削除しますか？</p>
					<div class="modal-actions">
						<button class="btn" style="background-color: var(--text-muted);" onclick="closeProjectDeleteModal()">キャンセル</button>
						<button class="btn btn-danger" onclick="executeDeleteProject()">削除</button>
					</div>
				</div>
			</div>

			<!-- ==========================================================
			   JavaScript 処理領域
			   ========================================================== -->
			<script>
				// グローバル変数
				let currentRawProjectId = null;
				let currentProjectCard = null;
				let taskModalMode = 'add';
				let targetTaskIdForEdit = null;
				let targetTaskIdForDelete = null;
				let targetProjectIdForDelete = null;

				/* --------------------------------------------------
				   テーマ切り替え機能 (LocalStorage保存機能付き)
				   -------------------------------------------------- */
				function initTheme() {
					const savedTheme = localStorage.getItem('app-theme') || 'light';
					document.documentElement.setAttribute('data-theme', savedTheme);
					updateThemeButtonText(savedTheme);
				}

				function toggleTheme() {
					const currentTheme = document.documentElement.getAttribute('data-theme');
					const newTheme = (currentTheme === 'dark') ? 'light' : 'dark';
					
					document.documentElement.setAttribute('data-theme', newTheme);
					localStorage.setItem('app-theme', newTheme);
					updateThemeButtonText(newTheme);
				}

				function updateThemeButtonText(theme) {
					const btn = document.getElementById('themeToggleBtn');
					if (btn) {
						btn.innerText = (theme === 'dark') ? '☀️ ライトモード' : '🌙 ダークモード';
					}
				}

				// 初期化実行
				document.addEventListener('DOMContentLoaded', initTheme);

				/* --------------------------------------------------
				   プロジェクト作成機能
				   -------------------------------------------------- */
				function createProject() {
					const nameInput = document.getElementById("newProjectName");
					if (nameInput && nameInput.value.trim() !== "") {
						const form = document.createElement("form");
						form.method = "POST";
						form.action = "projects.jsp";

						const inputAction = document.createElement("input");
						inputAction.type = "hidden";
						inputAction.name = "action";
						inputAction.value = "addProject";
						form.appendChild(inputAction);

						const inputName = document.createElement("input");
						inputName.type = "hidden";
						inputName.name = "projectName";
						inputName.value = nameInput.value.trim();
						form.appendChild(inputName);

						document.body.appendChild(form);
						form.submit();
					} else {
						alert("プロジェクト名を入力してください。");
					}
				}

				/* --------------------------------------------------
				   プロジェクトソート・選択機能
				   -------------------------------------------------- */
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
					document.getElementById("bottomProjectTitle").innerText = projectName + " のタスク";
					document.getElementById("taskContainer").innerHTML = '<div style="padding: 20px; color: var(--text-muted); text-align: center; width: 100%;">読み込み中...</div>';
					
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

				/* --------------------------------------------------
				   タスク CRUD 機能
				   -------------------------------------------------- */
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

				/* --------------------------------------------------
				   メニュー表示制御
				   -------------------------------------------------- */
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

				/* --------------------------------------------------
				   動的進捗計算機能
				   -------------------------------------------------- */
				function calculateProgressLocal() {
					if (!currentProjectCard) return;
					
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

			<!-- フッター -->
			<footer class="footer">
				<div class="footer-member">
					<a href="#" onclick="toggleMemberMenu(); return false;"> 開発メンバー ▼ </a>
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