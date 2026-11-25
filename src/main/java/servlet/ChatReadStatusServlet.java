
package servlet;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ChatMessageDAO;
import model.User;

/**
 * チャットの既読更新・既読状況取得Servlet
 */
@WebServlet("/chatReadStatus")
public class ChatReadStatusServlet extends HttpServlet {

    private final ChatMessageDAO chatMessageDAO =
        new ChatMessageDAO();

    /**
     * GET：自分が送信したメッセージの既読状況を取得
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

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

        long chatRoomId;

        try {

            chatRoomId = Long.parseLong(
                request.getParameter("roomId")
            );

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

            if (!chatMessageDAO.isRoomMember(
                    chatRoomId,
                    loginUser.getUserId())) {

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
                );
                return;
            }

            List<Map<String, Object>> statuses =
                chatMessageDAO.getReadStatuses(
                    chatRoomId,
                    loginUser.getUserId()
                );

            StringBuilder json = new StringBuilder();

            json.append("[");

            for (int i = 0; i < statuses.size(); i++) {

                Map<String, Object> status =
                    statuses.get(i);

                if (i > 0) {
                    json.append(",");
                }

                json.append("{");

                json.append("\"messageId\":")
                    .append(
                        ((Number) status.get("messageId"))
                            .longValue()
                    );

                json.append(",\"readCount\":")
                    .append(
                        ((Number) status.get("readCount"))
                            .longValue()
                    );

                json.append(",\"recipientCount\":")
                    .append(
                        ((Number) status.get("recipientCount"))
                            .longValue()
                    );

                json.append("}");
            }

            json.append("]");

            response.setContentType(
                "application/json; charset=UTF-8"
            );

            response.setCharacterEncoding("UTF-8");

            response.setHeader(
                "Cache-Control",
                "no-cache, no-store, must-revalidate"
            );

            response.setHeader(
                "X-Content-Type-Options",
                "nosniff"
            );

            response.getWriter().write(
                json.toString()
            );

        } catch (RuntimeException e) {

            getServletContext().log(
                "既読状況の取得に失敗しました。",
                e
            );

            if (!response.isCommitted()) {
                response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "既読状況を取得できませんでした。"
                );
            }
        }
    }

    /**
     * POST：現在開いているチャットルームを既読にする
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

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

        long chatRoomId;

        try {

            chatRoomId = Long.parseLong(
                request.getParameter("roomId")
            );

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

            if (!chatMessageDAO.isRoomMember(
                    chatRoomId,
                    loginUser.getUserId())) {

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
                );
                return;
            }

            // 最終閲覧日時を更新
            chatMessageDAO.markAsRead(
                chatRoomId,
                loginUser.getUserId()
            );

            response.setStatus(
                HttpServletResponse.SC_NO_CONTENT
            );

            response.setHeader(
                "Cache-Control",
                "no-cache, no-store"
            );

        } catch (RuntimeException e) {

            getServletContext().log(
                "チャットの既読更新に失敗しました。",
                e
            );

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "既読状態を更新できませんでした。"
            );
        }
    }
}