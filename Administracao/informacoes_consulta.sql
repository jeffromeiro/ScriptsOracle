-- owner = NKM
-- object name = PROFILESTOREDATA

--------------------------------------------------------------
---- SQL_ID: 7j6h57scxqrmg                                 ---
---- UPDATE PROFILESTOREDATA SET DATA=:1 WHERE ID=:2       ---
--------------------------------------------------------------
set lines 250 pages 5000
spool log.txt

---------------------------------------
--- TAMANHO DA TABELA E DOS ÍNDICES ---
---------------------------------------
PROMPT TAMANHO DA TABELA
SELECT SEGMENT_NAME, SEGMENT_TYPE, BYTES/1024/1024 FROM DBA_SEGMENTS WHERE SEGMENT_NAME='PROFILESTOREDATA' AND OWNER='NKM';

PROMPT TAMANHO DO ÍNDICE
SELECT SEGMENT_NAME, SEGMENT_TYPE, BYTES/1024/1024 FROM DBA_SEGMENTS WHERE OWNER='NKM' AND SEGMENT_NAME IN
(SELECT INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME='PROFILESTOREDATA' AND OWNER='NKM');

-------------------------------
--- FRAGMENTAÇAO DA TABELA  ---
-------------------------------

PROMPT FRAGMENTAÇÃO DA TABELA
select table_name, partition_name, last_analyzed, round((blocks*8),2)||'kb' "Tamanho Fragmentado", round((num_rows*avg_row_len/1024),2)||'kb' "Tamanho atual"
 from dba_tab_partitions
 where table_name = 'PROFILESTOREDATA'
 and table_owner='NKM';

--------------------------------------------
--- CLUSTERING FACTOR DOS ÍNDICES        ---
--------------------------------------------

PROMPT CLUSTERING FACTOR
select index_owner, index_name, partition_name, last_analyzed, num_rows, clustering_factor
 from dba_ind_partitions
 where index_owner = 'NKM'
 and index_name in (SELECT INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME='PROFILESTOREDATA' AND OWNER='NKM');

 
------------------------------------------ 
--- ESTRUTURA DA TABELA E DOS ÍNDICES  ---
------------------------------------------


set long 50000 
set lines 200
set longchunksize 200
set head off

 begin
dbms_metadata.set_transform_param
           ( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS_AS_ALTER', true );
            dbms_metadata.set_transform_param
          ( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false );
            dbms_metadata.set_transform_param
          ( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE );
  end;
/
select dbms_metadata.get_ddl(upper('table'),upper('PROFILESTOREDATA'),upper('NKM')) from dual;


select dbms_metadata.get_ddl( 'INDEX', index_name, upper('NKM') ) as create_index
  from dba_indexes
 where owner = upper('NKM')
   and table_name = upper('PROFILESTOREDATA');

set long 10000
set head on
set echo off
undefine type name owner 



-----------------------------------------------
-- EXECUÇÃO DO COMANDO NA LINHA DO TEMPO   ----
-----------------------------------------------

PROMPT EXECUÇÃO DO COMANDO NA LINHA DO TEMPO
select a.snap_id,b.begin_interval_time, a.EXECUTIONS_delta, 
       a.ELAPSED_TIME_delta / 1000000 "ELAPSED SEG",
       ROUND(a.ELAPSED_TIME_delta / 1000000 / a.EXECUTIONS_delta, 2) "EXEC SEG",
       a.ROWS_PROCESSED_delta / a.EXECUTIONS_delta "ROWS POR EXEC",
       a.BUFFER_GETS_delta / a.EXECUTIONS_delta "BUFFER POR EXEC",
       a.PLAN_HASH_VALUE
  from dba_hist_sqlstat a, DBA_HIST_SNAPSHOT b
 where a.snap_id = b.snap_id and a.sql_id = '7j6h57scxqrmg' and a.executions_delta > 0 and a.SNAP_ID > 12000
order by a.snap_id;


-----------------------------------------------
--     EXPLAIN PLAN DO UPDATE              ----
-----------------------------------------------
PROMPT EXPLAIN DO UPDATE
explain plan for UPDATE NKM.PROFILESTOREDATA SET DATA=:1 WHERE ID=:2;
select * from table(dbms_xplan.display);

PROMPT EXPLAIN SOMENTE DO SELECT
explain plan for SELECT * FROM NKM.PROFILESTOREDATA WHERE ID=:2;
select * from table(dbms_xplan.display);


PROMPT FIM DO SCRIPT
spool off