<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
request.setCharacterEncoding("UTF-8");

// ==========================================
// ① 保存処理（POST送信されてきた場合）
// ==========================================
if ("POST".equalsIgnoreCase(request.getMethod())) {
	String theme = request.getParameter("theme");
	String fontSize = request.getParameter("fontSize");
	String bgColor = request.getParameter("bgColor");
	String textColor = request.getParameter("textColor");

	String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
	String dbUser = "taskuser";
	String dbPass = "taskpass";
	int currentUserId = 1;

	if (theme != null && fontSize != null) {
		try {
	Class.forName("org.postgresql.Driver");

	// DB更新処理 (UPDATE)
	String sql = "UPDATE user_settings SET theme = ?, font_size = ?, bg_color = ?, text_color = ? WHERE user_id = ?";
	try (Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
			PreparedStatement pstmt = conn.prepareStatement(sql)) {

		pstmt.setString(1, theme);
		pstmt.setString(2, fontSize);
		pstmt.setString(3, bgColor);
		pstmt.setString(4, textColor);
		pstmt.setInt(5, currentUserId);

		int updatedRows = pstmt.executeUpdate();

		// レコードがなければ新規挿入 (INSERT)
		if (updatedRows == 0) {
			String insertSql = "INSERT INTO user_settings (user_id, theme, font_size, bg_color, text_color) VALUES (?, ?, ?, ?, ?)";
			try (PreparedStatement insertPstmt = conn.prepareStatement(insertSql)) {
				insertPstmt.setInt(1, currentUserId);
				insertPstmt.setString(2, theme);
				insertPstmt.setString(3, fontSize);
				insertPstmt.setString(4, bgColor);
				insertPstmt.setString(5, textColor);
				insertPstmt.executeUpdate();
			}
		}
	}
		} catch (Exception e) {
	e.printStackTrace();
		}

		// セッションも同期更新
		session.setAttribute("currentTheme", theme);
		session.setAttribute("currentFontSize", fontSize);
		session.setAttribute("currentBgColor", bgColor);
		session.setAttribute("currentTextColor", textColor);
	}

	// JavaScriptからの非同期通信(Ajax)の場合はレスポンスを返して処理を終了
	if ("1".equals(request.getParameter("ajax"))) {
		out.print("SUCCESS");
		return; // ここで処理を止め、下のHTMLは出力しない
	}
}

// ==========================================
// ② 設定読み込み処理（初回表示・画面描画用）
// ==========================================
String currentTheme = (String) session.getAttribute("currentTheme");
String currentBgColor = (String) session.getAttribute("currentBgColor");
String currentTextColor = (String) session.getAttribute("currentTextColor");
String currentFontSize = (String) session.getAttribute("currentFontSize");

// セッションにデータがない場合のみDBから取得
if (currentTheme == null) {
	String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
	String dbUser = "taskuser";
	String dbPass = "taskpass";

	currentTheme = "light";
	currentBgColor = "#ffffff";
	currentTextColor = "#333333";
	currentFontSize = "medium";

	int currentUserId = 1;

	try {
		Class.forName("org.postgresql.Driver");
		try (Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
		PreparedStatement pstmt = conn.prepareStatement(
				"SELECT theme, bg_color, text_color, font_size FROM user_settings WHERE user_id = ?")) {

	pstmt.setInt(1, currentUserId);

	try (ResultSet rs = pstmt.executeQuery()) {
		if (rs.next()) {
			currentTheme = rs.getString("theme");
			currentBgColor = rs.getString("bg_color");
			currentTextColor = rs.getString("text_color");
			currentFontSize = rs.getString("font_size");
		}
	}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}

	// 取得した値をセッションに保存
	session.setAttribute("currentTheme", currentTheme);
	session.setAttribute("currentBgColor", currentBgColor);
	session.setAttribute("currentTextColor", currentTextColor);
	session.setAttribute("currentFontSize", currentFontSize);
}
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ - 設定</title>
<link rel="stylesheet" href="css/style.css">

<style>
:root {
	--custom-bg-color: <%=currentBgColor%>;
	--custom-text-color: <%=currentTextColor%>;
}
</style>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // bodyにテーマとフォントサイズのクラスを付与
        document.body.classList.add('<%=currentTheme%>-theme');
        document.body.classList.add('font-<%=currentFontSize%>');
    });
