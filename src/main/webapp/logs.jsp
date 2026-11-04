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
<link rel="stylesheet" href="css/logs.css">
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

            logs = dao.findAll();

        } else {

            logs = dao.findAll();

        }
        %>

        <div class="content-body">

            <h2>ログ管理</h2>
            <p>テーブル表示テスト</p>
            <p>件数: <%= logs.size() %></p>

            <div class="log-tabs">
                <button class="log-tab active">操作ログ</button>
                <button class="log-tab">監査ログ</button>
                <button class="log-tab">ログイン履歴</button>
                <button class="log-tab">通知履歴</button>
            </div>

            <table class="log-table">

                <tr>
                    <th>日時</th>
                    <th>ユーザー</th>
                    <th>操作</th>
                    <th>詳細</th>
                </tr>

                <%
                for (ActivityLog log : logs) {
                %>

                <tr>
                    <td><%= log.getCreatedAt() %></td>
                    <td><%= log.getUserName() %></td>
                    <td><%= log.getAction() %></td>
                    <td><%= log.getDetail() %></td>
                </tr>

                <%
                }
                %>

            </table>

        </div>

        <%@ include file="common/footer.jsp"%>

    </main>

</div>

</body>
</html>