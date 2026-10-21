<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>新規登録</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/auth.css">
<script src="${pageContext.request.contextPath}/js/auth.js"></script>
</head>
<body>

	<div class="login-card">
		<h2>新規登録</h2>
		<p>必要事項を入力してください</p>

		<%-- 登録失敗時のエラー(RegisterServletがセット) --%>
		<c:if test="${not empty errorMessage}">
			<p class="message-error">
				<c:out value="${errorMessage}" />
			</p>
		</c:if>

		<form action="${pageContext.request.contextPath}/RegisterServlet"
			method="post" id="registerForm" data-prevent-double-submit>

			<!-- ユーザー名(失敗時は入力した内容を残す) -->
			<label for="username">ユーザー名</label> <input type="text"
				id="username" name="username" value="<c:out value='${username}'/>"
				placeholder="ユーザー名" autocomplete="name" required autofocus>

			<!-- メールアドレス(失敗時は入力した内容を残す) -->
			<label for="email">メールアドレス</label> <input type="email" id="email"
				name="email" value="<c:out value='${email}'/>"
				placeholder="メールアドレス" autocomplete="email" required>

			<!-- パスワード(セキュリティのため、失敗時も入力内容は残さない) -->
			<label for="password">パスワード</label>
			<div class="password-field">
				<input type="password" id="password" name="password"
					placeholder="パスワード" autocomplete="new-password" required>
				<button type="button" class="password-toggle"
					data-target="password"></button>
			</div>

			<!-- パスワード確認 -->
			<label for="passwordConfirm">パスワード(確認)</label>
			<div class="password-field">
				<input type="password" id="passwordConfirm" name="passwordConfirm"
					placeholder="パスワード(確認)" autocomplete="new-password" required>
				<button type="button" class="password-toggle"
					data-target="passwordConfirm"></button>
			</div>

			<div class="button-area">
				<button type="submit" class="register-btn">登録</button>
			</div>

		</form>

		<p class="auth-link">
			すでにアカウントをお持ちの方は <a
				href="${pageContext.request.contextPath}/login.jsp">ログインはこちら</a>
		</p>
	</div>

</body>
</html>