</script>

</head>
<body>

	<%
	request.setAttribute("pageTitle", "設定");
	request.setAttribute("currentPage", "settings");
	%>

	<div class="app-container">

		<%@ include file="common/sidebar.jsp"%>

		<main class="main-content">
			<%@ include file="common/header.jsp"%>

			<div class="content-body settings-container">

				<aside class="settings-sidebar">
					<ul class="settings-menu">
						<li class="settings-item active" id="tab-general"><a href="#"
							onclick="switchTab('general')">一般</a></li>
						<li class="settings-item" id="tab-account"><a href="#"
							onclick="switchTab('account')">アカウント</a></li>
						<li class="settings-item" id="tab-notifications"><a href="#"
							onclick="switchTab('notifications')">通知</a></li>
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
								<label class="radio-label"><input type="radio"
									name="theme" value="light" onchange="changeTheme('light')">
									ライト</label> <label class="radio-label"><input type="radio"
									name="theme" value="dark" onchange="changeTheme('dark')">
									ダーク</label> <label class="radio-label"><input type="radio"
									name="theme" value="custom" onchange="changeTheme('custom')">
									カスタムカラー</label>
							</div>

							<div id="custom-color-picker"
								style="display: none; margin-top: 15px; padding: 15px; background: #f8f9fa; border-radius: 8px; border: 1px solid #ddd;">
								<div style="margin-bottom: 10px;">
									<label style="display: flex; align-items: center; gap: 10px;">
										背景色を選択: <input type="color" id="bgColor" value="#ffffff"
										onchange="applyCustomColors()">
									</label>
								</div>
								<div>
									<label style="display: flex; align-items: center; gap: 10px;">
										テキスト色を選択: <input type="color" id="textColor" value="#333333"
										onchange="applyCustomColors()">
									</label>
								</div>
							</div>
						</div>

						<div class="setting-group">
							<h3>フォントサイズ</h3>
							<p>画面のテキストサイズを調整します。</p>
							<div class="setting-options-column">
								<label class="radio-label"> <input type="radio"
									name="fontsize" value="small"
									onchange="changeFontSize(this.value)"> 小
								</label> <label class="radio-label"> <input type="radio"
									name="fontsize" value="medium"
									onchange="changeFontSize(this.value)"> 中（標準）
								</label> <label class="radio-label"> <input type="radio"
									name="fontsize" value="large"
									onchange="changeFontSize(this.value)"> 大
								</label>
							</div>
						</div>
					</div>

					<div id="content-account" class="setting-section">
						<h2>アカウント設定</h2>
						<br>

						<div class="setting-group">
							<h3>アカウントメール</h3>
							<input type="email" class="setting-input"
								value="user@example.com" readonly>
							<p style="font-size: 0.85em; color: #666; margin-top: 5px;">※メールアドレスの変更は管理者にお問い合わせください。</p>
						</div>

						<div class="setting-group">
							<h3>権限</h3>
							<div class="role-badge">プロジェクト管理者</div>
						</div>

						<div class="setting-group">
							<h3>パスワードを変更</h3>
							<input type="password" class="setting-input"
								placeholder="現在のパスワード"><br> <input type="password"
								class="setting-input" placeholder="新しいパスワード"
								style="margin-top: 10px;"><br>
							<button class="setting-btn" style="margin-top: 15px;">変更を保存</button>
						</div>
					</div>

					<div id="content-notifications" class="setting-section">
						<h2>通知設定</h2>
						<br>

						<div class="setting-group">
							<label class="checkbox-label main-checkbox"> <input
								type="checkbox" id="allowAllNotifications" checked> 通知許可
							</label>
							<hr
								style="margin: 15px 0; border: 0; border-top: 1px solid #eee;">

							<div class="checkbox-list">
								<label class="checkbox-label"><input type="checkbox"
									checked> メンション強制</label> <label class="checkbox-label"><input
									type="checkbox" checked> プロジェクトの更新</label> <label
									class="checkbox-label"><input type="checkbox" checked>
									タスクの追加・変更</label> <label class="checkbox-label"><input
									type="checkbox" checked> コメントの追加</label> <label
									class="checkbox-label"><input type="checkbox" checked>
									担当者の割り当て</label>
							</div>
						</div>
					</div>

				</section>
			</div>

			<%@ include file="common/footer.jsp"%>
		</main>
	</div>

	<script>
        // ==========================================
        // 読み込み時の設定反映 (セッション/DBからの値を使用)
        // ==========================================
        document.addEventListener("DOMContentLoaded", function() {
            const savedTheme = '<%=currentTheme%>';
            const savedBgColor = '<%=currentBgColor%>';
            const savedTextColor = '<%=currentTextColor%>';
            const savedFontSize = '<%=currentFontSize%>';

            // ① UI（ラジオボタン・カラーピッカー）の状態を合わせる
            document.querySelectorAll('input[name="theme"]').forEach(radio => {
                if (radio.value === savedTheme) radio.checked = true;
            });
            document.querySelectorAll('input[name="fontsize"]').forEach(radio => {
                if (radio.value === savedFontSize) radio.checked = true;
            });
            document.getElementById('bgColor').value = savedBgColor;
            document.getElementById('textColor').value = savedTextColor;

            // ② カスタムテーマの場合はカラーピッカーを表示
            if (savedTheme === 'custom') {
                document.getElementById('custom-color-picker').style.display = 'block';
            }
        });

        // ==========================================
        // 自分自身(settings.jsp)のPOST処理へ送信する関数
        // ==========================================
        function saveSettingsToDB() {
            const selectedTheme = document.querySelector('input[name="theme"]:checked');
            const selectedFontSize = document.querySelector('input[name="fontsize"]:checked');
            
            const theme = selectedTheme ? selectedTheme.value : 'light';
            const fontSize = selectedFontSize ? selectedFontSize.value : 'medium';
            const bgColor = document.getElementById('bgColor').value;
            const textColor = document.getElementById('textColor').value;

            const params = new URLSearchParams();
            params.append('ajax', '1'); // 自分自身のPOST処理を呼び出すフラグ
            params.append('theme', theme);
            params.append('fontSize', fontSize);
            params.append('bgColor', bgColor);
            params.append('textColor', textColor);

            // 自分自身(settings.jsp)にPOST送信
            fetch('settings.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            }).then(response => {
                if(response.ok) {
                    console.log("データベースおよびセッションに設定を保存しました！");
                }
            }).catch(error => console.error("保存エラー:", error));
        }

        // ==========================================
        // 各種設定の切り替え機能
        // ==========================================

        function switchTab(tabId) {
            document.querySelectorAll('.settings-item').forEach(item => item.classList.remove('active'));
            document.querySelectorAll('.setting-section').forEach(section => section.classList.remove('active'));

            document.getElementById('tab-' + tabId).classList.add('active');
            document.getElementById('content-' + tabId).classList.add('active');
        }

        function changeTheme(theme) {
            document.body.classList.remove('dark-theme', 'custom-theme', 'light-theme');
            document.getElementById('custom-color-picker').style.display = 'none';
            document.documentElement.style.removeProperty('--custom-bg-color');
            document.documentElement.style.removeProperty('--custom-text-color');

            if (theme === 'dark') {
                document.body.classList.add('dark-theme');
            } else if (theme === 'custom') {
                document.body.classList.add('custom-theme');
                document.getElementById('custom-color-picker').style.display = 'block';
                applyCustomColors();
            } else {
                document.body.classList.add('light-theme');
            }
            
            saveSettingsToDB();
        }

        function applyCustomColors() {
            if (document.body.classList.contains('custom-theme')) {
                const bgColor = document.getElementById('bgColor').value;
                const textColor = document.getElementById('textColor').value;
                
                document.documentElement.style.setProperty('--custom-bg-color', bgColor);
                document.documentElement.style.setProperty('--custom-text-color', textColor);
                
                saveSettingsToDB();
            }
        }

        function changeFontSize(size) {
            document.body.classList.remove('font-small', 'font-medium', 'font-large');
            document.body.classList.add('font-' + size);
            
            saveSettingsToDB();
        }

        function toggleMemberMenu() {
            const menu = document.getElementById("memberSubmenu");
            menu.style.display = (menu.style.display === "block") ? "none" : "block";
        }
    </script>

</body>
</html>