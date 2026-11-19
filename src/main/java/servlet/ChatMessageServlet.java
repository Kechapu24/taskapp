
package servlet;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import dao.ChatAttachmentDAO;
import dao.ChatMessageDAO;
import model.User;

/**
 * チャットメッセージの取得・送信を担当するServlet
 */
@WebServlet("/chatMessage")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 35 * 1024 * 1024
)
public class ChatMessageServlet extends HttpServlet {

    private final ChatMessageDAO chatMessageDAO =
        new ChatMessageDAO();

    // 1ファイル最大10MB
    private static final long MAX_FILE_SIZE =
        10L * 1024 * 1024;

    // 添付ファイル全体で最大30MB
    private static final long MAX_TOTAL_SIZE =
        30L * 1024 * 1024;

    // 一度に添付できるファイル数
    private static final int MAX_FILE_COUNT = 5;

    /**
     * チャット画面を開いたときの処理
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ログイン確認
        if (session == null ||
                session.getAttribute("loginUser") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        User loginUser =
            (User) session.getAttribute("loginUser");

        // チャットルームIDを取得
        String roomIdParam =
            request.getParameter("roomId");

        long chatRoomId;

        try {
            chatRoomId = Long.parseLong(roomIdParam);

            if (chatRoomId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "チャットルームIDが不正です。"
            );
            return;
        }

        try {

            // 参加者かどうか確認
            boolean isMember =
                chatMessageDAO.isRoomMember(
                    chatRoomId,
                    loginUser.getUserId()
                );

            if (!isMember) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "このチャットルームにはアクセスできません。"
                );
                return;
            }

            // メッセージ一覧を取得
            request.setAttribute(
                "messages",
                chatMessageDAO.getMessages(
                    chatRoomId,
                    loginUser.getUserId()
                )
            );

            // 最終閲覧日時を更新
            chatMessageDAO.markAsRead(
                chatRoomId,
                loginUser.getUserId()
            );

            request.setAttribute("activeRoomId", chatRoomId);

            // チャット画面を表示
            request.getRequestDispatcher(
                "/chat.jsp"
            ).forward(request, response);

        } catch (RuntimeException e) {

            getServletContext().log(
                "メッセージ取得に失敗しました。",
                e
            );

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "チャットの読み込みに失敗しました。"
            );
        }
    }

    /**
     * メッセージ・添付ファイル送信時の処理
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // ログイン確認
        if (session == null ||
                session.getAttribute("loginUser") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        User loginUser =
            (User) session.getAttribute("loginUser");

        List<Path> savedPaths = new ArrayList<>();

        try {

            String contentType = request.getContentType();

            boolean isMultipart =
                contentType != null &&
                contentType.toLowerCase(Locale.ROOT)
                    .startsWith("multipart/form-data");

            // multipartの場合だけファイル情報を取得
            List<Part> parts = new ArrayList<>();

            if (isMultipart) {
                parts.addAll(request.getParts());
            }

            String roomIdParam =
                request.getParameter("roomId");

            String messageText =
                request.getParameter("messageText");

            long chatRoomId;

            try {
                chatRoomId = Long.parseLong(roomIdParam);

                if (chatRoomId <= 0) {
                    throw new NumberFormatException();
                }

            } catch (NumberFormatException e) {

                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "チャットルームIDが不正です。"
                );
                return;
            }

            // アップロード前に参加者であることを確認
            boolean isMember =
                chatMessageDAO.isRoomMember(
                    chatRoomId,
                    loginUser.getUserId()
                );

            if (!isMember) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "このチャットルームには送信できません。"
                );
                return;
            }

            // 添付ファイルを保存
            List<ChatAttachmentDAO.UploadedFile> uploadedFiles =
                saveAttachments(parts, savedPaths);

            // 本文も添付ファイルもなければ送信しない
            if ((messageText == null ||
                    messageText.trim().isEmpty()) &&
                    uploadedFiles.isEmpty()) {

                response.sendRedirect(
                    request.getContextPath()
                    + "/chatMessage?roomId=" + chatRoomId
                );
                return;
            }

            // メッセージと添付情報をまとめて登録
            long messageId =
                chatMessageDAO.sendMessageWithAttachments(
                    chatRoomId,
                    loginUser.getUserId(),
                    messageText,
                    uploadedFiles
                );

            if (messageId <= 0) {

                deleteSavedFiles(savedPaths);

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "メッセージを送信できませんでした。"
                );
                return;
            }

            // 送信後にチャット画面へ戻る
            response.sendRedirect(
                request.getContextPath()
                + "/chatMessage?roomId=" + chatRoomId
            );

        } catch (IllegalArgumentException e) {

            deleteSavedFiles(savedPaths);

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                e.getMessage()
            );

        } catch (IllegalStateException e) {

            deleteSavedFiles(savedPaths);

            response.sendError(
                HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE,
                "ファイルの容量が上限を超えています。"
            );

        } catch (Exception e) {

            deleteSavedFiles(savedPaths);

            getServletContext().log(
                "メッセージ・ファイル送信に失敗しました。",
                e
            );

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "メッセージまたはファイルの送信に失敗しました。"
            );
        }
    }

    /**
     * 添付ファイルを保存し、DB登録用の情報を作る。
     */
    private List<ChatAttachmentDAO.UploadedFile> saveAttachments(
            List<Part> parts,
            List<Path> savedPaths) throws IOException {

        List<ChatAttachmentDAO.UploadedFile> uploadedFiles =
            new ArrayList<>();

        Path uploadDirectory = getUploadDirectory();

        long totalSize = 0;

        for (Part part : parts) {

            if (!"files".equals(part.getName())) {
                continue;
            }

            // ファイルが選択されていない場合
            String submittedName = part.getSubmittedFileName();

            if (submittedName == null ||
                    submittedName.trim().isEmpty() ||
                    part.getSize() == 0) {
                continue;
            }

            if (uploadedFiles.size() >= MAX_FILE_COUNT) {
                throw new IllegalArgumentException(
                    "添付できるファイルは最大5個です。"
                );
            }

            long fileSize = part.getSize();

            if (fileSize > MAX_FILE_SIZE) {
                throw new IllegalArgumentException(
                    "1つのファイルは10MB以下にしてください。"
                );
            }

            totalSize += fileSize;

            if (totalSize > MAX_TOTAL_SIZE) {
                throw new IllegalArgumentException(
                    "添付ファイルの合計容量は30MB以下にしてください。"
                );
            }

            // ファイル名を安全な表示用文字列にする
            String originalFileName =
                sanitizeFileName(submittedName);

            String extension =
                getExtension(originalFileName);

            String safeContentType =
                getAllowedContentType(extension);

            if (safeContentType == null) {
                throw new IllegalArgumentException(
                    "対応していないファイル形式です。"
                    + " PDF、画像、Word、Excel、PowerPoint、"
                    + "TXT、CSVを使用してください。"
                );
            }

            // ファイルの内容を簡易確認
            if (!hasValidSignature(part, extension)) {
                throw new IllegalArgumentException(
                    "ファイルの内容と拡張子が一致しません。"
                );
            }

            Files.createDirectories(uploadDirectory);

            // 元のファイル名を保存先に使わない
            String storedFileName =
                UUID.randomUUID().toString()
                + "." + extension;

            Path targetPath =
                uploadDirectory.resolve(storedFileName).normalize();

            if (!targetPath.startsWith(uploadDirectory)) {
                throw new IllegalArgumentException(
                    "不正なファイル名です。"
                );
            }

            // 一時ファイルに保存してから確定
            Path temporaryPath =
                uploadDirectory.resolve(
                    UUID.randomUUID().toString() + ".tmp"
                );

            try {
                try (InputStream input = part.getInputStream()) {
                    Files.copy(
                        input,
                        temporaryPath,
                        StandardCopyOption.REPLACE_EXISTING
                    );
                }

                Files.move(
                    temporaryPath,
                    targetPath,
                    StandardCopyOption.REPLACE_EXISTING
                );

                savedPaths.add(targetPath);

            } finally {
                Files.deleteIfExists(temporaryPath);
            }

            uploadedFiles.add(
                new ChatAttachmentDAO.UploadedFile(
                    originalFileName,
                    storedFileName,
                    safeContentType,
                    fileSize
                )
            );
        }

        return uploadedFiles;
    }

