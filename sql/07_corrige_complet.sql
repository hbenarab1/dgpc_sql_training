-- Exécuter uniquement sur la copie individuelle dgpc_training.
-- Vérifier les résultats de 00 avant de poursuivre.
-- Vérifier la base et les types avant toute création.
SELECT current_database();
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema='dgpc'
AND table_name IN ('agents','units','interventions')
ORDER BY table_name, ordinal_position;
SELECT * FROM dgpc.units WHERE unit_id=2;
SELECT * FROM dgpc.interventions WHERE intervention_id=3;


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


-- Tests positifs : aucune modification persistante.
SELECT dgpc.fn_count_agents(2);
SELECT unit_id, unit_name, dgpc.fn_count_agents(unit_id) AS total_agents
FROM dgpc.units ORDER BY unit_id;
SELECT * FROM dgpc.fn_interventions_by_unit(2);
BEGIN;
CALL dgpc.sp_update_response_time(3,15);
SELECT intervention_id,response_minutes FROM dgpc.interventions
WHERE intervention_id=3;
ROLLBACK;
BEGIN;
UPDATE dgpc.interventions SET response_minutes=25 WHERE intervention_id=3;
SELECT * FROM dgpc.intervention_response_audit ORDER BY audit_id;
ROLLBACK;
-- Tests négatifs : sélectionner et exécuter séparément les lignes commentées.
-- CALL dgpc.sp_update_response_time(3,-10);
-- CALL dgpc.sp_update_response_time(3,NULL);
-- CALL dgpc.sp_update_response_time(-1,20);
-- UPDATE dgpc.interventions SET response_minutes=-15 WHERE intervention_id=3;
-- Après une erreur dans une transaction explicite : ROLLBACK;


BEGIN;
SELECT dgpc.fn_count_agents(2);
SELECT * FROM dgpc.fn_interventions_by_unit(2);
SELECT response_minutes FROM dgpc.interventions WHERE intervention_id=3;
SELECT count(*) AS audit_avant FROM dgpc.intervention_response_audit;
CALL dgpc.sp_update_response_time(3,30);
SELECT * FROM dgpc.intervention_response_audit ORDER BY audit_id;
-- Aucun nouvel audit si la valeur reste identique.
UPDATE dgpc.interventions SET response_minutes=30 WHERE intervention_id=3;
SELECT count(*) AS audit_apres FROM dgpc.intervention_response_audit;
ROLLBACK;
SELECT response_minutes FROM dgpc.interventions WHERE intervention_id=3;
SELECT count(*) AS audit_final FROM dgpc.intervention_response_audit;
