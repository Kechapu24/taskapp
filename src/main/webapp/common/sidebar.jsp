<%@ page pageEncoding="UTF-8" %>

<aside class="sidebar">
    <div class="sidebar-brand">タスク管理</div>

    <ul class="sidebar-menu">
        <li class="menu-item ${currentPage == 'index' ? 'active' : ''}">
            <a href="index.jsp">ダッシュボード</a>
        </li>

        <li class="menu-item ${currentPage == 'projects' ? 'active' : ''}">
            <a href="projects.jsp">プロジェクト一覧</a>
        </li>

        <li class="menu-item ${currentPage == 'taskboard' ? 'active' : ''}">
            <a href="taskboard.jsp">タスクボード</a>
        </li>

        <li class="menu-item ${currentPage == 'settings' ? 'active' : ''}">
            <a href="settings.jsp">設定</a>
        </li>

        <li class="menu-item ${currentPage == 'mytasks' ? 'active' : ''}">
            <a href="mytasks.jsp">マイタスク</a>
        </li>

        <li class="menu-item ${currentPage == 'notifications' ? 'active' : ''}">
            <a href="notifications.jsp">通知センター</a>
        </li>

        <li class="menu-item ${currentPage == 'logs' ? 'active' : ''}">
            <a href="logs.jsp">ログ</a>
        </li>
    </ul>
</aside>