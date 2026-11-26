<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.temporal.ChronoUnit"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.HashSet"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
@SuppressWarnings("unchecked")
Map<String, Object> task = (Map<String, Object>) request.getAttribute("taskData");

int taskId = (Integer) task.get("taskId");

@SuppressWarnings("unchecked")
List<Map<String, Object>> currentAssignees = (List<Map<String, Object>>) task.get("assigneeList");

//タスクカード用の担当者一覧
int cardAssigneeCount = currentAssignees == null ? 0 : currentAssignees.size();

pageContext.setAttribute(
		"cardAssignees",
		currentAssignees == null
		? java.util.Collections.emptyList()
		: currentAssignees);

/* 団体権限の日本語表示名 */
Map<String, String> orgRoleNames = new java.util.HashMap<>();

orgRoleNames.put("owner", "オーナー");
orgRoleNames.put("admin", "管理者");
orgRoleNames.put("manager", "マネージャー");
orgRoleNames.put("leader", "リーダー");
orgRoleNames.put("member", "メンバー");

pageContext.setAttribute("orgRoleNames", orgRoleNames);

StringBuilder currentAssigneeIds = new StringBuilder();

if (currentAssignees != null) {

	for (Map<String, Object> assignee : currentAssignees) {

		Object userId = assignee.get("userId");

		if (userId instanceof Number) {

	if (currentAssigneeIds.length() > 0) {
		currentAssigneeIds.append(",");
	}

	currentAssigneeIds.append(
			((Number) userId).intValue());
		}
	}
}

@SuppressWarnings("unchecked")
List<Map<String, Object>> tagOptions = (List<Map<String, Object>>) request.getAttribute("tagOptions");

Set<Integer> selectedTagIds = new HashSet<>();

String rawTagIds = (String) task.get("tagIds");

if (rawTagIds != null
		&& !rawTagIds.isEmpty()) {

	String[] parts = rawTagIds.split(",");

	for (String part : parts) {

		try {

	selectedTagIds.add(
			Integer.parseInt(part));

		} catch (NumberFormatException e) {
		}
	}
}

String deadlineClass = "";

java.sql.Date dueDateSql = (java.sql.Date) task.get("dueDate");

if (dueDateSql != null) {

	LocalDate today = LocalDate.now();

	LocalDate dueDate = dueDateSql.toLocalDate();

	long daysLeft = ChronoUnit.DAYS.between(
	today,
	dueDate);

	if (daysLeft < 0) {

		deadlineClass = "overdue";

	} else if (daysLeft <= 1) {

		deadlineClass = "deadline-red";

	} else if (daysLeft <= 3) {

		deadlineClass = "deadline-yellow";
	}
}
%>

