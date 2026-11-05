package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import model.TaskFilter;
import util.DBConnection;

public class TaskDAO {

    /**
     * タスクボードに表示するタスクを取得する。
     *
     * activeOrgId == null
     *   → 個人モード（project.user_id）
     *
     * activeOrgId != null
     *   → 団体モード（project.org_id）
     *
     * 検索・絞り込み条件は TaskFilter から受け取る。
     */
    public List<Map<String, Object>> getTasksForBoard(
            int loginUserId,
            Integer activeOrgId,
            TaskFilter filter) {

        List<Map<String, Object>> result = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        StringBuilder sql = new StringBuilder();

        sql.append(
              "SELECT "
            + "t.task_id, "
            + "t.task_name, "
            + "t.description, "
            + "t.status, "
            + "t.priority, "
            + "t.start_date, "
            + "t.due_date, "
            + "p.project_id, "
            + "p.project_name, "
            + "COALESCE(string_agg(DISTINCT u.user_name, ', '), '未設定') AS assignees, "
            + "COALESCE(string_agg(DISTINCT c.comment_text, '<br>'), 'コメントなし') AS comments, "
            + "COALESCE(string_agg(DISTINCT a.file_name, '<br>'), '添付なし') AS files, "
            + "COALESCE(string_agg(DISTINCT tg.tag_name, ', '), 'タグなし') AS tags "
            + "FROM task t "
            + "JOIN project p ON t.project_id = p.project_id "
            + "LEFT JOIN task_assignee ta ON t.task_id = ta.task_id "
            + "LEFT JOIN users u ON ta.user_id = u.user_id "
            + "LEFT JOIN comment c ON t.task_id = c.task_id "
            + "LEFT JOIN attachment a ON t.task_id = a.task_id "
            + "LEFT JOIN task_tag tt ON t.task_id = tt.task_id "
            + "LEFT JOIN tag tg ON tt.tag_id = tg.tag_id "
            + "WHERE 1 = 1 "
        );

        // モードによる表示範囲
        if (activeOrgId == null) {
            sql.append("AND p.user_id = ? ");
            params.add(loginUserId);
        } else {
            sql.append("AND p.org_id = ? ");
            params.add(activeOrgId);
        }

        // タスク名
        if (hasText(filter.getKeyword())) {
            sql.append("AND t.task_name ILIKE ? ");
            params.add("%" + filter.getKeyword().trim() + "%");
        }

        // プロジェクト
        Integer projectId = parseInteger(filter.getProjectId());

        if (projectId != null) {
            sql.append("AND t.project_id = ? ");
            params.add(projectId);
        }

        // 担当者
        Integer userId = parseInteger(filter.getUserId());

        if (userId != null) {
            sql.append(
                  "AND EXISTS ("
                + "SELECT 1 "
                + "FROM task_assignee ta2 "
                + "WHERE ta2.task_id = t.task_id "
                + "AND ta2.user_id = ?"
                + ") "
            );

            params.add(userId);
        }

        // タグID
        Integer tagId = parseInteger(filter.getTagId());

        if (tagId != null) {
            sql.append(
                  "AND EXISTS ("
                + "SELECT 1 "
                + "FROM task_tag tt2 "
                + "WHERE tt2.task_id = t.task_id "
                + "AND tt2.tag_id = ?"
                + ") "
            );

            params.add(tagId);
        }

        // タグ名検索
        if (hasText(filter.getTagKeyword())) {
            sql.append(
                  "AND EXISTS ("
                + "SELECT 1 "
                + "FROM task_tag tt3 "
                + "JOIN tag tg3 ON tt3.tag_id = tg3.tag_id "
                + "WHERE tt3.task_id = t.task_id "
                + "AND tg3.tag_name ILIKE ?"
                + ") "
            );

            params.add("%" + filter.getTagKeyword().trim() + "%");
        }

        // 優先度
        if (hasText(filter.getPriority())) {
            sql.append("AND t.priority = ? ");
            params.add(filter.getPriority());
        }

        // 期限
        if ("overdue".equals(filter.getDeadline())) {

            sql.append("AND t.due_date < CURRENT_DATE ");

        } else if ("today".equals(filter.getDeadline())) {

            sql.append("AND t.due_date = CURRENT_DATE ");

        } else if ("week".equals(filter.getDeadline())) {

            sql.append(
                "AND t.due_date BETWEEN CURRENT_DATE "
              + "AND CURRENT_DATE + INTERVAL '7 days' "
            );
        }

        sql.append(
              "GROUP BY "
            + "t.task_id, "
            + "t.task_name, "
            + "t.description, "
            + "t.status, "
            + "t.priority, "
            + "t.start_date, "
            + "t.due_date, "
            + "p.project_id, "
            + "p.project_name "
        );

        // 並び替え
        if ("due_desc".equals(filter.getSort())) {

            sql.append("ORDER BY t.due_date DESC NULLS LAST");

        } else if ("priority".equals(filter.getSort())) {

            sql.append(
                  "ORDER BY CASE t.priority "
                + "WHEN '高' THEN 1 "
                + "WHEN '中' THEN 2 "
                + "WHEN '低' THEN 3 "
                + "ELSE 4 END, "
                + "t.due_date ASC NULLS LAST"
            );

        } else if ("name".equals(filter.getSort())) {

            sql.append("ORDER BY t.task_name ASC");

        } else {

            sql.append("ORDER BY t.due_date ASC NULLS LAST");
        }

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement stmt =
                conn.prepareStatement(sql.toString())
        ) {

            for (int i = 0; i < params.size(); i++) {

                Object value = params.get(i);

                if (value instanceof Integer) {
                    stmt.setInt(i + 1, (Integer) value);
                } else {
                    stmt.setString(i + 1, (String) value);
                }
            }

            try (ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> task =
                        new LinkedHashMap<>();

                    task.put(
                        "taskId",
                        rs.getInt("task_id")
                    );

                    task.put(
                        "taskName",
                        rs.getString("task_name")
                    );

                    task.put(
                        "description",
                        rs.getString("description")
                    );

                    task.put(
                        "status",
                        rs.getString("status")
                    );

                    task.put(
                        "priority",
                        rs.getString("priority")
                    );

                    task.put(
                        "startDate",
                        rs.getDate("start_date")
                    );

                    task.put(
                        "dueDate",
                        rs.getDate("due_date")
                    );

                    task.put(
                        "projectId",
                        rs.getInt("project_id")
                    );

                    task.put(
                        "projectName",
                        rs.getString("project_name")
                    );

                    task.put(
                        "assignees",
                        rs.getString("assignees")
                    );

                    task.put(
                        "comments",
                        rs.getString("comments")
                    );

                    task.put(
                        "files",
                        rs.getString("files")
                    );

                    task.put(
                        "tags",
                        rs.getString("tags")
                    );

                    result.add(task);
                }
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "タスク一覧取得中にDBエラーが発生しました",
                e
            );
        }

        return result;
    }

    private boolean hasText(String value) {
        return value != null
            && !value.trim().isEmpty();
    }

    private Integer parseInteger(String value) {

        if (!hasText(value)) {
            return null;
        }

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}