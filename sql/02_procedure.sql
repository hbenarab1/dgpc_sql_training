CREATE OR REPLACE PROCEDURE dgpc.sp_update_response_time(
    p_intervention_id INT, p_minutes INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_minutes IS NULL OR p_minutes < 0 THEN
        RAISE EXCEPTION 'Invalid response time';
    END IF;
    UPDATE dgpc.interventions AS i
    SET response_minutes = p_minutes
    WHERE i.intervention_id = p_intervention_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Intervention not found';
    END IF;
    RAISE NOTICE 'Intervention % updated', p_intervention_id;
END;
$$;
