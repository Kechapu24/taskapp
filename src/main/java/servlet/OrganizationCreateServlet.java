package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ActivityLogDAO;
import dao.OrgDAO;
import dao.UserDAO;
import model.Organization;
import model.User;
import util.DBConnection;


@WebServlet("/organization/create")
public class OrganizationCreateServlet extends HttpServlet {

	private final UserDAO userDAO = new UserDAO();
	private final OrgDAO orgDAO = new OrgDAO();
	
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
         // ④ 作成した団体へ自動切り替え
         //--------------------------------------

         // 最後に選択した団体としてDBに保存
         userDAO.saveLastOrgId(
                 loginUser.getUserId(),
                 orgId
         );

         // 所属団体一覧を最新状態に更新
         List<Organization> orgList =
                 orgDAO.getOrganizationsForUser(
                         loginUser.getUserId()
                 );

         session.setAttribute("orgList", orgList);

         // 現在の作業モードを新しい団体に切り替える
         session.setAttribute("activeOrgId", orgId);

            //--------------------------------------
            // ⑤ ログ出力
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
            // ⑥ 管理画面へ戻る
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