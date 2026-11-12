<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
request.setCharacterEncoding("UTF-8");

// 戻り先を判定
String returnTo = request.getParameter("return_to");

String returnPath = "mytasks".equals(returnTo)
    ? "/mytasks.jsp"
    : "/taskboard.jsp";

String returnLabel = "mytasks".equals(returnTo)
    ? "マイタスクへ戻る"
    : "タスクボードへ戻る";


String taskIdStr = request.getParameter("task_id");

Connection conn = null;

try {

    if (taskIdStr == null || taskIdStr.trim().isEmpty()) {
        throw new IllegalArgumentException("タスクIDが指定されていません。");
    }

    int taskId = Integer.parseInt(taskIdStr);

    conn = DBConnection.getConnection();


    String sql = "DELETE FROM task WHERE task_id = ?";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, taskId);

        int deletedRows = stmt.executeUpdate();

        if (deletedRows == 0) {
            throw new SQLException("削除対象のタスクが見つかりません。");
        }
    }


    // 削除元のページへ戻る
    response.sendRedirect(
        request.getContextPath() + returnPath
    );

} catch (Exception e) {

    application.log("タスク削除エラー", e);

    response.setStatus(500);

%>

<!DOCTYPE html>
<html lang="ja">

<head>
    <meta charset="UTF-8">
    <title>タスク削除エラー</title>
</head>

<body>

    <h2>タスク削除エラー</h2>

    <p>
        タスクの削除に失敗しました。
    </p>

    <p>
        <%= e.getMessage() == null ? "" : e.getMessage() %>
    </p>

    <p>
        <a href="<%= request.getContextPath() + returnPath %>">
            <%= returnLabel %>
        </a>
    </p>

</body>
</html>

<%

} finally {

    if (conn != null) {
        try {
            conn.close();
        } catch (Exception closeError) {
            application.log("DB接続の終了に失敗しました。", closeError);
        }
    }
}

%>