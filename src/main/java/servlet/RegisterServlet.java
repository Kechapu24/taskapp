package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.UserDAO;

/**
 * 新規登録処理。
 *
 * 前提: register.jsp のフォームが次の name で送信していること。
 *   username / email / password / passwordConfirm
 * (違う場合は、下の getParameter の名前を register.jsp に合わせて直す)
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /**
     * アドレス欄に直接URLを入力した場合や、履歴から開いた場合はGETで届く。
     * このサーブレットはフォーム送信(POST)専用なので、
     * GETのときは登録画面(register.jsp)へ案内する。
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8"); // 日本語の名前が文字化けしないように

        // register.jsp の name 属性と一致させる(username は全部小文字)
        String userName = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String passwordConfirm = request.getParameter("passwordConfirm");

        // 失敗してregister.jspに戻るとき、入力欄に残すために渡しておく
        // (パスワードは安全のため渡さない)
        request.setAttribute("username", userName);
        request.setAttribute("email", email);

        // 未入力チェック
        if (isBlank(userName) || isBlank(email) || isBlank(password)) {
            backToForm(request, response, "すべての項目を入力してください");
            return;
        }

        // パスワードと確認用パスワードが一致しているか
        if (!password.equals(passwordConfirm)) {
            backToForm(request, response, "パスワードが一致しません");
            return;
        }

        // 登録(emailが既に使われていたら false が返る)
        boolean created = userDAO.insert(userName.trim(), email.trim(), password);

        if (!created) {
            backToForm(request, response, "このメールアドレスは既に登録されています");
            return;
        }

        // 成功: ログイン画面へ(role は DB の初期値 'member' になる)
        // ?registered=1 は「登録直後ですよ」という目印。login.jsp がメッセージ表示に使う
        response.sendRedirect(request.getContextPath() + "/login.jsp?registered=1");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void backToForm(HttpServletRequest request, HttpServletResponse response,
            String message) throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
}