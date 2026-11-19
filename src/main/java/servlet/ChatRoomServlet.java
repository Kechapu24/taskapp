
package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ChatRoomDAO;
import model.User;

/**
 * チャットルームの取得・作成を担当するServlet
 *
 * userIdが指定されていない場合：団体全体チャット
 * userIdが指定されている場合：個人チャット
 */
@WebServlet("/chatRoom")
public class ChatRoomServlet extends HttpServlet {

    private final ChatRoomDAO chatRoomDAO =
            new ChatRoomDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // =====================================
        // 1. リクエスト情報の確認
        // =====================================

        String targetUserIdParam =
            request.getParameter("userId");

        System.out.println("==================================");
        System.out.println("ChatRoomServlet 開始");
        System.out.println("リクエストURL: " + request.getRequestURL());
        System.out.println("URLパラメータ: " + request.getQueryString());
        System.out.println("取得したuserId: " + targetUserIdParam);
        System.out.println("==================================");


        // =====================================
        // 2. ログイン状態を確認
        // =====================================

        HttpSession session =
            request.getSession(false);

        if (session == null ||
                session.getAttribute("loginUser") == null) {

            System.out.println("ログインしていません。");

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );

            return;
        }

        User loginUser =
            (User) session.getAttribute("loginUser");

        System.out.println(
            "ログインユーザーID: " + loginUser.getUserId()
        );


        // =====================================
        // 3. 現在選択中の団体を取得
        // =====================================

        Integer activeOrgId =
            (Integer) session.getAttribute("activeOrgId");

        System.out.println(
            "現在の団体ID: " + activeOrgId
        );

        // 個人モードの場合
        if (activeOrgId == null) {

            System.out.println(
                "個人モードのためチャットルームを作成しません。"
            );

            response.sendRedirect(
                request.getContextPath() + "/chat.jsp"
            );

            return;
        }


        // =====================================
        // 4. チャットルームの取得・作成
        // =====================================

        try {

            long chatRoomId;

            // ---------------------------------
            // 個人チャット
            // ---------------------------------

            if (targetUserIdParam != null &&
                    !targetUserIdParam.trim().isEmpty()) {

                System.out.println(
                    "個人チャットの処理に入りました。"
                );

                int targetUserId;

                try {

                    targetUserId =
                        Integer.parseInt(targetUserIdParam);

                    if (targetUserId <= 0) {
                        throw new NumberFormatException();
                    }

                } catch (NumberFormatException e) {

                    System.out.println(
                        "ユーザーIDの形式が不正です。"
                    );

                    response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "チャット相手のIDが不正です。"
                    );

                    return;
                }

                System.out.println(
                    "チャット相手のユーザーID: " + targetUserId
                );

                // 個人チャットルームを取得または作成
                chatRoomId =
                    chatRoomDAO.getOrCreateDirectRoom(
                        activeOrgId,
                        loginUser.getUserId(),
                        targetUserId
                    );

                System.out.println(
                    "個人チャットルームID: " + chatRoomId
                );

            }

            // ---------------------------------
            // 団体全体チャット
            // ---------------------------------

            else {

                System.out.println(
                    "団体全体チャットの処理に入りました。"
                );

                // 団体全体チャットルームを取得または作成
                chatRoomId =
                    chatRoomDAO.getOrCreateGroupRoom(
                        activeOrgId,
                        loginUser.getUserId()
                    );

                System.out.println(
                    "団体チャットルームID: " + chatRoomId
                );
            }


            // =================================
            // 5. チャット画面へ移動
            // =================================

            String redirectUrl =
                request.getContextPath()
                + "/chatMessage?roomId="
                + chatRoomId;

            System.out.println(
                "移動先URL: " + redirectUrl
            );

            System.out.println(
                "ChatRoomServlet 正常終了"
            );

            System.out.println("==================================");

            response.sendRedirect(redirectUrl);


        } catch (IllegalArgumentException e) {

            System.out.println(
                "チャットルーム作成時の入力エラー: "
                + e.getMessage()
            );

            e.printStackTrace();

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                e.getMessage()
            );


        } catch (RuntimeException e) {

            System.out.println(
                "チャットルーム作成時にエラーが発生しました。"
            );

            e.printStackTrace();

            getServletContext().log(
                "チャットルームの取得・作成に失敗しました。",
                e
            );

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "チャットルームを開けませんでした。"
            );
        }
    }
}
