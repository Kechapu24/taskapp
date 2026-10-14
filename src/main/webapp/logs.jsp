<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<jsp:include page="common/theme.jsp" />
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ</title>
<link rel="stylesheet" href="css/common.css">
</head>
<body  class="${themeValue}-theme font-${themeFontSize}"
      style="--custom-bg-color: ${themeBgColor};
             --custom-text-color: ${themeTextColor};">

	<%
	request.setAttribute("pageTitle", "ログ");
	request.setAttribute("currentPage", "logs");
	%>

	<div class="app-container">

		<%@ include file="common/sidebar.jsp" %>

		<main class="main-content">
		
			<%@ include file="common/header.jsp" %>

			<div class="content-body"></div>

			<%@ include file="common/footer.jsp" %>
			
		</main>

	</div>


</body>
</html>