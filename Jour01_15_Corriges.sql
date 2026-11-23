-- DGPC Jour 01 | SQL exercises | READ ONLY
-- Base expected: dgpc_training; schema: dgpc
-- C05 assumes status = 'closed'; inspect actual values before running.
DO $guard$ BEGIN IF current_database() <> 'dgpc_training' THEN RAISE EXCEPTION 'Wrong database: %',current_database(); END IF; END $guard$;
-- A01 Afficher les dix interventions les plus récentes.
SELECT intervention_id, started_at, status FROM dgpc.interventions ORDER BY started_at DESC NULLS LAST, intervention_id DESC LIMIT 10;

-- A02 Afficher les interventions dont le délai de réponse dépasse 20 minutes.
SELECT intervention_id, response_minutes FROM dgpc.interventions WHERE response_minutes > 20 ORDER BY response_minutes DESC, intervention_id;

-- A03 Compter les interventions par statut.
SELECT status, COUNT(*) AS total FROM dgpc.interventions GROUP BY status ORDER BY status;

-- A04 Afficher les interventions du 1er au 15 février 2026 inclus.
SELECT intervention_id, started_at FROM dgpc.interventions WHERE started_at >= TIMESTAMP '2026-02-01' AND started_at < TIMESTAMP '2026-02-16' ORDER BY started_at, intervention_id;

-- A05 Identifier les interventions dont le délai de réponse est inconnu (NULL).
SELECT intervention_id, response_minutes FROM dgpc.interventions WHERE response_minutes IS NULL ORDER BY intervention_id;

-- B01 Afficher le numéro d’intervention, le nom de l’unité et le type.
SELECT i.intervention_id,u.unit_name,t.type_name FROM dgpc.interventions i JOIN dgpc.units u ON u.unit_id=i.unit_id JOIN dgpc.intervention_types t ON t.type_id=i.type_id ORDER BY i.intervention_id;

-- B02 Compter les interventions de chaque unité, y compris celles sans intervention.
SELECT u.unit_id,u.unit_name,COUNT(i.intervention_id) AS total FROM dgpc.units u LEFT JOIN dgpc.interventions i ON i.unit_id=u.unit_id GROUP BY u.unit_id,u.unit_name ORDER BY u.unit_id;

-- B03 Calculer le délai moyen de réponse par type d’intervention.
SELECT t.type_id,t.type_name,ROUND(AVG(i.response_minutes)::numeric,2) AS avg_minutes FROM dgpc.intervention_types t LEFT JOIN dgpc.interventions i ON i.type_id=t.type_id GROUP BY t.type_id,t.type_name ORDER BY t.type_id;

-- B04 Compter les interventions par unité et par statut.
SELECT u.unit_name,i.status,COUNT(*) AS total FROM dgpc.interventions i JOIN dgpc.units u ON u.unit_id=i.unit_id GROUP BY u.unit_id,u.unit_name,i.status ORDER BY u.unit_name,i.status;

-- B05 Afficher les unités ayant plus de 80 interventions.
SELECT u.unit_id,u.unit_name,COUNT(i.intervention_id) AS total FROM dgpc.units u LEFT JOIN dgpc.interventions i ON i.unit_id=u.unit_id GROUP BY u.unit_id,u.unit_name HAVING COUNT(i.intervention_id)>80 ORDER BY total DESC;

-- C01 Identifier le mois ayant le plus d’interventions.
SELECT date_trunc('month',started_at) AS mois,COUNT(*) AS total FROM dgpc.interventions WHERE started_at IS NOT NULL GROUP BY 1 ORDER BY total DESC,mois ASC LIMIT 1;

-- C02 Identifier les unités sans intervention.
SELECT u.unit_id,u.unit_name FROM dgpc.units u LEFT JOIN dgpc.interventions i ON i.unit_id=u.unit_id WHERE i.intervention_id IS NULL ORDER BY u.unit_id;

-- C03 Compter les interventions sans doublons après jointure agents/véhicules.
SELECT COUNT(DISTINCT i.intervention_id) AS total_unique FROM dgpc.interventions i LEFT JOIN dgpc.intervention_agents ia ON ia.intervention_id=i.intervention_id LEFT JOIN dgpc.intervention_vehicles iv ON iv.intervention_id=i.intervention_id;

-- C04 Compter les agents affectés à chaque intervention.
SELECT i.intervention_id,COUNT(DISTINCT ia.agent_id) AS agents_count FROM dgpc.interventions i LEFT JOIN dgpc.intervention_agents ia ON ia.intervention_id=i.intervention_id GROUP BY i.intervention_id ORDER BY i.intervention_id;

-- C05 Calculer le délai moyen de réponse des interventions clôturées par unité.
SELECT u.unit_id,u.unit_name,ROUND(AVG(i.response_minutes)::numeric,2) AS avg_minutes FROM dgpc.units u JOIN dgpc.interventions i ON i.unit_id=u.unit_id WHERE i.status='closed' GROUP BY u.unit_id,u.unit_name ORDER BY u.unit_id;
