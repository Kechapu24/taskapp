<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>

<%
request.setCharacterEncoding("UTF-8");

String taskIdStr = request.getParameter("task_id");

String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
String user = "taskuser";
String password = "taskpass";

Connection conn = null;
PreparedStatement stmt = null;

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(url, user, password);

	String sql = "DELETE FROM task WHERE task_id = ?";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, Integer.parseInt(taskIdStr));

	stmt.executeUpdate();

	response.sendRedirect("taskboard.jsp");

} catch (Exception e) {
%>
<p style="color: red;">
	タスク削除エラー：<%=e.getMessage()%></p>
<p>
	<a href="taskboard.jsp">タスクボードへ戻る</a>
</p>
<%
} finally {
if (stmt != null)
	try {
		stmt.close();
	} catch (Exception e) {
	}
if (conn != null)
	try {
		conn.close();
	} catch (Exception e) {
	}
}
%>