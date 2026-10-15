<%@ page pageEncoding="UTF-8" import="java.sql.*" trimDirectiveWhitespaces="true" %>
<%
String theme = (String) session.getAttribute("currentTheme");
String bgColor = (String) session.getAttribute("currentBgColor");
String textColor = (String) session.getAttribute("currentTextColor");
String fontSize = (String) session.getAttribute("currentFontSize");

if (theme == null) {

    theme = "light";
    bgColor = "#ffffff";
    textColor = "#333333";
    fontSize = "medium";

    String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
    String dbUser = "taskuser";
    String dbPass = "taskpass";

    int currentUserId = 1;

    try {
        Class.forName("org.postgresql.Driver");

        try (
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            PreparedStatement pstmt = conn.prepareStatement(
                "SELECT theme, bg_color, text_color, font_size " +
                "FROM user_settings WHERE user_id = ?"
            )
        ) {
            pstmt.setInt(1, currentUserId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    theme = rs.getString("theme");
                    bgColor = rs.getString("bg_color");
                    textColor = rs.getString("text_color");
                    fontSize = rs.getString("font_size");
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    session.setAttribute("currentTheme", theme);
    session.setAttribute("currentBgColor", bgColor);
    session.setAttribute("currentTextColor", textColor);
    session.setAttribute("currentFontSize", fontSize);
}

request.setAttribute("themeValue", theme);
request.setAttribute("themeBgColor", bgColor);
request.setAttribute("themeTextColor", textColor);
request.setAttribute("themeFontSize", fontSize);
%>