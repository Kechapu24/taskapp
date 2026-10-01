
package dao;
 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import util.DBConnection;
 
public class UserDAO {
 
    /**
     * emailだけで検索する(パスワードの一致判定はここではやらない)。
     *
     * パスワードの照合をSQLに書かない理由:
     * 将来パスワードをハッシュ化したとき、SQL側では
     * 「平文の入力値」と「DBに保存されたハッシュ値」を直接比較できないため。
     * 呼び出し側(LoginServlet)でJavaのコードとして照合する。
     */
    public User findByEmail(String email) {
        String sql = "SELECT user_id, user_name, email, password, role " +
                     "FROM users WHERE email = ?";
 
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
 
            stmt.setString(1, email);
 
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new User(
                        rs.getInt("user_id"),
                        rs.getString("user_name"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("role")
                    );
                }
                return null; // 該当するemailが無い
            }
 
        } catch (SQLException e) {
            throw new RuntimeException("ユーザー検索中にDBエラーが発生しました", e);
        }
    }
}
 
