<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
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
				<li class="menu-item"><a href="taskboard.jsp">タスクボード</a></li>
				<li class="menu-item"><a href="settings.jsp">設定</a></li>
				<li class="menu-item active"><a href="mytasks.jsp">マイタスク</a></li>
				<li class="menu-item"><a href="notifications.jsp">通知センター</a></li>
				<li class="menu-item"><a href="logs.jsp">ログ</a></li>
			</ul>
		</aside>

		<main class="main-content">
			<header class="content-header">
				<h1 class="page-title">マイタスク</h1>
				<div class="main-search-box">
					<input type="text" class="search-input" placeholder="タスクを検索...">
				</div>
				 <a href="account.jsp" class="account-button">アカウント情報</a>
			</header>

			<div class="content-body">
			
			
			
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

			</footer>
		</main>

	</div>


</body>
</html>