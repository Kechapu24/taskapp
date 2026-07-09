DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS activity_log;
DROP TABLE IF EXISTS attachment;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS task_tag;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS task_assignee;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS project_member;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS personal_task;

CREATE TABLE project (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(30) DEFAULT 'member'
);

CREATE TABLE project_member (
    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, user_id),
    FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE task (
    task_id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(30) DEFAULT '未着手',
    priority VARCHAR(30),
    start_date DATE,
    due_date DATE,
    FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE CASCADE
);

CREATE TABLE task_assignee (
    task_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    PRIMARY KEY (task_id, user_id),
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE tag (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE task_tag (
    task_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (task_id, tag_id),
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tag(tag_id) ON DELETE CASCADE
);

CREATE TABLE comment (
    comment_id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE attachment (
    attachment_id SERIAL PRIMARY KEY,
    task_id INTEGER NOT NULL,
    uploaded_by INTEGER NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE activity_log (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    project_id INTEGER,
    task_id INTEGER,
    action VARCHAR(100) NOT NULL,
    detail TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE SET NULL,
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE SET NULL
);

CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    project_id INTEGER,
    task_id INTEGER,
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES project(project_id) ON DELETE SET NULL,
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON DELETE SET NULL
);

CREATE TABLE personal_task (
    personal_task_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    status VARCHAR(30) DEFAULT '進行中',
    due_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
is_read = false
);
UPDATE notifications
SET is_read = true
WHERE user_id = ?
);
CREATE TABLE notifications(
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    type VARCHAR(30),
    task_id INT,
    project_id INT,
    detail TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME
);
CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    task_name VARCHAR(100),
    project_name VARCHAR(100),
    type VARCHAR(30),
    detail TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);