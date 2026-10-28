<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ログイン</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/auth.css">
<script src="${pageContext.request.contextPath}/js/auth.js"></script>
</head>
<body>

	<div class="login-card">
		<h2>ログイン</h2>
		<p>アカウントにサインインしてください</p>

		<%-- ログイン失敗時のエラー(LoginServletがセット) --%>
		<c:if test="${not empty errorMessage}">
			<p class="message-error">
				<c:out value="${errorMessage}" />
			</p>
		</c:if>

		<%-- 新規登録の直後(RegisterServletが ?registered=1 を付けて遷移) --%>
		<c:if test="${param.registered == '1'}">
			<p class="message-success">登録が完了しました。ログインしてください。</p>
		</c:if>

		<form action="${pageContext.request.contextPath}/login" method="post"
			id="loginForm" data-prevent-double-submit>

			<!-- メールアドレス(ログイン失敗時は、入力した内容を残す) -->
			<label for="email">メールアドレス</label> <input type="email" id="email"
				name="email" value="<c:out value='${email}'/>"
				placeholder="メールアドレス" autocomplete="username" required
				<c:if test="${empty email}">autofocus</c:if>>

			<!-- パスワード(表示/非表示ボタン付き) -->
			<label for="password">パスワード</label>
			<div class="password-field">
				<input type="password" id="password" name="password"
					placeholder="パスワード" autocomplete="current-password" required
					<c:if test="${not empty email}">autofocus</c:if>>
				<button type="button" class="password-toggle"
					data-target="password"></button>
			</div>

			<div class="button-area">
				<button type="submit" class="login-btn">ログイン</button>
			</div>
		</form>

		<p class="auth-link">
			アカウントをお持ちでない方は <a
				href="${pageContext.request.contextPath}/register.jsp">新規登録はこちら</a>
		</p>
	</div>

</body>
</html>
