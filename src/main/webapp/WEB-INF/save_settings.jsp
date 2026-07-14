<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. 送られてきたデータの文字化けを防ぐ
    request.setCharacterEncoding("UTF-8");

    // 2. settings.jspのfetchから送られてきたデータを受け取る
    String theme = request.getParameter("theme");
    String fontSize = request.getParameter("fontSize");
    String bgColor = request.getParameter("bgColor");
    String textColor = request.getParameter("textColor");

    // ※ログイン機能ができるまでの仮のユーザーID（settings.jspに合わせたID）
    int userId = 1;

    // 3. データベース接続情報
    String url = "jdbc:postgresql://172.16.1.94:5432/taskapp";
    String dbUser = "taskuser";
    String dbPass = "taskpass";

    // データがちゃんと送られてきているかチェック
    if (theme != null && fontSize != null) {
        try {
            Class.forName("org.postgresql.Driver");
            try (Connection conn = DriverManager.getConnection(url, dbUser, dbPass)) {
                
                // 4. PostgreSQL特有の「無ければINSERT、あればUPDATE」をするSQL（ON CONFLICT）
                String sql = "INSERT INTO user_settings (user_id, theme, bg_color, text_color, font_size) "
                           + "VALUES (?, ?, ?, ?, ?) "
                           + "ON CONFLICT (user_id) DO UPDATE SET "
                           + "theme = EXCLUDED.theme, "
                           + "bg_color = EXCLUDED.bg_color, "
                           + "text_color = EXCLUDED.text_color, "
                           + "font_size = EXCLUDED.font_size";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, userId);
                    pstmt.setString(2, theme);
                    pstmt.setString(3, bgColor);
                    pstmt.setString(4, textColor);
                    pstmt.setString(5, fontSize);
                    
                    // SQLを実行してデータベースを更新
                    pstmt.executeUpdate();
                }
            }
            
            // 処理が成功したことをJavaScript側に返す
            out.print("success");
            
        } catch (Exception e) {
            // エラーが起きた場合はEclipseのコンソールにエラーを出力し、JS側にもエラーを伝える
            e.printStackTrace();
            response.setStatus(500); 
            out.print("error: " + e.getMessage());
        }
    } else {
        // データが足りない場合のエラー処理
        response.setStatus(400); 
        out.print("bad request");
    }
%>