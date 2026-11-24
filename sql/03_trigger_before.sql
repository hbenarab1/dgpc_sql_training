CREATE OR REPLACE FUNCTION dgpc.fn_validate_response_time()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.response_minutes < 0 THEN
        RAISE EXCEPTION 'Negative response time';
    END IF;
    RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER trg_validate_response_time
BEFORE INSERT OR UPDATE ON dgpc.interventions
FOR EACH ROW
EXECUTE FUNCTION dgpc.fn_validate_response_time();
