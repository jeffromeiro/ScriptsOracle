SELECT address, hash_value, child_number, sql_text
 FROM v$sql
 WHERE sql_text LIKE '%online discount%' AND sql_text NOT LIKE '%v$sql%';

 
DELETE plan_table;

 INSERT INTO plan_table (operation, options, object_node, object_owner,
object_name, optimizer, search_columns, id,
parent_id, position, cost, cardinality, bytes,
other_tag, partition_start, partition_stop,
partition_id, other, distribution, cpu_cost,
io_cost, temp_space, access_predicates,
filter_predicates)
SELECT operation, options, object_node, object_owner, object_name,
optimizer, search_columns, id, parent_id, position, cost,
 cardinality, bytes, other_tag, partition_start, partition_stop,
 partition_id, other, distribution, cpu_cost, io_cost, temp_space,
 access_predicates, filter_predicates
 FROM v$sql_plan
 WHERE address = '0000000055DCD888'
 AND hash_value = 4132422484
 AND child_number = 0;

 SELECT * FROM table(dbms_xplan.display);
