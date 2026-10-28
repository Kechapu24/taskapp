<%@ page pageEncoding="UTF-8"%>

<aside class="sidebar">
	<div class="sidebar-brand">タスク管理</div>

	<ul class="sidebar-menu">
		<li class="menu-item ${currentPage == 'index' ? 'active' : ''}">
			<a href="index.jsp">ダッシュボード</a>
		</li>

		<li class="menu-item ${currentPage == 'projects' ? 'active' : ''}">
			<a href="projects.jsp">プロジェクト一覧</a>
		</li>

		<li class="menu-item ${currentPage == 'taskboard' ? 'active' : ''}">
			<a href="taskboard.jsp">タスクボード</a>
		</li>

		<li class="menu-item ${currentPage == 'settings' ? 'active' : ''}">
			<a href="settings.jsp">設定</a>
		</li>

		<li class="menu-item ${currentPage == 'mytasks' ? 'active' : ''}">
			<a href="mytasks.jsp">マイタスク</a>
		</li>

		<li
			class="menu-item ${currentPage == 'notifications' ? 'active' : ''}">
			<a href="notifications.jsp">通知センター</a>
		</li>

		<li class="menu-item ${currentPage == 'logs' ? 'active' : ''}"><a
			href="logs.jsp">ログ</a></li>
	</ul>


	<!-- 開発情報メニュー -->
	<div class="sidebar-dev">
		<button type="button" id="devMenuButton" class="sidebar-dev-button"
			aria-expanded="false" aria-controls="devMenuPopup">
			<span>開発情報</span> <span aria-hidden="true">›</span>
		</button>

		<!-- サイドバー右側に開くメニュー -->
		<div id="devMenuPopup" class="sidebar-dev-popup" aria-label="開発情報"
			hidden>

			<h3>開発情報</h3>

			<div class="sidebar-dev-section">
				<p class="sidebar-dev-heading">開発資料</p>

				<a href="member/Higashi/docs.jsp"> 資料・マニュアル </a> <a
					href="https://github.com/Kechapu24/taskapp" target="_blank"
					rel="noopener noreferrer"> ソースコード（GitHub） </a>
			</div>

			<div class="sidebar-dev-section">
				<p class="sidebar-dev-heading">開発メンバー</p>

				<a href="member/sakata/Sakata.jsp">坂田</a> <a
					href="member/Shimizu.jsp">清水</a> <a
					href="member/Higashi/Higashi.jsp">東</a> <a
					href="member/Miyazaki/Miyazaki.jsp">宮崎</a>
			</div>
		</div>
	</div>


	<%-- サイドバーの最下部に、常にユーザー表示を出す
         ログイン中: アイコン付きのユーザーボタン(ホバーで、右側に情報カード)
         未ログイン: これまでの「アカウント情報」ボタン --%>
	<div class="sidebar-user">
		<%
		if (session.getAttribute("loginUser") != null) {
		%>
		<jsp:include page="/common/user_badge.jsp" />

		<%
		}
		%>
	</div>
</aside>


<script>
	(function() {
		const button = document.getElementById('devMenuButton');
		const popup = document.getElementById('devMenuPopup');

		if (!button || !popup)
			return;

		function positionPopup() {
			const rect = button.getBoundingClientRect();

			const left = Math.max(12, Math.min(rect.right + 8,
					window.innerWidth - popup.offsetWidth - 12));

			const top = Math.max(12, Math.min(rect.top, window.innerHeight
					- popup.offsetHeight - 12));

			popup.style.left = left + 'px';
			popup.style.top = top + 'px';
		}

		function closePopup() {
			popup.hidden = true;
			button.setAttribute('aria-expanded', 'false');
		}

		button.addEventListener('click', function() {
			if (!popup.hidden) {
				closePopup();
				return;
			}

			popup.hidden = false;
			button.setAttribute('aria-expanded', 'true');
			positionPopup();
		});

		// メニュー外をクリックしたら閉じる
		document.addEventListener('click',
				function(event) {
					if (!popup.contains(event.target)
							&& !button.contains(event.target)) {
						closePopup();
					}
				});

		// Escapeキーで閉じる
		document.addEventListener('keydown', function(event) {
			if (event.key === 'Escape') {
				closePopup();
			}
		});

		// 画面サイズやスクロールに追従
		window.addEventListener('resize', function() {
			if (!popup.hidden)
				positionPopup();
		});

		document.addEventListener('scroll', function() {
			if (!popup.hidden)
				positionPopup();
		}, true);
	})();
</script>

