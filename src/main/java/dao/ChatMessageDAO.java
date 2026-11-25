
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import util.DBConnection;

/**
 * チャットメッセージを管理するDAO
 */
public class ChatMessageDAO {

    /**
     * 指定されたチャットルームのメッセージと
     * 添付ファイル一覧を取得する。
     *
     * 閲覧ユーザーがそのルームの参加者であることも確認する。
     */
    public List<Map<String, Object>> getMessages(
            long chatRoomId,
            int userId) {

        String sql =
            "SELECT " +
            "m.message_id, " +
            "m.chat_room_id, " +
            "m.sender_id, " +
            "COALESCE(u.user_name, '退会したユーザー') AS sender_name, " +
            "m.message_text, " +
            "m.created_at " +
            "FROM chat_message m " +
            "INNER JOIN chat_room_member rm " +
            "ON m.chat_room_id = rm.chat_room_id " +
            "AND rm.user_id = ? " +
            "LEFT JOIN users u " +
            "ON m.sender_id = u.user_id " +
            "WHERE m.chat_room_id = ? " +
            "AND m.deleted_at IS NULL " +
            "ORDER BY m.created_at ASC, m.message_id ASC";

        List<Map<String, Object>> messages = new ArrayList<>();

        ChatAttachmentDAO attachmentDAO = new ChatAttachmentDAO();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setLong(2, chatRoomId);

            try (ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> message =
                        new LinkedHashMap<>();

                    long messageId = rs.getLong("message_id");

                    message.put("messageId", messageId);
                    message.put(
                        "chatRoomId",
                        rs.getLong("chat_room_id")
                    );
                    message.put(
                        "senderId",
                        rs.getObject("sender_id")
                    );
                    message.put(
                        "senderName",
                        rs.getString("sender_name")
                    );
                    message.put(
                        "messageText",
                        rs.getString("message_text")
                    );
                    message.put(
                        "createdAt",
                        rs.getTimestamp("created_at")
                    );

                    // メッセージに紐づく添付ファイルを取得
                    message.put(
                        "attachments",
                        attachmentDAO.getAttachments(messageId)
                    );

                    messages.add(message);
                }
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "チャットメッセージの取得に失敗しました。",
                e
            );
        }

        return messages;
    }

    /**
     * 通常のテキストメッセージを送信する。
     *
     * 従来の呼び出し方を維持するためのメソッド。
     */
    public boolean sendMessage(
            long chatRoomId,
            int senderId,
            String messageText) {

        long messageId = sendMessageWithAttachments(
            chatRoomId,
            senderId,
            messageText,
            Collections.emptyList()
        );

        return messageId > 0;
    }

    /**
     * メッセージと添付ファイル情報をまとめて保存する。
     *
     * 途中で失敗した場合は、両方の登録を取り消す。
     *
     * 添付ファイルだけの場合は、
     * 本文に「ファイルを送信しました。」を設定する。
     *
     * @return 保存されたメッセージID。登録できない場合は0。
     */
    public long sendMessageWithAttachments(
            long chatRoomId,
            int senderId,
            String messageText,
            List<ChatAttachmentDAO.UploadedFile> files) {

        if (files == null) {
            files = Collections.emptyList();
        }

        String text = messageText == null
                ? ""
                : messageText.trim();

        // 本文もファイルもない場合は送信しない
        if (text.isEmpty() && files.isEmpty()) {
            return 0;
        }

        // 添付ファイルのみの送信に対応
        if (text.isEmpty()) {
            text = "ファイルを送信しました。";
        }

        String sql =
            "INSERT INTO chat_message " +
            "(chat_room_id, sender_id, message_text) " +
            "SELECT ?, ?, ? " +
            "WHERE EXISTS (" +
            "SELECT 1 FROM chat_room_member " +
            "WHERE chat_room_id = ? AND user_id = ?" +
            ") " +
            "RETURNING message_id";

        try (Connection conn = DBConnection.getConnection()) {

            conn.setAutoCommit(false);

            try {

                long messageId;

                // メッセージを登録
                try (PreparedStatement stmt =
                        conn.prepareStatement(sql)) {

                    stmt.setLong(1, chatRoomId);
                    stmt.setInt(2, senderId);
                    stmt.setString(3, text);
                    stmt.setLong(4, chatRoomId);
                    stmt.setInt(5, senderId);

                    try (ResultSet rs = stmt.executeQuery()) {

                        // ルームの参加者でなければ登録されない
                        if (!rs.next()) {
                            conn.rollback();
                            return 0;
                        }

                        messageId = rs.getLong("message_id");
                    }
                }

                // 添付ファイル情報を同じトランザクションで登録
                if (!files.isEmpty()) {

                    ChatAttachmentDAO attachmentDAO =
                        new ChatAttachmentDAO();

                    attachmentDAO.insertAttachments(
                        conn,
                        messageId,
                        senderId,
                        files
                    );
                }

                // 全て成功した場合だけ確定
                conn.commit();

                return messageId;

            } catch (SQLException | RuntimeException e) {

                // 途中で失敗した場合は取り消す
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "チャットメッセージと添付情報の保存に失敗しました。",
                e
            );
        }
    }

    /**
     * チャットルームの最終閲覧日時を更新する。
     */
    

