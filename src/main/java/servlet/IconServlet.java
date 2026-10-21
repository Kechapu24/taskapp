
package servlet;
 
import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.UserDAO;
import model.UserIcon;
 
/**
 * アイコン画像をブラウザに返す。  例: <img src=".../icon?userId=3">
 *
 * ログイン中のユーザーだけが取得できる(未ログインは401)。
 * アイコンが未設定のユーザーは404を返す。
 */
@WebServlet("/icon")
public class IconServlet extends HttpServlet {
 
    private final UserDAO userDAO = new UserDAO();
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
 
        int userId;
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
 
        UserIcon icon = userDAO.findIcon(userId);
        if (icon == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
 
        response.setContentType(icon.getContentType());
        response.setContentLength(icon.getData().length);
        // 画像として以外には解釈させない(念のための安全対策)
        response.setHeader("X-Content-Type-Options", "nosniff");
        // アイコンを変更した直後に古い画像が残らないよう、毎回確認させる
        response.setHeader("Cache-Control", "private, no-cache");
 
        try (OutputStream out = response.getOutputStream()) {
            out.write(icon.getData());
        }
    }
}
 
