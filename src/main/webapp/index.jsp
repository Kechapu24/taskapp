<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>タスクカレンダー</title>
<style>
    :root {
        --sidebar-bg: #2c3e50;
        --sidebar-hover: #34495e;
        --main-bg: #f5f7fa;
        --border-color: #64748b; 
        --theme-color: #1b6ef3;
        --saturday-bg: #c0d9ff; /* 土曜日：しっかりした青（キープ） */
        --sunday-bg: #fbc4c4;   /* 日曜日：しっかりした赤（キープ） */
    }

    body { margin: 0; font-family: 'Segoe UI', Meiryo, sans-serif; display: flex; height: 100vh; overflow: hidden; background-color: var(--main-bg); color: #333; }
    
    .sidebar { width: 220px; background-color: var(--sidebar-bg); color: #fff; display: flex; flex-direction: column; z-index: 100; }
    .sidebar-brand { padding: 20px; font-size: 1.2rem; font-weight: bold; border-bottom: 1px solid #1a252f; }
    .sidebar-menu { list-style: none; padding: 0; margin: 0; }
    .sidebar-menu li { padding: 15px 20px; cursor: pointer; border-bottom: 1px solid #1a252f; }
    .sidebar-menu li.active { background-color: var(--sidebar-hover); border-left: 4px solid var(--theme-color); }
    
    .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
    .header { padding: 15px 20px; background: #fff; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; z-index: 10; flex-shrink: 0; }
    
    .calendar-container { padding: 20px; flex: 1; display: flex; flex-direction: column; overflow: hidden; }
    .calendar-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px; flex-shrink: 0; }
    
    /* フィルター領域 */
    .filter-section { display: flex; flex-direction: column; gap: 6px; margin-top: 10px; }
    .filter-group { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
    .filter-label { font-size: 0.8rem; font-weight: bold; color: #555; min-width: 55px; }
    
    .legend-item, .assignee-item { 
        display: flex; align-items: center; gap: 6px; font-size: 0.85rem; padding: 4px 10px; 
        border-radius: 16px; background-color: #fff; border: 1px solid var(--border-color);
        cursor: pointer; user-select: none; transition: all 0.2s;
    }
    .legend-item:hover, .assignee-item:hover { background-color: #f0f4f8; }
    .legend-item.active, .assignee-item.active { background-color: #e8f0fe; border-color: var(--theme-color); font-weight: bold; color: var(--theme-color); }
    .legend-item.inactive, .assignee-item.inactive { opacity: 0.4; background-color: #f9f9f9; }

    /* コントロール周り */
    .calendar-controls { display: flex; flex-direction: column; align-items: flex-end; gap: 10px; }
    
    .view-switch { display: flex; background: #cbd5e1; border-radius: 6px; padding: 3px; }
    .view-switch button { border: none; background: transparent; padding: 6px 16px; cursor: pointer; font-weight: bold; color: #555; border-radius: 4px; transition: 0.2s; }
    .view-switch button:hover { background: #94a3b8; }
    .view-switch button.active { background: #fff; color: var(--theme-color); box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    
    .date-nav-wrapper { display: flex; align-items: center; gap: 15px; }
    .date-nav-wrapper button { background: #fff; border: 1px solid var(--border-color); border-radius: 4px; width: 32px; height: 32px; cursor: pointer; display: flex; justify-content: center; align-items: center; color: #555; transition: 0.2s; }
    .date-nav-wrapper button:hover { background: #f0f4f8; border-color: #94a3b8; }
    .month-nav { font-size: 1.2rem; font-weight: bold; min-width: 180px; text-align: center; }

    .view-wrapper { flex: 1; overflow: hidden; display: none; flex-direction: column; background: #fff; border: 1px solid var(--border-color); border-radius: 6px;}
    .view-wrapper.active { display: flex; }

    /* ==================== ステータスカラー ==================== */
    .status-normal { border-color: #2563eb; background-color: #eff6ff; color: #1e40af; }     
    .status-warning { border-color: #dc2626; background-color: #fef2f2; color: #991b1b; }     
    .status-overdue { border-color: #475569; background-color: #f8fafc; color: #334155; }     
    .status-completed { border-color: #64748b; background-color: #f1f5f9; color: #475569; opacity: 0.85; } 

    /* ==================== 月ビュー ==================== */
    .grid-body-scroll { flex: 1; overflow-y: auto; display: flex; flex-direction: column; position: relative; background: #fff; }

    .grid-header { 
        display: grid; 
        grid-template-columns: repeat(7, 1fr); 
        background: #f8f9fa; 
        border-bottom: 2px solid var(--border-color); 
        position: sticky; 
        top: 0; 
        z-index: 20; 
    }
    .day-name { padding: 10px; text-align: center; font-weight: bold; font-size: 0.9rem; border-right: 1px solid var(--border-color); }
    .day-name:last-child { border-right: none; }
    .day-name.saturday { color: #1d4ed8; background-color: #a5c7fe; } 
    .day-name.sunday { color: #b91c1c; background-color: #f8a5a5; }   
    
    .week-row { 
        position: relative; 
        display: grid; 
        grid-template-columns: repeat(7, 1fr); 
        min-height: 120px; 
        border-bottom: 1px solid var(--border-color); 
    }
    .week-row:last-child { border-bottom: none; }

    .day-cell { border-right: 1px solid var(--border-color); padding: 6px; box-sizing: border-box; }
    .day-cell:last-child { border-right: none; }
    .day-cell:nth-child(6) { background-color: var(--saturday-bg); } 
    .day-cell:nth-child(7) { background-color: var(--sunday-bg); }   

    .day-cell.other-month { opacity: 0.45; }

    .date-number { font-size: 0.85rem; color: #333; display: inline-block; padding: 2px 6px; font-weight: bold; }
    .date-number.today-mark { background: var(--theme-color); color: #fff; border-radius: 12px; }

    .task-bar-container { position: absolute; top: 28px; left: 0; right: 0; bottom: 4px; pointer-events: none; }
    
    .task-bar {
        position: absolute; 
        height: 22px; 
        border: 2px solid; 
        border-radius: 3px;
        padding: 0 5px; 
        box-sizing: border-box; 
        font-size: 0.75rem; 
        background-color: #fff;
        display: flex; 
        align-items: center; 
        cursor: pointer; 
        pointer-events: auto;
        top: calc(var(--slot) * 24px); 
        z-index: 5;
        box-shadow: 0 1px 2px rgba(0,0,0,0.06);
        transition: box-shadow 0.2s;
    }
    .task-bar:hover { box-shadow: 0 2px 6px rgba(0,0,0,0.12); z-index: 10; }

    .task-header { display: flex; align-items: center; gap: 4px; font-weight: bold; width: 100%; pointer-events: none; }
    .project-square { font-size: 0.85rem; flex-shrink: 0; line-height: 1; margin-right: 1px; }
    .task-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; pointer-events: none; }

    /* クリック時のポップアップカード */
    .task-bar.active { 
        z-index: 1000 !important; 
        height: auto !important; 
        min-width: 190px; 
        box-shadow: 0 10px 25px rgba(0,0,0,0.15) !important; 
        background: #ffffff !important; 
        padding: 10px 12px;
        flex-direction: column;
        align-items: flex-start;
        border-radius: 6px;
    }
    .task-bar.active .task-name { 
        white-space: normal; 
        line-height: 1.4; 
        font-size: 0.88rem; 
        font-weight: bold;
        color: #1e293b;
        margin-bottom: 4px;
    }
    .task-details { 
        display: none; 
        margin-top: 6px; 
        padding-top: 6px; 
        border-top: 1px solid #cbd5e1; 
        font-size: 0.78rem; 
        line-height: 1.6; 
        color: #334155; 
        width: 100%; 
        pointer-events: none; 
    }
    .task-bar.active .task-details { display: block; }
    .task-detail-row { display: flex; align-items: center; gap: 6px; margin-bottom: 3px; }
    .task-detail-row:last-child { margin-bottom: 0; }
    .task-detail-label { color: #64748b; font-weight: 600; min-width: 35px; }

    /* ==================== 週ビュー ==================== */
    .week-container { flex: 1; display: flex; flex-direction: column; background: #fff; overflow: hidden; }
    .week-grid-body { flex: 1; overflow-y: auto; position: relative; min-height: 400px; display: flex; flex-direction: column; background: #fff; }
    
    .week-grid-header { 
        display: grid; 
        grid-template-columns: repeat(7, 1fr); 
        background: #f8f9fa; 
        border-bottom: 2px solid var(--border-color); 
        position: sticky; 
        top: 0; 
        z-index: 20; 
        flex-shrink: 0; 
    }

    .week-bg-grid-wrapper { position: relative; flex: 1; min-height: 400px; display: flex; flex-direction: column; }
    .week-bg-grid { position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: grid; grid-template-columns: repeat(7, 1fr); pointer-events: none; z-index: 1; }
    .week-bg-col { border-right: 1px solid var(--border-color); box-sizing: border-box; }
    .week-bg-col:last-child { border-right: none; }
    .week-bg-col:nth-child(6) { background-color: var(--saturday-bg); }
    .week-bg-col:nth-child(7) { background-color: var(--sunday-bg); }

    .week-task-container { position: absolute; top: 0; left: 0; right: 0; bottom: 0; z-index: 2; pointer-events: none; }
    
    .week-task-bar {
        position: absolute;
        height: 44px;
        border: 2px solid;
        border-radius: 4px;
        padding: 4px 8px;
        box-sizing: border-box;
        font-size: 0.78rem;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        display: flex;
        flex-direction: column;
        justify-content: center;
        gap: 2px;
        cursor: pointer;
        pointer-events: auto;
    }
    .week-task-bar:hover { z-index: 10; box-shadow: 0 3px 8px rgba(0,0,0,0.12); }
    .week-task-title { font-weight: bold; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: flex; align-items: center; gap: 4px; }
    .week-task-info { font-size: 0.7rem; opacity: 0.85; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* ==================== 今日ビュー ==================== */
    .today-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 15px; padding: 20px; overflow-y: auto; height: 100%; align-content: flex-start; background: #fafbfc; }
    .no-task-msg { padding: 30px; text-align: center; color: #888; font-size: 1.1rem; grid-column: 1 / -1; }
    
    .today-card { background: #fff; border: 1px solid var(--border-color); border-radius: 6px; padding: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.05); border-left-width: 5px; border-left-style: solid; }
    .today-card .proj-label { font-size: 0.75rem; color: #666; margin-bottom: 6px; display: flex; align-items: center; gap: 4px; font-weight: bold; }
    .today-card .card-title { font-size: 0.95rem; font-weight: bold; margin: 0 0 8px 0; color: #222; line-height: 1.3; }
    .today-card .card-meta { font-size: 0.8rem; color: #555; display: flex; flex-direction: column; gap: 4px; }
</style>
</head>
<body>

<aside class="sidebar">
    <div class="sidebar-brand">タスク管理</div>
    <ul class="sidebar-menu">
        <li class="active">タスクカレンダー</li>
    </ul>
</aside>

<main class="main-content">
    <header class="header">
        <h1>ダッシュボード</h1>
    </header>

    <div class="calendar-container">
        <div class="calendar-header">
            <div>
                <h2 style="margin:0 0 5px 0; font-size:1.3rem;">タスク状況</h2>
                <div class="filter-section">
                    <div class="filter-group">
                        <span class="filter-label">案件:</span>
                        <div id="projectLegends" style="display: flex; flex-wrap: wrap; gap: 8px;"></div>
                    </div>
                    <div class="filter-group">
                        <span class="filter-label">担当者:</span>
                        <div id="assigneeLegends" style="display: flex; flex-wrap: wrap; gap: 8px;"></div>
                    </div>
                </div>
            </div>
            
            <div class="calendar-controls">
                <div class="view-switch">
                    <button id="btn-today" onclick="changeView('today')">今日</button>
                    <button id="btn-week" onclick="changeView('week')">週</button>
                    <button id="btn-month" class="active" onclick="changeView('month')">月</button>
                </div>
                <div class="date-nav-wrapper">
                    <button onclick="changeDate(-1)">&#9664;</button>
                    <div class="month-nav" id="displayDateText">2026年10月</div>
                    <button onclick="changeDate(1)">&#9654;</button>
                </div>
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
</main>

<script>
    const actualToday = new Date(2026, 9, 8); // 2026年10月8日
    
    let baseDate = new Date(actualToday);
    let currentView = 'month';
    let activeProjectId = null; 
    let activeAssignee = null;  

    const projects = [
        { id: 'proj-portal', name: '社内ポータル', color: '#1b6ef3' },
        { id: 'proj-inventory', name: '在庫管理', color: '#20c997' },
        { id: 'proj-attendance', name: '勤怠管理', color: '#fd7e14' },
        { id: 'proj-customer', name: '顧客管理', color: '#6f42c1' }
    ];

    const tasks = [
        { id: 1, projectId: 'proj-portal', name: "要件定義書の作成（完了）", assignee: "山田", startDate: "2026-10-01", dueDate: "2026-10-04", isCompleted: true },
        { id: 2, projectId: 'proj-inventory', name: "DB設計の修正", assignee: "佐藤", startDate: "2026-10-04", dueDate: "2026-10-06", isCompleted: false },
        { id: 3, projectId: 'proj-portal', name: "トップ画面レイアウト実装", assignee: "高橋", startDate: "2026-10-06", dueDate: "2026-10-08", isCompleted: false },
        { id: 4, projectId: 'proj-inventory', name: "在庫一覧画面のテスト", assignee: "伊藤", startDate: "2026-10-06", dueDate: "2026-10-09", isCompleted: false },
        { id: 5, projectId: 'proj-attendance', name: "勤怠データ連携API作成", assignee: "加藤", startDate: "2026-10-07", dueDate: "2026-10-12", isCompleted: false },
        { id: 6, projectId: 'proj-customer', name: "顧客情報移行スクリプト", assignee: "中村", startDate: "2026-10-09", dueDate: "2026-10-15", isCompleted: false },
        { id: 7, projectId: 'proj-portal', name: "デザインレビュー会議", assignee: "山田", startDate: "2026-10-08", dueDate: "2026-10-08", isCompleted: false },
        { id: 8, projectId: 'proj-inventory', name: "倉庫マスターメンテナンス", assignee: "佐藤", startDate: "2026-10-11", dueDate: "2026-10-14", isCompleted: false },
        { id: 9, projectId: 'proj-attendance', name: "打刻ウィジェット修正", assignee: "渡辺", startDate: "2026-10-13", dueDate: "2026-10-16", isCompleted: false },
        { id: 10, projectId: 'proj-portal', name: "ユーザー権限管理機能", assignee: "高橋", startDate: "2026-10-14", dueDate: "2026-10-20", isCompleted: false },
        { id: 11, projectId: 'proj-customer', name: "顧客検索クエリ最適化", assignee: "中村", startDate: "2026-10-16", dueDate: "2026-10-19", isCompleted: false },
        { id: 12, projectId: 'proj-inventory', name: "棚卸しレポート出力機能", assignee: "伊藤", startDate: "2026-10-19", dueDate: "2026-10-23", isCompleted: false },
        { id: 13, projectId: 'proj-attendance', name: "有給申請フロー承認テスト", assignee: "加藤", startDate: "2026-10-21", dueDate: "2026-10-26", isCompleted: false },
        { id: 14, projectId: 'proj-portal', name: "総合結合テスト実施", assignee: "山田", startDate: "2026-10-26", dueDate: "2026-10-30", isCompleted: false }
    ];

    function getDateDiffInDays(dateA, dateB) {
        const a = new Date(dateA.getFullYear(), dateA.getMonth(), dateA.getDate());
        const b = new Date(dateB.getFullYear(), dateB.getMonth(), dateB.getDate());
        return Math.round((a - b) / (1000 * 60 * 60 * 24));
    }

    function changeView(view) {
        currentView = view;
        if (view === 'today') baseDate = new Date(actualToday);
        document.querySelectorAll('.view-switch button').forEach(b => b.classList.remove('active'));
        document.getElementById(`btn-${view}`).classList.add('active');
        document.querySelectorAll('.view-wrapper').forEach(el => el.classList.remove('active'));
        document.getElementById(`view-${view}`).classList.add('active');
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
        renderFilters();
        updateHeaderDateText();
        if (currentView === 'month') renderMonthView();
        if (currentView === 'week') renderWeekView();
        if (currentView === 'today') renderTodayView();
    }

    function renderFilters() {
        const projContainer = document.getElementById('projectLegends');
        projContainer.innerHTML = projects.map(p => {
            const stateClass = activeProjectId ? (activeProjectId === p.id ? 'active' : 'inactive') : '';
            return `<div class="legend-item ${stateClass}" onclick="toggleProjectFilter('${p.id}')">
                        <span style="color: ${p.color}; font-size: 1.1rem; line-height: 1;">■</span>
                        <span>${p.name}</span>
                    </div>`;
        }).join('');

        const assignees = [...new Set(tasks.map(t => t.assignee))];
        const assigneeContainer = document.getElementById('assigneeLegends');
        assigneeContainer.innerHTML = assignees.map(name => {
            const stateClass = activeAssignee ? (activeAssignee === name ? 'active' : 'inactive') : '';
            return `<div class="assignee-item ${stateClass}" onclick="toggleAssigneeFilter('${name}')">
                        <span>🧑‍💻 ${name}</span>
                    </div>`;
        }).join('');
    }

    function updateHeaderDateText() {
        const textEl = document.getElementById('displayDateText');
        const y = baseDate.getFullYear(), m = baseDate.getMonth() + 1, d = baseDate.getDate();

        if (currentView === 'month') {
            textEl.innerText = `${y}年 ${m}月`;
        } else if (currentView === 'week') {
            const wStart = getWeekStart(baseDate);
            const wEnd = new Date(wStart);
            wEnd.setDate(wStart.getDate() + 6);
            textEl.innerText = `${wStart.getMonth() + 1}月${wStart.getDate()}日 〜 ${wEnd.getMonth() + 1}月${wEnd.getDate()}日`;
        } else if (currentView === 'today') {
            textEl.innerText = `${y}年 ${m}月 ${d}日`;
        }
    }

    function getFilteredTasks() {
        return tasks.filter(task => {
            const matchProj = activeProjectId ? task.projectId === activeProjectId : true;
            const matchAssignee = activeAssignee ? task.assignee === activeAssignee : true;
            return matchProj && matchAssignee;
        });
    }

    function getTasksForDate(targetDate) {
        const filtered = getFilteredTasks();
        const targetTime = new Date(targetDate).setHours(0,0,0,0);
        return filtered.filter(task => {
            const st = new Date(task.startDate).setHours(0,0,0,0);
            const en = new Date(task.dueDate).setHours(0,0,0,0);
            return targetTime >= st && targetTime <= en;
        });
    }

    function getTaskStatusClass(task) {
        if (task.isCompleted) return "status-completed";
        if (new Date(task.dueDate).setHours(0,0,0,0) < actualToday.setHours(0,0,0,0)) return "status-overdue";
        if (new Date(task.dueDate).setHours(0,0,0,0) - actualToday.setHours(0,0,0,0) <= 86400000) return "status-warning";
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

    function renderMonthView() {
        const gridBody = document.getElementById('calendarBody');
        const headerEl = gridBody.querySelector('.grid-header');
        gridBody.innerHTML = '';
        gridBody.appendChild(headerEl);

        const filteredTasks = getFilteredTasks();

        let startDate = new Date(baseDate.getFullYear(), baseDate.getMonth(), 1);
        let dayOfWeek = startDate.getDay() - 1;
        if (dayOfWeek < 0) dayOfWeek = 6;
        startDate.setDate(startDate.getDate() - dayOfWeek);

        for (let w = 0; w < 6; w++) {
            const weekStart = new Date(startDate);
            weekStart.setDate(startDate.getDate() + (w * 7));
            const weekEnd = new Date(weekStart);
            weekEnd.setDate(weekStart.getDate() + 6);

            let weekHtml = `<div class="week-row">`;
            for (let d = 0; d < 7; d++) {
                const cellDate = new Date(weekStart);
                cellDate.setDate(weekStart.getDate() + d);
                const isToday = cellDate.getTime() === actualToday.getTime();
                const isCurrentMonth = cellDate.getMonth() === baseDate.getMonth();
                const cellClass = isCurrentMonth ? 'day-cell' : 'day-cell other-month';

                weekHtml += `<div class="${cellClass}"><span class="date-number ${isToday ? 'today-mark':''}">${cellDate.getDate()}</span></div>`;
            }

            weekHtml += `<div class="task-bar-container">`;
            const slots = Array(7).fill(0);

            filteredTasks.forEach(task => {
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

                    const project = projects.find(p => p.id === task.projectId);
                    const statClass = getTaskStatusClass(task);

                    weekHtml += `
                        <div class="task-bar ${statClass}" 
                             style="left: calc(${(drawStartIdx/7)*100}% + 2px); width: calc(${(spanDays/7)*100}% - 4px); --slot: ${slotIndex};"
                             onclick="toggleTaskActive(this, event)">
                            <div class="task-header">
                                <span class="project-square" style="color: ${project ? project.color : '#ccc'};">■</span>
                                <span class="task-name">${task.name}</span>
                            </div>
                            <div class="task-details">
                                <div class="task-detail-row">
                                    <span>👤</span><span class="task-detail-label">担当:</span>
                                    <span style="font-weight: 600; color: #1e293b;">${task.assignee}</span>
                                </div>
                                <div class="task-detail-row">
                                    <span>📅</span><span class="task-detail-label">期間:</span>
                                    <span>${task.startDate.slice(5).replace('-','/')} ～ ${task.dueDate.slice(5).replace('-','/')}</span>
                                </div>
                            </div>
                        </div>
                    `;
                }
            });
            weekHtml += `</div></div>`;
            gridBody.innerHTML += weekHtml;
        }
    }

    function toggleTaskActive(element, event) {
        event.stopPropagation();
        const isActive = element.classList.contains('active');
        document.querySelectorAll('.task-bar.active').forEach(el => el.classList.remove('active'));
        if (!isActive) element.classList.add('active');
    }
    document.addEventListener('click', () => {
        document.querySelectorAll('.task-bar.active').forEach(el => el.classList.remove('active'));
    });

    function renderWeekView() {
        const weekHeaderGrid = document.getElementById('weekHeaderGrid');
        const weekTaskContainer = document.getElementById('weekTaskContainer');
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

            weekHeaderGrid.innerHTML += `
                <div class="day-name ${isSat?'saturday':''} ${isSun?'sunday':''}" style="${colorStyle}">
                    ${currentDay.getMonth() + 1}/${currentDay.getDate()} (${daysStr[i]})
                </div>
            `;
        }

        const filteredTasks = getFilteredTasks();
        const visibleTasks = filteredTasks.filter(task => {
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
            const topPos = slotIndex * 50 + 8;

            weekTaskContainer.innerHTML += `
                <div class="week-task-bar ${statClass}"
                     style="left: calc(${(drawStartIdx / 7) * 100}% + 2px); width: calc(${(spanDays / 7) * 100}% - 4px); top: ${topPos}px;">
                    <div class="week-task-title">
                        <span style="color: ${project ? project.color : '#ccc'};">■</span> ${task.name}
                    </div>
                    <div class="week-task-info">
                        🧑‍💻 ${task.assignee} | 📅 ${task.startDate.slice(5).replace('-','/')}〜${task.dueDate.slice(5).replace('-','/')}
                    </div>
                </div>
            `;
        });
    }

    function renderTodayView() {
        const todayBody = document.getElementById('todayBody');
        const dayTasks = getTasksForDate(baseDate);
        
        if (dayTasks.length === 0) {
            todayBody.innerHTML = `<div class="no-task-msg">条件に一致する進行中のタスクはありません🎉</div>`;
            return;
        }

        todayBody.innerHTML = dayTasks.map(task => {
            const project = projects.find(p => p.id === task.projectId);
            const projColor = project ? project.color : '#ccc';
            return `
                <div class="today-card" style="border-left-color: ${projColor};">
                    <div class="proj-label">
                        <span style="color: ${projColor};">■</span> ${project ? project.name : 'その他'}
                    </div>
                    <h4 class="card-title">${task.name}</h4>
                    <div class="card-meta">
                        <span>🧑‍💻 担当: <b>${task.assignee}</b></span>
                        <span>📅 期間: ${task.startDate.slice(5).replace('-','/')} ～ ${task.dueDate.slice(5).replace('-','/')}</span>
                    </div>
                </div>
            `;
        }).join('');
    }

    renderAll();
</script>
</body>
</html>