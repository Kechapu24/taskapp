
package model;

import java.sql.Timestamp;

public class Notification {

    private int notificationId;
    private String type;
    private String message;
    private String taskName;
    private String projectName;
    private Timestamp createdAt;
    private boolean isRead;

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

    public String getType() {
        return type;
    }

    public String getMessage() {
        return message;
    }

    public String getTaskName() {
        return taskName;
    }

    public String getProjectName() {
        return projectName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public boolean isRead() {
        return isRead;
    }
}
