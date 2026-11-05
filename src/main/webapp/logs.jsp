<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="dao.ActivityLogDAO"%>
<%@ page import="model.ActivityLog"%>
<%@ page import="java.util.List"%>

<jsp:include page="common/theme.jsp" />

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ</title>
<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/logs.css">
</head>

<body class="${themeValue}-theme font-${themeFontSize}"
	style="--custom-bg-color: ${themeBgColor};
             --custom-text-color: ${themeTextColor};">

	<%
	request.setAttribute("pageTitle", "ログ");
	request.setAttribute("currentPage", "logs");
	%>

	<div class="app-container">

		<%@ include file="common/sidebar.jsp"%>

		<main class="main-content">

			<%@ include file="common/header.jsp"%>

			<%@ include file="common/mode.jsp"%>

			<%
			ActivityLogDAO dao = new ActivityLogDAO();

			List<ActivityLog> logs;

			if (personalMode) {
				logs = dao.findByUserId(loginUserId);
			} else {
				logs = dao.findByOrgId(activeOrgId);
			}
			%>
			<div class="content-body">

				<h2 class="log-title"><%= personalMode ? "ログ管理（個人）" : "ログ管理（団体）" %></h2>
				<p class="log-count">
					件数:
					<%=logs.size()%></p>

				<div class="log-tabs">
					<button type="button" class="log-tab active">操作ログ</button>
					<button type="button" class="log-tab">監査ログ</button>
					<button type="button" class="log-tab">ログイン履歴</button>
					<button type="button" class="log-tab">通知履歴</button>
				</div>

				<table class="log-table">
					<thead>
						<tr>
							<th>日時</th>
							<th>ユーザー</th>
							<th>操作</th>
							<th>詳細</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (ActivityLog log : logs) {
						%>
						<tr class="log-row">
							<td class="log-date"><%=log.getCreatedAt()%></td>
							<td class="log-user"><%=log.getUserName()%></td>
							<td class="log-action"><span class="log-action-badge"><%=log.getAction()%></span></td>
							<td class="log-detail"><%=log.getDetail()%></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>

			</div>

			<%@ include file="common/footer.jsp"%>

		</main>

	</div>

</body>
</html>
