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
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<jsp:include page="common/theme.jsp" />
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスク管理アプリ</title>
<link rel="stylesheet" href="css/common.css">
<link rel="stylesheet" href="css/taskboard.css">
<link rel="stylesheet" href="css/assignee-editor.css">
<link rel="stylesheet" href="css/task-modal.css">
<script src="js/assignee-editor.js" defer></script>
<script src="js/tag-editor.js" defer></script>
<script src="js/task-modal.js" defer></script>
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
				taskFilter.setSort(sort);

				TaskDAO taskDAO = new TaskDAO();
				
				List<Map<String, Object>> boardProjectOptions = taskDAO.getProjectOptionsForBoard(
					        loginUserId, activeOrgId);
					request.setAttribute("boardProjectOptions",boardProjectOptions);

				List<Map<String, Object>> allTasks = taskDAO.getTasksForBoard(loginUserId, activeOrgId, taskFilter);

				List<Map<String, Object>> tagOptions = taskDAO.getTagOptionsForBoard(loginUserId, activeOrgId);

				request.setAttribute("tagOptions", tagOptions);

				String selectedTagName = "";

				if (filterTagId != null && !filterTagId.isEmpty()) {

					for (Map<String, Object> tag : tagOptions) {

						int tagId = (Integer) tag.get("tagId");

						if (String.valueOf(tagId).equals(filterTagId)) {

					selectedTagName = (String) tag.get("tagName");

					break;
						}
					}
				}

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

								</select> <label>タグ</label>

								<div class="tag-combobox" id="tagFilterCombobox">

									<div class="tag-combobox-control">

										<input type="text" id="tagFilterInput"
											class="tag-combobox-input" placeholder="すべて"
											autocomplete="off" value="<%=selectedTagName%>"
											onfocus="openTagFilter()" oninput="filterTagOptions()">

										<button type="button" class="tag-combobox-toggle"
											onclick="toggleTagFilter()">▼</button>

									</div>

									<input type="hidden" name="tag_id" id="tagFilterValue"
										value="<%=filterTagId == null ? "" : filterTagId%>">

									<div class="tag-combobox-menu" id="tagFilterMenu">

										<button type="button" class="tag-combobox-option"
											data-tag-name="" onclick="selectTagFilter('', '')">
											すべて</button>

										<%
										for (Map<String, Object> tag : tagOptions) {

											int tagId = (Integer) tag.get("tagId");

											String tagName = (String) tag.get("tagName");
										%>

										<button type="button" class="tag-combobox-option"
											data-tag-name="<%=tagName%>"
											onclick="selectTagFilter('<%=tagId%>','<%=tagName%>')">
											<%=tagName%>
										</button>

										<%
										}
										%>

									</div>

								</div>
								<label>優先度</label> <select name="priority">
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

					const editForm = modalBody.querySelector(
						    "form.edit-form"
						);

						if (editForm) {
						    refreshTaskAssigneeEditor(editForm);
						}

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

			    TaskModal.open({
			        mode: "add",
			        status: status,
			        sourceId: "task-add-form"
			    });

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

			<script>
				function openTagFilter() {

					const menu = document.getElementById("tagFilterMenu");

					menu.classList.add("open");
				}

				function toggleTagFilter() {

					const menu = document.getElementById("tagFilterMenu");

					menu.classList.toggle("open");
				}

				function filterTagOptions() {

					const input = document.getElementById("tagFilterInput");

					const menu = document.getElementById("tagFilterMenu");

					const hidden = document.getElementById("tagFilterValue");

					const keyword = input.value.trim().toLowerCase();

					// 文字を書き換えた時点で
					// 前の選択状態は解除
					hidden.value = "";

					const options = menu
							.querySelectorAll(".tag-combobox-option");

					options.forEach(function(option) {

						const tagName = (option.dataset.tagName || "")
								.toLowerCase();

						// 「すべて」は常に表示
						if (tagName === "") {

							option.style.display = "";

							return;
						}

						if (keyword === "" || tagName.includes(keyword)) {

							option.style.display = "";

						} else {

							option.style.display = "none";
						}
					});

					menu.classList.add("open");
				}

				function selectTagFilter(tagId, tagName) {

					const input = document.getElementById("tagFilterInput");

					const hidden = document.getElementById("tagFilterValue");

					const menu = document.getElementById("tagFilterMenu");

					hidden.value = tagId;

					input.value = tagName;

					menu.classList.remove("open");
				}

				// 外側をクリックしたら閉じる
				document.addEventListener("click", function(event) {

					const combobox = document
							.getElementById("tagFilterCombobox");

					if (combobox && !combobox.contains(event.target)) {

						document.getElementById("tagFilterMenu").classList
								.remove("open");
					}
				});
			</script>

			<script>
				function updateTaskTagOverflow() {

					const tagRows = document
							.querySelectorAll(".task-card-tags");

					tagRows
							.forEach(function(row) {

								const tags = Array
										.from(row
												.querySelectorAll(".task-tag-chip:not(.task-tag-more)"));

								const more = row
										.querySelector(".task-tag-more");

								if (!more) {
									return;
								}

								// 一度全部表示して測り直す
								tags.forEach(function(tag) {
									tag.style.display = "inline-flex";
								});

								more.style.display = "none";

								if (tags.length === 0) {
									return;
								}

								const rowStyle = window.getComputedStyle(row);

								const gap = parseFloat(rowStyle.gap) || 0;

								const availableWidth = row.clientWidth;

								// 全タグがそのまま収まるか確認
								let totalWidth = 0;

								tags.forEach(function(tag, index) {

									if (index > 0) {
										totalWidth += gap;
									}

									totalWidth += tag.offsetWidth;
								});

								// 全部入るなら「…」不要
								if (totalWidth <= availableWidth) {
									return;
								}

								// はみ出すので「…」を表示
								more.style.display = "inline-flex";

								const moreWidth = more.offsetWidth;

								let usedWidth = 0;

								let visibleCount = 0;

								let overflowStarted = false;

								tags.forEach(function(tag) {

									if (overflowStarted) {

										tag.style.display = "none";

										return;
									}

									const beforeTagGap = visibleCount > 0 ? gap
											: 0;

									// 最後に「…」を置くスペースも予約
									const requiredWidth = usedWidth
											+ beforeTagGap + tag.offsetWidth
											+ gap + moreWidth;

									if (requiredWidth <= availableWidth) {

										usedWidth += beforeTagGap
												+ tag.offsetWidth;

										visibleCount++;

									} else {

										overflowStarted = true;

										tag.style.display = "none";
									}
								});
							});
				}

				window.addEventListener("load", updateTaskTagOverflow);

				window.addEventListener("resize", updateTaskTagOverflow);
			</script>


			<script>