/**
 * 自分が送信したメッセージの既読状況を取得する。
 *
 * @param chatRoomId チャットルームID
 * @param senderId 送信者のユーザーID
 * @return メッセージごとの既読人数一覧
 */
public List<Map<String, Object>> getReadStatuses(
        long chatRoomId,
        int senderId) {

    String sql =
        "SELECT " +
        "m.message_id, " +

        // 既読にした人数
        "(SELECT COUNT(*) " +
        "FROM chat_room_member reader " +
        "WHERE reader.chat_room_id = m.chat_room_id " +
        "AND reader.user_id IS DISTINCT FROM m.sender_id " +
        "AND reader.last_read_at IS NOT NULL " +
        "AND reader.last_read_at >= m.created_at" +
        ") AS read_count, " +

        // 既読対象人数
        "(SELECT COUNT(*) " +
        "FROM chat_room_member recipient " +
        "WHERE recipient.chat_room_id = m.chat_room_id " +
        "AND recipient.user_id IS DISTINCT FROM m.sender_id" +
        ") AS recipient_count " +

        "FROM chat_message m " +
        "WHERE m.chat_room_id = ? " +
        "AND m.sender_id = ? " +
        "AND m.deleted_at IS NULL " +
        "ORDER BY m.message_id ASC";

    List<Map<String, Object>> statuses =
        new ArrayList<>();

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setLong(1, chatRoomId);
        stmt.setInt(2, senderId);

        try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {

                Map<String, Object> status =
                    new LinkedHashMap<>();

                status.put(
                    "messageId",
                    rs.getLong("message_id")
                );

                status.put(
                    "readCount",
                    rs.getLong("read_count")
                );

                status.put(
                    "recipientCount",
                    rs.getLong("recipient_count")
                );

                statuses.add(status);
            }
        }

    } catch (SQLException e) {

        throw new RuntimeException(
            "メッセージの既読状況取得に失敗しました。",
            e
        );
    }

    return statuses;
}

    
    public void markAsRead(
            long chatRoomId,
            int userId) {

        String sql =
            "UPDATE chat_room_member " +
            "SET last_read_at = CURRENT_TIMESTAMP " +
            "WHERE chat_room_id = ? AND user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, chatRoomId);
            stmt.setInt(2, userId);

            stmt.executeUpdate();

        } catch (SQLException e) {

            throw new RuntimeException(
                "最終閲覧日時の更新に失敗しました。",
                e
            );
        }
    }

    /**
     * ユーザーが指定されたチャットルームに
     * 参加しているか確認する。
     */
    public boolean isRoomMember(
            long chatRoomId,
            int userId) {

        String sql =
            "SELECT 1 FROM chat_room_member " +
            "WHERE chat_room_id = ? AND user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, chatRoomId);
            stmt.setInt(2, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "チャット参加者の確認に失敗しました。",
                e
            );
        }
    }
}
