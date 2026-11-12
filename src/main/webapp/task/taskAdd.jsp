<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="dao.TaskDAO"%>

<%
request.setCharacterEncoding("UTF-8");

String projectIdStr = request.getParameter("project_id");
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

String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
String user = "taskuser";
String password = "taskpass";

Connection conn = null;
PreparedStatement taskStmt = null;
PreparedStatement assigneeStmt = null;
ResultSet generatedKeys = null;

try {
	Class.forName("org.postgresql.Driver");
	conn = DriverManager.getConnection(url, user, password);

	conn.setAutoCommit(false);

	String taskSql = "INSERT INTO task "
	+ "(project_id, task_name, description, status, priority, start_date, due_date) "
	+ "VALUES (?, ?, ?, ?, ?, ?, ?)";

	taskStmt = conn.prepareStatement(taskSql, Statement.RETURN_GENERATED_KEYS);

	taskStmt.setInt(1, Integer.parseInt(projectIdStr));
	taskStmt.setString(2, taskName);
	taskStmt.setString(3, description);
	taskStmt.setString(4, status);
	taskStmt.setString(5, priority);

	if (startDate == null || startDate.isEmpty()) {
		taskStmt.setNull(6, java.sql.Types.DATE);
	} else {
		taskStmt.setDate(6, java.sql.Date.valueOf(startDate));
	}

	if (dueDate == null || dueDate.isEmpty()) {
		taskStmt.setNull(7, java.sql.Types.DATE);
	} else {
		taskStmt.setDate(7, java.sql.Date.valueOf(dueDate));
	}

	taskStmt.executeUpdate();

	generatedKeys = taskStmt.getGeneratedKeys();

	if (generatedKeys.next()) {
		int taskId = generatedKeys.getInt(1);

		String assigneeSql = "INSERT INTO task_assignee (task_id, user_id) VALUES (?, ?)";
		assigneeStmt = conn.prepareStatement(assigneeSql);
		assigneeStmt.setInt(1, taskId);
		assigneeStmt.setInt(2, Integer.parseInt(userIdStr));
		assigneeStmt.executeUpdate();
		TaskDAO taskDAO =new TaskDAO();
			taskDAO.replaceTaskTags(
					conn,taskId,tagIds,newTagNames,newTagColors);
	}

	conn.commit();

	response.sendRedirect(
	request.getContextPath() + "/taskboard.jsp");

} catch (Exception e) {
	if (conn != null) {
		try {
	conn.rollback();
		} catch (Exception rollbackError) {
		}
	}
%>
<p style="color: red;">
	タスク追加エラー：<%=e.getMessage()%></p>
<p>
	<a href="<%=request.getContextPath()%>/taskboard.jsp">タスクボードへ戻る</a>
</p>
<%
} finally {
if (generatedKeys != null)
	try {
		generatedKeys.close();
	} catch (Exception e) {
	}
if (taskStmt != null)
	try {
		taskStmt.close();
	} catch (Exception e) {
	}
if (assigneeStmt != null)
	try {
		assigneeStmt.close();
	} catch (Exception e) {
	}
if (conn != null)
	try {
		conn.close();
	} catch (Exception e) {
	}
}
%>