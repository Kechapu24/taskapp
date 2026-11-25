
BEGIN;

-- チャット添付ファイル管理テーブル
CREATE TABLE IF NOT EXISTS chat_attachment (
    chat_attachment_id BIGSERIAL PRIMARY KEY,

    -- 添付ファイルが属するメッセージ
    message_id BIGINT NOT NULL
        REFERENCES chat_message(message_id)
        ON DELETE CASCADE,

    -- 元のファイル名
    original_file_name VARCHAR(255) NOT NULL,

    -- サーバー内部で使用する保存ファイル名
    stored_file_name VARCHAR(100) NOT NULL UNIQUE,

    -- ファイル形式
    content_type VARCHAR(127) NOT NULL,

    -- ファイル容量（バイト）
    file_size BIGINT NOT NULL,

    -- アップロードしたユーザー
    uploaded_by INTEGER
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    -- 登録日時
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- 1バイト以上10MB以下
    CONSTRAINT chk_chat_attachment_size
        CHECK (file_size BETWEEN 1 AND 10485760)
);

-- メッセージごとの添付ファイル検索
CREATE INDEX IF NOT EXISTS idx_chat_attachment_message
ON chat_attachment(message_id);

-- ユーザーごとの添付ファイル検索
CREATE INDEX IF NOT EXISTS idx_chat_attachment_uploaded_by
ON chat_attachment(uploaded_by);

COMMIT;
