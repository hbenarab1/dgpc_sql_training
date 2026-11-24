-- Vérifier la base et les types avant toute création.
SELECT current_database();
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema='dgpc'
AND table_name IN ('agents','units','interventions')
ORDER BY table_name, ordinal_position;
SELECT * FROM dgpc.units WHERE unit_id=2;
SELECT * FROM dgpc.interventions WHERE intervention_id=3;
