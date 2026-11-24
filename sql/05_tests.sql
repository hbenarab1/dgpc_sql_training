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
