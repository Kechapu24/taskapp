<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.Map"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.temporal.ChronoUnit"%>

<%
@SuppressWarnings("unchecked")
Map<String, Object> task =
    (Map<String, Object>)
        request.getAttribute("taskData");

int taskId =
    (Integer) task.get("taskId");

String deadlineClass = "";

java.sql.Date dueDateSql =
    (java.sql.Date) task.get("dueDate");

if (dueDateSql != null) {

    LocalDate today =
        LocalDate.now();

    LocalDate dueDate =
        dueDateSql.toLocalDate();

    long daysLeft =
        ChronoUnit.DAYS.between(
            today,
            dueDate
        );

    if (daysLeft < 0) {

        deadlineClass = "overdue";

    } else if (daysLeft <= 1) {

        deadlineClass =
            "deadline-red";

    } else if (daysLeft <= 3) {

        deadlineClass =
            "deadline-yellow";
    }
}
%>

<div
    class="task-card <%=deadlineClass%>"
    onclick="showTaskDetail(
        'detail-<%=taskId%>',
        this
    )">

    <div class="task-card-header">

        <h3>
            <%=task.get("taskName")%>
        </h3>

        <div class="task-menu">

            <button
                class="menu-button"
                onclick="
                    toggleTaskMenu(
                        event,
                        'menu-<%=taskId%>'
                    )
                ">
                ⋯
            </button>

            <div
                class="menu-dropdown"
                id="menu-<%=taskId%>">

                <button
                    onclick="
                        openModalFromElement(
                            '詳細',
                            'detail-<%=taskId%>'
                        )
                    ">
                    詳細
                </button>

                <button
                    onclick="
                        openModalFromElement(
                            '編集',
                            'edit-<%=taskId%>'
                        )
                    ">
                    編集
                </button>

                <button
                    class="delete-menu-button"
                    onclick="
                        openModalFromElement(
                            'タスク削除',
                            'delete-<%=taskId%>'
                        )
                    ">
                    削除
                </button>

            </div>

        </div>

    </div>

    <p>
        <%=task.get("projectName")%>
    </p>

    <p>
        <%=task.get("assignees")%>
    </p>

    <div class="task-card-bottom">

        <p>
            <%=task.get("dueDate")%>
        </p>

        <div class="task-card-actions">

            <button
                class="icon-button"
                onclick="
                    event.stopPropagation();
                    openModalFromElement(
                        'コメント',
                        'comment-<%=taskId%>'
                    )
                ">
                💬
            </button>

            <button
                class="icon-button"
                onclick="
                    event.stopPropagation();
                    openModalFromElement(
                        '添付ファイル',
                        'file-<%=taskId%>'
                    )
                ">
                📎
            </button>

        </div>

    </div>


    <!-- 詳細 -->
    <div
        id="detail-<%=taskId%>"
        style="display: none;">

        <p>
            <strong>タスク名：</strong>
            <%=task.get("taskName")%>
        </p>

        <p>
            <strong>プロジェクト：</strong>
            <%=task.get("projectName")%>
        </p>

        <p>
            <strong>説明：</strong>
            <%=task.get("description")%>
        </p>

        <p>
            <strong>担当者：</strong>
            <%=task.get("assignees")%>
        </p>

        <p>
            <strong>タグ：</strong>
            <%=task.get("tags")%>
        </p>

        <p>
            <strong>状態：</strong>
            <%=task.get("status")%>
        </p>

        <p>
            <strong>優先度：</strong>
            <%=task.get("priority")%>
        </p>

        <p>
            <strong>開始日：</strong>
            <%=task.get("startDate")%>
        </p>

        <p>
            <strong>期限：</strong>
            <%=task.get("dueDate")%>
        </p>

    </div>


    <!-- 編集 -->
    <div
        id="edit-<%=taskId%>"
        style="display: none;">

        <form
            class="edit-form"
            action="<%=request.getContextPath()%>/task/taskUpdate.jsp"
            method="post">

            <input
                type="hidden"
                name="task_id"
                value="<%=taskId%>">

            <label>タスク名</label>

            <input
                type="text"
                name="task_name"
                value="<%=task.get("taskName")%>"
                required>

            <label>状態</label>

            <select name="status">

                <option
                    value="未着手"
                    <%="未着手".equals(task.get("status"))
                        ? "selected"
                        : ""%>>
                    未着手
                </option>

                <option
                    value="進行中"
                    <%="進行中".equals(task.get("status"))
                        ? "selected"
                        : ""%>>
                    進行中
                </option>

                <option
                    value="完了"
                    <%="完了".equals(task.get("status"))
                        ? "selected"
                        : ""%>>
                    完了
                </option>

            </select>

            <label>優先度</label>

            <select name="priority">

                <option
                    value="低"
                    <%="低".equals(task.get("priority"))
                        ? "selected"
                        : ""%>>
                    低
                </option>

                <option
                    value="中"
                    <%="中".equals(task.get("priority"))
                        ? "selected"
                        : ""%>>
                    中
                </option>

                <option
                    value="高"
                    <%="高".equals(task.get("priority"))
                        ? "selected"
                        : ""%>>
                    高
                </option>

            </select>

            <label>開始日</label>

            <input
                type="date"
                name="start_date"
                value="<%=task.get("startDate") == null
                    ? ""
                    : task.get("startDate")%>">

            <label>期限</label>

            <input
                type="date"
                name="due_date"
                value="<%=task.get("dueDate") == null
                    ? ""
                    : task.get("dueDate")%>">

            <label>説明</label>

            <textarea
                name="description"><%=task.get("description") == null
                    ? ""
                    : task.get("description")%></textarea>

            <!-- 担当者は次にDB連携へ置換 -->
            <label>担当者</label>

            <select name="user_id">

                <option value="1">伊藤</option>
                <option value="2">高橋</option>
                <option value="3">中村</option>
                <option value="4">小林</option>
                <option value="5">加藤</option>

            </select>

            <button
                type="submit"
                class="modal-submit-btn custom-theme-accent">
                保存
            </button>

        </form>

    </div>


    <!-- 削除 -->
    <div
        id="delete-<%=taskId%>"
        style="display: none;">

        <p>
            <strong>
                <%=task.get("taskName")%>
            </strong>
            を削除してもよろしいですか？
        </p>

        <p
            style="
                color: #777;
                margin-top: 8px;
            ">
            この操作は取り消せません。
        </p>

        <form
            action="<%=request.getContextPath()%>/task/taskDelete.jsp"
            method="post"
            class="delete-form">

            <input
                type="hidden"
                name="task_id"
                value="<%=taskId%>">

            <div class="delete-actions">

                <button
                    type="button"
                    class="cancel-button"
                    onclick="closeModal()">
                    キャンセル
                </button>

                <button
                    type="submit"
                    class="delete-button">
                    削除する
                </button>

            </div>

        </form>

    </div>


    <!-- コメント -->
    <div
        id="comment-<%=taskId%>"
        style="display: none;">

        <p>
            <%=task.get("comments")%>
        </p>

    </div>


    <!-- 添付 -->
    <div
        id="file-<%=taskId%>"
        style="display: none;">

        <p>
            <%=task.get("files")%>
        </p>

    </div>

</div>