package servlet;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ChatMessageDAO;
import model.User;

/**
 * チャットメッセージの削除を担当するServlet
 */
@WebServlet("/chatDeleteMessage")
public class ChatDeleteMessageServlet extends HttpServlet {

    private final ChatMessageDAO chatMessageDAO =
        new ChatMessageDAO();

    /**
     * POST：自分が送信したメッセージを削除する
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");

        // ログイン確認
        HttpSession session =
            request.getSession(false);

        if (session == null ||
                session.getAttribute("loginUser") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        User loginUser =
            (User) session.getAttribute("loginUser");

        // チャットルームIDとメッセージIDを取得
        long chatRoomId;
        long messageId;

        try {

            chatRoomId = Long.parseLong(
                request.getParameter("roomId")
            );

            messageId = Long.parseLong(
                request.getParameter("messageId")
            );

            if (chatRoomId <= 0 || messageId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "削除対象のIDが不正です。"
            );
            return;
        }

        try {

            // チャット参加者か確認
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

            // 自分が送信したメッセージだけを削除
            boolean deleted =
                chatMessageDAO.deleteMessage(
                    messageId,
                    chatRoomId,
                    loginUser.getUserId()
                );

            if (!deleted) {

                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "削除できるメッセージが見つかりません。"
                );
                return;
            }

            // 削除後は同じチャット画面に戻る
            response.sendRedirect(
                request.getContextPath()
                + "/chatMessage?roomId="
                + chatRoomId
            );

        } catch (RuntimeException e) {

            getServletContext().log(
                "チャットメッセージの削除に失敗しました。",
                e
            );

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "メッセージを削除できませんでした。"
            );
        }
    }
}