
BEGIN;

-- ========================================
-- チャットルーム
-- room_type: group / direct / task
-- ========================================
CREATE TABLE IF NOT EXISTS chat_room (
    chat_room_id BIGSERIAL PRIMARY KEY,
    room_type VARCHAR(20) NOT NULL,
    org_id INTEGER,
    task_id INTEGER,
    direct_user_low_id INTEGER,
    direct_user_high_id INTEGER,
    room_name VARCHAR(100),
    created_by INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_chat_room_type
        CHECK (room_type IN ('group', 'direct', 'task')),

    CONSTRAINT fk_chat_room_org
        FOREIGN KEY (org_id)
        REFERENCES organization(org_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_chat_room_task
        FOREIGN KEY (task_id)
        REFERENCES task(task_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_chat_room_user_low
        FOREIGN KEY (direct_user_low_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_chat_room_user_high
        FOREIGN KEY (direct_user_high_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_chat_room_creator
        FOREIGN KEY (created_by)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_chat_room_members
        CHECK (
            (
                room_type = 'group'
                AND org_id IS NOT NULL
                AND task_id IS NULL
                AND direct_user_low_id IS NULL
                AND direct_user_high_id IS NULL
            )
            OR
            (
                room_type = 'direct'
                AND org_id IS NOT NULL
                AND task_id IS NULL
                AND direct_user_low_id IS NOT NULL
                AND direct_user_high_id IS NOT NULL
                AND direct_user_low_id < direct_user_high_id
            )
            OR
            (
                room_type = 'task'
                AND org_id IS NULL
                AND task_id IS NOT NULL
                AND direct_user_low_id IS NULL
                AND direct_user_high_id IS NULL
            )
        )
);

-- 同じ団体のグループチャットは1つだけ
CREATE UNIQUE INDEX IF NOT EXISTS uq_chat_room_group
    ON chat_room(org_id)
    WHERE room_type = 'group';

-- 同じ団体の同じ2人の個別チャットは1つだけ
CREATE UNIQUE INDEX IF NOT EXISTS uq_chat_room_direct
    ON chat_room(org_id, direct_user_low_id, direct_user_high_id)
    WHERE room_type = 'direct';

-- 1つのタスクに対するチャットルームは1つだけ
CREATE UNIQUE INDEX IF NOT EXISTS uq_chat_room_task
    ON chat_room(task_id)
    WHERE room_type = 'task';


-- ========================================
-- チャットルーム参加者
-- ========================================
CREATE TABLE IF NOT EXISTS chat_room_member (
    chat_room_id BIGINT NOT NULL,
    user_id INTEGER NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP,
    is_muted BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (chat_room_id, user_id),

    FOREIGN KEY (chat_room_id)
        REFERENCES chat_room(chat_room_id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_chat_room_member_user
    ON chat_room_member(user_id);


-- ========================================
-- チャットメッセージ
-- ========================================
CREATE TABLE IF NOT EXISTS chat_message (
    message_id BIGSERIAL PRIMARY KEY,
    chat_room_id BIGINT NOT NULL,
    sender_id INTEGER,
    message_text TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edited_at TIMESTAMP,
    deleted_at TIMESTAMP,

    FOREIGN KEY (chat_room_id)
        REFERENCES chat_room(chat_room_id)
        ON DELETE CASCADE,

    FOREIGN KEY (sender_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_chat_message_text
        CHECK (LENGTH(BTRIM(message_text)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_chat_message_room_created
    ON chat_message(chat_room_id, created_at, message_id);

COMMIT;
