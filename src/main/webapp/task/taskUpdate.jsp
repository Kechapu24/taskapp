<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.sql.*" %>
<%@ page import="dao.TaskDAO" %>
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


// フォームから受け取る値
String taskIdStr = request.getParameter("task_id");
String taskName = request.getParameter("task_name");
String description = request.getParameter("description");
String status = request.getParameter("status");
String priority = request.getParameter("priority");
String startDate = request.getParameter("start_date");
String dueDate = request.getParameter("due_date");
String userIdStr = request.getParameter("user_id");

String[] tagIds = request.getParameterValues("tag_ids");
String[] newTagNames = request.getParameterValues("new_tag_names");
String[] newTagColors = request.getParameterValues("new_tag_colors");

Connection conn = null;

try {

    // 入力チェック
    if (taskIdStr == null || taskIdStr.trim().isEmpty()) {
        throw new IllegalArgumentException("タスクIDが指定されていません。");
    }

    if (taskName == null || taskName.trim().isEmpty()) {
        throw new IllegalArgumentException("タスク名を入力してください。");
    }

    if (userIdStr == null || userIdStr.trim().isEmpty()) {
        throw new IllegalArgumentException("担当者を選択してください。");
    }

    int taskId = Integer.parseInt(taskIdStr);
    int userId = Integer.parseInt(userIdStr);


    Class.forName("org.postgresql.Driver");

    conn = DBConnection.getConnection();

    conn.setAutoCommit(false);


    // ======================================
    // ① タスク本体を更新
    // ======================================

    String taskSql =
        "UPDATE task "
        + "SET task_name = ?, "
        + "description = ?, "
        + "status = ?, "
        + "priority = ?, "
        + "start_date = ?, "
        + "due_date = ? "
        + "WHERE task_id = ?";

    try (PreparedStatement taskStmt = conn.prepareStatement(taskSql)) {

        taskStmt.setString(1, taskName.trim());
        taskStmt.setString(2, description == null ? "" : description);
        taskStmt.setString(3, status);
        taskStmt.setString(4, priority);

        if (startDate == null || startDate.isEmpty()) {
            taskStmt.setNull(5, java.sql.Types.DATE);
        } else {
            taskStmt.setDate(5, java.sql.Date.valueOf(startDate));
        }

        if (dueDate == null || dueDate.isEmpty()) {
            taskStmt.setNull(6, java.sql.Types.DATE);
        } else {
            taskStmt.setDate(6, java.sql.Date.valueOf(dueDate));
        }

        taskStmt.setInt(7, taskId);

        int updatedRows = taskStmt.executeUpdate();

        if (updatedRows == 0) {
            throw new SQLException("更新対象のタスクが見つかりません。");
        }
    }


    // ======================================
    // ② 担当者を更新
    // ======================================

    String deleteAssigneeSql =
        "DELETE FROM task_assignee WHERE task_id = ?";

    try (PreparedStatement deleteAssigneeStmt =
            conn.prepareStatement(deleteAssigneeSql)) {

        deleteAssigneeStmt.setInt(1, taskId);
        deleteAssigneeStmt.executeUpdate();
    }


    String insertAssigneeSql =
        "INSERT INTO task_assignee (task_id, user_id) VALUES (?, ?)";

    try (PreparedStatement insertAssigneeStmt =
            conn.prepareStatement(insertAssigneeSql)) {

        insertAssigneeStmt.setInt(1, taskId);
        insertAssigneeStmt.setInt(2, userId);

        insertAssigneeStmt.executeUpdate();
    }


    // ======================================
    // ③ タグを更新
    // ======================================

    TaskDAO taskDAO = new TaskDAO();

    taskDAO.replaceTaskTags(
        conn,
        taskId,
        tagIds,
        newTagNames,
        newTagColors
    );


    // ======================================
    // ④ DBへ確定
    // ======================================

    conn.commit();


    // 編集元のページへ戻る
    response.sendRedirect(
        request.getContextPath() + returnPath
    );

} catch (Exception e) {

    // エラー時はロールバック
    if (conn != null) {
        try {
            conn.rollback();
        } catch (Exception rollbackError) {
            application.log("タスク更新のロールバックに失敗しました。", rollbackError);
        }
    }

    application.log("タスク更新エラー", e);

    response.setStatus(500);

%>

<!DOCTYPE html>
<html lang="ja">

<head>
    <meta charset="UTF-8">
    <title>タスク更新エラー</title>
</head>

<body>

    <h2>タスク更新エラー</h2>

    <p>
        タスクの更新に失敗しました。
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
            conn.setAutoCommit(true);
            conn.close();
        } catch (Exception closeError) {
            application.log("DB接続の終了に失敗しました。", closeError);
        }
    }
}

%>