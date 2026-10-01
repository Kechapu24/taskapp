package dao;
 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Organization;
import util.DBConnection;
 
public class OrgDAO {
 
    /** 指定ユーザーが所属している団体の一覧を取得する */
    public List<Organization> getOrganizationsForUser(int userId) {
        String sql =
            "SELECT o.org_id, o.org_name, om.org_role " +
            "FROM organization o " +
            "JOIN org_member om ON o.org_id = om.org_id " +
            "WHERE om.user_id = ? " +
            "ORDER BY o.org_name";
 
        List<Organization> result = new ArrayList<>();
 
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
 
            stmt.setInt(1, userId);
 
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.add(new Organization(
                        rs.getInt("org_id"),
                        rs.getString("org_name"),
                        rs.getString("org_role")
                    ));
                }
            }
 
        } catch (SQLException e) {
            throw new RuntimeException("団体一覧の取得中にDBエラーが発生しました", e);
        }
 
        return result;
    }
 
    /**
     * 指定ユーザーが指定org_idに本当に所属しているかを確認する。
     * 切り替えボタンで、他人の団体IDを勝手に指定されるのを防ぐために使う。
     */
    public boolean isUserMemberOfOrg(int userId, int orgId) {
        String sql = "SELECT 1 FROM org_member WHERE user_id = ? AND org_id = ?";
 
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
 
            stmt.setInt(1, userId);
            stmt.setInt(2, orgId);
 
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
 
        } catch (SQLException e) {
            throw new RuntimeException("所属確認中にDBエラーが発生しました", e);
        }
    }
}
 
