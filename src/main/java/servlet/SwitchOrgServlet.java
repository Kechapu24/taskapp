
package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.OrgDAO;
import dao.UserDAO;
import model.User;

@WebServlet("/switchOrg")
public class SwitchOrgServlet extends HttpServlet {

	private final OrgDAO orgDAO = new OrgDAO();
	private final UserDAO userDAO = new UserDAO();

	@Override
	protected void doPost(
			HttpServletRequest request,
			HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		// 未ログインならログイン画面へ
		if (session == null ||
				session.getAttribute("loginUser") == null) {

			response.sendRedirect(
					request.getContextPath() + "/login");
			return;
		}

		User loginUser = (User) session.getAttribute("loginUser");

		String orgIdParam = request.getParameter("orgId");

		// nullなら個人モード
		Integer nextOrgId = null;

		// 団体が指定されている場合
		if (orgIdParam != null &&
				!orgIdParam.isEmpty() &&
				!"0".equals(orgIdParam)) {

			int requestedOrgId;

			try {
				requestedOrgId = Integer.parseInt(orgIdParam);
			} catch (NumberFormatException e) {
				response.sendError(
						HttpServletResponse.SC_BAD_REQUEST,
						"団体IDが不正です");
				return;
			}

			// 指定された団体に所属しているか確認
			if (!orgDAO.isUserMemberOfOrg(
					loginUser.getUserId(), requestedOrgId)) {

				response.sendError(
						HttpServletResponse.SC_FORBIDDEN,
						"この団体にはアクセスできません");
				return;
			}

			nextOrgId = requestedOrgId;
		}

		// 最後に選択したモードをDBへ保存
		userDAO.saveLastOrgId(
				loginUser.getUserId(), nextOrgId);

		// 現在のセッションにも反映
		session.setAttribute("activeOrgId", nextOrgId);

		// タスクボードへ移動
		response.sendRedirect(
				request.getContextPath() + "/taskboard.jsp");
	}
}
