package servlet;

import java.io.IOException;
import java.io.InputStream;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import dao.UserDAO;
import model.User;

/**
 * アイコン画像のアップロード・削除。
 *
 *   アップロード: <input type="file" name="icon"> を multipart で POST
 *   削除        : action=delete を POST
 *
 * 結果は ?iconResult=... を付けて account.jsp に戻し、画面側でメッセージを出す。
 *   ok / deleted / empty / invalid / toolarge
 */
@WebServlet("/uploadIcon")
@MultipartConfig(maxFileSize = 2 * 1024 * 1024, maxRequestSize = 3 * 1024 * 1024)
public class UploadIconServlet extends HttpServlet {

    private static final int MAX_BYTES = 2 * 1024 * 1024; // 2MB

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = (session == null) ? null : (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String result;
        try {
            if ("delete".equals(request.getParameter("action"))) {
                userDAO.deleteIcon(loginUser.getUserId());
                loginUser.setIconSet(false);
                result = "deleted";
            } else {
                result = saveUploadedIcon(request, loginUser);
            }
        } catch (IllegalStateException e) {
            // @MultipartConfig の上限(2MB)を超えたとき
            result = "toolarge";
        }

        response.sendRedirect(request.getContextPath() + "/account.jsp?iconResult=" + result);
    }

    /** 送られてきた画像を検査して保存し、結果コードを返す */
    private String saveUploadedIcon(HttpServletRequest request, User loginUser)
            throws IOException, ServletException {

        Part part = request.getPart("icon");
        if (part == null || part.getSize() == 0) {
            return "empty";
        }

        byte[] data;
        try (InputStream in = part.getInputStream()) {
            data = in.readNBytes(MAX_BYTES + 1); // 上限+1バイトまで読んで、超過を判定
        }
        if (data.length > MAX_BYTES) {
            return "toolarge";
        }

        // ブラウザが申告する種類は信用せず、ファイルの中身(先頭のバイト列)で判定する
        String contentType = detectImageType(data);
        if (contentType == null) {
            return "invalid";
        }

        userDAO.updateIcon(loginUser.getUserId(), contentType, data);
        loginUser.setIconSet(true);
        return "ok";
    }

    /**
     * 先頭のバイト列から画像の種類を判定する。対応外なら null。
     * SVGは中にスクリプトを仕込めるため、意図的に対応しない。
     */
    private String detectImageType(byte[] d) {
        if (d.length >= 8
                && (d[0] & 0xFF) == 0x89 && d[1] == 'P' && d[2] == 'N' && d[3] == 'G'
                && d[4] == 0x0D && d[5] == 0x0A && d[6] == 0x1A && d[7] == 0x0A) {
            return "image/png";
        }
        if (d.length >= 3
                && (d[0] & 0xFF) == 0xFF && (d[1] & 0xFF) == 0xD8 && (d[2] & 0xFF) == 0xFF) {
            return "image/jpeg";
        }
        if (d.length >= 6 && d[0] == 'G' && d[1] == 'I' && d[2] == 'F' && d[3] == '8'
                && (d[4] == '7' || d[4] == '9') && d[5] == 'a') {
            return "image/gif";
        }
        if (d.length >= 12 && d[0] == 'R' && d[1] == 'I' && d[2] == 'F' && d[3] == 'F'
                && d[8] == 'W' && d[9] == 'E' && d[10] == 'B' && d[11] == 'P') {
            return "image/webp";
        }
        return null;
    }
}