(function () {

    function updateTaskAssigneeOverflow() {

        const displays = document.querySelectorAll(
            ".task-card-assignee-display"
        );

        displays.forEach(function (display) {

            const avatarRow = display.querySelector(
                ".task-card-assignee-avatars"
            );

            const more = display.querySelector(
                ".task-card-assignee-more"
            );

            if (!avatarRow || !more) {
                return;
            }

            const avatars = Array.from(
                avatarRow.querySelectorAll(
                    ".task-card-assignee-avatar"
                )
            );

            const total = avatars.length;

            if (total === 0) {
                return;
            }

            // 前回の計算結果をいったん解除
            display.classList.add("is-ready");
            avatarRow.classList.remove("is-overlapping");

            avatars.forEach(function (avatar) {
                avatar.style.display = "inline-flex";
            });

            more.style.display = "none";

            // 担当者表示に使える横幅
            const availableWidth = display.clientWidth;

            if (availableWidth <= 0) {
                return;
            }

            const iconWidth = avatars[0]
                .getBoundingClientRect().width;

            const gap = parseFloat(
                window.getComputedStyle(avatarRow).gap
            ) || 0;

            const displayGap = parseFloat(
                window.getComputedStyle(display).gap
            ) || 0;

            // 通常配置した場合の横幅
            const normalWidth =
                total * iconWidth +
                Math.max(0, total - 1) * gap;

            // 6人以上、または通常配置では収まらない場合
            const overlapMode =
                total > 5 || normalWidth > availableWidth;

            const overlapWidth = iconWidth / 2;

            avatarRow.classList.toggle(
                "is-overlapping",
                overlapMode
            );

            // 最大5人まで表示
            const maximumVisible = Math.min(total, 5);

            let visibleCount = 0;

            // 最大人数から順に、収まる人数を探す
            for (
                let count = maximumVisible;
                count >= 0;
                count--
            ) {

                const hiddenCount = total - count;

                let avatarsWidth = 0;

                if (count > 0) {

                    if (overlapMode) {
                        avatarsWidth =
                            iconWidth +
                            (count - 1) * overlapWidth;
                    } else {
                        avatarsWidth =
                            count * iconWidth +
                            (count - 1) * gap;
                    }
                }

                let moreWidth = 0;

                if (hiddenCount > 0) {

                    // 実際の +N の横幅を測定
                    more.textContent = "+" + hiddenCount;
                    more.style.display = "inline-flex";

                    moreWidth = more.getBoundingClientRect().width;
                } else {
                    more.style.display = "none";
                }

                const requiredWidth =
                    avatarsWidth +
                    (hiddenCount > 0 && count > 0
                        ? displayGap
                        : 0) +
                    moreWidth;

                if (requiredWidth <= availableWidth) {
                    visibleCount = count;
                    break;
                }
            }

            // 計算結果を表示に反映
            avatars.forEach(function (avatar, index) {
                avatar.style.display =
                    index < visibleCount
                        ? "inline-flex"
                        : "none";
            });

            const hiddenCount = total - visibleCount;

            if (hiddenCount > 0) {

                more.textContent = "+" + hiddenCount;
                more.style.display = "inline-flex";

                // 省略された担当者の名前を表示
                const hiddenNames = avatars
                    .slice(visibleCount)
                    .map(function (avatar) {
                        return avatar.getAttribute("title") || "";
                    })
                    .filter(Boolean);

                more.title = hiddenNames.join("\n");

                more.setAttribute(
                    "aria-label",
                    "ほかに" + hiddenCount + "人: " +
                    hiddenNames.join("、")
                );

            } else {

                more.style.display = "none";
                more.removeAttribute("title");
                more.removeAttribute("aria-label");
            }

        });
    }

    // 短時間に何度も計算しないようにする
    let updateScheduled = false;

    function scheduleAssigneeUpdate() {

        if (updateScheduled) {
            return;
        }

        updateScheduled = true;

        requestAnimationFrame(function () {
            updateScheduled = false;
            updateTaskAssigneeOverflow();
        });
    }

    // 初期表示
    window.addEventListener("load", function () {

        scheduleAssigneeUpdate();

        // カード幅が変わったときにも再計算
        if ("ResizeObserver" in window) {

            const observer = new ResizeObserver(
                scheduleAssigneeUpdate
            );

            document.querySelectorAll(
                ".task-card-assignee-row"
            ).forEach(function (row) {
                observer.observe(row);
            });
        }

    });

    // ウィンドウサイズ変更
    window.addEventListener(
        "resize",
        scheduleAssigneeUpdate
    );

})();
</script>


			<script>
