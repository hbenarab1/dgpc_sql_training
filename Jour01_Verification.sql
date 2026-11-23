-- Non-destructive readiness checks; run before the exercises.
SELECT current_database() AS database_name, current_user AS login;
SELECT table_name,column_name FROM information_schema.columns WHERE table_schema='dgpc' AND table_name IN ('units','agents','interventions','intervention_types','intervention_agents','intervention_vehicles') ORDER BY table_name,ordinal_position;
SELECT status,COUNT(*) AS total FROM dgpc.interventions GROUP BY status ORDER BY status;
SELECT COUNT(*) AS interventions FROM dgpc.interventions;
