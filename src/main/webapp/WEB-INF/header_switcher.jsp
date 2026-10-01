<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.Organization" %>
<%@ page import="java.util.List" %>

<%
    List<Organization> orgList = (List<Organization>) session.getAttribute("orgList");
    Object activeOrgIdObj = session.getAttribute("activeOrgId");
    Integer activeOrgId = (activeOrgIdObj != null) ? (Integer) activeOrgIdObj : null;
%>

<form action="<%= request.getContextPath() %>/switchOrg" method="post" style="display:inline;">
    <select name="orgId" onchange="this.form.submit()">
        <option value="0" <%= (activeOrgId == null) ? "selected" : "" %>>個人</option>

        <% if (orgList != null) {
            for (Organization org : orgList) {
        %>
            <option value="<%= org.getOrgId() %>"
                <%= (activeOrgId != null && activeOrgId == org.getOrgId()) ? "selected" : "" %>>
                <%= org.getOrgName() %>
                <%= "admin".equals(org.getOrgRole()) ? "(管理者)" : "" %>
            </option>
        <%  }
        } %>
    </select>
</form>
