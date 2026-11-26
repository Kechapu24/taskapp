
package model;

import java.sql.Timestamp;

/**
 * ログイン中のユーザーから見た「所属団体」1件分を表すモデルクラス。
 * orgRole は「その団体の中だけ」での権限(admin / member)。
 * User.role(システム全体の権限)とは別物。
 */
public class Organization {

    private int orgId;
    private String orgName;
    private String orgRole;
    private Timestamp createdAt;

    // 既存のコンストラクタ（互換性を維持）
    public Organization(int orgId, String orgName, String orgRole) {
        this.orgId = orgId;
        this.orgName = orgName;
        this.orgRole = orgRole;
    }

    // 作成日時も受け取るコンストラクタ
    public Organization(int orgId, String orgName,
                        String orgRole, Timestamp createdAt) {
        this.orgId = orgId;
        this.orgName = orgName;
        this.orgRole = orgRole;
        this.createdAt = createdAt;
    }

    public int getOrgId() {
        return orgId;
    }

    public String getOrgName() {
        return orgName;
    }

    public String getOrgRole() {
        return orgRole;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }
}
