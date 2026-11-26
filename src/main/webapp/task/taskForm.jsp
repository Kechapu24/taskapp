<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
String formMode =
    (String) request.getAttribute("taskFormMode");

boolean formEditing = "edit".equals(formMode);
boolean formAdding = "add".equals(formMode);

if (!formEditing && !formAdding) {
    throw new IllegalArgumentException(
        "フォームのモードが指定されていません。");
}

@SuppressWarnings("unchecked")
Map<String, Object> formTask =
    (Map<String, Object>) request.getAttribute("taskData");

if (formEditing && formTask == null) {
    throw new IllegalArgumentException(
        "編集するタスク情報がありません。");
}

@SuppressWarnings("unchecked")
List<Map<String, Object>> formProjects =
    (List<Map<String, Object>>) request.getAttribute(
        "boardProjectOptions"
    );

if (formProjects == null) {
    formProjects = Collections.emptyList();
}

String formReturnTo =
    (String) request.getAttribute("taskFormReturnTo");

if (formReturnTo == null) {
    formReturnTo = "taskboard";
}

String formStatus = formEditing
    && formTask.get("status") != null
    ? String.valueOf(formTask.get("status"))
    : "未着手";

String formPriority = formEditing
    && formTask.get("priority") != null
    ? String.valueOf(formTask.get("priority"))
    : "中";

// 編集時の担当者ID
StringBuilder formAssigneeIds = new StringBuilder();

if (formEditing) {

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> formAssignees =
        (List<Map<String, Object>>) formTask.get(
            "assigneeList"
        );

    if (formAssignees != null) {
        for (Map<String, Object> person : formAssignees) {

            if (formAssigneeIds.length() > 0) {
                formAssigneeIds.append(",");
            }

            formAssigneeIds.append(
                person.get("userId")
            );
        }
    }
}

// 編集時のタグID
Set<Integer> formTagIds = new HashSet<>();

if (formEditing) {

    String rawIds =
        (String) formTask.get("tagIds");

    if (rawIds != null && !rawIds.isEmpty()) {

        for (String value : rawIds.split(",")) {
            try {
                formTagIds.add(
                    Integer.parseInt(value.trim())
                );
            } catch (NumberFormatException e) {
                // 不正なIDは無視
            }
        }
    }
}

request.setAttribute("selectedTagIds", formTagIds);

pageContext.setAttribute("sharedFormTask", formTask);
%>

<form class="edit-form task-shared-form"
    action="<%=request.getContextPath()%>/task/<%=formEditing ? "taskUpdate.jsp" : "taskAdd.jsp"%>"
    method="post">

    <% if (formEditing) { %>

        <input type="hidden"
            name="task_id"
            value="<%=formTask.get("taskId")%>">

        <input type="hidden"
            name="return_to"
            value="<%=formReturnTo%>">

    <% } else { %>

        <input type="hidden"
            name="status"
            id="addTaskStatus">

        <label>プロジェクト</label>

        <select name="project_id" required
            onchange="refreshTaskAssigneeEditor(this.form, [])">

            <option value="">プロジェクトを選択</option>

            <% for (Map<String, Object> project : formProjects) { %>

                <option value="<%=project.get("projectId")%>">
                    <c:out value="<%=project.get("projectName")%>"/>
                </option>

            <% } %>

        </select>

    <% } %>

    <label>タスク名</label>

    <input type="text"
        name="task_name"
        value="<% if (formEditing) { %><c:out value="${sharedFormTask.taskName}"/><% } %>"
        required>

    <label>説明</label>

    <textarea name="description"><% if (formEditing) { %><c:out value="${sharedFormTask.description}"/><% } %></textarea>

    <% if (formEditing) { %>

        <label>状態</label>

        <select name="status">
            <option value="未着手"
                <%="未着手".equals(formStatus) ? "selected" : ""%>>
                未着手
            </option>
            <option value="進行中"
                <%="進行中".equals(formStatus) ? "selected" : ""%>>
                進行中
            </option>
            <option value="完了"
                <%="完了".equals(formStatus) ? "selected" : ""%>>
                完了
            </option>
        </select>

    <% } %>

    <label>優先度</label>

    <select name="priority">
        <option value="低"
            <%="低".equals(formPriority) ? "selected" : ""%>>
            低
        </option>
        <option value="中"
            <%="中".equals(formPriority) ? "selected" : ""%>>
            中
        </option>
        <option value="高"
            <%="高".equals(formPriority) ? "selected" : ""%>>
            高
        </option>
    </select>

    <label>開始日</label>
    <input type="date"
        name="start_date"
        value="<% if (formEditing && formTask.get("startDate") != null) { %><%=formTask.get("startDate")%><% } %>">

    <label>期限</label>
    <input type="date"
        name="due_date"
        value="<% if (formEditing && formTask.get("dueDate") != null) { %><%=formTask.get("dueDate")%><% } %>">

    <% if (formEditing) { %>

        <div class="assignee-editor-mount"
            data-project-id="<%=formTask.get("projectId")%>"
            data-selected-ids="<%=formAssigneeIds.toString()%>">
        </div>

    <% } else { %>

        <div class="assignee-editor-mount"></div>

    <% } %>

    <jsp:include page="/task/tagEditor.jsp"/>

    <button type="submit"
        class="modal-submit-btn custom-theme-accent">
        <%=formEditing ? "保存" : "追加"%>
    </button>

</form>
