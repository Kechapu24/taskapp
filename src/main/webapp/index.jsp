<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentPage", "calendar");

    String loginUserName = (String) session.getAttribute("userName");
    if (loginUserName == null) loginUserName = "";

    String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
    String dbUser = "taskuser";
    String dbPassword = "taskpass";

    List<Map<String, String>> projList = new ArrayList<>();
    List<Map<String, String>> userList = new ArrayList<>();
    List<Map<String, String>> taskList = new ArrayList<>();

    Connection conn = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPassword);

        // 1. プロジェクト情報の取得
        Statement pStmt = conn.createStatement();
        ResultSet pRs = pStmt.executeQuery("SELECT * FROM project ORDER BY project_id ASC");
        String[] colors = {"#1b6ef3", "#20c997", "#fd7e14", "#6f42c1", "#e83e8c"};
        int cIdx = 0;
        while (pRs.next()) {
            int id = 0;
            try { id = pRs.getInt("project_id"); } catch (Exception e) { id = pRs.getInt("id"); }
            String name = null;
            try { name = pRs.getString("project_name"); } catch (Exception e1) {
                try { name = pRs.getString("name"); } catch (Exception e2) {}
            }
            if (name == null) name = "プロジェクト " + id;

            Map<String, String> m = new HashMap<>();
            m.put("id", "proj-" + id);
            m.put("rawId", String.valueOf(id));
            m.put("name", name.replace("\"", "\\\"").replace("'", "\\'"));
            m.put("color", colors[cIdx % colors.length]);
            projList.add(m);
            cIdx++;
        }
        pRs.close();
        pStmt.close();

        // 2. ユーザー情報の取得
        Statement uStmt = conn.createStatement();
        ResultSet uRs = uStmt.executeQuery("SELECT * FROM users ORDER BY user_id ASC");
        while (uRs.next()) {
            int id = 0;
            try { id = uRs.getInt("user_id"); } catch (Exception e) { id = uRs.getInt("id"); }
            String name = null;
            try { name = uRs.getString("user_name"); } catch (Exception e1) {
                try { name = uRs.getString("name"); } catch (Exception e2) {}
            }
            if (name == null) name = "ユーザー " + id;

            Map<String, String> m = new HashMap<>();
            m.put("id", String.valueOf(id));
            m.put("name", name.replace("\"", "\\\"").replace("'", "\\'"));
            userList.add(m);
        }
        uRs.close();
        uStmt.close();

        // 3. タスク情報の取得
        Statement tStmt = conn.createStatement();
        ResultSet tRs = tStmt.executeQuery("SELECT t.*, u.user_name AS u_name, ta.user_id AS u_id FROM task t LEFT JOIN task_assignee ta ON t.task_id = ta.task_id LEFT JOIN users u ON ta.user_id = u.user_id ORDER BY t.task_id ASC");
        Map<Integer, Map<String, Object>> tMapGroup = new LinkedHashMap<>();
        while (tRs.next()) {
            int tid = 0;
            try { tid = tRs.getInt("task_id"); } catch (Exception e) { tid = tRs.getInt("id"); }
            int pid = 0;
            try { pid = tRs.getInt("project_id"); } catch (Exception e) {}
            
            String tName = null;
            try { tName = tRs.getString("task_name"); } catch (Exception e1) {
                try { tName = tRs.getString("name"); } catch (Exception e2) {}
            }
            if (tName == null) tName = "タスク " + tid;

            String status = "";
            try { status = tRs.getString("status"); } catch (Exception e) {}

            String description = "";
            try { description = tRs.getString("description"); } catch (Exception e) {
                try { description = tRs.getString("details"); } catch (Exception ex) {}
            }
            if (description == null) description = "";

            String priority = "中";
            try { priority = tRs.getString("priority"); } catch (Exception e) {}
            if (priority == null || priority.isEmpty()) priority = "中";

            String tag = "";
            try { tag = tRs.getString("tag"); } catch (Exception e) {
                try { tag = tRs.getString("tags"); } catch (Exception ex) {}
            }
            if (tag == null) tag = "";

            java.sql.Date sDate = null;
            try { sDate = tRs.getDate("start_date"); } catch (Exception e) {}
            java.sql.Date dDate = null;
            try { dDate = tRs.getDate("due_date"); } catch (Exception e) {}
            
            String uName = "";
            try { uName = tRs.getString("u_name"); } catch (Exception e) {}
            int uId = 0;
            try { uId = tRs.getInt("u_id"); } catch (Exception e) {}

            if (!tMapGroup.containsKey(tid)) {
                Map<String, Object> tm = new HashMap<>();
                tm.put("id", tid);
                tm.put("rawProjectId", pid);
                tm.put("projectId", "proj-" + pid);
                tm.put("name", tName.replace("\"", "\\\"").replace("'", "\\'"));
                tm.put("description", description.replace("\"", "\\\"").replace("'", "\\'").replace("\r", "").replace("\n", "\\n"));
                tm.put("priority", priority);
                tm.put("tag", tag);
                tm.put("status", status != null ? status : "");
                tm.put("startDate", sDate != null ? sDate.toString() : "");
                tm.put("dueDate", dDate != null ? dDate.toString() : "");
                
                List<String> assignees = new ArrayList<>();
                List<Integer> assigneeIds = new ArrayList<>();
                if (uName != null && !uName.isEmpty()) {
                    assignees.add(uName);
                    assigneeIds.add(uId);
                }
                tm.put("assignees", assignees);
                tm.put("assigneeIds", assigneeIds);
                tMapGroup.put(tid, tm);
            } else {
                if (uName != null && !uName.isEmpty()) {
                    @SuppressWarnings("unchecked")
                    List<String> assignees = (List<String>) tMapGroup.get(tid).get("assignees");
                    @SuppressWarnings("unchecked")
                    List<Integer> assigneeIds = (List<Integer>) tMapGroup.get(tid).get("assigneeIds");
                    if (!assignees.contains(uName)) {
                        assignees.add(uName);
                        assigneeIds.add(uId);
                    }
                }
            }
        }
        tRs.close();
        tStmt.close();

        for (Map<String, Object> tm : tMapGroup.values()) {
            @SuppressWarnings("unchecked")
            List<String> assignees = (List<String>) tm.get("assignees");
            @SuppressWarnings("unchecked")
            List<Integer> assigneeIds = (List<Integer>) tm.get("assigneeIds");
            
            String assigneeStr = assignees.isEmpty() ? "未設定" : String.join(", ", assignees);

            Map<String, String> fm = new HashMap<>();
            fm.put("id", String.valueOf(tm.get("id")));
            fm.put("rawProjectId", String.valueOf(tm.get("rawProjectId")));
            fm.put("projectId", (String) tm.get("projectId"));
            fm.put("name", (String) tm.get("name"));
            fm.put("description", (String) tm.get("description"));
            fm.put("priority", (String) tm.get("priority"));
            fm.put("tag", (String) tm.get("tag"));
            fm.put("status", (String) tm.get("status"));
            fm.put("startDate", (String) tm.get("startDate"));
            fm.put("dueDate", (String) tm.get("dueDate"));
            fm.put("assignee", assigneeStr.replace("\"", "\\\"").replace("'", "\\'"));
            
            StringBuilder idsSb = new StringBuilder();
            for (int i = 0; i < assigneeIds.size(); i++) {
                if (i > 0) idsSb.append(",");
                idsSb.append(assigneeIds.get(i));
            }
            fm.put("assigneeIds", idsSb.toString());

            taskList.add(fm);
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) { try { conn.close(); } catch (SQLException ex) {} }
    }
