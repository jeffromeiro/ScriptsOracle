SELECT e0.name, e0.value AS value_child_0, e1.value AS value_child_1
 FROM v$sql_optimizer_env e0, v$sql_optimizer_env e1
 WHERE e0.sql_id = e1.sql_id
 AND e0.sql_id = '&sql_id'
 AND e0.child_number = 0
 AND e1.child_number = 1
 AND e0.name = e1.name
 AND e0.value <> e1.value;