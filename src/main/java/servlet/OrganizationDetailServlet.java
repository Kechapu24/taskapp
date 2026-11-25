//org_id受取

//団体情報取得

//所属メンバー取得

//organization_detail.jspへ渡す

package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.User;

@WebServlet("/organization/detail")
public class OrganizationDetailServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User loginUser =
                (User) session.getAttribute("loginUser");

        // 未ログイン対策
        if (loginUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp");

            return;
        }

        // 将来利用する
        String orgId =
                request.getParameter("orgId");

        request.setAttribute("orgId", orgId);

        request.getRequestDispatcher(
                "/organization_detail.jsp")
                .forward(request, response);
    }
}
