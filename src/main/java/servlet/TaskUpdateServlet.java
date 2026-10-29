package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/TaskUpdateServlet")
public class TaskUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // フォームから送信されたデータの受け取り
        String taskIdStr = request.getParameter("taskId");
        String taskName = request.getParameter("taskName");
        String projectIdStr = request.getParameter("projectId");
        String description = request.getParameter("description");
        String status = request.getParameter("status");
        String priority = request.getParameter("priority");
        String startDateStr = request.getParameter("startDate");
        String dueDateStr = request.getParameter("dueDate");

        int taskId = 0;
        int projectId = 1;
        try {
            if (taskIdStr != null && !taskIdStr.isEmpty()) {
                taskId = Integer.parseInt(taskIdStr);
            }
            if (projectIdStr != null && !projectIdStr.isEmpty()) {
                projectId = Integer.parseInt(projectIdStr);
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        String url = "jdbc:postgresql://172.16.1.119:5432/taskapp";
        String dbUser = "taskuser";
        String dbPassword = "taskpass";

        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(url, dbUser, dbPassword);
            conn.setAutoCommit(false); // トランザクション開始

            // task テーブルの更新処理
            String sql = "UPDATE task SET task_name = ?, project_id = ?, description = ?, status = ?, priority = ?, start_date = ?, due_date = ? WHERE task_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, taskName);
            pstmt.setInt(2, projectId);
            pstmt.setString(3, description);
            pstmt.setString(4, status);
            pstmt.setString(5, priority);
            
            if (startDateStr != null && !startDateStr.isEmpty()) {
                pstmt.setDate(6, java.sql.Date.valueOf(startDateStr));
            } else {
                pstmt.setNull(6, java.sql.Types.DATE);
            }

            if (dueDateStr != null && !dueDateStr.isEmpty()) {
                pstmt.setDate(7, java.sql.Date.valueOf(dueDateStr));
            } else {
                pstmt.setNull(7, java.sql.Types.DATE);
            }

            pstmt.setInt(8, taskId);
            pstmt.executeUpdate();
            pstmt.close();

            conn.commit(); // コミット
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }

        // 処理完了後、カレンダー画面にリダイレクト
        response.sendRedirect("calendar.jsp");
    }
}