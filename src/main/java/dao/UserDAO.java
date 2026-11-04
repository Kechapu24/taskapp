package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import model.User;
import model.UserIcon;
import util.DBConnection;

public class UserDAO {

    /**
     * emailだけで検索する(パスワードの一致判定はここではやらない)。
     *
     * パスワードの照合をSQLに書かない理由:
     * 将来パスワードをハッシュ化したとき、SQL側では
     * 「平文の入力値」と「DBに保存されたハッシュ値」を直接比較できないため。
     * 呼び出し側(LoginServlet)でJavaのコードとして照合する。
     *
     * icon_data(画像本体)は重いので読み込まず、
     * 「設定されているか」(icon_set)だけを取得する。
     */
    public User findByEmail(String email) {
        String sql = "SELECT user_id, user_name, email, password, role, " +
                     "(icon_data IS NOT NULL) AS icon_set " +
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
                        rs.getString("role"),
                        rs.getBoolean("icon_set")
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

    /** アイコン画像を保存する(すでにあれば上書き) */
    public void updateIcon(int userId, String contentType, byte[] data) {
        String sql = "UPDATE users SET icon_type = ?, icon_data = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, contentType);
            stmt.setBytes(2, data);
            stmt.setInt(3, userId);
            stmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("アイコンの保存中にDBエラーが発生しました", e);
        }
    }

    /** アイコン画像を削除する(未設定の状態に戻す) */
    public void deleteIcon(int userId) {
        String sql = "UPDATE users SET icon_type = NULL, icon_data = NULL WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("アイコンの削除中にDBエラーが発生しました", e);
        }
    }

    /** アイコン画像を取得する。未設定なら null */
    public UserIcon findIcon(int userId) {
        String sql = "SELECT icon_type, icon_data FROM users " +
                     "WHERE user_id = ? AND icon_data IS NOT NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new UserIcon(rs.getString("icon_type"), rs.getBytes("icon_data"));
                }
                return null;
            }

        } catch (SQLException e) {
            throw new RuntimeException("アイコンの取得中にDBエラーが発生しました", e);
        }
    }
    

    /**
     * 最後に選択した団体IDを取得する
     * nullの場合は個人モード
     */
    public Integer findLastOrgId(int userId) {

        String sql =
            "SELECT last_org_id FROM users WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);

            try (ResultSet rs = stmt.executeQuery()) {

                if (rs.next()) {
                    int orgId = rs.getInt("last_org_id");

                    if (rs.wasNull()) {
                        return null;
                    }

                    return orgId;
                }
            }

            return null;

        } catch (SQLException e) {
            throw new RuntimeException(
                "最終選択モードの取得に失敗しました", e
            );
        }
    }

    /**
     * 最後に選択した団体IDを保存する
     * nullの場合は個人モードとして保存
     */
    public void saveLastOrgId(int userId, Integer orgId) {

        String sql =
            "UPDATE users SET last_org_id = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (orgId == null) {
                stmt.setNull(1, java.sql.Types.INTEGER);
            } else {
                stmt.setInt(1, orgId);
            }

            stmt.setInt(2, userId);

            stmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException(
                "最終選択モードの保存に失敗しました", e
            );
        }
    }

}