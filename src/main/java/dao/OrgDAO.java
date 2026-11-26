package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Member;
import model.Organization;
import util.DBConnection;

public class OrgDAO {

	/** 指定ユーザーが所属している団体の一覧を取得する */
	public List<Organization> getOrganizationsForUser(int userId) {
		String sql = "SELECT o.org_id, o.org_name, om.org_role, o.created_at" +
				"FROM organization o " +
				"JOIN org_member om ON o.org_id = om.org_id " +
				"WHERE om.user_id = ? " +
				"ORDER BY o.org_name";

		List<Organization> result = new ArrayList<>();

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {

			stmt.setInt(1, userId);

			try (ResultSet rs = stmt.executeQuery()) {
				while (rs.next()) {
					result.add(new Organization(
							rs.getInt("org_id"),
							rs.getString("org_name"),
							rs.getString("org_role"),
							rs.getTimestamp("created_at")));
				}
			}

		} catch (SQLException e) {
			throw new RuntimeException("団体一覧の取得中にDBエラーが発生しました", e);
		}

		return result;
	}

	/**
	 * 指定IDの団体を取得
	 */
	public Organization getOrganizationById(int orgId) {

		String sql = "SELECT org_id, org_name, created_at " +
				"FROM organization " +
				"WHERE org_id = ?";

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement stmt = conn.prepareStatement(sql)) {

			stmt.setInt(1, orgId);

			try (ResultSet rs = stmt.executeQuery()) {

				if (rs.next()) {

					System.out.println(
							"orgName=" +
									rs.getString("org_name"));

					return new Organization(
							rs.getInt("org_id"),
							rs.getString("org_name"),
							null,
							rs.getTimestamp("created_at"));
				}
			}

		} catch (SQLException e) {

			throw new RuntimeException(
					"団体情報取得中にエラー",
					e);
		}

		return null;
	}

	/**
	 * 指定団体の所属メンバー一覧を取得
	 */
	public List<Member> getMembersByOrgId(int orgId) {

		String sql = "SELECT u.user_id, " +
				"u.user_name, " +
				"om.org_role " +
				"FROM org_member om " +
				"JOIN users u " +
				"ON om.user_id = u.user_id " +
				"WHERE om.org_id = ? " +
				"ORDER BY u.user_name";

		List<Member> result = new ArrayList<>();

		try (Connection conn = DBConnection.getConnection();

				PreparedStatement stmt = conn.prepareStatement(sql)) {

			stmt.setInt(1, orgId);

			try (ResultSet rs = stmt.executeQuery()) {

				while (rs.next()) {

					result.add(
							new Member(
									rs.getInt("user_id"),
									rs.getString("user_name"),
									rs.getString("org_role")));
				}
			}

		} catch (SQLException e) {

			throw new RuntimeException(
					"メンバー一覧取得中にDBエラーが発生しました",
					e);
		}

		return result;
	}

	//	今後の追加予定
	//    getOrganization(int orgId)
	//    getMembersByOrgId(int orgId)
	//    updateOrganizationName(...)
	//    deleteOrganization(...)
	//    changeMemberRole(...)
	//    removeMember(...)

	/**
	 * 指定ユーザーが指定org_idに本当に所属しているかを確認する。
	 * 切り替えボタンで、他人の団体IDを勝手に指定されるのを防ぐために使う。
	 */
	public boolean isUserMemberOfOrg(int userId, int orgId) {
		String sql = "SELECT 1 FROM org_member WHERE user_id = ? AND org_id = ?";

		try (Connection conn = DBConnection.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql)) {

			stmt.setInt(1, userId);
			stmt.setInt(2, orgId);

			try (ResultSet rs = stmt.executeQuery()) {
				return rs.next();
			}

		} catch (SQLException e) {
			throw new RuntimeException("所属確認中にDBエラーが発生しました", e);
		}
	}
}
