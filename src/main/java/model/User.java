package model;

/**
 * users テーブル1行分を表すモデルクラス。
 * role は「システム全体」での権限(admin / member)。
 *
 * password はログイン直後の照合処理でのみ使い、
 * それ以外の画面(taskboard.jspなど)には絶対に表示しないこと。
 *
 * アイコンの画像データそのものは、重くなるためここには持たない。
 * 「アイコンが設定済みか」(iconSet)だけを持ち、
 * 画像は /icon?userId=... (IconServlet) から取得する。
 */
public class User {
    private int userId;
    private String userName;
    private String email;
    private String password; // 照合用。表示には使わない
    private String role;
    private boolean iconSet; // アイコンが設定されているか

    public User(int userId, String userName, String email, String password, String role) {
        this(userId, userName, email, password, role, false);
    }

    public User(int userId, String userName, String email, String password,
            String role, boolean iconSet) {
        this.userId = userId;
        this.userName = userName;
        this.email = email;
        this.password = password;
        this.role = role;
        this.iconSet = iconSet;
    }

    public int getUserId() { return userId; }
    public String getUserName() { return userName; }
    public String getEmail() { return email; }
    public String getPassword() { return password; }
    public String getRole() { return role; }

    /** JSPから ${loginUser.iconSet} で使う */
    public boolean isIconSet() { return iconSet; }
    public void setIconSet(boolean iconSet) { this.iconSet = iconSet; }

    public boolean isAdmin() {
        return "admin".equals(role);
    }
}