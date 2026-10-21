-- ユーザーアイコン(プロフィール画像)用の列を users テーブルに追加する。
--
-- ・既存の行や、既存のコードには影響しない(列を足すだけ。未設定は NULL)
-- ・IF NOT EXISTS を付けているので、2回実行してもエラーにならない
-- ・画像そのものを icon_data に保存する。DBは全員で共有しているが、
--   Tomcatは各自のPCで動いているため、画像をファイルで保存すると
--   他のメンバーのPCからは見えなくなるため。
--
-- 実行する順番: 先にこのSQLを実行してから、新しいJavaコードを動かすこと
-- (列が無い状態で動かすと、ログイン時のSQLがエラーになる)

ALTER TABLE users ADD COLUMN IF NOT EXISTS icon_type VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS icon_data BYTEA;

-- icon_type : 画像の種類(image/png など)。アイコン未設定なら NULL
-- icon_data : 画像データ本体。アイコン未設定なら NULL