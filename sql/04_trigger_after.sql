CREATE TABLE IF NOT EXISTS dgpc.intervention_response_audit (
    audit_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    intervention_id INT NOT NULL,
    old_minutes INT,
    new_minutes INT,
    changed_at TIMESTAMPTZ DEFAULT clock_timestamp(),
    changed_by TEXT DEFAULT CURRENT_USER
);
CREATE OR REPLACE FUNCTION dgpc.fn_audit_response_time()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dgpc.intervention_response_audit
        (intervention_id, old_minutes, new_minutes)
    VALUES (NEW.intervention_id, OLD.response_minutes,
            NEW.response_minutes);
    RETURN NULL;
END;
$$;
CREATE OR REPLACE TRIGGER trg_audit_response_time
AFTER UPDATE ON dgpc.interventions
FOR EACH ROW
WHEN (OLD.response_minutes IS DISTINCT FROM NEW.response_minutes)
EXECUTE FUNCTION dgpc.fn_audit_response_time();