%>
<jsp:include page="common/theme.jsp" />
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>カレンダー</title>
<link rel="stylesheet" href="css/common.css">
<style>
    :root {
        --saturday-bg: #e8f0fe;
        --sunday-bg: #fce8e8;
    }
    .calendar-container { padding: 20px; flex: 1; display: flex; flex-direction: column; overflow: hidden; background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); width: 100%; box-sizing: border-box; }
    .calendar-header { display: flex; flex-direction: column; gap: 10px; margin-bottom: 15px; flex-shrink: 0; }
    
    .filter-section { display: flex; flex-direction: column; gap: 8px; margin-top: 5px; }
    .filter-group { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
    .filter-group-row2 { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
    .filter-label { font-size: 0.8rem; font-weight: bold; color: #555; min-width: 55px; }
    
    .legend-item, .assignee-item { 
        display: flex; align-items: center; gap: 6px; font-size: 0.85rem; padding: 4px 10px; 
        border-radius: 16px; background-color: #fff; border: 1px solid #64748b;
        cursor: pointer; user-select: none; transition: all 0.2s; color: #333;
    }
    .legend-item:hover, .assignee-item:hover { background-color: #f0f4f8; }
    .legend-item.active, .assignee-item.active { background-color: #e8f0fe; border-color: #1b6ef3; font-weight: bold; color: #1b6ef3; }
    .legend-item.inactive, .assignee-item.inactive { opacity: 0.4; background-color: #f9f9f9; }
    .my-task-btn {
        background-color: #f8fafc; border: 1px solid #64748b; border-radius: 16px; padding: 4px 12px;
        font-size: 0.85rem; font-weight: bold; cursor: pointer; color: #333; transition: all 0.2s;
    }
    .my-task-btn:hover { background-color: #f0f4f8; }
    .my-task-btn.active { background-color: #1b6ef3; color: #fff; border-color: #1b6ef3; }
    
    /* 今日・週・月ボタン & 日付ナビゲーション */
    .view-switch { display: flex; background: #cbd5e1; border-radius: 6px; padding: 3px; }
    .view-switch button { border: none; background: transparent; padding: 6px 16px; cursor: pointer; font-weight: bold; color: #555; border-radius: 4px; transition: 0.2s; }
    .view-switch button:hover { background: #94a3b8; }
    .view-switch button.active { background: #fff; color: #1b6ef3; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    
    .date-nav-wrapper { display: flex; align-items: center; gap: 15px; margin-top: 5px; }
    .date-nav-wrapper button { background: #fff; border: 1px solid #64748b; border-radius: 4px; width: 32px; height: 32px; cursor: pointer; display: flex; justify-content: center; align-items: center; color: #555; transition: 0.2s; }
    .date-nav-wrapper button:hover { background: #f0f4f8; border-color: #94a3b8; }
    .month-nav { font-size: 1.2rem; font-weight: bold; min-width: 150px; text-align: center; color: #333; }
    
    .view-wrapper { flex: 1; overflow: hidden; display: none; flex-direction: column; background: #fff; border: 1px solid #64748b; border-radius: 6px;}
    .view-wrapper.active { display: flex; }
    
    /* ステータス別の枠線色 */
    .status-normal { border-color: #2563eb; background-color: #eff6ff; color: #1e40af; }     /* 青（デフォルト・期限内未完了） */
    .status-overdue { border-color: #0f172a; background-color: #f8fafc; color: #0f172a; }    /* 黒（期限切れ未完了） */
    .status-completed { border-color: #94a3b8; background-color: #f1f5f9; color: #64748b; opacity: 0.75; } /* 薄い表示（完了済み） */

    .grid-body-scroll { flex: 1; overflow-y: auto; display: flex; flex-direction: column; position: relative; background: #fff; }
    .grid-header { display: grid; grid-template-columns: repeat(7, 1fr); background: #f8f9fa; border-bottom: 2px solid #64748b; position: sticky; top: 0; z-index: 20; }
    .day-name { padding: 10px; text-align: center; font-weight: bold; font-size: 0.9rem; border-right: 1px solid #64748b; color: #333; }
    .day-name:last-child { border-right: none; }
    .day-name.saturday { color: #1d4ed8; background-color: #a5c7fe; } 
    .day-name.sunday { color: #b91c1c; background-color: #f8a5a5; }   
    .week-row { position: relative; display: grid; grid-template-columns: repeat(7, 1fr); min-height: 130px; border-bottom: 1px solid #64748b; }
    .week-row:last-child { border-bottom: none; }
    .day-cell { border-right: 1px solid #64748b; padding: 6px; box-sizing: border-box; position: relative; }
    .day-cell:last-child { border-right: none; }
    .day-cell:nth-child(6) { background-color: var(--saturday-bg); } 
    .day-cell:nth-child(7) { background-color: var(--sunday-bg); }   
    .day-cell.other-month { opacity: 0.45; }
    .date-number { font-size: 0.85rem; color: #333; display: inline-block; padding: 2px 6px; font-weight: bold; z-index: 2; position: relative; }
    .date-number.today-mark { background: #1b6ef3; color: #fff; border-radius: 12px; }
    
    .task-bar-container { position: absolute; top: 28px; left: 0; right: 0; bottom: 4px; pointer-events: none; z-index: 5; }
    .task-bar {
        position: absolute; height: 22px; border: 2px solid; border-radius: 3px; padding: 0 5px; 
        box-sizing: border-box; font-size: 0.75rem; background-color: #fff; display: flex; 
        align-items: center; cursor: pointer; pointer-events: auto; top: calc(var(--slot) * 24px); 
        box-shadow: 0 1px 2px rgba(0,0,0,0.06); transition: box-shadow 0.2s;
    }
    .task-bar:hover { box-shadow: 0 2px 6px rgba(0,0,0,0.12); z-index: 20; }
    .task-header { display: flex; align-items: center; gap: 4px; font-weight: bold; width: 100%; pointer-events: none; }
    .project-square { font-size: 0.85rem; flex-shrink: 0; line-height: 1; margin-right: 1px; }
    .task-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; pointer-events: none; color: #333; }

    /* 「+〇件」バッジのスタイル（サイズ拡大・視認性向上） */
    .more-badge {
        position: absolute; height: 22px; padding: 0 8px; box-sizing: border-box;
        font-size: 0.75rem; font-weight: bold; background-color: #1e293b; color: #ffffff;
        border-radius: 4px; display: flex; align-items: center; justify-content: center;
        cursor: pointer; pointer-events: auto; top: calc(var(--slot) * 24px);
        box-shadow: 0 1px 3px rgba(0,0,0,0.2); transition: background 0.2s; z-index: 15;
    }
    .more-badge:hover { background-color: #0f172a; }

    /* モーダルのスタイル */
    .modal-overlay {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0, 0, 0, 0.5); display: flex; justify-content: center; align-items: center;
        z-index: 9999;
    }
    .modal-content {
        background: #fff; width: 520px; max-width: 92%; border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.25); overflow: hidden; display: flex; flex-direction: column;
    }
    .modal-header {
        display: flex; justify-content: space-between; align-items: center;
        padding: 12px 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0;
    }
    .modal-tabs { display: flex; gap: 8px; }
    .modal-tab-btn {
        background: transparent; border: none; font-size: 1rem; font-weight: bold;
        color: #64748b; padding: 6px 16px; cursor: pointer; border-radius: 4px; transition: all 0.2s;
    }
    .modal-tab-btn.active { background: #1b6ef3; color: #fff; }
    .modal-close {
        background: transparent; border: none; font-size: 1.5rem; cursor: pointer; color: #64748b; line-height: 1U;
    }
    .modal-close:hover { color: #0f172a; }
    
    .modal-body {
        padding: 20px; font-size: 0.9rem; color: #334155; max-height: 70vh; overflow-y: auto;
    }
    .tab-pane { display: none; flex-direction: column; gap: 12px; }
    .tab-pane.active { display: flex; }

    .modal-row { display: flex; gap: 12px; line-height: 1.5; }
    .modal-row strong { min-width: 95px; color: #64748b; text-align: right; flex-shrink: 0; }
    .modal-row span { word-break: break-all; flex: 1; color: #1e293b; }

    /* 編集フォーム用スタイル */
    .form-group { display: flex; flex-direction: column; gap: 4px; }
    .form-group label { font-weight: bold; color: #475569; font-size: 0.85rem; }
    .form-control {
        width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 4px;
        font-size: 0.9rem; box-sizing: border-box; color: #1e293b;
    }
    .form-control:focus { outline: none; border-color: #1b6ef3; }
    .form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .modal-footer {
        padding: 12px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px;
    }
    .btn-save { background: #1b6ef3; color: #fff; border: none; padding: 8px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; }
    .btn-save:hover { background: #1557b0; }

    .week-container { flex: 1; display: flex; flex-direction: column; background: #fff; overflow: hidden; }
    .week-grid-body { flex: 1; overflow-y: auto; position: relative; min-height: 400px; display: flex; flex-direction: column; background: #fff; }
    .week-grid-header { display: grid; grid-template-columns: repeat(7, 1fr); background: #f8f9fa; border-bottom: 2px solid #64748b; position: sticky; top: 0; z-index: 20; flex-shrink: 0; }
    .week-bg-grid-wrapper { position: relative; flex: 1; min-height: 400px; display: flex; flex-direction: column; }
    .week-bg-grid { position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: grid; grid-template-columns: repeat(7, 1fr); pointer-events: none; z-index: 1; }
    .week-bg-col { border-right: 1px solid #64748b; box-sizing: border-box; }
    .week-bg-col:last-child { border-right: none; }
    .week-bg-col:nth-child(6) { background-color: var(--saturday-bg); }
    .week-bg-col:nth-child(7) { background-color: var(--sunday-bg); }
    .week-task-container { position: absolute; top: 0; left: 0; right: 0; bottom: 0; z-index: 2; pointer-events: none; }
    .week-task-bar {
        position: absolute; height: 44px; border: 2px solid; border-radius: 4px; padding: 4px 8px;
        box-sizing: border-box; font-size: 0.78rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        display: flex; flex-direction: column; justify-content: center; gap: 2px; cursor: pointer; pointer-events: auto;
    }
    .week-task-bar:hover { z-index: 10; box-shadow: 0 3px 8px rgba(0,0,0,0.12); }
    .week-task-title { font-weight: bold; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: flex; align-items: center; gap: 4px; color: #333; }
    .week-task-info { font-size: 0.7rem; opacity: 0.85; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #333; }
    .today-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; padding: 20px; overflow-y: auto; height: 100%; align-content: flex-start; background: #fafbfc; }
    .no-task-msg { padding: 30px; text-align: center; color: #888; font-size: 1.1rem; grid-column: 1 / -1; }
    .today-card { background: #fff; border: 1px solid #64748b; border-radius: 6px; padding: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.05); border-left-width: 5px; border-left-style: solid; }
    .today-card .proj-label { font-size: 0.75rem; color: #666; margin-bottom: 6px; display: flex; align-items: center; gap: 4px; font-weight: bold; }
    .today-card .card-title { font-size: 0.95rem; font-weight: bold; margin: 0 0 8px 0; color: #222; line-height: 1.3; }
    .today-card .card-meta { font-size: 0.8rem; color: #555; display: flex; flex-direction: column; gap: 4px; }
</style>
</head>
<body class="theme-default">

	<div class="app-container">
		<%@ include file="common/sidebar.jsp" %>

		<main class="main-content">
			<%@ include file="common/header.jsp" %>

			<div class="content-body">
				<div class="calendar-container">
					<div class="calendar-header">
						<h2 style="margin:0; font-size:1.3rem;">カレンダー</h2>
						
						<div class="filter-section">
							<!-- 1行目: 案件フィルター -->
							<div class="filter-group">
								<span class="filter-label">案件:</span>
								<div id="projectLegends" style="display: flex; flex-wrap: wrap; gap: 8px;"></div>
							</div>
							
							<!-- 2行目: 担当者フィルター（左側） と 今日/週/月ボタン（右側） -->
							<div class="filter-group-row2">
								<div class="filter-group">
									<span class="filter-label">担当者:</span>
									<button type="button" id="myTaskBtn" class="my-task-btn" onclick="toggleMyTask()">自分のタスク</button>
									<div id="assigneeLegends" style="display: flex; flex-wrap: wrap; gap: 8px;"></div>
								</div>
								
								<div class="view-switch">
									<button id="btn-today" type="button" onclick="changeView('today')">今日</button>
									<button id="btn-week" type="button" onclick="changeView('week')">週</button>
									<button id="btn-month" type="button" class="active" onclick="changeView('month')">月</button>
								</div>
							</div>
						</div>

						<!-- 日付ナビゲーション -->
						<div class="date-nav-wrapper">
							<button type="button" onclick="changeDate(-1)">&lt;</button>
							<div class="month-nav" id="displayDateText">2026年10月</div>
							<button type="button" onclick="changeDate(1)">&gt;</button>
						</div>
					</div>

					<div id="view-month" class="view-wrapper active">
						<div id="calendarBody" class="grid-body-scroll">
							<div class="grid-header">
								<div class="day-name">月</div><div class="day-name">火</div><div class="day-name">水</div><div class="day-name">木</div>
								<div class="day-name">金</div><div class="day-name saturday">土</div><div class="day-name sunday">日</div>
							</div>
						</div>
					</div>

					<div id="view-week" class="view-wrapper">
						<div class="week-container">
							<div class="week-grid-body">
								<div id="weekHeaderGrid" class="week-grid-header"></div>
								<div class="week-bg-grid-wrapper">
									<div id="weekBgGrid" class="week-bg-grid">
										<div class="week-bg-col"></div><div class="week-bg-col"></div><div class="week-bg-col"></div>
										<div class="week-bg-col"></div><div class="week-bg-col"></div><div class="week-bg-col"></div>
										<div class="week-bg-col"></div>
									</div>
									<div id="weekTaskContainer" class="week-task-container"></div>
								</div>
							</div>
						</div>
					</div>

					<div id="view-today" class="view-wrapper">
						<div id="todayBody" class="today-grid"></div>
					</div>
				</div>
			</div>

			<%@ include file="common/footer.jsp" %>
		</main>
	</div>

    <!-- タスク詳細・編集モーダル -->
    <div id="taskModal" class="modal-overlay" style="display: none;" onclick="closeModalOnBackdrop(event)">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-tabs">
                    <button type="button" id="tabBtnDetail" class="modal-tab-btn active" onclick="switchModalTab('detail')">詳細</button>
                    <button type="button" id="tabBtnEdit" class="modal-tab-btn" onclick="switchModalTab('edit')">編集</button>
                </div>
                <button type="button" class="modal-close" onclick="closeModal()">×</button>
            </div>
            
            <div class="modal-body">
                <!-- 1. 詳細タブ -->
                <div id="tabPaneDetail" class="tab-pane active">
                    <div class="modal-row"><strong>タスク名：</strong><span id="modalTaskName"></span></div>
                    <div class="modal-row"><strong>プロジェクト：</strong><span id="modalProjName"></span></div>
                    <div class="modal-row"><strong>説明：</strong><span id="modalDesc"></span></div>
                    <div class="modal-row"><strong>担当者：</strong><span id="modalAssignee"></span></div>
                    <div class="modal-row"><strong>タグ：</strong><span id="modalTag"></span></div>
                    <div class="modal-row"><strong>状態：</strong><span id="modalStatus"></span></div>
                    <div class="modal-row"><strong>優先度：</strong><span id="modalPriority"></span></div>
                    <div class="modal-row"><strong>開始日：</strong><span id="modalStartDate"></span></div>
                    <div class="modal-row"><strong>期限：</strong><span id="modalDueDate"></span></div>
                </div>

                <!-- 2. 編集タブ -->
                <div id="tabPaneEdit" class="tab-pane">
                    <form id="editTaskForm" action="TaskUpdateServlet" method="post">
                        <input type="hidden" id="editTaskId" name="taskId">
                        <div class="form-group">
                            <label>タスク名</label>
                            <input type="text" id="editTaskName" name="taskName" class="form-control" required>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label>プロジェクト</label>
                            <select id="editProjectId" name="projectId" class="form-control">
                                <% for (Map<String, String> p : projList) { %>
                                    <option value="<%= p.get("rawId") %>"><%= p.get("name") %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label>説明</label>
                            <textarea id="editDescription" name="description" class="form-control" rows="3"></textarea>
                        </div>
                        <div class="form-row-2" style="margin-top: 10px;">
                            <div class="form-group">
                                <label>状態</label>
                                <select id="editStatus" name="status" class="form-control">
                                    <option value="未着手">未着手</option>
                                    <option value="進行中">進行中</option>
                                    <option value="完了">完了</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>優先度</label>
                                <select id="editPriority" name="priority" class="form-control">
                                    <option value="高">高</option>
                                    <option value="中">中</option>
                                    <option value="低">低</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-row-2" style="margin-top: 10px;">
                            <div class="form-group">
                                <label>開始日</label>
                                <input type="date" id="editStartDate" name="startDate" class="form-control">
                            </div>
                            <div class="form-group">
                                <label>期限</label>
                                <input type="date" id="editDueDate" name="dueDate" class="form-control">
                            </div>
                        </div>
                        <div class="form-group" style="margin-top: 10px;">
                            <label>タグ</label>
                            <input type="text" id="editTag" name="tag" class="form-control">
                        </div>
                    </form>
                </div>
            </div>

            <div id="modalFooter" class="modal-footer" style="display: none;">
                <button type="button" class="btn-save" onclick="saveTask()">保存する</button>
            </div>
        </div>
    </div>

    <!-- 週ごとの隠れタスク一覧ポップアップモーダル -->
    <div id="moreTasksModal" class="modal-overlay" style="display: none;" onclick="closeMoreModalOnBackdrop(event)">
        <div class="modal-content" style="width: 420px;">
            <div class="modal-header">
                <h3 style="margin:0; font-size:1.05rem; color:#1e293b;">該当週のタスク一覧</h3>
                <button type="button" class="modal-close" onclick="closeMoreModal()">×</button>
            </div>
            <div class="modal-body" id="moreTasksBody" style="display: flex; flex-direction: column; gap: 8px;">
                <!-- JSで動的生成 -->
            </div>
        </div>
    </div>

<script>
    const projects = [
        <% for (int i = 0; i < projList.size(); i++) {
            Map<String, String> p = projList.get(i); %>
            { id: "<%= p.get("id") %>", rawId: "<%= p.get("rawId") %>", name: "<%= p.get("name") %>", color: "<%= p.get("color") %>" }<%= (i < projList.size() - 1) ? "," : "" %>
        <% } %>
    ];

    const users = [
        <% for (int i = 0; i < userList.size(); i++) {
            Map<String, String> u = userList.get(i); %>
            { id: "<%= u.get("id") %>", name: "<%= u.get("name") %>" }<%= (i < userList.size() - 1) ? "," : "" %>
        <% } %>
    ];

    const tasks = [
        <% for (int i = 0; i < taskList.size(); i++) {
            Map<String, String> t = taskList.get(i); %>
            {
                id: "<%= t.get("id") %>",
                rawProjectId: "<%= t.get("rawProjectId") %>",
                projectId: "<%= t.get("projectId") %>",
                name: "<%= t.get("name") %>",
                description: "<%= t.get("description") %>",
                priority: "<%= t.get("priority") %>",
                tag: "<%= t.get("tag") %>",
                assignee: "<%= t.get("assignee") %>",
                startDate: "<%= t.get("startDate") %>",
                dueDate: "<%= t.get("dueDate") %>",
                status: "<%= t.get("status") %>",
                isCompleted: <%= "完了".equals(t.get("status")) %>
            }<%= (i < taskList.size() - 1) ? "," : "" %>
        <% } %>
    ];
    
    const loginUserName = "<%= loginUserName %>";
    const actualToday = new Date(2026, 9, 21);
    
    let baseDate = new Date(actualToday);
    let currentView = 'month';
    let activeProjectId = null; 
    let activeAssignee = null;  

    function toggleMyTask() {
        if (!loginUserName) {
            alert("ログインユーザー情報が見つかりません。");
            return;
        }
        if (activeAssignee === loginUserName) {
            activeAssignee = null; 
        } else {
            activeAssignee = loginUserName; 
        }
        renderAll();
    }

    function getDateDiffInDays(dateA, dateB) {
        const a = new Date(dateA.getFullYear(), dateA.getMonth(), dateA.getDate());
        const b = new Date(dateB.getFullYear(), dateB.getMonth(), dateB.getDate());
        return Math.round((a - b) / (1000 * 60 * 60 * 24));
    }

    function changeView(view) {
        currentView = view;
        if (view === 'today') baseDate = new Date(actualToday);
        document.querySelectorAll('.view-switch button').forEach(b => b.classList.remove('active'));
        const btn = document.getElementById('btn-' + view);
        if (btn) btn.classList.add('active');
        document.querySelectorAll('.view-wrapper').forEach(el => el.classList.remove('active'));
        const viewEl = document.getElementById('view-' + view);
        if (viewEl) viewEl.classList.add('active');
        renderAll();
    }

    function changeDate(offset) {
        if (currentView === 'month') baseDate.setMonth(baseDate.getMonth() + offset);
        else if (currentView === 'week') baseDate.setDate(baseDate.getDate() + (offset * 7));
        else if (currentView === 'today') baseDate.setDate(baseDate.getDate() + offset);
        renderAll();
    }

    function toggleProjectFilter(projectId) {
        activeProjectId = activeProjectId === projectId ? null : projectId;
        renderAll();
    }

    function toggleAssigneeFilter(assigneeName) {
        activeAssignee = activeAssignee === assigneeName ? null : assigneeName;
        renderAll();
    }

    function renderAll() {
        try {
            renderFilters();
            updateHeaderDateText();
            if (currentView === 'month') renderMonthView();
            if (currentView === 'week') renderWeekView();
            if (currentView === 'today') renderTodayView();
        } catch (e) {
            console.error("renderAll Error:", e);
        }
    }

    function renderFilters() {
        const projContainer = document.getElementById('projectLegends');
        if (projContainer) {
            projContainer.innerHTML = projects.map(p => {
                const stateClass = activeProjectId ? (activeProjectId === p.id ? 'active' : 'inactive') : '';
                return '<div class="legend-item ' + stateClass + '" onclick="toggleProjectFilter(\'' + p.id + '\')">' +
                            '<span style="color: ' + p.color + '; font-size: 1.1rem; line-height: 1;">■</span>' +
                            '<span>' + p.name + '</span>' +
                        '</div>';
            }).join('');
        }

        const myTaskBtn = document.getElementById('myTaskBtn');
        if (myTaskBtn) {
            if (loginUserName && activeAssignee === loginUserName) {
                myTaskBtn.classList.add('active');
            } else {
                myTaskBtn.classList.remove('active');
            }
        }

        const assigneeContainer = document.getElementById('assigneeLegends');
        if (assigneeContainer) {
            assigneeContainer.innerHTML = users.map(u => {
                const stateClass = activeAssignee ? (activeAssignee === u.name ? 'active' : 'inactive') : '';
                return '<div class="assignee-item ' + stateClass + '" onclick="toggleAssigneeFilter(\'' + u.name + '\')">' +
                            '<span>' + u.name + '</span>' +
                        '</div>';
            }).join('');
        }
    }

    function updateHeaderDateText() {
        const textEl = document.getElementById('displayDateText');
        if (!textEl) return;
        const y = baseDate.getFullYear(), m = baseDate.getMonth() + 1, d = baseDate.getDate();

        if (currentView === 'month') {
            textEl.innerText = y + "年 " + m + "月";
        } else if (currentView === 'week') {
            const wStart = getWeekStart(baseDate);
            const wEnd = new Date(wStart);
            wEnd.setDate(wStart.getDate() + 6);
            textEl.innerText = (wStart.getMonth() + 1) + "月" + wStart.getDate() + "日 〜 " + (wEnd.getMonth() + 1) + "月" + wEnd.getDate() + "日";
        } else if (currentView === 'today') {
            textEl.innerText = y + "年 " + m + "月 " + d + "日";
        }
    }

    function getFilteredTasks() {
        return tasks.filter(task => {
            const matchProj = activeProjectId ? task.projectId === activeProjectId : true;
            const matchAssignee = activeAssignee ? task.assignee.includes(activeAssignee) : true;
            return matchProj && matchAssignee;
        });
    }

    function getTasksForDate(targetDate) {
        const filtered = getFilteredTasks();
        const targetTime = new Date(targetDate).setHours(0,0,0,0);
        return filtered.filter(task => {
            if (!task.startDate || !task.dueDate) return false;
            const st = new Date(task.startDate).setHours(0,0,0,0);
            const en = new Date(task.dueDate).setHours(0,0,0,0);
            return targetTime >= st && targetTime <= en;
        });
    }

    function getTaskStatusClass(task) {
        if (task.isCompleted) return "status-completed";
        if (task.dueDate) {
            const dueDateObj = new Date(task.dueDate);
            dueDateObj.setHours(0,0,0,0);
            const todayObj = new Date(actualToday);
            todayObj.setHours(0,0,0,0);
            if (dueDateObj < todayObj) {
                return "status-overdue";
            }
        }
        return "status-normal";
    }

    function getWeekStart(date) {
        const d = new Date(date);
        let dayOfWeek = d.getDay() - 1;
        if (dayOfWeek < 0) dayOfWeek = 6;
        d.setDate(d.getDate() - dayOfWeek);
        d.setHours(0,0,0,0);
        return d;
    }

    // モーダル関連
    function switchModalTab(tabName) {
        document.querySelectorAll('.modal-tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));

        if (tabName === 'detail') {
            document.getElementById('tabBtnDetail').classList.add('active');
            document.getElementById('tabPaneDetail').classList.add('active');
            document.getElementById('modalFooter').style.display = 'none';
        } else {
            document.getElementById('tabBtnEdit').classList.add('active');
            document.getElementById('tabPaneEdit').classList.add('active');
            document.getElementById('modalFooter').style.display = 'flex';
        }
    }

    function openTaskModal(taskId, event) {
        if (event) event.stopPropagation();
        const task = tasks.find(t => t.id === String(taskId));
        if (!task) return;

        const project = projects.find(p => p.id === task.projectId);

        document.getElementById('modalTaskName').innerText = task.name || '（未設定）';
        document.getElementById('modalProjName').innerText = project ? project.name : 'その他';
        document.getElementById('modalDesc').innerText = task.description || '（なし）';
        document.getElementById('modalAssignee').innerText = task.assignee || '未設定';
        document.getElementById('modalTag').innerText = task.tag || '（なし）';
        document.getElementById('modalStatus').innerText = task.status || '未着手';
        document.getElementById('modalPriority').innerText = task.priority || '中';
        document.getElementById('modalStartDate').innerText = task.startDate || '未設定';
        document.getElementById('modalDueDate').innerText = task.dueDate || '未設定';

        document.getElementById('editTaskId').value = task.id;
        document.getElementById('editTaskName').value = task.name || '';
        document.getElementById('editProjectId').value = task.rawProjectId || '';
        document.getElementById('editDescription').value = task.description || '';
        document.getElementById('editStatus').value = task.status || '未着手';
        document.getElementById('editPriority').value = task.priority || '中';
        document.getElementById('editStartDate').value = task.startDate || '';
        document.getElementById('editDueDate').value = task.dueDate || '';
        document.getElementById('editTag').value = task.tag || '';

        switchModalTab('detail');
        document.getElementById('taskModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('taskModal').style.display = 'none';
    }

    function closeModalOnBackdrop(event) {
        if (event.target.id === 'taskModal') {
            closeModal();
        }
    }

    const weekHiddenTasksMap = {};

    function openMoreTasksModal(weekIndex) {
        const list = weekHiddenTasksMap[weekIndex] || [];
        const bodyEl = document.getElementById('moreTasksBody');
        bodyEl.innerHTML = list.map(t => {
            const project = projects.find(p => p.id === t.projectId);
            const projColor = project ? project.color : '#ccc';
            return '<div style="padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 4px; background: #f8fafc; cursor: pointer; display: flex; flex-direction: column; gap: 4px;" onclick="closeMoreModal(); openTaskModal(\'' + t.id + '\', event)">' +
                   '<div style="font-size:0.75rem; font-weight:bold; color:#555;"><span style="color:' + projColor + ';">■</span> ' + (project ? project.name : 'その他') + '</div>' +
                   '<div style="font-size:0.9rem; font-weight:bold; color:#1e293b;">' + t.name + '</div>' +
                   '<div style="font-size:0.75rem; color:#64748b;">[期間] ' + t.startDate + ' 〜 ' + t.dueDate + '</div>' +
                   '</div>';
        }).join('');
        document.getElementById('moreTasksModal').style.display = 'flex';
    }

    function closeMoreModal() {
        document.getElementById('moreTasksModal').style.display = 'none';
    }

    function closeMoreModalOnBackdrop(event) {
        if (event.target.id === 'moreTasksModal') {
            closeMoreModal();
        }
    }

    function saveTask() {
        const form = document.getElementById('editTaskForm');
        if (form.checkValidity()) {
            form.submit();
        } else {
            form.reportValidity();
        }
    }

    function renderMonthView() {
        const gridBody = document.getElementById('calendarBody');
        if (!gridBody) return;
        const headerEl = gridBody.querySelector('.grid-header');
        gridBody.innerHTML = '';
        if (headerEl) gridBody.appendChild(headerEl);

        const filteredTasks = getFilteredTasks();

        let startDate = new Date(baseDate.getFullYear(), baseDate.getMonth(), 1);
        let dayOfWeek = startDate.getDay() - 1;
        if (dayOfWeek < 0) dayOfWeek = 6;
        startDate.setDate(startDate.getDate() - dayOfWeek);

        // 1つの週行に表示できる最大タスク数（日付と被らないよう余裕を持たせる）
        const MAX_SLOTS = 3;

        for (let w = 0; w < 6; w++) {
            const weekStart = new Date(startDate);
            weekStart.setDate(startDate.getDate() + (w * 7));
            const weekEnd = new Date(weekStart);
            weekEnd.setDate(weekStart.getDate() + 6);

            weekHiddenTasksMap[w] = [];

            let weekHtml = '<div class="week-row">';
            for (let d = 0; d < 7; d++) {
                const cellDate = new Date(weekStart);
                cellDate.setDate(weekStart.getDate() + d);
                const isToday = cellDate.getTime() === actualToday.getTime();
                const isCurrentMonth = cellDate.getMonth() === baseDate.getMonth();
                const cellClass = isCurrentMonth ? 'day-cell' : 'day-cell other-month';

                weekHtml += '<div class="' + cellClass + '"><span class="date-number ' + (isToday ? 'today-mark':'') + '">' + cellDate.getDate() + '</span></div>';
            }

            weekHtml += '<div class="task-bar-container">';
            const slots = Array(7).fill(0);

            filteredTasks.forEach(task => {
                if (!task.startDate || !task.dueDate) return;
                const tStart = new Date(task.startDate);
                const tEnd = new Date(task.dueDate);

                if (tEnd >= weekStart && tStart <= weekEnd) {
                    const drawStartIdx = Math.max(0, getDateDiffInDays(tStart, weekStart));
                    const drawEndIdx = Math.min(6, getDateDiffInDays(tEnd, weekStart));
                    const spanDays = drawEndIdx - drawStartIdx + 1;

                    let slotIndex = 0;
                    while (true) {
                        let fit = true;
                        for (let i = drawStartIdx; i <= drawEndIdx; i++) {
                            if ((slots[i] & (1 << slotIndex)) !== 0) { fit = false; break; }
                        }
                        if (fit) {
                            for (let i = drawStartIdx; i <= drawEndIdx; i++) slots[i] |= (1 << slotIndex);
                            break;
                        }
                        slotIndex++;
                    }

                    // 最大スロット数を超える場合は非表示にして「+〇件」用に保存
                    if (slotIndex >= MAX_SLOTS) {
                        if (!weekHiddenTasksMap[w].some(t => t.id === task.id)) {
                            weekHiddenTasksMap[w].push(task);
                        }
                        return;
                    }

                    const project = projects.find(p => p.id === task.projectId);
                    const statClass = getTaskStatusClass(task);

                    weekHtml += '<div class="task-bar ' + statClass + '" ' +
                                'style="left: calc(' + ((drawStartIdx/7)*100) + '% + 2px); width: calc(' + ((spanDays/7)*100) + '% - 4px); --slot: ' + slotIndex + ';" ' +
                                'onclick="openTaskModal(\'' + task.id + '\', event)">' +
                                '<div class="task-header">' +
                                '<span class="project-square" style="color: ' + (project ? project.color : '#ccc') + ';">■</span>' +
                                '<span class="task-name">' + task.name + '</span>' +
                                '</div></div>';
                }
            });

            // 溢れたタスクがある場合、一番左下の分かりやすい位置（上の週に属することが明確な位置）に「+〇件」を表示
            if (weekHiddenTasksMap[w].length > 0) {
                const hiddenCount = weekHiddenTasksMap[w].length;
                weekHtml += '<div class="more-badge" style="left: 6px; top: ' + (MAX_SLOTS * 24 + 2) + 'px;" onclick="openMoreTasksModal(' + w + ')">' +
                            '+ ' + hiddenCount + ' 件' +
                            '</div>';
            }

            weekHtml += '</div></div>';
            gridBody.innerHTML += weekHtml;
        }
    }

    function renderWeekView() {
        const weekHeaderGrid = document.getElementById('weekHeaderGrid');
        const weekTaskContainer = document.getElementById('weekTaskContainer');
        if (!weekHeaderGrid || !weekTaskContainer) return;
        weekHeaderGrid.innerHTML = '';
        weekTaskContainer.innerHTML = '';

        const weekStart = getWeekStart(baseDate);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 6);
        weekEnd.setHours(23,59,59,999);

        const daysStr = ["月", "火", "水", "木", "金", "土", "日"];
        
        for (let i = 0; i < 7; i++) {
            const currentDay = new Date(weekStart);
            currentDay.setDate(weekStart.getDate() + i);
            const isToday = currentDay.setHours(0,0,0,0) === actualToday.setHours(0,0,0,0);
            const isSat = (i === 5);
            const isSun = (i === 6);
            
            let colorStyle = isToday ? 'color:var(--theme-color); font-weight:bold;' : '';
            if (isSat) colorStyle = 'color: #1d4ed8;';
            if (isSun) colorStyle = 'color: #b91c1c;';

            weekHeaderGrid.innerHTML += '<div class="day-name ' + (isSat?'saturday':'') + ' ' + (isSun?'sunday':'') + '" style="' + colorStyle + '">' +
                (currentDay.getMonth() + 1) + '/' + currentDay.getDate() + ' (' + daysStr[i] + ')' +
                '</div>';
        }

        const filteredTasks = getFilteredTasks();
        const visibleTasks = filteredTasks.filter(task => {
            if (!task.startDate || !task.dueDate) return false;
            const tStart = new Date(task.startDate).setHours(0,0,0,0);
            const tEnd = new Date(task.dueDate).setHours(0,0,0,0);
            return tEnd >= weekStart.getTime() && tStart <= weekEnd.getTime();
        });

        const slots = Array(7).fill(0);
        
        visibleTasks.forEach(task => {
            const tStart = new Date(task.startDate);
            const tEnd = new Date(task.dueDate);

            const drawStartIdx = Math.max(0, getDateDiffInDays(tStart, weekStart));
            const drawEndIdx = Math.min(6, getDateDiffInDays(tEnd, weekStart));
            const spanDays = drawEndIdx - drawStartIdx + 1;

            let slotIndex = 0;
            while (true) {
                let fit = true;
                for (let i = drawStartIdx; i <= drawEndIdx; i++) {
                    if ((slots[i] & (1 << slotIndex)) !== 0) { fit = false; break; }
                }
                if (fit) {
                    for (let i = drawStartIdx; i <= drawEndIdx; i++) slots[i] |= (1 << slotIndex);
                    break;
                }
                slotIndex++;
            }

            const project = projects.find(p => p.id === task.projectId);
            const statClass = getTaskStatusClass(task);
            const topPos = (slotIndex * 50) + 8;

            weekTaskContainer.innerHTML += '<div class="week-task-bar ' + statClass + '" ' +
                'style="left: calc(' + ((drawStartIdx / 7) * 100) + '% + 2px); width: calc(' + ((spanDays / 7) * 100) + '% - 4px); top: ' + topPos + 'px;" ' +
                'onclick="openTaskModal(\'' + task.id + '\', event)">' +
                '<div class="week-task-title"><span style="color: ' + (project ? project.color : '#ccc') + ';">■</span> ' + task.name + '</div>' +
                '<div class="week-task-info">' + task.assignee + ' | [期間] ' + task.startDate.slice(5).replace('-','/') + '〜' + task.dueDate.slice(5).replace('-','/') + '</div>' +
                '</div>';
        });
    }

    function renderTodayView() {
        const todayBody = document.getElementById('todayBody');
        if (!todayBody) return;
        const dayTasks = getTasksForDate(baseDate);
        
        if (dayTasks.length === 0) {
            todayBody.innerHTML = '<div class="no-task-msg">条件に一致する進行中のタスクはありません</div>';
            return;
        }

        todayBody.innerHTML = dayTasks.map(task => {
            const project = projects.find(p => p.id === task.projectId);
            const projColor = project ? project.color : '#ccc';
            return '<div class="today-card" style="border-left-color: ' + projColor + '; cursor: pointer;" onclick="openTaskModal(\'' + task.id + '\', event)">' +
                   '<div class="proj-label"><span style="color: ' + projColor + ';">■</span> ' + (project ? project.name : 'その他') + '</div>' +
                   '<h4 class="card-title">' + task.name + '</h4>' +
                   '<div class="card-meta">' +
                   '<span>[担当] <b>' + task.assignee + '</b></span>' +
                   '<span>[期間] ' + task.startDate.slice(5).replace('-','/') + ' ～ ' + task.dueDate.slice(5).replace('-','/') + '</span>' +
                   '</div></div>';
        }).join('');
    }

    document.addEventListener('DOMContentLoaded', () => {
        renderAll();
    });
    
    renderAll();
</script>
</body>
</html>