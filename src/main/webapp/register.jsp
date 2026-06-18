<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>新規登録</title>
<link rel="stylesheet" href="css/auth.css">
</head>
<body>

	<div class="login-card">
		<h2>新規登録</h2>
		<p>必要事項を入力してください</p>

		<form action="RegisterServlet" method="post" id="registerForm"
			novalidate>

			<!-- ユーザー名 -->
			<label for="username">ユーザー名</label> <input type="text" id="username"
				name="username" placeholder="ユーザー名" required>

			<!-- メールアドレス -->
			<label for="email">メールアドレス</label> <input type="email" id="email"
				name="email" placeholder="メールアドレス" required>

			<!-- パスワード -->
			<label for="password">パスワード</label> <input type="password"
				id="password" name="password" placeholder="パスワード" required>

			<!-- パスワード確認 -->
			<label for="passwordConfirm">パスワード（確認）</label> <input type="password"
				id="passwordConfirm" name="passwordConfirm" placeholder="パスワード（確認）"
				required>

			<div class="button-area">
				<button type="submit" class="register-btn">登録</button>
			</div>

		</form>
	</div>

</body>
</html>
