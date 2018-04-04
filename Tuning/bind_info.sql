PROMPT
PROMPT is_bind_sensitive indicates not only whether bind variable peeking was used to generate the execution plan but also whether the execution plan depends on the peeked value.
PROMPT
PROMPT is_bind_aware indicates whether the cursor is using extended cursor sharing
PROMPT
PROMPT is_shareable indicates whether the cursor can be shared
PROMPT

SELECT child_number, is_bind_sensitive, is_bind_aware, is_shareable
 FROM v$sql
 WHERE sql_id = '&&SQL_ID'
 ORDER BY child_number;

SELECT child_number, peeked, executions, rows_processed, buffer_gets
 FROM v$sql_cs_statistics
 WHERE sql_id = '&SQL_ID'
 ORDER BY child_number;

SELECT child_number, predicate, low, high
 FROM v$sql_cs_selectivity
 WHERE sql_id = '&SQL_ID'
 ORDER BY child_number;

select * from V$SQL_CS_HISTOGRAM
 WHERE sql_id = '&SQL_ID'
 ORDER BY child_number;