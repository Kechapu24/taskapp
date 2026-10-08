package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.OrgDAO;
import dao.UserDAO;
import model.Organization;
import model.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final OrgDAO orgDAO = new OrgDAO();

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("LoginServlet実行");

        String email = request.getParameter("email");
        String inputPassword = request.getParameter("password");

        User user = userDAO.findByEmail(email);

        // 認証失敗
        if (user == null || !user.getPassword().equals(inputPassword)) {
            request.setAttribute(
                    "errorMessage",
                    "メールアドレスまたはパスワードが違います");

            request.getRequestDispatcher("/login.jsp")
                   .forward(request, response);
            return;
        }

        // 認証成功
        HttpSession session = request.getSession();
        session.setAttribute("loginUser", user);

        List<Organization> orgList =
                orgDAO.getOrganizationsForUser(user.getUserId());

        session.setAttribute("orgList", orgList);

        if (!orgList.isEmpty()) {
            session.setAttribute(
                    "activeOrgId",
                    orgList.get(0).getOrgId());
        } else {
            session.setAttribute("activeOrgId", null);
        }

        // ログイン成功後は index.jsp へ遷移
        response.sendRedirect(
                request.getContextPath() + "/index.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }
}