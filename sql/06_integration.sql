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
