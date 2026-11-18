<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.*"%>
<%@ page import="model.User"%>
<%@ page import="util.DBConnection"%>

<%
request.setCharacterEncoding("UTF-8");

User loginUser =
    (User) session.getAttribute(
        "loginUser"
    );

if (loginUser == null) {

    response.sendRedirect(
        request.getContextPath()
        + "/login.jsp"
    );

    return;
}


String tagIdStr =
    request.getParameter(
        "tag_id"
    );

String color =
    request.getParameter(
        "color"
    );


if (tagIdStr == null
        || !tagIdStr.matches("\\d+")
        || color == null
        || !color.matches(
            "^#[0-9A-Fa-f]{6}$"
        )) {

    response.sendRedirect(
        request.getContextPath()
        + "/taskboard.jsp"
    );

    return;
}


int tagId =
    Integer.parseInt(
        tagIdStr
    );

Integer activeOrgId =
    (Integer) session.getAttribute(
        "activeOrgId"
    );


String sql;

if (activeOrgId == null) {

    sql =
          "UPDATE tag "
        + "SET color = ? "
        + "WHERE tag_id = ? "
        + "AND user_id = ? "
        + "AND org_id IS NULL";

} else {

    sql =
          "UPDATE tag "
        + "SET color = ? "
        + "WHERE tag_id = ? "
        + "AND org_id = ? "
        + "AND user_id IS NULL";
}


try (
    Connection conn =
        DBConnection.getConnection();

    PreparedStatement stmt =
        conn.prepareStatement(sql)
) {

    stmt.setString(
        1,
        color
    );

    stmt.setInt(
        2,
        tagId
    );

    if (activeOrgId == null) {

        stmt.setInt(
            3,
            loginUser.getUserId()
        );

    } else {

        stmt.setInt(
            3,
            activeOrgId
        );
    }

    stmt.executeUpdate();
}


response.sendRedirect(
    request.getContextPath()
    + "/taskboard.jsp"
);
%>