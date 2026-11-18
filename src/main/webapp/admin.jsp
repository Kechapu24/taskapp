<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c"
    uri="http://java.sun.com/jsp/jstl/core" %>

<%
request.setAttribute("pageTitle", "管理");
request.setAttribute("currentPage", "admin");
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<jsp:include page="common/theme.jsp" />

<title>管理</title>

<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet" href="css/setting.css">

</head>

<body class="${themeValue}-theme font-${themeFontSize}"
	style="--custom-bg-color:${themeBgColor};
        --custom-text-color:${themeTextColor};">

	<div class="app-container">

		<%@ include file="common/sidebar.jsp"%>

		<main class="main-content">

			<%@ include file="common/header.jsp"%>

			<div class="content-body settings-container">

				<aside class="settings-sidebar">

					<ul class="settings-menu">

						<li class="settings-item active"><a href="#">団体管理</a></li>

						<li class="settings-item"><a href="#">プロジェクト管理</a></li>

						<li class="settings-item"><a href="#">メンバー管理</a></li>

						<li class="settings-item"><a href="#">ログ管理</a></li>

					</ul>

				</aside>

				<section class="settings-panel">

					<h2>団体管理</h2>

					<button class="setting-btn"
						onclick="location.href='organization_create.jsp'">＋ 団体作成</button>

					<hr>

					<h3>所属団体一覧</h3>

					<div class="org-list">

						<c:forEach var="org" items="${orgList}">

							<div class="org-card">

								<strong> <c:out value="${org.orgName}" />
								</strong>
								
							</div>

						</c:forEach>

					</div>

				</section>
			</div>

			<%@ include file="common/footer.jsp"%>

		</main>

	</div>

</body>
</html>