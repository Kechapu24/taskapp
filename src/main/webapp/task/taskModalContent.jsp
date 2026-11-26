
<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.*"%>
<%@ page import="dao.TaskDAO"%>
<%@ page import="model.TaskFilter"%>
<%@ page import="model.User"%>

<%
request.setCharacterEncoding("UTF-8");
response.setHeader("Cache-Control", "no-store");

User modalLoginUser =
    (User) session.getAttribute("loginUser");

if (modalLoginUser == null) {
    response.sendError(401);
    return;
}

Integer modalOrgId =
    (Integer) session.getAttribute("activeOrgId");

String modalMode = request.getParameter("mode");

if (!"add".equals(modalMode)
        && !"edit".equals(modalMode)
        && !"detail".equals(modalMode)) {
    response.sendError(400);
    return;
}

String modalReturnTo = request.getParameter("returnTo");

if (!"projects".equals(modalReturnTo)
        && !"mytasks".equals(modalReturnTo)) {
    modalReturnTo = "taskboard";
}

TaskDAO modalDao = new TaskDAO();

List<Map<String, Object>> modalProjects =
    modalDao.getProjectOptionsForBoard(
        modalLoginUser.getUserId(),
        modalOrgId
    );

request.setAttribute(
    "boardProjectOptions",
    modalProjects
);

request.setAttribute(
    "tagOptions",
    modalDao.getTagOptionsForBoard(
        modalLoginUser.getUserId(),
        modalOrgId
    )
);

Map<String, Object> modalTask = null;

if (!"add".equals(modalMode)) {

    int modalTaskId;

    try {
        modalTaskId = Integer.parseInt(
            request.getParameter("taskId")
        );
    } catch (Exception e) {
        response.sendError(400);
        return;
    }

    TaskFilter modalFilter = new TaskFilter();
    modalFilter.setTaskId(modalTaskId);

    List<Map<String, Object>> matchingTasks =
        modalDao.getTasksForBoard(
            modalLoginUser.getUserId(),
            modalOrgId,
            modalFilter
        );

    if (matchingTasks.isEmpty()) {
        response.sendError(404);
        return;
    }

    modalTask = matchingTasks.get(0);

    request.setAttribute("taskData", modalTask);
}

request.setAttribute(
    "taskFormMode",
    modalMode
);

request.setAttribute(
    "taskFormReturnTo",
    modalReturnTo
);
%>

<%
if ("detail".equals(modalMode)) {
%>

    <jsp:include page="/task/taskDetail.jsp"/>

<%
} else {
%>

    <jsp:include page="/task/taskForm.jsp"/>

<%
}
%>

<%
if (!"detail".equals(modalMode)) {

    for (Map<String, Object> project : modalProjects) {

        int projectId =
            ((Number) project.get("projectId")).intValue();

        // 編集モードでは対象プロジェクトのみ
        if (modalTask != null
                && projectId !=
                   ((Number) modalTask.get("projectId")).intValue()) {
            continue;
        }

        request.setAttribute(
            "assigneeOptions",
            modalDao.getAssigneeCandidatesForProject(
                projectId,
                modalLoginUser.getUserId(),
                modalOrgId
            )
        );

        request.removeAttribute("selectedAssigneeIds");
%>

<template id="assignee-project-<%=projectId%>">
    <jsp:include page="/task/assigneeEditor.jsp"/>
</template>

<%
    }
}
%>
