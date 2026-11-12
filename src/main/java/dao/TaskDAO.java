package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
						+ "COALESCE(string_agg(DISTINCT tg.tag_name, ', '), 'タグなし') AS tags, "
						+ "COALESCE(string_agg(DISTINCT tg.tag_id::text, ',' ORDER BY tg.tag_id::text), '') AS tag_ids "
						+ "FROM task t "
						+ "JOIN project p ON t.project_id = p.project_id "
						+ "LEFT JOIN task_assignee ta ON t.task_id = ta.task_id "
						+ "LEFT JOIN users u ON ta.user_id = u.user_id "
						+ "LEFT JOIN comment c ON t.task_id = c.task_id "
						+ "LEFT JOIN attachment a ON t.task_id = a.task_id "
						+ "LEFT JOIN task_tag tt ON t.task_id = tt.task_id "
						+ "LEFT JOIN tag tg ON tt.tag_id = tg.tag_id "
						+ "WHERE 1 = 1 ");

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
							+ ") ");

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
							+ ") ");

			params.add(tagId);
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
							+ "AND CURRENT_DATE + INTERVAL '7 days' ");
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
						+ "p.project_name ");

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
							+ "t.due_date ASC NULLS LAST");

		} else if ("name".equals(filter.getSort())) {

			sql.append("ORDER BY t.task_name ASC");

		} else {

			sql.append("ORDER BY t.due_date ASC NULLS LAST");
		}

		try (
				Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

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

					Map<String, Object> task = new LinkedHashMap<>();

					task.put(
							"taskId",
							rs.getInt("task_id"));

					task.put(
							"taskName",
							rs.getString("task_name"));

					task.put(
							"description",
							rs.getString("description"));

					task.put(
							"status",
							rs.getString("status"));

					task.put(
							"priority",
							rs.getString("priority"));

					task.put(
							"startDate",
							rs.getDate("start_date"));

					task.put(
							"dueDate",
							rs.getDate("due_date"));

					task.put(
							"projectId",
							rs.getInt("project_id"));

					task.put(
							"projectName",
							rs.getString("project_name"));

					task.put(
							"assignees",
							rs.getString("assignees"));

					task.put(
							"comments",
							rs.getString("comments"));

					task.put(
							"files",
							rs.getString("files"));

					task.put(
							"tags",
							rs.getString("tags"));

					task.put(
							"tagIds",
							rs.getString("tag_ids"));

					result.add(task);
				}
			}

		} catch (SQLException e) {

			throw new RuntimeException(
					"タスク一覧取得中にDBエラーが発生しました",
					e);
		}

		return result;
	}

	public List<Map<String, Object>> getTagOptionsForBoard(
			int loginUserId,
			Integer activeOrgId) {

		List<Map<String, Object>> result = new ArrayList<>();

		String sql;

		if (activeOrgId == null) {

			sql = "SELECT tag_id, tag_name, color "
					+ "FROM tag "
					+ "WHERE user_id = ? "
					+ "AND org_id IS NULL "
					+ "ORDER BY tag_name";

		} else {

			sql = "SELECT tag_id, tag_name, color "
					+ "FROM tag "
					+ "WHERE org_id = ? "
					+ "AND user_id IS NULL "
					+ "ORDER BY tag_name";
		}

		try (
				Connection conn = DBConnection.getConnection();

				PreparedStatement stmt = conn.prepareStatement(sql)) {

			if (activeOrgId == null) {
				stmt.setInt(1, loginUserId);
			} else {
				stmt.setInt(1, activeOrgId);
			}

			try (
					ResultSet rs = stmt.executeQuery()) {

				while (rs.next()) {

					Map<String, Object> tag = new LinkedHashMap<>();

					tag.put(
							"tagId",
							rs.getInt("tag_id"));

					tag.put(
							"tagName",
							rs.getString("tag_name"));

					tag.put(
							"color",
							rs.getString("color"));

					result.add(tag);
				}
			}

		} catch (SQLException e) {

			throw new RuntimeException(
					"タグ一覧取得中にDBエラーが発生しました",
					e);
		}

		return result;
	}

	public void replaceTaskTags(
			Connection conn,
			int taskId,
			String[] tagIds,
			String[] newTagNames,
			String[] newTagColors)
			throws SQLException {

		Integer scopeUserId = null;
		Integer scopeOrgId = null;

		// タスク自身の所属スコープを取得
		String scopeSql = "SELECT p.user_id, p.org_id "
				+ "FROM task t "
				+ "JOIN project p "
				+ "ON t.project_id = p.project_id "
				+ "WHERE t.task_id = ?";

		try (
				PreparedStatement stmt = conn.prepareStatement(scopeSql)) {

			stmt.setInt(1, taskId);

			try (
					ResultSet rs = stmt.executeQuery()) {

				if (!rs.next()) {
					throw new SQLException(
							"対象タスクが見つかりません");
				}

				scopeUserId = (Integer) rs.getObject("user_id");

				scopeOrgId = (Integer) rs.getObject("org_id");
			}
		}

		Set<Integer> finalTagIds = new LinkedHashSet<>();

		// 既存タグ
		if (tagIds != null) {

			for (String tagIdStr : tagIds) {

				Integer tagId = parseInteger(tagIdStr);

				if (tagId == null) {
					continue;
				}

				if (!tagBelongsToScope(
						conn,
						tagId,
						scopeUserId,
						scopeOrgId)) {

					throw new SQLException(
							"現在の所属先では使用できないタグです");
				}

				finalTagIds.add(tagId);
			}
		}

		// 新しいタグ
		if (newTagNames != null) {

			for (int i = 0; i < newTagNames.length; i++) {

				String tagName = newTagNames[i];

				if (!hasText(tagName)) {
					continue;
				}

				String color = "#6B7280";

				if (newTagColors != null
						&& i < newTagColors.length
						&& newTagColors[i] != null
						&& newTagColors[i].matches(
								"^#[0-9A-Fa-f]{6}$")) {

					color = newTagColors[i];
				}

				int newTagId = getOrCreateTagId(
						conn,
						tagName.trim(),
						color,
						scopeUserId,
						scopeOrgId);

				finalTagIds.add(newTagId);
			}
		}

		// 現在の関連付けを削除
		String deleteSql = "DELETE FROM task_tag "
				+ "WHERE task_id = ?";

		try (
				PreparedStatement stmt = conn.prepareStatement(deleteSql)) {

			stmt.setInt(1, taskId);
			stmt.executeUpdate();
		}

		// 新しい関連付けを保存
		if (!finalTagIds.isEmpty()) {

			String insertSql = "INSERT INTO task_tag "
					+ "(task_id, tag_id) "
					+ "VALUES (?, ?)";

			try (
					PreparedStatement stmt = conn.prepareStatement(insertSql)) {

				for (Integer tagId : finalTagIds) {

					stmt.setInt(1, taskId);
					stmt.setInt(2, tagId);

					stmt.addBatch();
				}

				stmt.executeBatch();
			}
		}
	}

	private boolean tagBelongsToScope(
			Connection conn,
			int tagId,
			Integer userId,
			Integer orgId)
			throws SQLException {

		String sql;

		if (orgId != null) {

			sql = "SELECT 1 "
					+ "FROM tag "
					+ "WHERE tag_id = ? "
					+ "AND org_id = ? "
					+ "AND user_id IS NULL";

		} else {

			sql = "SELECT 1 "
					+ "FROM tag "
					+ "WHERE tag_id = ? "
					+ "AND user_id = ? "
					+ "AND org_id IS NULL";
		}

		try (
				PreparedStatement stmt = conn.prepareStatement(sql)) {

			stmt.setInt(1, tagId);

			if (orgId != null) {
				stmt.setInt(2, orgId);
			} else {
				stmt.setInt(2, userId);
			}

			try (
					ResultSet rs = stmt.executeQuery()) {

				return rs.next();
			}
		}
	}

	private int getOrCreateTagId(
			Connection conn,
			String tagName,
			String color,
			Integer userId,
			Integer orgId)
			throws SQLException {

		String sql;

		if (orgId != null) {

			sql = "INSERT INTO tag "
					+ "(tag_name, color, user_id, org_id) "
					+ "VALUES (?, ?, NULL, ?) "
					+ "ON CONFLICT (org_id, tag_name) "
					+ "WHERE org_id IS NOT NULL "
					+ "DO UPDATE SET "
					+ "tag_name = EXCLUDED.tag_name "
					+ "RETURNING tag_id";

		} else {

			sql = "INSERT INTO tag "
					+ "(tag_name, color, user_id, org_id) "
					+ "VALUES (?, ?, ?, NULL) "
					+ "ON CONFLICT (user_id, tag_name) "
					+ "WHERE user_id IS NOT NULL "
					+ "DO UPDATE SET "
					+ "tag_name = EXCLUDED.tag_name "
					+ "RETURNING tag_id";
		}

		try (
				PreparedStatement stmt = conn.prepareStatement(sql)) {

			stmt.setString(1, tagName);
			stmt.setString(2, color);

			if (orgId != null) {
				stmt.setInt(3, orgId);
			} else {
				stmt.setInt(3, userId);
			}

			try (
					ResultSet rs = stmt.executeQuery()) {

				if (!rs.next()) {
					throw new SQLException(
							"タグの作成に失敗しました");
				}

				return rs.getInt("tag_id");
			}
		}
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