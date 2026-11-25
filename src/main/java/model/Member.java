package model;

public class Member {

    private int userId;

    private String userName;

    private String orgRole;

    public Member(
            int userId,
            String userName,
            String orgRole) {

        this.userId = userId;
        this.userName = userName;
        this.orgRole = orgRole;
    }

    public int getUserId() {
        return userId;
    }

    public String getUserName() {
        return userName;
    }

    public String getOrgRole() {
        return orgRole;
    }
}