ALTER TABLE notification
ADD COLUMN IF NOT EXISTS org_id INTEGER;

ALTER TABLE notification
ADD CONSTRAINT fk_notification_organization
FOREIGN KEY (org_id)
REFERENCES organization(org_id)
ON DELETE SET NULL;