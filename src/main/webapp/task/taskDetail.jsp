
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.HashSet"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Collections"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
// ====================================
// 詳細表示するタスクを取得
// ====================================

@SuppressWarnings("unchecked")
Map<String, Object> task = (Map<String, Object>) request.getAttribute("taskData");

if (task == null) {
	throw new IllegalArgumentException(
	"詳細表示するタスク情報がありません。");
}

int taskId = ((Number) task.get("taskId")).intValue();

// ====================================
// 担当者一覧
// ====================================

@SuppressWarnings("unchecked")
List<Map<String, Object>> detailAssignees = (List<Map<String, Object>>) task.get("assigneeList");

pageContext.setAttribute(
		"cardAssignees",
		detailAssignees == null
		? Collections.emptyList()
		: detailAssignees);

// ====================================
// 団体権限の表示名
// ====================================

Map<String, String> orgRoleNames = new HashMap<>();

orgRoleNames.put("owner", "オーナー");
orgRoleNames.put("admin", "管理者");
orgRoleNames.put("manager", "マネージャー");
orgRoleNames.put("leader", "リーダー");
orgRoleNames.put("member", "メンバー");

pageContext.setAttribute(
		"orgRoleNames",
		orgRoleNames);

// ====================================
// タグ一覧と選択済みタグ
// ====================================

@SuppressWarnings("unchecked")
List<Map<String, Object>> tagOptions = (List<Map<String, Object>>) request.getAttribute("tagOptions");

Set<Integer> selectedTagIds = new HashSet<>();

String rawTagIds = (String) task.get("tagIds");

if (rawTagIds != null && !rawTagIds.isEmpty()) {

	for (String value : rawTagIds.split(",")) {

		try {
	selectedTagIds.add(
			Integer.parseInt(value.trim()));
		} catch (NumberFormatException e) {
	// 不正なタグIDは無視
		}
	}
}
%>



