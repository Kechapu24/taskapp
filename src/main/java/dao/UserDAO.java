package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.User;
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

    /**
     * 新規ユーザーを登録する。role は指定せず、DBの初期値('member')に任せる。
     * 戻り値: 登録できたら true、emailが重複していたら false。
     */
    public boolean insert(String userName, String email, String password) {
        String sql = "INSERT INTO users (user_name, email, password) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, userName);
            stmt.setString(2, email);
            stmt.setString(3, password);
            stmt.executeUpdate();
            return true;

        } catch (SQLException e) {
            // 23505 = UNIQUE制約違反(同じemailが既にある)
            if ("23505".equals(e.getSQLState())) {
                return false;
            }
            throw new RuntimeException("ユーザー登録中にDBエラーが発生しました", e);
        }
    }
}