    /**
     * ファイルを保存するディレクトリ。
     *
     * システムプロパティ chat.upload.dir が指定されていれば
     * その場所を使用する。
     * 未指定の場合はユーザーのホームフォルダ内を使用する。
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
     * パス情報や制御文字を除去したファイル名を返す。
     */
    private String sanitizeFileName(String fileName) {

        String name = fileName.replace('\\', '/');

        int lastSlash = name.lastIndexOf('/');

        if (lastSlash >= 0) {
            name = name.substring(lastSlash + 1);
        }

        name = name.replaceAll("[\\p{Cntrl}]", "_").trim();

        if (name.isEmpty()) {
            throw new IllegalArgumentException(
                "ファイル名が不正です。"
            );
        }

        if (name.length() > 255) {
            name = name.substring(0, 255);
        }

        return name;
    }

    /**
     * 拡張子を取得する。
     */
    private String getExtension(String fileName) {

        int dot = fileName.lastIndexOf('.');

        if (dot < 0 || dot == fileName.length() - 1) {
            throw new IllegalArgumentException(
                "拡張子のないファイルは添付できません。"
            );
        }

        return fileName.substring(dot + 1)
            .toLowerCase(Locale.ROOT);
    }

    /**
     * 許可した拡張子に対応する形式だけを返す。
     */
    private String getAllowedContentType(String extension) {

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

    /**
     * ファイルの先頭部分を確認する。
     */
    private boolean hasValidSignature(
            Part part,
            String extension) throws IOException {

        byte[] header;

        try (InputStream input = part.getInputStream()) {
            header = input.readNBytes(16);
        }

        if (extension.equals("png")) {
            byte[] signature = {
                (byte) 0x89, 0x50, 0x4E, 0x47,
                0x0D, 0x0A, 0x1A, 0x0A
            };

            if (header.length < 8) {
                return false;
            }

            for (int i = 0; i < signature.length; i++) {
                if (header[i] != signature[i]) {
                    return false;
                }
            }

            return true;
        }

        if (extension.equals("jpg") ||
                extension.equals("jpeg")) {

            return header.length >= 3
                && (header[0] & 0xFF) == 0xFF
                && (header[1] & 0xFF) == 0xD8
                && (header[2] & 0xFF) == 0xFF;
        }

        if (extension.equals("gif")) {

            String signature = new String(
                header, 0, Math.min(header.length, 6),
                java.nio.charset.StandardCharsets.US_ASCII
            );

            return signature.equals("GIF87a")
                || signature.equals("GIF89a");
        }

        if (extension.equals("webp")) {

            return header.length >= 12
                && header[0] == 'R'
                && header[1] == 'I'
                && header[2] == 'F'
                && header[3] == 'F'
                && header[8] == 'W'
                && header[9] == 'E'
                && header[10] == 'B'
                && header[11] == 'P';
        }

        if (extension.equals("pdf")) {

            String signature = new String(
                header, 0, header.length,
                java.nio.charset.StandardCharsets.US_ASCII
            );

            return signature.startsWith("%PDF-");
        }

        if (extension.equals("docx") ||
                extension.equals("xlsx") ||
                extension.equals("pptx")) {

            // Office Open XML形式はZIP形式を使用する
            return header.length >= 4
                && header[0] == 'P'
                && header[1] == 'K'
                && header[2] == 3
                && header[3] == 4;
        }

        if (extension.equals("txt") ||
                extension.equals("csv")) {

            // テキスト形式にバイナリデータが混ざっていないか確認
            for (byte b : header) {
                if (b == 0) {
                    return false;
                }
            }

            return header.length > 0;
        }

        return false;
    }

    /**
     * DB登録に失敗した場合などに保存済みファイルを削除する。
     */
    private void deleteSavedFiles(List<Path> savedPaths) {

        for (Path path : savedPaths) {

            try {
                Files.deleteIfExists(path);

            } catch (IOException e) {
                getServletContext().log(
                    "一時保存ファイルの削除に失敗しました。",
                    e
                );
            }
        }
    }
}
