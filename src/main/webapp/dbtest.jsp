<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>DB接続テスト</title>
</head>
<body>

<h1>DB接続テスト</h1>

<table border="1">
    <tr>
        <th>ID</th>
        <th>タスク名</th>
        <th>状態</th>
        <th>優先度</th>
        <th>期限</th>
    </tr>
    test

<%
String url = "jdbc:postgresql://172.16.1.94:5432/taskapp"";
String user = "taskuser";
String password = "taskpass";

try {
    Class.forName("org.postgresql.Driver");

    Connection conn = DriverManager.getConnection(url, user, password);

    String sql = "SELECT task_id, task_name, status, priority, due_date FROM task ORDER BY task_id";
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(sql);

    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("task_id") %></td>
        <td><%= rs.getString("task_name") %></td>
        <td><%= rs.getString("status") %></td>
        <td><%= rs.getString("priority") %></td>
        <td><%= rs.getDate("due_date") %></td>
    </tr>
<%
    }

    rs.close();
    stmt.close();
    conn.close();

} catch (Exception e) {
%>
    <p style="color:red;">エラー: <%= e.getMessage() %></p>
<%
}
%>

</table>

</body>
</html>