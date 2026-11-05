package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import model.ActivityLog;
import util.DBConnection;

public class ActivityLogDAO {

    private static final String BASE_SELECT =
        "SELECT " +
        "a.log_id, " +
        "u.user_name, " +
        "a.action, " +
        "a.detail, " +
        "a.created_at " +
        "FROM activity_log a " +
        "LEFT JOIN users u " +
        "ON a.user_id = u.user_id ";

    private static final String ORDER_BY =
        "ORDER BY a.created_at DESC";

    /** 全件（管理用） */
    public List<ActivityLog> findAll() {
        return query(BASE_SELECT + ORDER_BY, null);
    }

    /** 個人モード：自分が個人として行った操作のみ（団体での操作は含めない） */
    public List<ActivityLog> findByUserId(int userId) {
        return query(
            BASE_SELECT
                + "WHERE a.user_id = ? AND a.org_id IS NULL "
                + ORDER_BY,
            userId);
    }

    /** 団体モード：その団体で行われた全メンバーの操作 */
    public List<ActivityLog> findByOrgId(int orgId) {
        return query(
            BASE_SELECT
                + "WHERE a.org_id = ? "
                + ORDER_BY,
            orgId);
    }

    /**
     * ログ記録。
     * orgId が null なら個人モードでの操作として保存する。
     */
    public void insert(int userId, Integer orgId, String action, String detail) {

        String sql =
            "INSERT INTO activity_log " +
            "(user_id, org_id, action, detail, created_at) " +
            "VALUES (?, ?, ?, ?, NOW())";

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            if (orgId == null) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, orgId);
            }

            ps.setString(3, action);
            ps.setString(4, detail);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 共通の検索処理（param が null なら条件なし） */
    private List<ActivityLog> query(String sql, Integer param) {

        List<ActivityLog> logs = new ArrayList<>();

        try (
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {

            if (param != null) {
                ps.setInt(1, param);
            }

            try (ResultSet rs = ps.executeQuery()) {

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
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return logs;
    }
}
