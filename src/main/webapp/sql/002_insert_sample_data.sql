INSERT INTO users (user_name, email, password, role) VALUES
('東', 'higashi@example.com', 'password', 'admin'),
('坂田', 'sakata@example.com', 'password', 'member'),
('清水', 'shimizu@example.com', 'password', 'member'),
('宮崎', 'miyazaki@example.com', 'password', 'member');

INSERT INTO project (project_name, description) VALUES
('タスク管理アプリ開発', 'システム開発演習で作成するタスク管理アプリ'),
('卒業研究', 'にじさんじ甲子園DB開発');

INSERT INTO project_member (project_id, user_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(2, 1);

INSERT INTO task (
project_id,
task_name,
description,
status,
priority,
start_date,
due_date
) VALUES
(
1,
'ER図作成',
'データベース設計を行う',
'進行中',
'高',
'2026-06-01',
'2026-06-15'
),
(
1,
'タスクボード画面作成',
'JSPとCSSで画面作成',
'未着手',
'中',
'2026-06-05',
'2026-06-20'
),
(
1,
'通知機能設計',
'通知テーブルと画面設計',
'未着手',
'低',
'2026-06-10',
'2026-06-25'
);

INSERT INTO task_assignee (task_id, user_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

INSERT INTO tag (tag_name) VALUES
('設計'),
('画面'),
('DB'),
('通知');

INSERT INTO task_tag (task_id, tag_id) VALUES
(1, 1),
(1, 3),
(2, 2),
(3, 4);

INSERT INTO comment (
task_id,
user_id,
comment_text
) VALUES
(
1,
1,
'ER図の初版を作成しました'
),
(
1,
2,
'リレーションを追加しました'
),
(
2,
3,
'CSS調整中です'
);

INSERT INTO attachment (
task_id,
uploaded_by,
file_name,
file_path
) VALUES
(
1,
1,
'ERD.png',
'/uploads/ERD.png'
),
(
2,
3,
'wireframe.pdf',
'/uploads/wireframe.pdf'
);

INSERT INTO activity_log (
user_id,
project_id,
task_id,
action,
detail
) VALUES
(
1,
1,
1,
'TASK_CREATE',
'ER図作成タスクを登録'
),
(
3,
1,
2,
'TASK_UPDATE',
'タスクボード画面作成を更新'
);

INSERT INTO notification (
user_id,
project_id,
task_id,
type,
message
) VALUES
(
2,
1,
1,
'ASSIGNED',
'ER図作成タスクの担当者に設定されました'
),
(
3,
1,
2,
'COMMENT',
'タスクボード画面作成にコメントが追加されました'
);
