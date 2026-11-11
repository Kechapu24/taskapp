package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ActivityLogDAO;
import dao.OrgDAO;
import dao.UserDAO;
import model.Organization;
import model.User;

/**
 * ログイン処理。
 *
 * 流れ:
 * 1. email で UserDAO.findByEmail() を呼び、該当ユーザーを取得
 * 2. 取得できたユーザーのpasswordと、入力されたpasswordをJava側で比較
 * 3. 一致すれば、OrgDAOで所属団体一覧を取得してセッションに保存
 * 4. role(システム全体の権限)に応じて admin.jsp か taskboard.jsp へ遷移
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

	private final UserDAO userDAO = new UserDAO();
	private final OrgDAO orgDAO = new OrgDAO();

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String email = request.getParameter("email");
		String inputPassword = request.getParameter("password");

		User user = userDAO.findByEmail(email);

		// emailが存在しない、またはパスワードが一致しない場合は認証失敗
		if (user == null || !user.getPassword().equals(inputPassword)) {
			request.setAttribute("errorMessage", "メールアドレスまたはパスワードが違います");
			request.setAttribute("email", email); // login.jspで入力欄に戻すため
			request.getRequestDispatcher("/login.jsp").forward(request, response);
			return;
		}

		// 認証成功: セッションにユーザー情報を保存
		HttpSession session = request.getSession();
		session.setAttribute("loginUser", user);
		
		//ログイン情報を保持させる
		new ActivityLogDAO().insert(
			    user.getUserId(),
			    null,
			    "LOGIN",
			    "ログインしました");
		System.out.println("LOGIN LOG INSERT");
		

		// このユーザーが所属する団体一覧を取得してセッションに保存
		List<Organization> orgList = orgDAO.getOrganizationsForUser(user.getUserId());
		session.setAttribute("orgList", orgList);

		// 最後に選択していた団体IDをDBから取得
		Integer lastOrgId = userDAO.findLastOrgId(user.getUserId());

		// 前回選択していた団体に現在も所属しているか確認
		if (lastOrgId != null &&
				orgDAO.isUserMemberOfOrg(user.getUserId(), lastOrgId)) {

			// 前回の団体モードを復元
			session.setAttribute("activeOrgId", lastOrgId);

		} else {

			// 初回ログイン、前回が個人モード、または団体から脱退した場合
			session.setAttribute("activeOrgId", null);
		}
		// role に応じて遷移先を分岐
		if (user.isAdmin()) {
			response.sendRedirect(request.getContextPath() + "/admin.jsp");
		} else {
			response.sendRedirect(request.getContextPath() + "/taskboard.jsp");
		}
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// ログインフォームの表示のみ
		request.getRequestDispatcher("/login.jsp").forward(request, response);
	}
}