<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="model.User"%>
<%@ page import="util.DBConnection"%>

<%
request.setCharacterEncoding("UTF-8");

User loginUser = (User) session.getAttribute("loginUser");
if (loginUser == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String tagIdStr = request.getParameter("tag_id");
String tagName = request.getParameter("tag_name");
String color = request.getParameter("color");

if (tagIdStr == null || !tagIdStr.matches("\\d+")
		|| tagName == null || tagName.trim().isEmpty() || tagName.trim().length() > 50
		|| color == null || !color.matches("^#[0-9A-Fa-f]{6}$")) {
	response.sendRedirect(request.getContextPath() + "/taskboard.jsp");
	return;
}

int tagId = Integer.parseInt(tagIdStr);
tagName = tagName.trim();

Integer activeOrgId = (Integer) session.getAttribute("activeOrgId");

String sql;
if (activeOrgId == null) {
	sql = "UPDATE tag SET tag_name = ?, color = ? "
		+ "WHERE tag_id = ? AND user_id = ? AND org_id IS NULL";
} else {
	sql = "UPDATE tag SET tag_name = ?, color = ? "
		+ "WHERE tag_id = ? AND org_id = ? AND user_id IS NULL";
}

try (Connection conn = DBConnection.getConnection();
		PreparedStatement stmt = conn.prepareStatement(sql)) {

	stmt.setString(1, tagName);
	stmt.setString(2, color);
	stmt.setInt(3, tagId);

	if (activeOrgId == null) {
		stmt.setInt(4, loginUser.getUserId());
	} else {
		stmt.setInt(4, activeOrgId);
	}

	stmt.executeUpdate();

} catch (SQLException e) {
	if ("23505".equals(e.getSQLState())) {
%>
		<p style="color:red;">同じ名前のタグがすでに存在します。</p>
		<p><a href="<%=request.getContextPath()%>/taskboard.jsp">タスクボードへ戻る</a></p>
<%
		return;
	}
	throw e;
}

response.sendRedirect(request.getContextPath() + "/taskboard.jsp");
%>