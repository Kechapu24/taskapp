
package model;
 
/**
 * ログイン中のユーザーから見た「所属団体」1件分を表すモデルクラス。
 * orgRole は「その団体の中だけ」での権限(admin / member)。
 * User.role(システム全体の権限)とは別物。
 */
public class Organization {
    private int orgId;
    private String orgName;
    private String orgRole;
 
    public Organization(int orgId, String orgName, String orgRole) {
        this.orgId = orgId;
        this.orgName = orgName;
        this.orgRole = orgRole;
    }
 
    public int getOrgId() { return orgId; }
    public String getOrgName() { return orgName; }
    public String getOrgRole() { return orgRole; }
}
 
