
-- 最後に選択した個人・団体モードを保存する
-- NULL : 個人モード
-- 数値 : 最後に選択した団体のorg_id

ALTER TABLE users
ADD COLUMN IF NOT EXISTS last_org_id INTEGER
REFERENCES organization(org_id)
ON DELETE SET NULL;
