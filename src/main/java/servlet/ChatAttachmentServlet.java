
package servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ChatAttachmentDAO;
import model.User;

/**
 * チャット添付ファイルの表示・ダウンロードを担当するServlet
 */
@WebServlet("/chatAttachment")
public class ChatAttachmentServlet extends HttpServlet {

    private final ChatAttachmentDAO attachmentDAO =
        new ChatAttachmentDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // ログイン確認
        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("loginUser") == null) {

            response.sendError(
                HttpServletResponse.SC_UNAUTHORIZED
            );
            return;
        }

        User loginUser =
            (User) session.getAttribute("loginUser");

        // 添付ファイルIDを取得
        String attachmentIdParam =
            request.getParameter("attachmentId");

        long attachmentId;

        try {

            attachmentId =
                Long.parseLong(attachmentIdParam);

            if (attachmentId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "添付ファイルIDが不正です。"
            );
            return;
        }

        try {

            // チャット参加者であることを確認
            Map<String, Object> attachment =
                attachmentDAO.findAttachmentForMember(
                    attachmentId,
                    loginUser.getUserId()
                );

            if (attachment == null) {

                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "添付ファイルが見つかりません。"
                );
                return;
            }

            String storedFileName =
                String.valueOf(
                    attachment.get("storedFileName")
                );

            String originalFileName =
                String.valueOf(
                    attachment.get("originalFileName")
                );

            // 内部保存名を検証
            if (!isValidStoredFileName(storedFileName)) {

                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND
                );
                return;
            }

            // 保存先を取得
            Path uploadDirectory =
                getUploadDirectory();

            Path filePath =
                uploadDirectory.resolve(storedFileName)
                    .normalize();

            if (!filePath.startsWith(uploadDirectory)) {

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
                );
                return;
            }

            // ファイルの存在と読み取り権限を確認
            if (!Files.isRegularFile(
                    filePath,
                    LinkOption.NOFOLLOW_LINKS) ||
                    !Files.isReadable(filePath)) {

                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "ファイルが見つかりません。"
                );
                return;
            }

            // 実際のファイル形式を確認
            String contentType =
                getAllowedContentType(storedFileName);

            if (contentType == null) {

                response.sendError(
                    HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE
                );
                return;
            }

            // view=inline の場合は画像だけを画面内表示
            boolean inline =
                "inline".equals(request.getParameter("view"));

            if (inline && !contentType.startsWith("image/")) {

                response.sendError(
                    HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE,
                    "画面内表示に対応していないファイル形式です。"
                );
                return;
            }

            String encodedFileName =
                URLEncoder.encode(
                    originalFileName,
                    StandardCharsets.UTF_8.name()
                ).replace("+", "%20");

            response.setContentType(contentType);

            if (inline) {

                // 画像をブラウザ内に表示
                response.setHeader(
                    "Content-Disposition",
                    "inline; filename=\"image\"; filename*=UTF-8''"
                        + encodedFileName
                );

            } else {

                // 通常ファイルはダウンロード
                response.setHeader(
                    "Content-Disposition",
                    "attachment; filename=\"download\"; filename*=UTF-8''"
                        + encodedFileName
                );
            }

            response.setHeader(
                "X-Content-Type-Options",
                "nosniff"
            );

            response.setHeader(
                "X-Frame-Options",
                "DENY"
            );

            response.setHeader(
                "Cache-Control",
                "private, no-store"
            );

            response.setHeader(
                "Pragma",
                "no-cache"
            );

            response.setContentLengthLong(
                Files.size(filePath)
            );

            // ファイルをブラウザへ送信
            try (java.io.InputStream input =
                    Files.newInputStream(filePath);
                 java.io.OutputStream output =
                    response.getOutputStream()) {

                byte[] buffer = new byte[8192];

                int length;

                while ((length = input.read(buffer)) != -1) {
                    output.write(buffer, 0, length);
                }

                output.flush();
            }

        } catch (Exception e) {

            getServletContext().log(
                "添付ファイルの表示・ダウンロードに失敗しました。",
                e
            );

            if (!response.isCommitted()) {

                response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "ファイルの取得に失敗しました。"
                );
            }
        }
    }

    /**
     * 保存名がアプリケーションで生成する形式か確認する。
     */
    private boolean isValidStoredFileName(String fileName) {

        if (fileName == null) {
            return false;
        }

        return fileName.matches(
            "(?i)[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-"
            + "[0-9a-f]{4}-[0-9a-f]{12}\\."
            + "(png|jpg|jpeg|gif|webp|pdf|txt|csv|docx|xlsx|pptx)"
        );
    }

    /**
     * アップロード時と同じ保存フォルダを取得する。
     */
    private Path getUploadDirectory() {

        String configuredPath =
            System.getProperty("chat.upload.dir");

        Path directory;

        if (configuredPath != null &&
                !configuredPath.trim().isEmpty()) {

            directory = Paths.get(configuredPath);

        } else {

            directory = Paths.get(
                System.getProperty("user.home"),
                "taskapp-chat-uploads"
            );
        }

        return directory.toAbsolutePath().normalize();
    }

    /**
     * 許可されたファイル形式だけを返す。
     */
    private String getAllowedContentType(String storedFileName) {

        int dot = storedFileName.lastIndexOf('.');

        if (dot < 0) {
            return null;
        }

        String extension =
            storedFileName.substring(dot + 1)
                .toLowerCase(Locale.ROOT);

        switch (extension) {

            case "png":
                return "image/png";

            case "jpg":
            case "jpeg":
                return "image/jpeg";

            case "gif":
                return "image/gif";

            case "webp":
                return "image/webp";

            case "pdf":
                return "application/pdf";

            case "txt":
                return "text/plain";

            case "csv":
                return "text/csv";

            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

            case "xlsx":
                return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

            case "pptx":
                return "application/vnd.openxmlformats-officedocument.presentationml.presentation";

            default:
                return null;
        }
    }
}
