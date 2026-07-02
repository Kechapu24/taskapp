<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

String taskIdStr = request.getParameter("task_id");
String taskName = request.getParameter("task_name");
String description = request.getParameter("description");
String status = request.getParameter("status");
String priority = request.getParameter("priority");
String dueDate = request.getParameter("due_date");
String userIdStr = request.getParameter("user_id");

String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
String user = "taskuser";
String password = "taskpass";

Connection conn = null;
PreparedStatement taskStmt = null;
PreparedStatement deleteAssigneeStmt = null;
PreparedStatement insertAssigneeStmt = null;

try {
    Class.forName("org.postgresql.Driver");
    conn = DriverManager.getConnection(url, user, password);

    conn.setAutoCommit(false);

    String taskSql = "UPDATE task "
                   + "SET task_name = ?, "
                   + "description = ?, "
                   + "status = ?, "
                   + "priority = ?, "
                   + "due_date = ? "
                   + "WHERE task_id = ?";

    taskStmt = conn.prepareStatement(taskSql);

    taskStmt.setString(1, taskName);
    taskStmt.setString(2, description);
    taskStmt.setString(3, status);
    taskStmt.setString(4, priority);

    if (dueDate == null || dueDate.isEmpty()) {
        taskStmt.setNull(5, java.sql.Types.DATE);
    } else {
        taskStmt.setDate(5, java.sql.Date.valueOf(dueDate));
    }

    taskStmt.setInt(6, Integer.parseInt(taskIdStr));

    taskStmt.executeUpdate();

    /*
     * 担当者の更新
     * 今回はシンプルに、
     * 既存担当者を一度消す
     * ↓
     * 新しい担当者を登録
     * という形にする
     */
    String deleteAssigneeSql = "DELETE FROM task_assignee WHERE task_id = ?";
    deleteAssigneeStmt = conn.prepareStatement(deleteAssigneeSql);
    deleteAssigneeStmt.setInt(1, Integer.parseInt(taskIdStr));
    deleteAssigneeStmt.executeUpdate();

    String insertAssigneeSql = "INSERT INTO task_assignee (task_id, user_id) VALUES (?, ?)";
    insertAssigneeStmt = conn.prepareStatement(insertAssigneeSql);
    insertAssigneeStmt.setInt(1, Integer.parseInt(taskIdStr));
    insertAssigneeStmt.setInt(2, Integer.parseInt(userIdStr));
    insertAssigneeStmt.executeUpdate();

    conn.commit();

    response.sendRedirect("taskboard.jsp");

} catch (Exception e) {
    if (conn != null) {
        try {
            conn.rollback();
        } catch (Exception rollbackError) {
        }
    }
%>
    <p style="color:red;">タスク更新エラー：<%= e.getMessage() %></p>
    <p><a href="taskboard.jsp">タスクボードへ戻る</a></p>
<%
} finally {
    if (taskStmt != null) try { taskStmt.close(); } catch (Exception e) {}
    if (deleteAssigneeStmt != null) try { deleteAssigneeStmt.close(); } catch (Exception e) {}
    if (insertAssigneeStmt != null) try { insertAssigneeStmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>