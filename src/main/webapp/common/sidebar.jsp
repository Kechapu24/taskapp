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

    <%-- サイドバーの最下部に、常にユーザー表示を出す
         ログイン中: アイコン付きのユーザーボタン(ホバーで、右側に情報カード)
         未ログイン: これまでの「アカウント情報」ボタン --%>
    <div class="sidebar-user">
        <% if (session.getAttribute("loginUser") != null) { %>
            <jsp:include page="/common/user_badge.jsp" />
           
        <% } %>
    </div>
</aside>
