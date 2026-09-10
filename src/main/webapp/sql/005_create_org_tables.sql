DROP TABLE IF EXISTS org_member;
DROP TABLE IF EXISTS organization;

CREATE TABLE org_member (
    org_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    org_role VARCHAR(30) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (org_id, user_id),
    FOREIGN KEY (org_id) REFERENCES organization(org_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE organization (
    org_id SERIAL PRIMARY KEY,
    org_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
