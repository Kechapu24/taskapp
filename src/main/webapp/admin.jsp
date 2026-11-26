<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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

				<c:if test="${not empty sessionScope.activeOrgId}">

					<aside class="settings-sidebar">
						<ul class="settings-menu">
							<li class="settings-item active"><a href="#">団体管理</a></li>
							<li class="settings-item"><a href="#">プロジェクト管理</a></li>
							<li class="settings-item"><a href="#">メンバー管理</a></li>
							<li class="settings-item"><a href="logs.jsp">ログ管理</a></li>
						</ul>
					</aside>

				</c:if>
				<section class="settings-panel">

					<c:choose>

						<%-- 個人モード --%>
						<c:when test="${empty sessionScope.activeOrgId}">

							<h2>団体を作成する</h2>

							<p>新しい団体を作成して、メンバーと一緒に活動を始めましょう。</p>

							<form
								action="${pageContext.request.contextPath}/organization/create"
								method="post">

								<label for="orgName">団体名</label> <input type="text" id="orgName"
									name="orgName" required>

								<button type="submit" class="setting-btn">＋ 団体を作成</button>

							</form>

						</c:when>

						<%-- 団体モード --%>
						<c:otherwise>

							<h2>団体管理</h2>

							<c:forEach var="org" items="${sessionScope.orgList}">

								<c:if test="${org.orgId == sessionScope.activeOrgId}">

									<h3>団体情報</h3>

									<p>
										<strong>団体名：</strong>
										<c:out value="${org.orgName}" />
									</p>

									<p>
										<strong>作成日：</strong>
										<fmt:formatDate value="${org.createdAt}" pattern="yyyy年MM月dd日" />
									</p>

									<p>
										<strong>あなたの役割：</strong>
										<c:choose>
											<c:when test="${org.orgRole == 'admin'}">
                        管理者
                    </c:when>
											<c:when test="${org.orgRole == 'member'}">
                        メンバー
                    </c:when>
											<c:otherwise>
												<c:out value="${org.orgRole}" />
											</c:otherwise>
										</c:choose>
									</p>

								</c:if>

							</c:forEach>

						</c:otherwise>
					</c:choose>

				</section>
			</div>

			<%@ include file="common/footer.jsp"%>

		</main>

	</div>

</body>
</html>