
package servlet;

import java.io.IOException;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ChatMessageDAO;
import model.User;

/**
 * チャットの新着メッセージ・削除状況を取得するServlet
 */
@WebServlet("/chatLatestMessage")
public class ChatLatestMessageServlet extends HttpServlet {

    private final ChatMessageDAO chatMessageDAO =
        new ChatMessageDAO();

    /**
     * GET：チャットの最新状態をJSONで返す
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

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

        // チャットルームIDを取得
        long chatRoomId;

        try {

            String roomIdParam =
                request.getParameter("roomId");

            if (roomIdParam == null) {
                throw new NumberFormatException();
            }

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

            // チャットルームの参加者か確認
            if (!chatMessageDAO.isRoomMember(
                    chatRoomId,
                    loginUser.getUserId())) {

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
                );
                return;
            }

            // 最新メッセージIDと削除済み件数を取得
            Map<String, Long> state =
                chatMessageDAO.getMessageChangeState(
                    chatRoomId,
                    loginUser.getUserId()
                );

            long latestMessageId =
                state.get("latestMessageId") == null
                    ? 0L
                    : state.get("latestMessageId");

            long deletedCount =
                state.get("deletedCount") == null
                    ? 0L
                    : state.get("deletedCount");

            // JSONで返す
            String json =
                "{"
                + "\"latestMessageId\":" + latestMessageId + ","
                + "\"deletedCount\":" + deletedCount
                + "}";

            response.setContentType(
                "application/json; charset=UTF-8"
            );

            response.setCharacterEncoding("UTF-8");

            response.setHeader(
                "Cache-Control",
                "no-cache, no-store, must-revalidate"
            );

            response.setHeader(
                "Pragma",
                "no-cache"
            );

            response.setDateHeader(
                "Expires",
                0
            );

            response.getWriter().write(json);

        } catch (RuntimeException e) {

            getServletContext().log(
                "チャットの更新状態取得に失敗しました。",
                e
            );

            if (!response.isCommitted()) {
                response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "チャットの更新状態を取得できませんでした。"
                );
            }
        }
    }
}
