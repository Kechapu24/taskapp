

package servlet;
 
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.OrgDAO;
 
/**
 * ヘッダー/サイドバーの団体切り替えセレクトメニューから呼ばれるサーブレット。
 * orgId=0(または空)が送られてきたら「個人」モードとして扱う。
 *
 * 重要: 送られてきたorgIdを鵜呑みにせず、必ず
 * 「本当にこのユーザーがその団体に所属しているか」をDBで確認してから
 * セッションを更新する(URL改ざんによる他人の団体の覗き見を防ぐため)。
 */
@WebServlet("/switchOrg")
public class SwitchOrgServlet extends HttpServlet {
 
    private final OrgDAO orgDAO = new OrgDAO();
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
 
        if (session == null || session.getAttribute("loginUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
 
        User loginUser = (User) session.getAttribute("loginUser");
        String orgIdParam = request.getParameter("orgId");
 
        if (orgIdParam == null || orgIdParam.isEmpty() || "0".equals(orgIdParam)) {
            // 「個人」モードへの切り替え
            session.setAttribute("activeOrgId", null);
        } else {
            int requestedOrgId = Integer.parseInt(orgIdParam);
 
            if (orgDAO.isUserMemberOfOrg(loginUser.getUserId(), requestedOrgId)) {
                session.setAttribute("activeOrgId", requestedOrgId);
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "この団体にはアクセスできません");
                return;
            }
        }
 
        response.sendRedirect(request.getContextPath() + "/taskboard.jsp");
    }
}
 
