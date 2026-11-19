
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.Notification;
import util.DBConnection;

public class NotificationDAO {

    /**
     * 指定したユーザーの通知一覧を取得する
     */
    public List<Notification> getNotifications(int userId) {

        List<Notification> notifications = new ArrayList<>();

        String sql =
            "SELECT " +
            "n.notification_id, " +
            "n.type, " +
            "n.message, " +
            "t.task_name, " +
            "p.project_name, " +
            "n.created_at, " +
            "n.is_read " +
            "FROM notification n " +
            "LEFT JOIN task t " +
            "ON n.task_id = t.task_id " +
            "LEFT JOIN project p " +
            "ON n.project_id = p.project_id " +
            "WHERE n.user_id = ? " +
            "ORDER BY n.created_at DESC";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Notification notification =
                        new Notification(
                            rs.getInt("notification_id"),
                            rs.getString("type"),
                            rs.getString("message"),
                            rs.getString("task_name"),
                            rs.getString("project_name"),
                            rs.getTimestamp("created_at"),
                            rs.getBoolean("is_read")
                        );

                    notifications.add(notification);
                }
            }

        } catch (Exception e) {

            e.printStackTrace();

            throw new RuntimeException(
                "通知一覧の取得に失敗しました", e
            );
        }

        return notifications;
    }
}

