--shows whether peeking was used and the related execution statistics for each child curso

SELECT child_number, peeked, executions, rows_processed, buffer_gets
 FROM v$sql_cs_statistics
 WHERE sql_id = '&&sql_id'
 ORDER BY child_number;
 
 
--The view v$sql_cs_selectivity shows the selectivity range related to each predicate of each child cursor 

SELECT child_number, predicate, low, high
 FROM v$sql_cs_selectivity
 WHERE sql_id = '&sql_id'
 ORDER BY child_number;
 
 undef sql_id