<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ - プロジェクト一覧</title>
<link rel="stylesheet" href="css/style.css">
<style>
	/* エクリプス上の絶対配置の基準点にするため、ここだけ残します */
	.main-content {
		position: relative;
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
				<div class="project-list" id="projectList"></div>
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

				// プロジェクトを追加する
				function addProject() {
					const projectName = prompt("新しいプロジェクト名を入力してください：");
					if (projectName && projectName.trim() !== "") {
						const projectList = document.getElementById("projectList");
						const newCard = document.createElement("div");
						newCard.className = "project-card";
						
						const projectId = "proj_" + Date.now();
						newCard.setAttribute("data-id", projectId);
						
						newCard.innerHTML = 
							'<div class="project-info-block">' +
								'<div>' +
									'<span class="project-title">' + projectName + '</span>' +
									'<span class="project-percent-badge" id="badge_' + projectId + '">0%</span>' +
								'</div>' +
								'<div class="progress-container">' +
									'<div class="progress-bar-bg">' +
										'<div class="progress-bar-fill" id="fill_' + projectId + '"></div>' +
										'<div class="progress-text-inside" id="text_' + projectId + '">0%</div>' +
									'</div>' +
								'</div>' +
							'</div>' +
							'<button class="open-box-btn" onclick="showPanel(\'' + projectName + '\', \'' + projectId + '\')">＋</button>';
						
						projectList.appendChild(newCard);
					}
				}

				// 下からタスクパネルを出す
				function showPanel(projectName, projectId) {
					currentProjectCard = document.querySelector('[data-id="' + projectId + '"]');
					document.getElementById("panelProjectTitle").innerText = projectName;
					
					const taskUl = document.getElementById("taskUl");
					taskUl.innerHTML = '';
					
					document.getElementById("taskOverlay").classList.add("show");
					calculateProgress(projectId); 
				}

				// パネルを引っ込める
				function hidePanel() {
					document.getElementById("taskOverlay").classList.remove("show");
				}

				// タスクを追加する
				function addNewTask() {
					const taskText = prompt("新しいタスク内容を入力してください：");
					if (taskText && taskText.trim() !== "") {
						const projectId = currentProjectCard.getAttribute("data-id");
						const taskUl = document.getElementById("taskUl");
						const newLi = document.createElement("li");
						newLi.className = "task-li";
						
						const now = new Date();
						const month = String(now.getMonth() + 1).padStart(2, '0');
						const date = String(now.getDate()).padStart(2, '0');
						const hours = String(now.getHours()).padStart(2, '0');
						const minutes = String(now.getMinutes()).padStart(2, '0');
						const formattedDate = month + '/' + date + ' ' + hours + ':' + minutes;
						
						newLi.innerHTML = 
							'<input type="checkbox" class="task-check" onchange="calculateProgress(\'' + projectId + '\')"> ' +
							'<div class="task-content-text">' +
								'<span>' + taskText + '</span>' +
								'<span class="task-date">追加日: ' + formattedDate + '</span>' +
							'</div>' +
							'<button class="task-menu-trigger" onclick="toggleTaskMenu(this)">⋮</button>' +
							'<div class="task-dropdown-menu">' +
								'<button class="dropdown-delete-item" onclick="deleteTask(this, \'' + projectId + '\')">削除</button>' +
							'</div>';
						
						taskUl.appendChild(newLi);
						calculateProgress(projectId); 
					}
				}

				// 三点リーダーメニューの表示/非表示
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

				// タスクを削除する関数
				function deleteTask(buttonElement, projectId) {
					const liElement = buttonElement.parentElement.parentElement;
					liElement.remove();
					calculateProgress(projectId);
				}

				// 進捗度を計算する関数
				function calculateProgress(projectId) {
					const taskUl = document.getElementById("taskUl");
					const checkboxes = taskUl.querySelectorAll(".task-check");
					const totalTasks = checkboxes.length;
					
					let checkedTasks = 0;
					checkboxes.forEach(box => {
						if (box.checked) {
							checkedTasks++;
						}
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
	<script>
    document.addEventListener("DOMContentLoaded", function() {
        const savedTheme = localStorage.getItem('app-theme');
        const savedBgColor = localStorage.getItem('custom-bg-color');
        const savedTextColor = localStorage.getItem('custom-text-color');
        const savedFontSize = localStorage.getItem('app-fontSize');

        if (savedTheme === 'dark') {
            document.body.classList.add('dark-theme');
        } else if (savedTheme === 'custom') {
            document.body.classList.add('custom-theme');
            if (savedBgColor) document.documentElement.style.setProperty('--custom-bg-color', savedBgColor);
            if (savedTextColor) document.documentElement.style.setProperty('--custom-text-color', savedTextColor);
        }

        if (savedFontSize === 'small') {
            document.body.classList.add('font-small');
        } else if (savedFontSize === 'large') {
            document.body.classList.add('font-large');
        }
    });
</script>
</body>
</html>