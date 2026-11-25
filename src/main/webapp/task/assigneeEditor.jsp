
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.Collections"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
@SuppressWarnings("unchecked")
List<Map<String, Object>> assigneeOptions = (List<Map<String, Object>>) request.getAttribute("assigneeOptions");

@SuppressWarnings("unchecked")
Set<Integer> selectedAssigneeIds = (Set<Integer>) request.getAttribute("selectedAssigneeIds");

if (assigneeOptions == null) {
	assigneeOptions = Collections.emptyList();
}

if (selectedAssigneeIds == null) {
	selectedAssigneeIds = Collections.emptySet();
}

pageContext.setAttribute("aeOptions", assigneeOptions);
pageContext.setAttribute("aeSelected", selectedAssigneeIds);
%>

<div class="assignee-editor">

	<label>担当者</label>

	<div class="assignee-editor-combobox">

		<div class="assignee-editor-control">
			<input type="search" class="assignee-editor-search"
				placeholder="担当者を検索して追加" autocomplete="off" aria-label="担当者を検索">

			<button type="button" class="assignee-editor-toggle"
				aria-label="担当者候補を開閉" aria-expanded="false">▼</button>
		</div>

		<div class="assignee-editor-menu">

			<c:forEach var="person" items="${aeOptions}">

				<button type="button" class="assignee-editor-option"
					data-user-id="${person.userId}">

					<span class="assignee-editor-avatar"
						style="--h: ${(person.userId * 67) % 360};"> <c:choose>
							<c:when test="${person.iconSet}">
								<img
									src="${pageContext.request.contextPath}/icon?userId=${person.userId}"
									alt="">
							</c:when>
							<c:otherwise>
								<c:out value="${fn:substring(person.userName, 0, 1)}" />
							</c:otherwise>
						</c:choose>
					</span> <span class="assignee-editor-name"> <c:out
							value="${person.userName}" />
					</span>

					<c:if test="${not empty person.orgRole}">
						<span class="assignee-editor-role"> <c:choose>
								<c:when test="${person.orgRole == 'owner'}">オーナー</c:when>
								<c:when test="${person.orgRole == 'admin'}">管理者</c:when>
								<c:when test="${person.orgRole == 'manager'}">マネージャー</c:when>
								<c:when test="${person.orgRole == 'leader'}">リーダー</c:when>
								<c:when test="${person.orgRole == 'member'}">メンバー</c:when>
								<c:otherwise>
									<c:out value="${person.orgRole}" />
								</c:otherwise>
							</c:choose>
						</span>
					</c:if>

				</button>

			</c:forEach>

			<div class="assignee-editor-empty" hidden>該当する担当者はいません</div>

		</div>

	</div>

	<div class="assignee-editor-selected">

		<c:forEach var="person" items="${aeOptions}">

			<c:if test="${aeSelected.contains(person.userId)}">

				<span class="assignee-editor-chip" data-user-id="${person.userId}">

					<span class="assignee-editor-avatar"
					style="--h: ${(person.userId * 67) % 360};"> <c:choose>
							<c:when test="${person.iconSet}">
								<img
									src="${pageContext.request.contextPath}/icon?userId=${person.userId}"
									alt="">
							</c:when>
							<c:otherwise>
								<c:out value="${fn:substring(person.userName, 0, 1)}" />
							</c:otherwise>
						</c:choose>
				</span> <span> <c:out value="${person.userName}" />
				</span> <input type="hidden" name="user_ids" value="${person.userId}">

					<button type="button" class="assignee-editor-remove"
						aria-label="担当者を解除">×</button>

				</span>

			</c:if>

		</c:forEach>

	</div>

</div>
