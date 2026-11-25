
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

/**
 * チャット添付ファイルを管理するDAO
 */
public class ChatAttachmentDAO {

    /**
     * アップロード済みファイルの情報
     */
    public static class UploadedFile {

        private final String originalFileName;
        private final String storedFileName;
        private final String contentType;
        private final long fileSize;

        public UploadedFile(
                String originalFileName,
                String storedFileName,
                String contentType,
                long fileSize) {

            this.originalFileName = originalFileName;
            this.storedFileName = storedFileName;
            this.contentType = contentType;
            this.fileSize = fileSize;
        }

        public String getOriginalFileName() {
            return originalFileName;
        }

        public String getStoredFileName() {
            return storedFileName;
        }

        public String getContentType() {
            return contentType;
        }

        public long getFileSize() {
            return fileSize;
        }
    }

    /**
     * メッセージに添付ファイル情報を登録する。
     *
     * 呼び出し元のトランザクションに参加する。
     */
    public void insertAttachments(
            Connection conn,
            long messageId,
            int uploadedBy,
            List<UploadedFile> files) throws SQLException {

        String sql =
            "INSERT INTO chat_attachment " +
            "(message_id, original_file_name, stored_file_name, " +
            "content_type, file_size, uploaded_by) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (UploadedFile file : files) {

                stmt.setLong(1, messageId);
                stmt.setString(2, file.getOriginalFileName());
                stmt.setString(3, file.getStoredFileName());
                stmt.setString(4, file.getContentType());
                stmt.setLong(5, file.getFileSize());
                stmt.setInt(6, uploadedBy);

                stmt.executeUpdate();
            }
        }
    }

    /**
     * 指定されたメッセージの添付ファイル一覧を取得する。
     */
    public List<Map<String, Object>> getAttachments(long messageId) {

        String sql =
            "SELECT chat_attachment_id, " +
            "original_file_name, content_type, file_size " +
            "FROM chat_attachment " +
            "WHERE message_id = ? " +
            "ORDER BY chat_attachment_id ASC";

        List<Map<String, Object>> attachments = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, messageId);

            try (ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {

                    Map<String, Object> attachment =
                        new LinkedHashMap<>();

                    attachment.put(
                        "attachmentId",
                        rs.getLong("chat_attachment_id")
                    );

                    attachment.put(
                        "originalFileName",
                        rs.getString("original_file_name")
                    );

                    attachment.put(
                        "contentType",
                        rs.getString("content_type")
                    );

                    attachment.put(
                        "fileSize",
                        rs.getLong("file_size")
                    );

                    attachments.add(attachment);
                }
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "添付ファイル情報の取得に失敗しました。",
                e
            );
        }

        return attachments;
    }

    /**
     * ログインユーザーが参加しているチャットルームの
     * 添付ファイルだけを取得する。
     *
     * 参加していないルームのファイルは取得できない。
     */
    public Map<String, Object> findAttachmentForMember(
            long attachmentId,
            int userId) {

        String sql =
            "SELECT ca.chat_attachment_id, " +
            "ca.original_file_name, " +
            "ca.stored_file_name, " +
            "ca.content_type, " +
            "ca.file_size " +
            "FROM chat_attachment ca " +
            "INNER JOIN chat_message m " +
            "ON ca.message_id = m.message_id " +
            "INNER JOIN chat_room_member rm " +
            "ON m.chat_room_id = rm.chat_room_id " +
            "WHERE ca.chat_attachment_id = ? " +
            "AND rm.user_id = ? " +
            "AND m.deleted_at IS NULL";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, attachmentId);
            stmt.setInt(2, userId);

            try (ResultSet rs = stmt.executeQuery()) {

                if (!rs.next()) {
                    return null;
                }

                Map<String, Object> attachment =
                    new LinkedHashMap<>();

                attachment.put(
                    "attachmentId",
                    rs.getLong("chat_attachment_id")
                );

                attachment.put(
                    "originalFileName",
                    rs.getString("original_file_name")
                );

                attachment.put(
                    "storedFileName",
                    rs.getString("stored_file_name")
                );

                attachment.put(
                    "contentType",
                    rs.getString("content_type")
                );

                attachment.put(
                    "fileSize",
                    rs.getLong("file_size")
                );

                return attachment;
            }

        } catch (SQLException e) {

            throw new RuntimeException(
                "添付ファイルの確認に失敗しました。",
                e
            );
        }
    }
}
