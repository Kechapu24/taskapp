package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.OrgDAO;
import model.Member;
import model.Organization;

@WebServlet("/organization/detail")
public class OrganizationDetailServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
    	System.out.println("OrganizationDetailServlet 実行");
        String orgIdParam =
                request.getParameter("orgId");

        if (orgIdParam == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin.jsp");

            return;
        }

        int orgId =
                Integer.parseInt(orgIdParam);

        OrgDAO dao =
                new OrgDAO();

        Organization org =
                dao.getOrganizationById(orgId);
        
        List<Member> memberList =
                dao.getMembersByOrgId(orgId);

        request.setAttribute(
                "organization",
                org);
        
        request.setAttribute(
                "memberList",
                memberList);

        request.getRequestDispatcher(
                "/organization_detail.jsp")
                .forward(
                    request,
                    response);
    }
}