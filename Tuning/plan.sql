-- Plano com registros estimados, atuais e atuais por operações

set lines 250 pages 5000
col operation form a30

SELECT   * FROM table(DBMS_XPLAN.display_cursor('&&sql_id', NULL, 'IOSTATS LAST'));

WITH X
       AS (SELECT   sql_id
             FROM   v$sql
            WHERE   sql_id = '&sql_id'
                    AND ROWNUM = 1)
  SELECT   DEPTH
          ,LPAD(' ', 2 * DEPTH) || operation operation
          ,options
          ,object_name
          ,last_starts
          ,CARDINALITY "EST_ROWS"
          ,last_output_rows "ACTUAL_ROWS"
          ,last_output_rows / last_starts "ACTUAL_ROWS_PER_OP"
    FROM      v$sql_plan_statistics_all
           NATURAL JOIN
              x
ORDER BY   id;

undef sql_id