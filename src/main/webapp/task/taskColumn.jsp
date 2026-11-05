<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>

<%
String columnTitle = (String) request.getAttribute("columnTitle");

String columnStatus = (String) request.getAttribute("columnStatus");

@SuppressWarnings("unchecked")
List<Map<String, Object>> columnTasks = (List<Map<String, Object>>) request.getAttribute("columnTasks");

String columnClass = "";

if ("未着手".equals(columnStatus)) {
	columnClass = "status-todo";
} else if ("進行中".equals(columnStatus)) {
	columnClass = "status-doing";
} else if ("完了".equals(columnStatus)) {
	columnClass = "status-done";
}
%>

<div class="task-column <%=columnClass%>">

	<div class="column-header">

		<h2>
			<%=columnTitle%>（<%=columnTasks.size()%>）
		</h2>

		<button class="add-task-btn-small custom-theme-accent"
			onclick="openAddTaskModal('<%=columnStatus%>')">＋</button>

	</div>

	<%
	for (Map<String, Object> task : columnTasks) {

		request.setAttribute("taskData", task);
	%>

	<jsp:include page="/task/taskCard.jsp" />

	<%
	}
	%>

</div>