function openTagEditModal(button, tagId, currentColor) {
	const modalOverlay = document.getElementById("modalOverlay");
	const modalTitle = document.getElementById("modalTitle");
	const modalBody = document.getElementById("modalBody");
	const tagName = button.textContent.trim();

	modalTitle.textContent = "タグ編集";

	modalBody.innerHTML = `
		<form class="tag-edit-form" method="post"
			action="<%=request.getContextPath()%>/task/tagColorUpdate.jsp">

			<input type="hidden" name="tag_id">

			<div class="tag-edit-preview-row">
				<span>プレビュー</span>
				<span class="tag-edit-preview"></span>
			</div>

			<label>タグ名</label>
			<input type="text" name="tag_name" maxlength="50" required>

			<label>カラー</label>
			<input type="color" name="color" class="tag-color-picker">

			<button type="submit" class="modal-submit-btn custom-theme-accent">保存</button>
		</form>
	`;

	const form = modalBody.querySelector(".tag-edit-form");
	const nameInput = form.querySelector('[name="tag_name"]');
	const colorInput = form.querySelector('[name="color"]');
	const preview = form.querySelector(".tag-edit-preview");

	form.querySelector('[name="tag_id"]').value = tagId;
	nameInput.value = tagName;
	colorInput.value = currentColor;

	function updatePreview() {
		preview.textContent = nameInput.value || "タグ";
		preview.style.backgroundColor = colorInput.value;
	}

	nameInput.addEventListener("input", updatePreview);
	colorInput.addEventListener("input", updatePreview);
	updatePreview();

	modalOverlay.style.display = "flex";
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

	<jsp:include page="/task/taskModal.jsp" />


	<%
	for (Map<String, Object> projectOption : boardProjectOptions) {

		int candidateProjectId = (Integer) projectOption.get("projectId");

		List<Map<String, Object>> candidateUsers = taskDAO.getAssigneeCandidatesForProject(
		candidateProjectId,
		loginUserId,
		activeOrgId);

		request.setAttribute(
		"assigneeOptions",
		candidateUsers);

		request.removeAttribute("selectedAssigneeIds");
	%>

	<template id="assignee-project-<%=candidateProjectId%>">
		<jsp:include page="/task/assigneeEditor.jsp" />
	</template>

	<%
	}
	%>

	<div id="task-add-form" style="display: none;">
		<%
		request.setAttribute("taskFormMode", "add");
		request.setAttribute("taskFormReturnTo", "taskboard");
		%>
		<jsp:include page="/task/taskForm.jsp" />
	</div>

</body>
</html>