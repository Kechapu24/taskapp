package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Notification;

public class NotificationDAO {

    // ==============================
    // データベース接続情報
    // ==============================
    private static final String URL =
            "jdbc:postgresql://172.16.1.119:5432/taskapp";

    private static final String USER =
            "taskuser";

    private static final String PASSWORD =
            "taskpass";


    // ==============================
    // PostgreSQLドライバ読み込み
    // ==============================
    public NotificationDAO() {

        try {

            Class.forName("org.postgresql.Driver");

        } catch (ClassNotFoundException e) {

            e.printStackTrace();

        }

    }


    // ==================================================
    // ① 通知一覧を取得
    // ==================================================
    public List<Notification> getNotifications(int userId) {

        List<Notification> notifications = new ArrayList<>();

        String sql =
                "SELECT "
              + "n.notification_id, "
              + "n.user_id, "
              + "n.project_id, "
              + "n.task_id, "
              + "n.type, "
              + "n.message, "
              + "n.is_read, "
              + "n.created_at, "
              + "t.task_name, "
              + "p.project_name "
              + "FROM notification n "
              + "LEFT JOIN task t "
              + "ON n.task_id = t.task_id "
              + "LEFT JOIN project p "
              + "ON n.project_id = p.project_id "
              + "WHERE n.user_id = ? "
              + "ORDER BY n.created_at DESC";


        try (
                Connection conn =
                        DriverManager.getConnection(
                                URL, USER, PASSWORD);

                PreparedStatement ps =
                        conn.prepareStatement(sql)
        ) {

            // ユーザーIDを設定
            ps.setInt(1, userId);


            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Notification notification =
                            new Notification();


                    notification.setNotificationId(
                            rs.getInt("notification_id")
                    );

                    notification.setUserId(
                            rs.getInt("user_id")
                    );

                    notification.setProjectId(
                            rs.getInt("project_id")
                    );

                    notification.setTaskId(
                            rs.getInt("task_id")
                    );

                    notification.setType(
                            rs.getString("type")
                    );

                    notification.setMessage(
                            rs.getString("message")
                    );

                    notification.setIsRead(
                            rs.getBoolean("is_read")
                    );

                    notification.setCreatedAt(
                            rs.getTimestamp("created_at")
                    );


                    // JOINで取得したタスク名
                    notification.setTaskName(
                            rs.getString("task_name")
                    );

                    // JOINで取得したプロジェクト名
                    notification.setProjectName(
                            rs.getString("project_name")
                    );


                    notifications.add(notification);

                }

            }

        } catch (SQLException e) {

            e.printStackTrace();

        }


        return notifications;

    }


    // ==================================================
    // ② 通知を登録
    // ==================================================
    public boolean insertNotification(
            int userId,
            int projectId,
            int taskId,
            String type,
            String message) {


        String sql =
                "INSERT INTO notification "
              + "(user_id, project_id, task_id, type, message) "
              + "VALUES (?, ?, ?, ?, ?)";


        try (
                Connection conn =
                        DriverManager.getConnection(
                                URL, USER, PASSWORD);

                PreparedStatement ps =
                        conn.prepareStatement(sql)
        ) {


            ps.setInt(1, userId);

            ps.setInt(2, projectId);

            ps.setInt(3, taskId);

            ps.setString(4, type);

            ps.setString(5, message);


            int result = ps.executeUpdate();


            return result > 0;


        } catch (SQLException e) {

            e.printStackTrace();

            return false;

        }

    }


    // ==================================================
    // ③ 未読通知の件数を取得
    // ==================================================
    public int getUnreadCount(int userId) {


        String sql =
                "SELECT COUNT(*) "
              + "FROM notification "
              + "WHERE user_id = ? "
              + "AND is_read = false";


        try (
                Connection conn =
                        DriverManager.getConnection(
                                URL, USER, PASSWORD);

                PreparedStatement ps =
                        conn.prepareStatement(sql)
        ) {


            ps.setInt(1, userId);


            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    return rs.getInt(1);

                }

            }


        } catch (SQLException e) {

            e.printStackTrace();

        }


        return 0;

    }


    // ==================================================
    // ④ 通知を既読にする
    // ==================================================
    public boolean markAsRead(
            int notificationId,
            int userId) {


        String sql =
                "UPDATE notification "
              + "SET is_read = true "
              + "WHERE notification_id = ? "
              + "AND user_id = ?";


        try (
                Connection conn =
                        DriverManager.getConnection(
                                URL, USER, PASSWORD);

                PreparedStatement ps =
                        conn.prepareStatement(sql)
        ) {


            ps.setInt(1, notificationId);

            ps.setInt(2, userId);


            int result = ps.executeUpdate();


            return result > 0;


        } catch (SQLException e) {

            e.printStackTrace();

            return false;

        }

    }

}