package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/TaskCreateServlet")
public class TaskCreateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // フォームから送信されたパラメータの取得
        String taskName = request.getParameter("taskName");
        String projectIdStr = request.getParameter("projectId");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String priority = request.getParameter("priority");
        String startDate = request.getParameter("startDate");
        String dueDate = request.getParameter("dueDate");
        String userIdStr = request.getParameter("userId"); // 担当者ID

        String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
        String dbUser = "taskuser";
        String dbPassword = "taskpass";

        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPassword);
            conn.setAutoCommit(false); // トランザクション開始

            // 1. task テーブルにインサートし、自動採番された task_id を取得する
            String taskSql = "INSERT INTO task (project_id, task_name, description, status, priority, start_date, due_date) VALUES (?, ?, ?, ?, ?, ?, ?)";
            int generatedTaskId = -1;

            try (PreparedStatement pstmt = conn.prepareStatement(taskSql, Statement.RETURN_GENERATED_KEYS)) {
                pstmt.setInt(1, Integer.parseInt(projectIdStr));
                pstmt.setString(2, taskName);
                pstmt.setString(3, description);
                pstmt.setString(4, (status != null && !status.isEmpty()) ? status : "未着手");
                pstmt.setString(5, priority);

                // 開始日
                if (startDate != null && !startDate.isEmpty()) {
                    pstmt.setDate(6, java.sql.Date.valueOf(startDate));
                } else {
                    pstmt.setNull(6, Types.DATE);
                }

                // 期限
                if (dueDate != null && !dueDate.isEmpty()) {
                    pstmt.setDate(7, java.sql.Date.valueOf(dueDate));
                } else {
                    pstmt.setNull(7, Types.DATE);
                }

                pstmt.executeUpdate();

                // 自動採番された task_id の取得
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedTaskId = rs.getInt(1);
                    }
                }
            }

            // 2. 担当者が選択されている場合、task_assignee テーブルにインサート
            if (userIdStr != null && !userIdStr.isEmpty() && generatedTaskId != -1) {
                String assigneeSql = "INSERT INTO task_assignee (task_id, user_id) VALUES (?, ?)";
                try (PreparedStatement pstmtAssign = conn.prepareStatement(assigneeSql)) {
                    pstmtAssign.setInt(1, generatedTaskId);
                    pstmtAssign.setInt(2, Integer.parseInt(userIdStr));
                    pstmtAssign.executeUpdate();
                }
            }

            conn.commit(); // コミット
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }

        // 処理完了後、カレンダー画面にリダイレクト
        response.sendRedirect("calendar.jsp");
    }
}