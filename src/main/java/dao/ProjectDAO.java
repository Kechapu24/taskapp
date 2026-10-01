

package dao;
 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import util.DBConnection;
 
public class ProjectDAO {
 
    /** 指定org_idに紐づくプロジェクト一覧を取得する */
    public List<Map<String, Object>> getProjectsByOrg(int orgId) {
        String sql = "SELECT project_id, project_name, description " +
                     "FROM project WHERE org_id = ? ORDER BY project_id";
 
        List<Map<String, Object>> result = new ArrayList<>();
 
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
 
            stmt.setInt(1, orgId);
 
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("projectId", rs.getInt("project_id"));
                    row.put("projectName", rs.getString("project_name"));
                    row.put("description", rs.getString("description"));
                    result.add(row);
                }
            }
 
        } catch (SQLException e) {
            throw new RuntimeException("プロジェクト一覧の取得中にDBエラーが発生しました", e);
        }
 
        return result;
    }
}
 
