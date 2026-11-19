
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import util.DBConnection;

/**
 * チャットルームを管理するDAO
 *
 * 団体全体チャットを取得・作成する。
 * ルームが存在しない場合は新規作成し、
 * 団体に所属するメンバーを参加者として登録する。
 */
public class ChatRoomDAO {

    /**
     * 団体全体チャットのルームIDを取得する。
     *
     * まだルームが存在しない場合は作成する。
     *
     * @param orgId 団体ID
     * @param loginUserId ログイン中のユーザーID
     * @return チャットルームID
     */
    public long getOrCreateGroupRoom(
            int orgId,
            int loginUserId) {

        String checkMemberSql =
            "SELECT 1 FROM org_member " +
            "WHERE org_id = ? AND user_id = ?";

        String insertRoomSql =
            "INSERT INTO chat_room " +
            "(room_type, org_id, created_by) " +
            "VALUES ('group', ?, ?) " +
            "ON CONFLICT (org_id) " +
            "WHERE room_type = 'group' " +
            "DO NOTHING";

        String findRoomSql =
            "SELECT chat_room_id FROM chat_room " +
            "WHERE room_type = 'group' AND org_id = ?";

        String insertMembersSql =
            "INSERT INTO chat_room_member " +
            "(chat_room_id, user_id) " +
            "SELECT ?, user_id FROM org_member " +
            "WHERE org_id = ? " +
            "ON CONFLICT (chat_room_id, user_id) " +
            "DO NOTHING";

        try (Connection conn = DBConnection.getConnection()) {

            conn.setAutoCommit(false);

            try {

                // 1. ログインユーザーが団体に所属しているか確認
                try (PreparedStatement stmt =
                        conn.prepareStatement(checkMemberSql)) {

                    stmt.setInt(1, orgId);
                    stmt.setInt(2, loginUserId);

                    try (ResultSet rs = stmt.executeQuery()) {

                        if (!rs.next()) {
                            throw new IllegalArgumentException(
                                "この団体のメンバーではありません。"
                            );
                        }
                    }
                }

                // 2. 団体全体チャットを作成
                // すでに存在する場合は何もしない
                try (PreparedStatement stmt =
                        conn.prepareStatement(insertRoomSql)) {

                    stmt.setInt(1, orgId);
                    stmt.setInt(2, loginUserId);

                    stmt.executeUpdate();
                }

                // 3. チャットルームIDを取得
                long chatRoomId;

                try (PreparedStatement stmt =
                        conn.prepareStatement(findRoomSql)) {

                    stmt.setInt(1, orgId);

                    try (ResultSet rs = stmt.executeQuery()) {

                        if (!rs.next()) {
                            throw new SQLException(
                                "チャットルームを取得できませんでした。"
                            );
                        }

                        chatRoomId =
                            rs.getLong("chat_room_id");
                    }
                }

                // 4. 団体メンバーをチャット参加者に登録
                // すでに登録済みのメンバーは重複登録しない
                try (PreparedStatement stmt =
                        conn.prepareStatement(insertMembersSql)) {

                    stmt.setLong(1, chatRoomId);
                    stmt.setInt(2, orgId);

                    stmt.executeUpdate();
                }

                // 5. 処理を確定
                conn.commit();

                return chatRoomId;

            } catch (SQLException e) {

                conn.rollback();

                throw new RuntimeException(
                    "チャットルームの取得・作成に失敗しました。",
                    e
                );

            } catch (RuntimeException e) {

                conn.rollback();

                throw e;
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "データベース接続に失敗しました。",
                e
            );
        }
    }

/**
 * 個人チャットのルームを取得または作成する。
 *
 * 同じ団体の同じ2人なら、既存のルームを再利用する。
 *
 * @param orgId 現在の団体ID
 * @param loginUserId ログインユーザーID
 * @param targetUserId チャット相手のユーザーID
 * @return チャットルームID
 */
public long getOrCreateDirectRoom(
        int orgId,
        int loginUserId,
        int targetUserId) {

    // 自分自身とのチャットを禁止
    if (loginUserId == targetUserId || targetUserId <= 0) {
        throw new IllegalArgumentException(
            "チャット相手の指定が不正です。"
        );
    }

    // ユーザーIDの小さい順に統一する
    int lowUserId = Math.min(loginUserId, targetUserId);
    int highUserId = Math.max(loginUserId, targetUserId);

    // 2人とも現在の団体に所属しているか確認
    String checkMemberSql =
        "SELECT COUNT(*) FROM org_member " +
        "WHERE org_id = ? AND user_id IN (?, ?)";

    // 個人チャットを作成
    // すでに存在する場合は重複作成しない
    String insertRoomSql =
        "INSERT INTO chat_room " +
        "(room_type, org_id, direct_user_low_id, " +
        "direct_user_high_id, created_by) " +
        "VALUES ('direct', ?, ?, ?, ?) " +
        "ON CONFLICT " +
        "(org_id, direct_user_low_id, direct_user_high_id) " +
        "WHERE room_type = 'direct' " +
        "DO NOTHING";

    // 既存ルームを取得
    String findRoomSql =
        "SELECT chat_room_id FROM chat_room " +
        "WHERE room_type = 'direct' " +
        "AND org_id = ? " +
        "AND direct_user_low_id = ? " +
        "AND direct_user_high_id = ?";

    // 2人をチャット参加者として登録
    String insertMembersSql =
        "INSERT INTO chat_room_member " +
        "(chat_room_id, user_id) " +
        "VALUES (?, ?), (?, ?) " +
        "ON CONFLICT (chat_room_id, user_id) " +
        "DO NOTHING";

    try (Connection conn = DBConnection.getConnection()) {

        conn.setAutoCommit(false);

        try {

            // 1. 2人とも団体に所属しているか確認
            try (PreparedStatement stmt =
                    conn.prepareStatement(checkMemberSql)) {

                stmt.setInt(1, orgId);
                stmt.setInt(2, lowUserId);
                stmt.setInt(3, highUserId);

                try (ResultSet rs = stmt.executeQuery()) {

                    if (!rs.next() || rs.getInt(1) != 2) {
                        throw new IllegalArgumentException(
                            "同じ団体に所属しているメンバー同士でのみチャットできます。"
                        );
                    }
                }
            }

            // 2. 個人チャットルームを作成
            try (PreparedStatement stmt =
                    conn.prepareStatement(insertRoomSql)) {

                stmt.setInt(1, orgId);
                stmt.setInt(2, lowUserId);
                stmt.setInt(3, highUserId);
                stmt.setInt(4, loginUserId);

                stmt.executeUpdate();
            }

            // 3. ルームIDを取得
            long chatRoomId;

            try (PreparedStatement stmt =
                    conn.prepareStatement(findRoomSql)) {

                stmt.setInt(1, orgId);
                stmt.setInt(2, lowUserId);
                stmt.setInt(3, highUserId);

                try (ResultSet rs = stmt.executeQuery()) {

                    if (!rs.next()) {
                        throw new SQLException(
                            "個人チャットルームを取得できませんでした。"
                        );
                    }

                    chatRoomId =
                        rs.getLong("chat_room_id");
                }
            }

            // 4. 2人を参加者として登録
            try (PreparedStatement stmt =
                    conn.prepareStatement(insertMembersSql)) {

                stmt.setLong(1, chatRoomId);
                stmt.setInt(2, lowUserId);
                stmt.setLong(3, chatRoomId);
                stmt.setInt(4, highUserId);

                stmt.executeUpdate();
            }

            // 5. DBへの処理を確定
            conn.commit();

            return chatRoomId;

        } catch (SQLException e) {

            conn.rollback();

            throw new RuntimeException(
                "個人チャットルームの作成に失敗しました。",
                e
            );

        } catch (RuntimeException e) {

            conn.rollback();

            throw e;
        }

    } catch (SQLException e) {

        throw new RuntimeException(
            "個人チャットのデータベース処理に失敗しました。",
            e
        );
    }
}

}
