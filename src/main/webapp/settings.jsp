<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ - 設定</title>
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
				<li class="menu-item active"><a href="settings.jsp">設定</a></li>
				<li class="menu-item"><a href="mytasks.jsp">マイタスク</a></li>
				<li class="menu-item"><a href="notifications.jsp">通知センター</a></li>
				<li class="menu-item"><a href="logs.jsp">ログ</a></li>
			</ul>
		</aside>

		<main class="main-content">
			<header class="content-header" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
				<h1 class="page-title" style="margin: 0;">設定</h1>
				
				<div style="display: flex; align-items: center; gap: 15px;">
					<div class="main-search-box" style="margin: 0;">
						<input type="text" class="search-input" placeholder="タスクを検索...">
					</div>
					<a href="account.jsp" class="account-button">アカウント情報</a>
				</div>
			</header>

			<div class="content-body settings-container">
                
                <aside class="settings-sidebar">
                    <ul class="settings-menu">
                        <li class="settings-item active" id="tab-general">
                            <a href="#" onclick="switchTab('general')">一般</a>
                        </li>
                        <li class="settings-item" id="tab-account">
                            <a href="#" onclick="switchTab('account')">アカウント</a>
                        </li>
                        <li class="settings-item" id="tab-notifications">
                            <a href="#" onclick="switchTab('notifications')">通知</a>
                        </li>
                    </ul>
                </aside>

                <section class="settings-panel">
                    
                    <div id="content-general" class="setting-section active">
                        <h2>一般設定</h2>
                        <br>
                        
                        <div class="setting-group">
                            <h3>外観</h3>
                            <p>アプリのテーマカラーを選択します。</p>
                            <div class="setting-options">
                                <label class="radio-label"><input type="radio" name="theme" value="light" onchange="changeTheme('light')" checked> ライト</label>
                                <label class="radio-label"><input type="radio" name="theme" value="dark" onchange="changeTheme('dark')"> ダーク</label>
                                <label class="radio-label"><input type="radio" name="theme" value="custom" onchange="changeTheme('custom')"> カスタムカラー</label>
                            </div>
                            
                            <div id="custom-color-picker" style="display: none; margin-top: 15px; padding: 15px; background: #f8f9fa; border-radius: 8px; border: 1px solid #ddd;">
                                <div style="margin-bottom: 10px;">
                                    <label style="display: flex; align-items: center; gap: 10px;">
                                        背景色を選択: 
                                        <input type="color" id="bgColor" value="#ffffff" onchange="applyCustomColors()">
                                    </label>
                                </div>
                                <div>
                                    <label style="display: flex; align-items: center; gap: 10px;">
                                        テキスト色を選択: 
                                        <input type="color" id="textColor" value="#333333" onchange="applyCustomColors()">
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="setting-group">
                            <h3>フォントサイズ</h3>
                            <p>画面のテキストサイズを調整します。</p>
                            <div class="setting-options-column">
                                <label class="radio-label">
                                    <input type="radio" name="fontsize" value="small" onchange="changeFontSize(this.value)"> 小
                                </label>
                                <label class="radio-label">
                                    <input type="radio" name="fontsize" value="medium" onchange="changeFontSize(this.value)" checked> 中（標準）
                                </label>
                                <label class="radio-label">
                                    <input type="radio" name="fontsize" value="large" onchange="changeFontSize(this.value)"> 大
                                </label>
                            </div>
                        </div>
                    </div>

                    <div id="content-account" class="setting-section">
                        <h2>アカウント設定</h2>
                        <br>
                        
                        <div class="setting-group">
                            <h3>アカウントメール</h3>
                            <input type="email" class="setting-input" value="user@example.com" readonly>
                            <p style="font-size: 0.85em; color: #666; margin-top: 5px;">※メールアドレスの変更は管理者にお問い合わせください。</p>
                        </div>

                        <div class="setting-group">
                            <h3>権限</h3>
                            <div class="role-badge">プロジェクト管理者</div>
                        </div>

                        <div class="setting-group">
                            <h3>パスワードを変更</h3>
                            <input type="password" class="setting-input" placeholder="現在のパスワード"><br>
                            <input type="password" class="setting-input" placeholder="新しいパスワード" style="margin-top: 10px;"><br>
                            <button class="setting-btn" style="margin-top: 15px;">変更を保存</button>
                        </div>
                    </div>

                    <div id="content-notifications" class="setting-section">
                        <h2>通知設定</h2>
                        <br>
                        
                        <div class="setting-group">
                            <label class="checkbox-label main-checkbox">
                                <input type="checkbox" id="allowAllNotifications" checked> 通知許可
                            </label>
                            <hr style="margin: 15px 0; border: 0; border-top: 1px solid #eee;">
                            
                            <div class="checkbox-list">
                                <label class="checkbox-label"><input type="checkbox" checked> メンション強制</label>
                                <label class="checkbox-label"><input type="checkbox" checked> プロジェクトの更新</label>
                                <label class="checkbox-label"><input type="checkbox" checked> タスクの追加・変更</label>
                                <label class="checkbox-label"><input type="checkbox" checked> コメントの追加</label>
                                <label class="checkbox-label"><input type="checkbox" checked> 担当者の割り当て</label>
                            </div>
                        </div>
                    </div>

                </section>
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
			</footer>
		</main>
	</div>

    <script>
        // ==========================================
        // 初期読み込み時の設定反映 (LocalStorage)
        // ==========================================
        document.addEventListener("DOMContentLoaded", function() {
            // 保存されている設定を取得（なければデフォルト値）
            const savedTheme = localStorage.getItem('app-theme') || 'light';
            const savedBgColor = localStorage.getItem('custom-bg-color') || '#ffffff';
            const savedTextColor = localStorage.getItem('custom-text-color') || '#333333';
            const savedFontSize = localStorage.getItem('app-fontSize') || 'medium';

            // ① UI（ラジオボタン・カラーピッカー）の状態を合わせる
            document.querySelectorAll('input[name="theme"]').forEach(radio => {
                if (radio.value === savedTheme) radio.checked = true;
            });
            document.querySelectorAll('input[name="fontsize"]').forEach(radio => {
                if (radio.value === savedFontSize) radio.checked = true;
            });
            document.getElementById('bgColor').value = savedBgColor;
            document.getElementById('textColor').value = savedTextColor;

            // ② 実際の画面に適用する
            if (savedTheme === 'dark') {
                document.body.classList.add('dark-theme');
            } else if (savedTheme === 'custom') {
                document.body.classList.add('custom-theme');
                document.getElementById('custom-color-picker').style.display = 'block';
                document.documentElement.style.setProperty('--custom-bg-color', savedBgColor);
                document.documentElement.style.setProperty('--custom-text-color', savedTextColor);
            }

            if (savedFontSize === 'small') {
                document.body.classList.add('font-small');
            } else if (savedFontSize === 'large') {
                document.body.classList.add('font-large');
            }
        });

        // ==========================================
        // 各種設定の切り替え機能
        // ==========================================

        // --- タブ切り替え機能 ---
        function switchTab(tabId) {
            document.querySelectorAll('.settings-item').forEach(item => item.classList.remove('active'));
            document.querySelectorAll('.setting-section').forEach(section => section.classList.remove('active'));

            document.getElementById('tab-' + tabId).classList.add('active');
            document.getElementById('content-' + tabId).classList.add('active');
        }

        // --- 外観（ダーク/カスタム）切り替え機能 ---
        function changeTheme(theme) {
            document.body.classList.remove('dark-theme', 'custom-theme');
            document.getElementById('custom-color-picker').style.display = 'none';
            document.documentElement.style.removeProperty('--custom-bg-color');
            document.documentElement.style.removeProperty('--custom-text-color');

            // 変更内容を LocalStorage に保存
            localStorage.setItem('app-theme', theme);

            if (theme === 'dark') {
                document.body.classList.add('dark-theme');
            } else if (theme === 'custom') {
                document.body.classList.add('custom-theme');
                document.getElementById('custom-color-picker').style.display = 'block';
                applyCustomColors();
            }
        }

        // --- カスタムカラー適用機能 ---
        function applyCustomColors() {
            if (document.body.classList.contains('custom-theme')) {
                const bgColor = document.getElementById('bgColor').value;
                const textColor = document.getElementById('textColor').value;
                
                document.documentElement.style.setProperty('--custom-bg-color', bgColor);
                document.documentElement.style.setProperty('--custom-text-color', textColor);
                
                // 変更内容を LocalStorage に保存
                localStorage.setItem('custom-bg-color', bgColor);
                localStorage.setItem('custom-text-color', textColor);
            }
        }

        // --- フォントサイズ切り替え機能 ---
        function changeFontSize(size) {
            document.body.classList.remove('font-small', 'font-large');
            
            // 変更内容を LocalStorage に保存
            localStorage.setItem('app-fontSize', size);

            if (size === 'small') {
                document.body.classList.add('font-small');
            } else if (size === 'large') {
                document.body.classList.add('font-large');
            }
        }

        // 開発メンバーメニューの開閉（フッター用）
        function toggleMemberMenu() {
            const menu = document.getElementById("memberSubmenu");
            menu.style.display = (menu.style.display === "block") ? "none" : "block";
        }
    </script>

</body>
</html>