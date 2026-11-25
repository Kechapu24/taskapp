import java.sql.Timestamp;

/**
 * 通知情報を保持するモデルクラス
 */
public class Notification {

    private int notificationId;
    private String type;
    private String message;
    private String taskName;
    private String projectName;
    private Timestamp createdAt;
    private boolean isRead;

    // デフォルトコンストラクタ
    public Notification() {
    }

    // 通知情報をまとめて設定するコンストラクタ
    public Notification(
            int notificationId,
            String type,
            String message,
            String taskName,
            String projectName,
            Timestamp createdAt,
            boolean isRead) {

        this.notificationId = notificationId;
        this.type = type;
        this.message = message;
        this.taskName = taskName;
        this.projectName = projectName;
        this.createdAt = createdAt;
        this.isRead = isRead;
    }

    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getTaskName() {
        return taskName;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        this.isRead = read;
    }
}