<!-- 詳細 -->
<div id="detail-<%=taskId%>" style="display: none;">

	<%
	String detailStatus = (String) task.get("status");
	String detailPriority = (String) task.get("priority");

	String statusClass = "";

	if ("未着手".equals(detailStatus)) {
		statusClass = "detail-status-todo";

	} else if ("進行中".equals(detailStatus)) {
		statusClass = "detail-status-doing";

	} else if ("完了".equals(detailStatus)) {
		statusClass = "detail-status-done";
	}

	String priorityClass = "";

	if ("高".equals(detailPriority)) {
		priorityClass = "detail-priority-high";

	} else if ("中".equals(detailPriority)) {
		priorityClass = "detail-priority-middle";

	} else if ("低".equals(detailPriority)) {
		priorityClass = "detail-priority-low";
	}

	java.sql.Date detailStartDate = (java.sql.Date) task.get("startDate");

	java.sql.Date detailDueDate = (java.sql.Date) task.get("dueDate");

	String startDateText = detailStartDate == null
			? "未設定"
			: detailStartDate.toLocalDate().format(
			java.time.format.DateTimeFormatter.ofPattern("MM/dd"));

	String dueDateText = detailDueDate == null
			? "未設定"
			: detailDueDate.toLocalDate().format(
			java.time.format.DateTimeFormatter.ofPattern("MM/dd"));

	String descriptionText = (String) task.get("description");

	String commentsText = (String) task.get("comments");

	String[] commentList;

	if (commentsText == null
			|| commentsText.trim().isEmpty()
			|| "コメントなし".equals(commentsText)) {

		commentList = new String[0];

	} else {

		commentList = commentsText.split("<br>");
	}

	String filesText = (String) task.get("files");

	String[] fileList;

	if (filesText == null
			|| filesText.trim().isEmpty()
			|| "添付なし".equals(filesText)) {

		fileList = new String[0];

	} else {

		fileList = filesText.split("<br>");
	}
	%>


	<!-- タスク名・プロジェクト・状態 -->
	<div class="detail-header">

		<h2 class="detail-task-title">
			<%=task.get("taskName")%>
		</h2>

		<div class="detail-project-row">

			<span class="detail-project-name"> <%=task.get("projectName")%>
			</span> <span class="detail-status-badge <%=statusClass%>"> <%=detailStatus%>
			</span>

		</div>

	</div>


	<!-- 優先度・開始日・期限 -->
	<div class="detail-summary-grid">

		<div class="detail-summary-item">

			<div class="detail-summary-label">優先度</div>

			<span class="detail-priority-badge <%=priorityClass%>"> <%=detailPriority%>
			</span>

		</div>


		<div class="detail-summary-item">

			<div class="detail-summary-label">開始日</div>

			<div class="detail-summary-value">
				<%=startDateText%>
			</div>

		</div>


		<div class="detail-summary-item">

			<div class="detail-summary-label">期限</div>

			<div class="detail-summary-value">
				<%=dueDateText%>
			</div>

		</div>

	</div>


	<!-- 担当者・タグ -->
	<div class="detail-section">

		<div class="detail-group">


			<div class="detail-section-title">担当者</div>

			<div class="detail-chip-list detail-assignee-list">

				<c:choose>

					<c:when test="${empty cardAssignees}">
						<span class="detail-empty">未設定</span>
					</c:when>

					<c:otherwise>

						<c:forEach var="person" items="${cardAssignees}">

							<c:set var="roleLabel" value="${orgRoleNames[person.orgRole]}" />

							<c:if test="${empty roleLabel and not empty person.orgRole}">
								<c:set var="roleLabel" value="${person.orgRole}" />
							</c:if>

							<span class="detail-assignee-chip"> <span
								class="avatar detail-assignee-avatar"
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

							</span> <span class="detail-assignee-info"> <span
									class="detail-assignee-name"> <c:out
											value="${person.userName}" />
								</span> <c:if test="${not empty roleLabel}">
										<span class="detail-assignee-role"> <c:out
												value="${roleLabel}" />
										</span>
									</c:if>

							</span>

							</span>

						</c:forEach>

					</c:otherwise>

				</c:choose>

			</div>

		</div>


		<div class="detail-group">

			<div class="detail-section-title">タグ</div>

			<div class="detail-chip-list">

				<%
				boolean hasDetailTag = false;

				if (tagOptions != null) {

					for (Map<String, Object> tag : tagOptions) {

						int tagId = (Integer) tag.get("tagId");

						if (!selectedTagIds.contains(tagId)) {
					continue;
						}

						hasDetailTag = true;

						String tagName = (String) tag.get("tagName");

						String tagColor = (String) tag.get("color");
				%>

				<button type="button" class="detail-tag-chip"
					style="background-color:<%=tagColor%>;"
					onclick="
								event.stopPropagation();
								openTagColorModal(
									'<%=tagId%>',
									'<%=tagName%>',
									'<%=tagColor%>'
								);
							">

					<%=tagName%>

				</button>

				<%
				}
				}

				if (!hasDetailTag) {
				%>

				<span class="detail-empty"> タグなし </span>

				<%
				}
				%>

			</div>

		</div>

	</div>

	<!-- 説明 -->
	<div class="detail-section">

		<div class="detail-section-title">説明</div>

		<div class="detail-description">
			<%
			if (descriptionText == null
					|| descriptionText.trim().isEmpty()) {
			%><span class="detail-empty">説明はありません</span>
			<%
			} else {
			%><%=descriptionText%>
			<%
			}
			%>
		</div>

	</div>

	<!-- コメント -->
	<div class="detail-section">

		<div class="detail-section-heading">

			<div class="detail-section-title">コメント</div>

			<%
			if (commentList.length > 0) {
			%>

			<span class="detail-count"> <%=commentList.length%>件
			</span>

			<%
			}
			%>

		</div>


		<div class="detail-comment-list">

			<%
			if (commentList.length == 0) {
			%>

			<span class="detail-empty"> コメントはありません </span>

			<%
			} else {

			for (String comment : commentList) {
			%>

			<div class="detail-comment-item">

				<span class="detail-comment-dot"> ・ </span> <span> <%=comment%>
				</span>

			</div>

			<%
			}
			}
			%>

		</div>

	</div>


	<!-- 添付ファイル -->
	<div class="detail-section">

		<div class="detail-section-title">添付ファイル</div>

		<div class="detail-file-list">

			<%
			if (fileList.length == 0) {
			%>

			<span class="detail-empty"> 添付ファイルはありません </span>

			<%
			} else {

			for (String fileName : fileList) {
			%>

			<div class="detail-file-item">

				<span> 📎 </span> <span> <%=fileName%>
				</span>

			</div>

			<%
			}
			}
			%>

		</div>

	</div>

</div>
