
BEGIN;

-- 現在の件数が確認時から変わっていないか検証
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM tag) <> 8
       OR (SELECT COUNT(*) FROM task_tag) <> 24 THEN
        RAISE EXCEPTION 'タグデータの件数が変化しています。移行を中止します。';
    END IF;
END
$$;

-- 現在のタスクとタグの関係を一時保存
CREATE TEMP TABLE tag_link_backup
ON COMMIT DROP AS
SELECT
    tt.task_id,
    tg.tag_name,
    p.user_id,
    p.org_id
FROM task_tag tt
JOIN tag tg ON tt.tag_id = tg.tag_id
JOIN task t ON tt.task_id = t.task_id
JOIN project p ON t.project_id = p.project_id;

-- バックアップ件数を確認
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM tag_link_backup) <> 24 THEN
        RAISE EXCEPTION 'タグのバックアップ件数が一致しません。';
    END IF;
END
$$;

-- 古いタグ情報と関連付けを削除
DELETE FROM task_tag;
DELETE FROM tag;

-- 既存のtagテーブルにカラム追加
ALTER TABLE tag
ADD COLUMN user_id INTEGER,
ADD COLUMN org_id INTEGER,
ADD COLUMN color VARCHAR(7) NOT NULL DEFAULT '#6B7280';

-- 個人・団体への外部キー
ALTER TABLE tag
ADD CONSTRAINT tag_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE;

ALTER TABLE tag
ADD CONSTRAINT tag_org_id_fkey
FOREIGN KEY (org_id)
REFERENCES organization(org_id)
ON DELETE CASCADE;

-- 個人か団体のどちらか一方に所属
ALTER TABLE tag
ADD CONSTRAINT chk_tag_scope
CHECK (
    (user_id IS NOT NULL AND org_id IS NULL)
    OR
    (user_id IS NULL AND org_id IS NOT NULL)
);

-- カラーコードを検証
ALTER TABLE tag
ADD CONSTRAINT chk_tag_color
CHECK (color ~ '^#[0-9A-Fa-f]{6}$');

-- タグ名の全体UNIQUEを解除
ALTER TABLE tag
DROP CONSTRAINT tag_tag_name_key;

-- 同じユーザー内では同名タグ禁止
CREATE UNIQUE INDEX uq_tag_user_name
ON tag (user_id, tag_name)
WHERE user_id IS NOT NULL;

-- 同じ団体内では同名タグ禁止
CREATE UNIQUE INDEX uq_tag_org_name
ON tag (org_id, tag_name)
WHERE org_id IS NOT NULL;

-- 既存タグを所属先ごとに再作成
INSERT INTO tag (tag_name, user_id, org_id)
SELECT DISTINCT
    tag_name,
    user_id,
    org_id
FROM tag_link_backup;

-- タスクとタグを再び関連付け
INSERT INTO task_tag (task_id, tag_id)
SELECT
    b.task_id,
    tg.tag_id
FROM tag_link_backup b
JOIN tag tg
    ON tg.tag_name = b.tag_name
    AND tg.user_id IS NOT DISTINCT FROM b.user_id
    AND tg.org_id IS NOT DISTINCT FROM b.org_id;

-- 全ての紐づけが正しく復元されたか検証
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM task_tag) <> 24 THEN
        RAISE EXCEPTION 'タグの復元件数が一致しません。';
    END IF;

    IF EXISTS (
        SELECT task_id, tag_name, user_id, org_id
        FROM tag_link_backup

        EXCEPT

        SELECT
            tt.task_id,
            tg.tag_name,
            p.user_id,
            p.org_id
        FROM task_tag tt
        JOIN tag tg ON tt.tag_id = tg.tag_id
        JOIN task t ON tt.task_id = t.task_id
        JOIN project p ON t.project_id = p.project_id
    ) THEN
        RAISE EXCEPTION 'タグの復元内容が一致しません。';
    END IF;
END
$$;

COMMIT;
