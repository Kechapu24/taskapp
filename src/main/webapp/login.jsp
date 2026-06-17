<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ログイン</title>
<link rel="stylesheet" href="css/auth.css">
</head>
<body>

	<div class="login-card">
		<h2>ログイン</h2>
		<p>アカウントにサインインしてください</p>

		<form action="LoginServlet" method="post" id="loginForm" novalidate>

			<!-- メールアドレス -->
			<label for="email">メールアドレス</label> <input type="email" id="email"
				name="email" placeholder="メールアドレス" required>

			<!-- パスワード -->
			<label for="password">パスワード</label> <input type="password"
				id="password" name="password" placeholder="パスワード" required>

			<div class="button-area">

				<button type="submit" class="login-btn">ログイン</button>

				<button type="button" class="register-btn"
					onclick="location.href='register.jsp'">新規登録</button>

			</div>
		</form>
	</div>

</body>


</html>
