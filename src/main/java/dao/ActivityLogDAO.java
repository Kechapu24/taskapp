package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.ActivityLog;
import util.DBConnection;

public class ActivityLogDAO {

    public List<ActivityLog> findAll() {

        List<ActivityLog> logs = new ArrayList<>();

        String sql =
            "SELECT " +
            "a.log_id, " +
            "u.user_name, " +
            "a.action, " +
            "a.detail, " +
            "a.created_at " +
            "FROM activity_log a " +
            "LEFT JOIN users u " +
            "ON a.user_id = u.user_id " +
            "ORDER BY a.created_at DESC";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                logs.add(
                    new ActivityLog(
                        rs.getInt("log_id"),
                        rs.getString("user_name"),
                        rs.getString("action"),
                        rs.getString("detail"),
                        rs.getTimestamp("created_at")
                    )
                );

            }

        } catch (Exception e) {

            e.printStackTrace();

        }

        return logs;
    }

    public List<ActivityLog> findByUserId(int userId) {

        return findAll();

    }

    public List<ActivityLog> findByOrgId(int orgId) {

        return findAll();

    }
}