<div class="task-card <%=deadlineClass%>"
	onclick="showTaskDetail(
        'detail-<%=taskId%>',
        this
    )">

	<div class="task-card-header">

		<h3>
			<%=task.get("taskName")%>
		</h3>

		<div class="task-menu">

			<button class="menu-button"
				onclick="
                    toggleTaskMenu(
                        event,
                        'menu-<%=taskId%>'
                    )
                ">
				⋯</button>

			<div class="menu-dropdown" id="menu-<%=taskId%>">

				<button
					onclick="
                        openModalFromElement(
                            '詳細',
                            'detail-<%=taskId%>'
                        )
                    ">
					詳細</button>

				<button
					onclick="
                        openModalFromElement(
                            '編集',
                            'edit-<%=taskId%>'
                        )
                    ">
					編集</button>

				<button class="delete-menu-button"
					onclick="
                        openModalFromElement(
                            'タスク削除',
                            'delete-<%=taskId%>'
                        )
                    ">
					削除</button>

			</div>

		</div>

	</div>

	<p>
		<%=task.get("projectName")%>
	</p>

	<div class="task-card-assignee-row">


		<div class="task-card-assignee-display"
			data-assignee-count="<%=cardAssigneeCount%>">

			<%
			if (cardAssigneeCount == 0) {
			%>

			<span class="task-card-assignee-empty"> 未設定 </span>

			<%
			} else {
			%>

			<div class="task-card-assignee-avatars">


				<c:forEach var="person" items="${cardAssignees}">

					<c:set var="roleLabel" value="${orgRoleNames[person.orgRole]}" />

					<c:if test="${empty roleLabel and not empty person.orgRole}">
						<c:set var="roleLabel" value="${person.orgRole}" />
					</c:if>

					<span class="avatar task-card-assignee-avatar"
						style="--h: ${(person.userId * 67) % 360};"
						title="${fn:escapeXml(person.userName)}${not empty roleLabel ? '（' : ''}${fn:escapeXml(roleLabel)}${not empty roleLabel ? '）' : ''}">
						<c:choose>
							<c:when test="${person.iconSet}">
								<img
									src="${pageContext.request.contextPath}/icon?userId=${person.userId}"
									alt="">
							</c:when>

							<c:otherwise>
								<c:out value="${fn:substring(person.userName, 0, 1)}" />
							</c:otherwise>
						</c:choose>

					</span>

				</c:forEach>

			</div>

			<span
				class="task-card-assignee-more
            <%=cardAssigneeCount > 5 ? "is-visible" : ""%>"
				aria-label="ほかに<%=Math.max(0, cardAssigneeCount - 5)%>人"> +<%=Math.max(0, cardAssigneeCount - 5)%>

			</span>

			<%
			}
			%>

		</div>


		<div class="task-card-actions">

			<button class="icon-button"
				onclick="
                event.stopPropagation();
                openModalFromElement(
                    'コメント',
                    'comment-<%=taskId%>'
                )
            ">
				💬</button>

			<button class="icon-button"
				onclick="
                event.stopPropagation();
                openModalFromElement(
                    '添付ファイル',
                    'file-<%=taskId%>'
                )
            ">
				📎</button>

		</div>

	</div>


	<div class="task-card-bottom">

		<p class="task-card-date">
			<%=task.get("dueDate")%>
		</p>

		<div class="task-card-tags">

			<%
			if (tagOptions != null) {

				for (Map<String, Object> tag : tagOptions) {

					int tagId = (Integer) tag.get("tagId");

					if (!selectedTagIds.contains(tagId)) {
				continue;
					}

					String tagName = (String) tag.get("tagName");

					String tagColor = (String) tag.get("color");
			%>

			<button type="button" class="task-tag-chip"
				style="background-color:<%=tagColor%>;"
				onclick="event.stopPropagation(); openTagEditModal(this, <%=tagId%>, '<%=tagColor%>');">
				<%=tagName%>
			</button>

			<%
			}
			}
			%>

			<span class="task-tag-chip task-tag-more"> … </span>

		</div>

	</div>
	
	<!-- 詳細 -->
	<jsp:include page="/task/taskDetail.jsp" />

	<!-- 編集 -->
	<div id="edit-<%=taskId%>" style="display: none;">
		<%
		request.setAttribute("taskFormMode", "edit");
		request.setAttribute("taskFormReturnTo", "taskboard");
		%>
		<jsp:include page="/task/taskForm.jsp" />
	</div>

	<!-- 削除 -->
	<div id="delete-<%=taskId%>" style="display: none;">

		<p>
			<strong> <%=task.get("taskName")%>
			</strong> を削除してもよろしいですか？
		</p>

		<p style="color: #777; margin-top: 8px;">この操作は取り消せません。</p>

		<form action="<%=request.getContextPath()%>/task/taskDelete.jsp"
			method="post" class="delete-form">

			<input type="hidden" name="task_id" value="<%=taskId%>">

			<div class="delete-actions">

				<button type="button" class="cancel-button" onclick="closeModal()">
					キャンセル</button>

				<button type="submit" class="delete-button">削除する</button>

			</div>

		</form>

	</div>


	<!-- コメント -->
	<div id="comment-<%=taskId%>" style="display: none;">

		<p>
			<%=task.get("comments")%>
		</p>

	</div>


	<!-- 添付 -->
	<div id="file-<%=taskId%>" style="display: none;">

		<p>
			<%=task.get("files")%>
		</p>

	</div>

</div>