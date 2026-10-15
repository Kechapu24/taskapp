package model;

/**
 * users テーブル1行分を表すモデルクラス。
 * role は「システム全体」での権限(admin / member)。
 *
 * password はログイン直後の照合処理でのみ使い、
 * それ以外の画面(taskboard.jspなど)には絶対に表示しないこと。
 */
public class User {
    private int userId;
    private String userName;
    private String email;
    private String password; // 照合用。表示には使わない
    private String role;

    public User(int userId, String userName, String email, String password, String role) {
        this.userId = userId;
        this.userName = userName;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public int getUserId() { return userId; }
    public String getUserName() { return userName; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public String getRole() { return role; }

    public boolean isAdmin() {
        return "admin".equals(role);
    }
}