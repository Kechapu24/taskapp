ALTER TABLE activity_log
ADD COLUMN org_id INTEGER;

ALTER TABLE activity_log
ADD CONSTRAINT activity_log_org_id_fkey
FOREIGN KEY (org_id)
REFERENCES organization(org_id)
ON DELETE SET NULL;