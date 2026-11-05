<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.temporal.ChronoUnit"%>
<%@ page import="dao.TaskDAO"%>
<%@ page import="model.TaskFilter"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<jsp:include page="common/theme.jsp" />
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ</title>
<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet" href="css/taskboard.css">
</head>
<body class="${themeValue}-theme font-${themeFontSize}"
	style="--custom-bg-color: ${themeBgColor};
             --custom-text-color: ${themeTextColor};">

	<%
	request.setAttribute("pageTitle", "タスクボード");
	request.setAttribute("currentPage", "taskboard");
	%>

	<div class="app-container">

		<%@ include file="common/sidebar.jsp"%>

		<main class="main-content">

			<%@ include file="common/header.jsp"%>

			<div class="content-body">

				<%@ include file="common/mode.jsp"%>

				<%
				String scopeCondition;

				if (personalMode) {
					scopeCondition = "p.user_id = ? ";
				} else {
					scopeCondition = "p.org_id = ? ";
				}
				%>

				<%
				String keyword = request.getParameter("keyword");
				String filterProjectId = request.getParameter("project_id");
				String filterUserId = request.getParameter("user_id");
				String filterPriority = request.getParameter("priority");
				String filterDeadline = request.getParameter("deadline");
				String filterTagId = request.getParameter("tag_id");
				String filterTagKeyword = request.getParameter("tag_keyword");
				String sort = request.getParameter("sort");

				String countUrl = "jdbc:postgresql://172.16.1.119:5432/taskapp";
				String countUser = "taskuser";
				String countPassword = "taskpass";

				%>

				<%
				TaskFilter taskFilter = new TaskFilter();

				taskFilter.setKeyword(keyword);
				taskFilter.setProjectId(filterProjectId);
				taskFilter.setUserId(filterUserId);
				taskFilter.setPriority(filterPriority);
				taskFilter.setDeadline(filterDeadline);
				taskFilter.setTagId(filterTagId);
				taskFilter.setTagKeyword(filterTagKeyword);
				taskFilter.setSort(sort);

				TaskDAO taskDAO = new TaskDAO();

				List<Map<String, Object>> allTasks = taskDAO.getTasksForBoard(loginUserId, activeOrgId, taskFilter);

				List<Map<String, Object>> todoTasks = new ArrayList<>();

				List<Map<String, Object>> doingTasks = new ArrayList<>();

				List<Map<String, Object>> doneTasks = new ArrayList<>();

				for (Map<String, Object> task : allTasks) {

					String taskStatus = (String) task.get("status");

					if ("未着手".equals(taskStatus)) {

						todoTasks.add(task);

					} else if ("進行中".equals(taskStatus)) {

						doingTasks.add(task);

					} else if ("完了".equals(taskStatus)) {

						doneTasks.add(task);
					}
				}

				%>

				<div class="task-board-wrapper">

					<div class="task-board">

						<%
						request.setAttribute("columnTitle", "未着手");

						request.setAttribute("columnStatus", "未着手");

						request.setAttribute("columnTasks", todoTasks);
						%>

						<jsp:include page="/task/taskColumn.jsp" />


						<%
						request.setAttribute("columnTitle", "進行中");

						request.setAttribute("columnStatus", "進行中");

						request.setAttribute("columnTasks", doingTasks);
						%>

						<jsp:include page="/task/taskColumn.jsp" />


						<%
						request.setAttribute("columnTitle", "完了");

						request.setAttribute("columnStatus", "完了");

						request.setAttribute("columnTasks", doneTasks);
						%>

						<jsp:include page="/task/taskColumn.jsp" />

					</div>

					<!-- 右：サイドパネル -->
					<div class="sidepanel" id="sidepanel">

						<!-- タブ -->
						<div class="sidepanel-tabs">
							<button type="button"
								class="sidepanel-tab active custom-theme-accent-active"
								onclick="switchSideTab('filter', this)">検索・絞込</button>

							<button type="button"
								class="sidepanel-tab custom-theme-accent-active" id="detailTab"
								onclick="switchSideTab('detail', this)">詳細</button>
						</div>


						<!-- 検索・絞り込み -->
						<div class="sidepanel-content active" id="filterPanel">

							<h3>タスク検索</h3>

							<form method="get" action="taskboard.jsp" class="filter-form">

								<input type="text" name="keyword" class="filter-input"
									placeholder="タスク名を検索"
									value="<%=request.getParameter("keyword") == null ? "" : request.getParameter("keyword")%>">

								<label>プロジェクト</label> <select name="project_id">

									<option value="">すべて</option>

									<%
									String projectFilterSql = "SELECT p.project_id, p.project_name " + "FROM project p " + "WHERE " + scopeCondition
											+ "ORDER BY p.project_name";

									try (Connection projectFilterConn = DriverManager.getConnection(countUrl, countUser, countPassword);

											PreparedStatement projectFilterStmt = projectFilterConn.prepareStatement(projectFilterSql)) {

										projectFilterStmt.setInt(1, scopeId);

										try (ResultSet projectFilterRs = projectFilterStmt.executeQuery()) {

											while (projectFilterRs.next()) {

										int projectId = projectFilterRs.getInt("project_id");

										String projectName = projectFilterRs.getString("project_name");
									%>

									<option value="<%=projectId%>"
										<%=String.valueOf(projectId).equals(filterProjectId) ? "selected" : ""%>>
										<%=projectName%>
									</option>

									<%
									}
									}

									} catch (Exception e) {
									e.printStackTrace();
									}
									%>

								</select> <label>担当者</label> <select name="user_id">

									<option value="">すべて</option>

									<%
									if (personalMode) {
									%>

									<option value="<%=loginUserId%>"
										<%=String.valueOf(loginUserId).equals(filterUserId) ? "selected" : ""%>>
										自分（<%=loginUser.getUserName()%>）
									</option>

									<%
									} else {

									String memberFilterSql = "SELECT u.user_id, u.user_name " + "FROM org_member om "
											+ "JOIN users u ON om.user_id = u.user_id " + "WHERE om.org_id = ? " + "ORDER BY u.user_name";

									try (Connection memberFilterConn = DriverManager.getConnection(countUrl, countUser, countPassword);

											PreparedStatement memberFilterStmt = memberFilterConn.prepareStatement(memberFilterSql)) {

										memberFilterStmt.setInt(1, activeOrgId);

										try (ResultSet memberFilterRs = memberFilterStmt.executeQuery()) {

											while (memberFilterRs.next()) {

										int memberUserId = memberFilterRs.getInt("user_id");

										String memberUserName = memberFilterRs.getString("user_name");
									%>

									<option value="<%=memberUserId%>"
										<%=String.valueOf(memberUserId).equals(filterUserId) ? "selected" : ""%>>
										<%=memberUserName%>
									</option>

									<%
									}
									}

									} catch (Exception e) {
									e.printStackTrace();
									}
									}
									%>

								</select> <label>優先度</label> <select name="priority">
									<option value="">すべて</option>

									<option value="高"
										<%="高".equals(request.getParameter("priority")) ? "selected" : ""%>>
										高</option>

									<option value="中"
										<%="中".equals(request.getParameter("priority")) ? "selected" : ""%>>
										中</option>

									<option value="低"
										<%="低".equals(request.getParameter("priority")) ? "selected" : ""%>>
										低</option>
								</select> <label>期限</label> <select name="deadline">

									<option value="">すべて</option>

									<option value="overdue"
										<%="overdue".equals(request.getParameter("deadline")) ? "selected" : ""%>>
										期限超過</option>

									<option value="today"
										<%="today".equals(request.getParameter("deadline")) ? "selected" : ""%>>
										今日まで</option>

									<option value="week"
										<%="week".equals(request.getParameter("deadline")) ? "selected" : ""%>>
										7日以内</option>

								</select>

								<div class="filter-buttons">
									<button type="submit" class="filter-submit custom-theme-accent">適用</button>

									<a href="taskboard.jsp" class="filter-reset"> リセット </a>
								</div>

							</form>

							<h3>並び替え</h3>

							<form method="get" action="taskboard.jsp" class="filter-form">

								<!-- 検索条件を維持したいのでhiddenで引き継ぐ -->
								<input type="hidden" name="keyword"
									value="<%=request.getParameter("keyword") == null ? "" : request.getParameter("keyword")%>">

								<label>並び順</label> <select name="sort">
									<option value="due_asc">期限が近い順</option>
									<option value="due_desc">期限が遠い順</option>
									<option value="priority">優先度順</option>
									<option value="name">タスク名順</option>
								</select>

								<button type="submit" class="filter-submit custom-theme-accent">適用</button>

							</form>

						</div>

						<!-- 詳細 -->
						<div class="sidepanel-content" id="detailPanel">

							<div id="panelContent">タスクを選択してください</div>

						</div>

					</div>
				</div>

			</div>


			<%@ include file="common/footer.jsp"%>

			<script>
				function openModalFromElement(title, elementId) {
					const source = document.getElementById(elementId);
					const modalOverlay = document
							.getElementById("modalOverlay");
					const modalTitle = document.getElementById("modalTitle");
					const modalBody = document.getElementById("modalBody");

					modalTitle.textContent = title;
					modalBody.innerHTML = source.innerHTML;
					modalOverlay.style.display = "flex";

					closeAllTaskMenus();
				}

				function closeModal() {
					document.getElementById("modalOverlay").style.display = "none";
				}

				function toggleTaskMenu(event, menuId) {
					event.stopPropagation();

					closeAllTaskMenus();

					const menu = document.getElementById(menuId);
					menu.style.display = "block";
				}

				function closeAllTaskMenus() {
					const menus = document.querySelectorAll(".menu-dropdown");

					menus.forEach(function(menu) {
						menu.style.display = "none";
					});
				}

				window.addEventListener("click", function(event) {
					closeAllTaskMenus();

					const modalOverlay = document
							.getElementById("modalOverlay");

					if (event.target === modalOverlay) {
						closeModal();
					}
				});
			</script>

			<script>
				function openAddTaskModal(status) {
					const source = document.getElementById("task-add-form");
					const modalOverlay = document
							.getElementById("modalOverlay");
					const modalTitle = document.getElementById("modalTitle");
					const modalBody = document.getElementById("modalBody");

					modalTitle.textContent = "タスク追加";
					modalBody.innerHTML = source.innerHTML;
					modalOverlay.style.display = "flex";

					const statusInput = modalBody
							.querySelector("#addTaskStatus");
					statusInput.value = status;

					closeAllTaskMenus();
				}
			</script>

			<script>
				function switchSideTab(tabName, button) {

					// 全パネルを非表示
					const contents = document
							.querySelectorAll(".sidepanel-content");

					contents.forEach(function(content) {
						content.classList.remove("active");
					});

					// 全タブのactiveを外す
					const tabs = document.querySelectorAll(".sidepanel-tab");

					tabs.forEach(function(tab) {
						tab.classList.remove("active");
					});

					// 選択したパネルを表示
					if (tabName === "filter") {
						document.getElementById("filterPanel").classList
								.add("active");

					} else if (tabName === "sort") {
						document.getElementById("sortPanel").classList
								.add("active");

					} else if (tabName === "detail") {
						document.getElementById("detailPanel").classList
								.add("active");
					}

					button.classList.add("active");
				}
			</script>

			<script>
				function showTaskDetail(detailId, card) {

					// カード内にある隠し詳細データを取得
					const detail = document.getElementById(detailId);

					// 右パネルの表示場所
					const panelContent = document
							.getElementById("panelContent");

					if (!detail || !panelContent) {
						return;
					}

					// 隠しdivの内容を右パネルへコピー
					panelContent.innerHTML = detail.innerHTML;

					// 選択中カードの見た目を変更
					document.querySelectorAll(".task-card").forEach(
							function(taskCard) {
								taskCard.classList.remove("selected");
							});

					card.classList.add("selected");

					// 詳細タブへ自動切り替え
					const detailPanel = document.getElementById("detailPanel");

					if (detailPanel) {

						document.querySelectorAll(".sidepanel-content")
								.forEach(function(content) {
									content.classList.remove("active");
								});

						document.querySelectorAll(".sidepanel-tab").forEach(
								function(tab) {
									tab.classList.remove("active");
								});

						detailPanel.classList.add("active");

						const detailTab = document.getElementById("detailTab");

						if (detailTab) {
							detailTab.classList.add("active");
						}
					}
				}
			</script>
		</main>

	</div>

	<div class="modal-overlay" id="modalOverlay">
		<div class="modal-content">
			<div class="modal-header">
				<h2 id="modalTitle">タイトル</h2>
				<button class="modal-close" onclick="closeModal()">×</button>
			</div>

			<div class="modal-body" id="modalBody"></div>
		</div>
	</div>

	<div id="task-add-form" style="display: none;">
		<form class="edit-form" action="task/taskAdd.jsp" method="post">

			<input type="hidden" name="status" id="addTaskStatus"> <label>プロジェクト</label>
			<select name="project_id" required>
				<option value="1">販売管理システム</option>
				<option value="2">在庫管理システム</option>
				<option value="3">社内ポータルサイト</option>
				<option value="4">勤怠管理システム</option>
			</select> <label>タスク名</label> <input type="text" name="task_name" required>

			<label>説明</label>
			<textarea name="description"></textarea>

			<label>優先度</label> <select name="priority">
				<option value="低">低</option>
				<option value="中" selected>中</option>
				<option value="高">高</option>
			</select> <label>開始日</label> <input type="date" name="start_date"> <label>期限</label>
			<input type="date" name="due_date"> <label>担当者</label> <select
				name="user_id">
				<option value="1">伊藤</option>
				<option value="2">高橋</option>
				<option value="3">中村</option>
				<option value="4">小林</option>
				<option value="5">加藤</option>
			</select>

			<button type="submit" class="modal-submit-btn custom-theme-accent">追加</button>
		</form>
	</div>



</body>
</html>