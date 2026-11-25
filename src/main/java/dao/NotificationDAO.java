
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.Notification;
import util.DBConnection;

public class NotificationDAO {

    // 通知一覧を取得
    public List<Notification> getNotifications(int userId) {

        List<Notification> notifications = new ArrayList<>();

        String sql =
            "SELECT n.notification_id, n.type, n.message, " +
            "t.task_name, p.project_name, n.created_at, n.is_read " +
            "FROM notification n " +
            "LEFT JOIN task t ON n.task_id = t.task_id " +
            "LEFT JOIN project p ON n.project_id = p.project_id " +
            "WHERE n.user_id = ? " +
            "ORDER BY n.created_at DESC";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(new Notification(
                        rs.getInt("notification_id"),
                        rs.getString("type"),
                        rs.getString("message"),
                        rs.getString("task_name"),
                        rs.getString("project_name"),
                        rs.getTimestamp("created_at"),
                        rs.getBoolean("is_read")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("通知一覧の取得に失敗しました", e);
        }

        return notifications;
    }

    // タスク作成時に担当者へ通知
    public boolean notifyTaskCreated(
            int userId,
            int projectId,
            int taskId,
            String taskName) {

    	String sql =
    		    "SELECT n.notification_id, n.type, n.message, " +
    		    "t.task_name, " +
    		    "COALESCE(o.org_name, p.project_name) AS project_name, " +
    		    "n.created_at, n.is_read " +
    		    "FROM notification n " +
    		    "LEFT JOIN task t ON n.task_id = t.task_id " +
    		    "LEFT JOIN project p ON n.project_id = p.project_id " +
    		    "LEFT JOIN organization o ON n.org_id = o.org_id " +
    		    "WHERE n.user_id = ? " +
    		    "ORDER BY n.created_at DESC";

        String message =
            "タスク「" + taskName + "」の担当者に設定されました。";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);
            ps.setInt(2, projectId);
            ps.setInt(3, taskId);
            ps.setString(4, "担当者になりました");
            ps.setString(5, message);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
public boolean createOrganizationNotification(
        int userId, int orgId, String type, String message) {

    String sql =
        "INSERT INTO notification " +
        "(user_id, org_id, type, message, is_read, created_at) " +
        "VALUES (?, ?, ?, ?, FALSE, CURRENT_TIMESTAMP)";

    try (
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql)
    ) {
        ps.setInt(1, userId);
        ps.setInt(2, orgId);
        ps.setString(3, type);
        ps.setString(4, message);

        return ps.executeUpdate() > 0;

    } catch (Exception e) {
        throw new RuntimeException("団体通知の登録に失敗しました", e);
    }
    public int notifyOrganizationMembers(
            int orgId,
            int excludedUserId,
            String type,
            String message) {

        String sql =
            "INSERT INTO notification " +
            "(user_id, org_id, type, message, is_read, created_at) " +
            "SELECT user_id, ?, ?, ?, FALSE, CURRENT_TIMESTAMP " +
            "FROM org_member " +
            "WHERE org_id = ? AND user_id <> ?";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, orgId);
            ps.setString(2, type);
            ps.setString(3, message);
            ps.setInt(4, orgId);
            ps.setInt(5, excludedUserId);

            return ps.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("メンバー通知の登録に失敗しました", e);
        }
    }
}