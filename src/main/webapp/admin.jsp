<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="model.User"%>
<%
// 未ログイン、または管理者以外はログイン画面へ戻す
User loginUser = (User) session.getAttribute("loginUser");
if (loginUser == null || !loginUser.isAdmin()) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>管理者画面</title>
</head>
<body>
	<h2>管理者画面</h2>
	<p><%=loginUser.getUserName()%>さん、ようこそ(仮の画面です)
	</p>
	<p>
		<a href="<%=request.getContextPath()%>/taskboard.jsp">タスクボードへ</a>
	</p>
</body>
</html>
