<%@ page import="model.User" %>

<%
User loginUser =
    (User) session.getAttribute("loginUser");

if (loginUser == null) {

    response.sendRedirect(
        request.getContextPath() + "/login.jsp"
    );

    return;
}

int loginUserId =
    loginUser.getUserId();

Integer activeOrgId =
    (Integer) session.getAttribute("activeOrgId");

boolean personalMode =
    (activeOrgId == null);
%>