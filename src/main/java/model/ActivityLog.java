package model;

import java.sql.Timestamp;

public class ActivityLog {

    private int logId;
    private String userName;
    private String action;
    private String detail;
    private Timestamp createdAt;

    public ActivityLog(
            int logId,
            String userName,
            String action,
            String detail,
            Timestamp createdAt) {

        this.logId = logId;
        this.userName = userName;
        this.action = action;
        this.detail = detail;
        this.createdAt = createdAt;
    }

    public int getLogId() {
        return logId;
    }

    public String getUserName() {
        return userName;
    }

    public String getAction() {
        return action;
    }

    public String getDetail() {
        return detail;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }
}