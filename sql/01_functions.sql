CREATE OR REPLACE FUNCTION dgpc.fn_count_agents(p_unit_id INT)
RETURNS BIGINT LANGUAGE sql STABLE AS $$
    SELECT COUNT(*) FROM dgpc.agents AS a
    WHERE a.unit_id = p_unit_id;
$$;

CREATE OR REPLACE FUNCTION dgpc.fn_interventions_by_unit(p_unit_id INT)
RETURNS TABLE(intervention_id INT, response_minutes INT, status TEXT)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN QUERY
    SELECT i.intervention_id, i.response_minutes, i.status
    FROM dgpc.interventions AS i
    WHERE i.unit_id = p_unit_id;
END;
$$;
