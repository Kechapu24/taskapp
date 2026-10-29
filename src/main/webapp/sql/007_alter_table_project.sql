BEGIN;

ALTER TABLE project
ADD COLUMN user_id INTEGER;

ALTER TABLE project
ADD CONSTRAINT project_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;

ALTER TABLE project
ALTER COLUMN org_id DROP NOT NULL;

ALTER TABLE project
ADD CONSTRAINT chk_project_scope
CHECK (
    (user_id IS NOT NULL AND org_id IS NULL)
    OR
    (user_id IS NULL AND org_id IS NOT NULL)
);

COMMIT;

-- 個人モードと団体モードで識別して表示するコンテンツを変更するための変更