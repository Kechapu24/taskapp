package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ActivityLogDAO;
import model.User;
import util.DBConnection;

@WebServlet("/organization/create")
public class OrganizationCreateServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String orgName = request.getParameter("orgName");

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        Connection conn = null;

        try {

            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            //--------------------------------------
            // ① organization登録
            //--------------------------------------
            String insertOrgSql =
                    "INSERT INTO organization (org_name) "
                  + "VALUES (?)";

            int orgId;

            try (
                PreparedStatement stmt =
                    conn.prepareStatement(
                        insertOrgSql,
                        Statement.RETURN_GENERATED_KEYS)
            ) {

                stmt.setString(1, orgName);
                stmt.executeUpdate();

                try (ResultSet rs =
                        stmt.getGeneratedKeys()) {

                    if (!rs.next()) {
                        throw new Exception(
                            "団体IDの取得に失敗しました");
                    }

                    orgId = rs.getInt(1);
                }
            }

            //--------------------------------------
            // ② 作成者をadminとして登録
            //--------------------------------------
            String memberSql =
                    "INSERT INTO org_member "
                  + "(org_id, user_id, org_role) "
                  + "VALUES (?, ?, ?)";

            try (
                PreparedStatement stmt =
                    conn.prepareStatement(memberSql)
            ) {

                stmt.setInt(1, orgId);
                stmt.setInt(2, loginUser.getUserId());
                stmt.setString(3, "admin");

                stmt.executeUpdate();
            }

            //--------------------------------------
            // ③ コミット
            //--------------------------------------
            conn.commit();

            //--------------------------------------
            // ④ ログ出力
            //--------------------------------------
            
            System.out.println("ログ登録前");
            new ActivityLogDAO().insert(
                    loginUser.getUserId(),
                    orgId,
                    "ORG_CREATE",
                    "団体「" + orgName + "」を作成しました"
            );
            System.out.println("ログ登録後");

            //--------------------------------------
            // ⑤ 管理画面へ戻る
            //--------------------------------------
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin.jsp");

        } catch (Exception e) {

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ignore) {
            }

            throw new ServletException(e);

        } finally {

            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }
}