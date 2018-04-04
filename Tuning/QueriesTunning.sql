select * from v$memory_target_advice

select * from gv$instance

SELECT * FROM V$SGA_TARGET_ADVICE
select * from v$instance;

select username from dba_users order by 1

select sid,machine, osuser, username,module, program, event ,sql_id,ACTION
from v$session where username is not null --and SID=2045
and status = 'ACTIVE' and event <> 'Streams AQ: waiting for messages in the queue'
and username <> 'GLEYSONM'

select * from v$active_session_history
 where --session_id=61 and session_serial#=62397
 module like '%ODI%'
 
 SELECT a.PARSING_SCHEMA_NAME, a.LAST_ACTIVE_TIME, A.SQL_ID,decode(A.EXECUTIONS,0,1),
--A.FETCHES/DECODE(a.EXECUTIONS,0,1),
plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / DECODE(a.EXECUTIONS,0,1), 4) tempo_exec_seg,
       A.ELAPSED_TIME/1000000,
       round(A.CPU_TIME / 1000000 / DECODE(a.EXECUTIONS,0,1), 4) temp_cpu_seg,
       round(a.BUFFER_GETS / DECODE(a.EXECUTIONS,0,1), 4) buffer_gets_exec,
       round(a.DISK_READS / DECODE(a.EXECUTIONS,0,1), 4) disk_reads_exec, A.ROWS_PROCESSED/DECODE(a.EXECUTIONS,0,1) RPEXEC,
       A.LAST_LOAD_TIME,A.SQL_FULLTEXT
        FROM gV$SQLarea A
WHERE MODULE LIKE '%ODI%'
ORDER BY LAST_ACTIVE_TIME

 
 SELECT * FROM V$SQLAREA WHERE MODULE LIKE '%ODI%' ORDER BY LAST_ACTIVE_TIME DESC

select * from v$active_session_history where sample_time =''

select * from dba_constraints where constraint_name='TESCINP0_TESCCHQCON0_FK_I'


select * from v$sqlarea where sql_id='gb9uus4qfybxz'

select table_name, NUM_ROWS
 from dba_tables where-- table_name='TFATCRED0'
 TABLE_NAME IN
('TFATEXB0',
'TFATCRED0',
'TFATINT0',
'TFATTPOPER0',
'TFATMERC0')
AND owner ='FATP'
ORDER BY 1


select owner from dba_tables where table_name='TFATEXB0'
select table_name
 from dba_tab_COLUMNS where-- table_name='TFATCRED0'
owner ='FATP' AND COLUMN_NAME='OI_RP'
ORDER BY 1


SELECT count(*) FROM FATP.TFATCRED0

select l.inst_id, l.group#, l.thread#, l.sequence#, l.status, f.member, l.bytes/1024/1024 as MBytes
      from gv$log l, gv$logfile f
     where l.group# = f.group#
       and l.inst_id = f.inst_id
     order by l.inst_id, l.group#;

select inst_id, event,sample_time, session_id, session_serial#, p2 object_id,sql_id
from   gv$active_session_history
where  event = 'enq: TX - row lock contention'


select  sql_id, object_name tabela, owner, count(*)
from   gv$active_session_history, dba_objects
where  event = 'enq: TM - contention'
--and sample_time > sysdate - 1/24
and p2=object_id
group by sql_id, object_name, owner
order by 4 desc

select  sql_id, object_name tabela, owner, count(*)
from   dba_hist_active_sess_history, dba_objects
where  event = 'enq: TM - contention'
--and sample_time > sysdate - 1/24
--and sql_id='btsx9vha2wt5w'
and p2=object_id
group by sql_id, object_name, owner
order by 4 desc

select min(begin_interval_time) from dba_hist_snapshot

select * from Dba_Constraints WHERE 
constraint_name='CLL_F189_INV_LINE_PAR_INT_PK'

TABLE_NAME='CLL_F189_INVOICE_PARENTS_INT' AND OWNER='CLL'

SELECT * FROM DBA_TAB_COLS WHERE TABLE_NAME='CLL_F189_INVOICE_PARENTS_INT' AND OWNER='CLL'

SELECT sysdate - 1/2 FROM DUAL


select object_name, owner, object_type
from   dba_objects
where  object_id = 510057

select sample_time,sql_id,event,session_id, session_serial#, blocking_session,blocking_session_serial#, blocking_session_status
 from gv$active_session_history
 where session_id=1123 and session_serial#=53429
-- where event= 'enq: TM - contention'



select *  from gv$active_session_history where sql_id='az4xjv4dsy0j6'
 
select sample_time,sql_id,event,session_id, session_serial#, blocking_session,blocking_session_serial#, blocking_session_status
 from gv$active_session_history
 where session_id in (select blocking_session from gv$active_session_history where event= 'enq: TX - row lock contention')


aqs3w7dy59rwd

select * from gv$active_session_history

SELECT inst_id, sga_size,sga_size_factor, estd_db_time_factor FROM GV$sGA_TARGET_ADVICE

select * from dba_users
select * from dba_hist_active_sess_history

select count(*), snap_id
from dba_

SELECT * FROM DBA_HIST_SGA_TARGET_ADVICE where snap_id=234


select * from gv$database

select * from dba_triggers where owner='DLX'

select * from dba_hist_parameter where parameter_name ='remote_listener'

-- VERIFICAR SE UMA COLUNA POSSUI HISTOGRAMA

SELECT histogram, num_buckets
 FROM DBA_tab_col_statistics
 WHERE table_name = 'T1' AND column_name = 'COL1'
 AND OWNER = 'TESTE';

-- TABELA
 select t.owner,t.row_movement,
       t.table_name,
           t.num_rows,
       t.last_analyzed,S.BLOCKS,
       round(t.num_rows * t.avg_row_len / 1024 / 1024/1024 , 2) Ocupado_GB,t.avg_row_len,
       round(s.bytes / 1024 / 1024/1024, 2) Alocado_GB,partitioned
  from dba_tables t, dba_segments s
 where t.owner = s.owner
   and s.segment_name = t.table_name
   and S.SEGMENT_NAME in --('PCKWRK_HDR','PCKWRK_DTL')
          ('TESCINB0') '
       ,'GL_JE_HEADERS'
       ,'GL_JE_CATEGORIES'
       ,'GL_JE_SOURCES'
       ,'GL_CODE_COMBINATIONS'
       ,'FND_FLEX_VALUES')'
   

 


-- TABELAS MAIORES
select * from( select t.owner,
       t.table_name,
           t.num_rows,
       t.last_analyzed,S.BLOCKS,
       round((t.num_rows * t.avg_row_len) / 1024 / 1024/1024 , 2) Ocupado_GB,t.avg_row_len,
       round(s.bytes / 1024 / 1024/1024, 2) Alocado_GB
  from dba_tables t, dba_segments s
 where t.owner = s.owner
   and s.segment_name = t.table_name
   and t.partitioned='NO'
   order by Alocado_GB desc)
   where rownum < 20

-- PARTIÇÕES MAIORES
select * from( select t.table_owner,t.table_name,t.partition_name,       
           t.num_rows,
       t.last_analyzed,S.BLOCKS,
       round((t.num_rows * t.avg_row_len) / 1024 / 1024/1024 , 2) Ocupado_GB,t.avg_row_len,
       round(s.bytes / 1024 / 1024/1024, 2) Alocado_GB      
  from dba_tab_partitions t, dba_segments s
 where t.table_owner = s.owner
   and s.segment_name = t.table_name
   and s.partition_name = t.partition_name
   and s.owner=t.table_owner and table_owner not in ('SYS','SYSTEM')
   order by ocupado_gb desc)
 
-- SOMA POR MAIORES TABELAS PARTICIONADAS
SELECT * FROM (
SELECT  t.table_owner,t.table_name,ROUND(sum(s.bytes)/1024/1024/1024,2) GB
from dba_tab_partitions t, dba_segments s
 where t.table_owner = s.owner
   and s.segment_name = t.table_name
   and s.partition_name = t.partition_name
   and s.owner=t.table_owner and table_owner NOT IN ('SYS','SYSTEM')
   group by t.table_owner,t.table_name
   order by GB DESC
) WHERE ROWNUM < 20  



-- INDICE
select t.owner,t.table_name,
       t.index_name,
       t.num_rows,
       t.last_analyzed,S.BLOCKS,
       round(s.bytes / 1024 / 1024/1024, 2) Alocado_GB
  from dba_indexes t, dba_segments s
 where t.owner  = s.owner
   and s.segment_name = t.index_name --and t.index_name='TRSEPRCLOG0_PF_I'
  and S.SEGMENT_NAME in (select index_name from dba_indexes where table_name='TGCMPAC0')

TESCINP0_TESCITR0_FK_I
select * from dba_indexes where index_name='TRSEPRCLOG0_PF_I'

select * from index_stats

select last_analyzed, index_name,num_rows from dba_indexes where table_name='PCKWRK_HDR'

select IC.INDEX_OWNER, IC.INDEX_NAME, IC.TABLE_OWNER, IC.TABLE_NAME, IC.COLUMN_NAME, IC.COLUMN_POSITION, IC.COLUMN_LENGTH 
from dba_ind_columns ic
 WHERE IC.TABLE_NAME='TGCMPAC0' --and 
-- index_name='IND_UNEV_VEHICLE_CLIENT_ID' 
  --table_owner='ZATIX_CLONE'
 ORDER BY TABLE_NAME, index_name,COLUMN_POSITION
  
  
  
select * 
from dba_ind_columns ic 
where ic.table_owner = 'ZATIX_CLONE' AND 
IC.TABLE_NAME='UNFINISHED_EVENT' 
and index_name='IND_UNEV_VEHICLE_CLIENT_ID'  

select * from gv$system_parameter

select sum(bytes)/1024/1024/1024 from dba_data_files


select * from dba_objects where object_name='IND_UNEV_VEHICLE_CLIENT_ID'
   
Select * from dba_indexes where --table_name='HISTORY_ENTRY'
index_name='IDX_TGCMHGC0_OI_PLANO_DATAS'
select created from dba_objects where object_name='IND_BITCLI_VEHI_PERM_HIEN_ITS' 



select object_type from dba_objects where object_name='PK_VEPO'


select * from dba_hist_sqltext where sql_id in
(
select distinct sql_id from dba_hist_sql_plan ttt where object_name='IND_BITCLI_VEHI_PERM_HIEN_ITS'
)
order by sql_id

AND INDEX_NAME='RAIZ_IDX_TRS_CTRL_TRCD_STID_N4'

-- MAIORES INDICES

select * from (
select s.owner,t.table_name,
t.index_name,       round(s.bytes / 1024 / 1024/1024, 2) Alocado_GB
  from dba_indexes t, dba_segments s
 where t.owner = s.owner
   and t.index_name = s.segment_name
   order by alocado_gb desc
   )
   where rownum < 20
   
-- MAIORES INDICES PARTICIONADOS  
select *
  from (select s.owner,
               t.index_name,
               t.partition_name,
               round(s.bytes / 1024 / 1024 / 1024, 2) Alocado_GB
          from dba_ind_partitions at, dba_segments s
         where t.index_owner = s.owner
           and t.index_name = s.segment_name
         order by alocado_gb desc)
 where rownum < 100
   
 
--MAIORES SEGMENTOS

select *
  from (select s.owner,
               S.SEGMENT_NAME,
               S.SEGMENT_TYPE,
               round(s.bytes / 1024 / 1024 / 1024, 2) Alocado_GB
          from  dba_segments s
         order by alocado_gb desc)
 where rownum < 100


 
   
-- ESTATÍSTICAS DAS COLUNAS
select * from dba_tab_col_statistics db where db.table_name='TBEDC_EDICAO'

select OWNER,TABLE_NAME,COLUMN_NAME, NUM_DISTINCT, DENSITY, NUM_NULLS, NUM_BUCKETS, last_analyzed,SAMPLE_SIZE, AVG_COL_LEN
 from dba_tab_col_statistics where table_name in ('TGCMHGC0') 
order by column_name

ASSIGN_GRP
PCKWRK_HDR_ASSIGN_GRP

SELECT * FROM DBA_CONS_COLUMNS CC WHERE CC.table_name='TBERE_ENTREGA_REAL'

select * from dba_histograms db where db.table_name='ROMANEIO' AND COLUMN_NAME='IND_SOLICITA_PROTOCOLO'

-- BUSCAR RAW VALUE 

declare
valor varchar2(30)
begin
dbms_stats.convert_raw_value(43, valor);
dbms_output.put_line(valor);
end;
end


-- INFO SOBRE CONSTRAINTS

SELECT * FROM DBA_CONS_COLUMNS CC WHERE CC.table_name='RAIZ_TEMP_BASE_RELATORIO'
SELECT * FROM DBA_CONSTRAINTS CC WHERE CC.table_name='MAC_CUSTOFORNECLOG'

SELECT ccc.owner,
       ccc.constraint_name,
       ccc.constraint_type,
       ccc.table_name,
       ccc.r_owner,
       ccc.r_constraint_name,
       ccc.index_owner,
       ccc.index_name
  FROM DBA_CONSTRAINTS CCC
 WHERE CCC.table_name = 'TPECMAF0'
 order by table_name

 select * from dba_constraints where constraint_name =''
  in ('SYS_C0032427','SYS_C0032858', 'SYS_C0032501', 'SYS_C0032592', 'SYS_C0032514')

  
select object_name, object_type, owner from dba_objects where object_id=34930718
 -- SQL_ID DA TABELA A PARTIR DE STRING

SELECT * FROM V$SQLAREA V WHERE V.SQL_FULLTEXT LIKE '%create table%'
select EVENT,  SQL_ID from v$session where username='SYS' AND STATUS='ACTIVE' 

SELECT SQL_TEXT, SQL_ID FROM dba_hist_sqltext st where upper(st.sql_text) like '%QP_EVENT_PHASES B WHERE B.PRICING_EVENT_CODE IN (SELECT DECODE(ROWNUM ,1 ,%'

SELECT st.sql_id,st.sql_text FROM dba_hist_sqltext st where SQL_ID in ( 'gqvafc7c089yk')

-- SQL_TEXT A PARTIR DE SQL_ID

SELECT SQL_TEXT FROM DBA_HIST_SQLTEXT WHERE SQL_ID='a6sxjr1c9hdww'
SELECT SQL_FULLTEXT FROM V$SQLAREA WHERE SQL_ID='854knbb15976z'


-- INFO SOBRE CHILD CURSORS

SELECT * FROM gV$SQL_SHARED_CURSOR SS WHERE SQL_ID='6ju26u33k6777'
SELECT * FROM V$SQL where sql_id='4b6n61uqsara0'


select sql_id, count(*) from
(
select distinct a.name,a.datatype_string, count(*)
    from gv$sql_bind_capture a join gv$sql b using (hash_value)
    where b.sql_id = '4b6n61uqsara0'
    group by a.name,a.datatype_string
)    
group by sql_id
having count(*) > 1


select distinct a.datatype_string, b.sql_id, count(*)
    from gv$sql_bind_capture a join gv$sql b using (hash_value)
    where b.sql_id = '2kubdpqsvn19n'
    group by a.datatype_string,b.sql_id    
    
select a.datatype_string, b.sql_id,a.CHILD_NUMBER,a.name
    from gv$sql_bind_capture a join gv$sql b using (hash_value)
    where b.sql_id = '2kubdpqsvn19n'
    group by a.datatype_string,b.sql_id       
  
   SELECT * FROM(
   SELECT COUNT(SC.SQL_ID) CURSOR_COUNT, A.SQL_ID,A.SQL_TEXT
   FROM V$SQLAREA A, V$SQL_SHARED_CURSOR SC
   WHERE A.SQL_ID=SC.SQL_ID
   GROUP BY A.SQL_ID, A.SQL_TEXT
   ORDER BY CURSOR_COUNT DESC)
   WHERE ROWNUM <= 30
   
SELECT NM_USUARIO,CD_TRANSACAO FROM RSE.VRSEPER0 WHERE NM_USUARIO= 'julio.davi'

select * from dba_views where view_name='VRSEPER0'
select * from TESCVIS0;

   
SELECT * FROM DBA_HIST_SQLSTAT

select * from v$asm_disk_stat
-- CAPITURAR BINDS

SELECT NAME, VALUE_STRING,DATATYPE_STRING FROM V$SQL_BIND_CAPTURE zz WHERE SQL_ID='8r1hawr8pmxuw' order by last_captured,name desc
BIND_MISMATCH='Y'

SELECT * FROM DBA_HIST_SQLBIND WHERE SQL_ID='asubx9a1b35c9' 
and name in (':B3') 
ORDER BY last_captured DESC

--DECLARAR BINDS

variable    B2    number
exec     :B2    :=    5

variable B4	number
variable B3	number
variable B2	number
variable B1	number

exec :B4 := 2256547;
exec :B3 := 2624;
exec :B2 := 82;
exec :B1 := 81;

 
 -- PLANO DE EXECUÇÃO

  select p.id,
         p.PARENT_ID,
         p.OPERATION,
         p.OPTIONS,
         p.OBJECT_OWNER,
         p.OBJECT_Name,
         p.object_type,
         p.cost,
         p.CARDINALITY,
         p.bytes,
         p.cpu_cost,
         p.access_predicates,
         p.filter_predicates
          from gv$sql_plan p
         where p.sql_id = 'ay2z6b30u215q'

select * from  gv$sql_plan where sql_id = 'ay2z6b30u215q'

select * from dba_hist_sqlstat where sql_id='ay2z6b30u215q'

  select p.id,
         p.PARENT_ID,
         p.OPERATION,
         p.OPTIONS,
         p.OBJECT_OWNER,
         p.OBJECT_Name,
         p.object_type,
         p.cost,
         p.CARDINALITY,
         p.bytes,
         p.cpu_cost,
         p.access_predicates,
         p.filter_predicates
          from DBA_HIST_SQL_PLAN p
         where p.sql_id = 'ay2z6b30u215q' --and p.PLAN_HASH_VALUE=1432503328

SELECT * FROM DBA_HIST_SQL_PLAN           where sql_id = 'a88ju5yvtc0zq'    order by plan_hash_value, id    

select * from dba_hist_seg_stat_obj where object_name='UNFINISHED_EVENT'
select * from dba_hist_seg_stat where obj#=41193


-- ESTATISTICAS DAS CONSULTAS 

SELECT A.SQL_ID,round(a.BUFFER_GETS / a.EXECUTIONS, 4) buffer_gets_exec,
a.parse_calls,a.invalidations,A.EXECUTIONS,A.FETCHES/a.EXECUTIONS,plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / a.EXECUTIONS, 4) tempo_exec_seg,
       round(A.CPU_TIME / 1000000 / a.EXECUTIONS, 4) temp_cpu_seg,
       round(a.DISK_READS / a.EXECUTIONS, 4) disk_reads_exec, A.ROWS_PROCESSED/A.EXECUTIONS,
       A.LAST_LOAD_TIME,
       a.LAST_ACTIVE_TIME
  FROM gV$SQL A 
WHERE SQL_ID = '0pvknwbmp8r6p' 
asubx9a1b35c9 -- original
5gkc9vt9k79pd-- minha query
6pyktfafjfnd7-- original da minha sessão


SELECT a.PARSING_SCHEMA_NAME, a.LAST_ACTIVE_TIME, A.SQL_ID,decode(A.EXECUTIONS,0,1),
--A.FETCHES/DECODE(a.EXECUTIONS,0,1),
plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / DECODE(a.EXECUTIONS,0,1), 4) tempo_exec_seg,
       A.ELAPSED_TIME/1000000,
       round(A.CPU_TIME / 1000000 / DECODE(a.EXECUTIONS,0,1), 4) temp_cpu_seg,
       round(a.BUFFER_GETS / DECODE(a.EXECUTIONS,0,1), 4) buffer_gets_exec,
       round(a.DISK_READS / DECODE(a.EXECUTIONS,0,1), 4) disk_reads_exec, A.ROWS_PROCESSED/DECODE(a.EXECUTIONS,0,1) RPEXEC,
       A.LAST_LOAD_TIME,A.SQL_FULLTEXT
        FROM gV$SQLarea A
WHERE SQL_ID = 'bwh3z1pjk4ags'


SELECT a.PARSING_SCHEMA_NAME, a.LAST_ACTIVE_TIME, A.SQL_ID,A.EXECUTIONS,
--A.FETCHES/DECODE(a.EXECUTIONS,0,1),
plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / (a.EXECUTIONS), 4) tempo_exec_seg,
       A.ELAPSED_TIME/1000000,
       round(A.CPU_TIME / 1000000 / a.EXECUTIONS, 4) temp_cpu_seg,
       round(a.BUFFER_GETS / a.EXECUTIONS, 4) buffer_gets_exec,
       round(a.DISK_READS / a.EXECUTIONS, 4) disk_reads_exec, A.ROWS_PROCESSED/DECODE(a.EXECUTIONS,0,1) RPEXEC,
       A.LAST_LOAD_TIME,A.SQL_FULLTEXT
        FROM gV$SQLarea A
WHERE SQL_ID = 'bwh3z1pjk4ags'


select *   FROM gV$SQLarea A
WHERE SQL_ID = 'bwh3z1pjk4ags'

--(A.ELAPSED_TIME / 1000000 / DECODE(a.EXECUTIONS,0,1)) > 0.001--is not null
--and a.last_active_time is not null
--and a.parsing_schema_name not in ('INMETRICS','SYS','SYSTEM')--,'IBMITMOR','SYS')
 a.parsing_schema_name in ('NEW_GMEP') and A.ELAPSED_TIME/1000000 > 10 --,'IBMITMOR','SYS')
order by 2 desc,7--a.plan_hash_value 
--=3500288809



3500288809

select * from v$sql where sql_id='a88ju5yvtc0zq'

SELECT * FROM V$SQLAREA WHERE SQL_ID='6mad7943kcyux'

col begin_interval_time form a25
SELECT ss.snap_id,hs.instance_number,hs.begin_interval_time, ss.plan_hash_value,
 ss.executions_DELTA,
 round(ss.elapsed_time_total / 1000000 / decode(ss.executions_total,0,1, ss.executions_total), 2) elaps_p_seg,
        round(ss.cpu_time_total / 1000000 / decode(ss.executions_total,0,1, ss.executions_total), 2) cpu_p_seg,
       round(ss.buffer_gets_total / decode(ss.executions_total,0,1, ss.executions_total), 2)  bg_p_exec,
       round(ss.disk_reads_total / decode(ss.executions_total,0,1, ss.executions_total), 2) dr_p_exec,
       round(ss.rows_processed_total / decode(ss.executions_total,0,1, ss.executions_total),2) rows_p_exec,
       ss.force_matching_signature
  FROM dba_hist_sqlstat ss, dba_hist_snapshot hs
  where hs.snap_id=ss.snap_id and
 SS.EXECUTIONS_TOTAL > 0 --and 
 and ss.sql_id = 'asubx9a1b35c9'
 and hs.begin_interval_time > sysdate - 20
 order by ss.snap_id 
 
 select * from dba_hist_active_sess_history where sql_id='asubx9a1b35c9'
select * from dba_hist_sqltext where sql_id='6zy3xz7830jjc'
SELECT * FROM DBA_USERS WHERE USER_ID=173

 SELECT SQL_ID                      ,
                        SUM(BUFFER_GETS_DELTA) buffer_gets,
                        SUM(DISK_READS_DELTA) disk_reads,
                        to_char(SUM(BUFFER_GETS_DELTA)/1000000,'9999990,9') BG_EXEC,
                        to_char(SUM(CPU_TIME_DELTA)/1000000,'9999990,9') cpu_time_s,
                        to_char(SUM(ELAPSED_TIME_DELTA)/SUM(decode(EXECUTIONS_DELTA,0,1))/1000000,'9999990,9') elaps_exec,
                        to_char(sum(ELAPSED_TIME_delta)/1000000,'9999990,9') ELAP_time_s,
                        SUM(PARSE_CALLS_DELTA) parses,
                        SUM(EXECUTIONS_DELTA) execs
                FROM    DBA_HIST_SQLSTAT
                WHERE   snap_id > 56402
                                    AND INSTANCE_NUMBER =  1
                                    and sql_id='92jat4nw1pxb5'
                GROUP BY SQL_ID
                

select elapsed_time_delta/1000000, elapsed_time_total/1000000,executions_delta ,elapsed_time_delta/1000000/executions_delta from 
DBA_HIST_SQLSTAT
                WHERE   snap_id > 56402
                                    AND INSTANCE_NUMBER =  1
                                    and sql_id='92jat4nw1pxb5'

select sum(elapsed_time_DELTA)/1000000,
to_char(sum(ELAPSED_TIME_delta/1000000),'9999999D99'), sum(buffer_gets_delta)/sum(executions_delta)
from DBA_HIST_SQLSTAT
                WHERE   snap_id > 56416
                                    AND INSTANCE_NUMBER =  1
                                    and sql_id='92jat4nw1pxb5'


select snap_id from dba_hist_snapshot where begin_interval_time >= to_date('201502220157','yyyymmddhh24mi')  order by 1

SELECT ss.sql_id,hs.instance_number, ss.plan_hash_value,
sum(buffer_gets_DELTA)
  FROM dba_hist_sqlstat ss, dba_hist_snapshot hs
  where hs.snap_id=ss.snap_id and 
 SS.EXECUTIONS_TOTAL > 0 --and 
 group by ss.sql_id,hs.instance_number, ss.plan_hash_value
-- ss.sql_id = 'a88ju5yvtc0zq'
 order by 4 desc


-- MISCELLANEOUS 


select * from dba_hist_active_sess_history where sql_id='1mrpjfgjddj87' AND SNAP_ID > (SELECT SNAP_ID FROM DBA_HIST_SNAPSHOT
WHERE BEGIN_INTERVAL_TIME > SYSDATE - 10)

select count(*),trunc(sh.sample_time)  from dba_hist_active_sess_history sh where sh.sql_id='1965uc7u4zg74'
group by trunc(sh.sample_time)

select min(snap_id) from dba_hist_snapshot

select max(snap_id) from dba_hist_snapshot

 select * from dba_hist_filestatxs where tsname='INTFX' and time > 1000000 and snap_id between 31448 and 31458 order by snap_id
 
 
 select snap_id,
        name,
        round(value / 1024 / 1024, 2) "VALOR MB",
        round(value / 1024 / 1024 - LAG(value / 1024 / 1024, 1, 0)
              OVER(PARTITION BY name ORDER BY snap_id),
              2) AS "DIFERENÇA MB"
   from dba_hist_sga
  where dbid = 503588348
  order by NAME, SNAP_ID


SELECT B.END_INTERVAL_TIME,
       A.NAME,
       A.POOL,
       ROUND(A.BYTES / 1024 / 1024, 2) "VALOR MB",
       ROUND(A.BYTES / 1024 / 1024 - LAG(A.bytes / 1024 / 1024, 1, 0) 
       over(PARTITION BY A.NAME, A.POOL ORDER BY A.NAME, A.POOL, A.SNAP_ID), 2) "DIFERENÇA MB"
  FROM DBA_HIST_SGASTAT A, DBA_HIST_SNAPSHOT B
 where A.dbid = 503588348
   AND A.snap_id = B.SNAP_ID
--   AND A.NAME = 'free memory'
 ORDER BY A.NAME, A.POOL, A.SNAP_ID


select * from gv$instance


-- INFO SOBRE LOCKS 
select a.session_id,
       a.oracle_username,
       a.os_user_name,
       b.owner "OBJECT OWNER",
       b.object_name,
       b.object_type,
       a.locked_mode
  from (select object_id,
               SESSION_ID,
               ORACLE_USERNAME,
               OS_USER_NAME,
               LOCKED_MODE
          from gv$locked_object) a,
       (select object_id, owner, object_name, object_type from dba_objects) b
 where a.object_id = b.object_id

 SELECT l.ID1,l.sid, s.blocking_session blocker, s.event, l.type, l.lmode, l.request, o.object_name, o.object_type
 FROM v$lock l, dba_objects o, v$session s
 WHERE UPPER(s.username) = UPPER('&User')
 AND l.id1 = o.object_id (+)
 AND l.sid = s.sid
 ORDER BY sid, type
 
 select l1.sid, ' IS BLOCKING ', l2.sid
    from Gv$lock l1, v$lock l2
    where l1.block =2  and l2.request > 0
    and l1.id1=l2.id1
    and l1.id2=l2.id2


select SID, TYPE, ID1, ID2, LMODE,
          (select object_name from user_objects where object_id=id1) oname,
              block
      from Gv$lock
     where sid = (&SID )
     or block = 1;
  

  select username,sql_id,sid, serial#,
         osuser,
         machine,
         gv.COMMAND,
         gv.EVENT,
         gv.LOCKWAIT,
         gv.PROGRAM,
         gv.SECONDS_IN_WAIT,gv.SERVICE_NAME
    from v$session gv
   where username='STRESSTEST'
   AND status = 'ACTIVE' and event not in('rdbms ipc message','gc cr request','SQL*Net message from client') --and username='STRESSTEST'
  and  username is not null 

select *
  from v$sqlarea sttt
 where sttt.SQL_FULLTEXT like
       'SELECT distinct(r2.role_sq_role)%LEFT JOIN role_client%INNER JOIN VW_USER_PERMISSION %GROUP BY role_sq_role%'

select * from dba_blockers
SELECT * FROM V$SESSION_LONGOPS WHERE TIME_REMAINING > 0;

SELECT BYTES/1024/1024/1024 FROM DBA_SEGMENTS WHERE SEGMENT_NAME='INM_HIST_ENTRY'
select sysdate from dual

select * from dba_hist_snapshot order by snap_id desc

 ORDER BY gv.INST_ID
 
 select * from dba_users order by 1
 
 select * from v$sqlarea where sql_id='bjf05cwcj5s6p'
bjf05cwcj5s6p
select * from dba_objects where object_name
in 
('VEHICLE', 'VEHICLE_FENCE')

 
 SELECT * FROM GV$ACTIVE_SESSION_HISTORY WHERE 
 SESSION_ID= 743 AND SESSION_SERIAL#= 367
 AND SQL_ID='dxfw6d64zg2uz' 

SELECT * FROM V$SQL_PLAN
WHERE 
--PLAN_HASH_VALUE=1425390098 AND 
SQL_ID='dxfw6d64zg2uz'
ORDER BY TIMESTAMP,ID
  
 SELECT OBJECT_NAME, OBJECT_TYPE FROM DBA_OBJECTS WHERE OBJECT_ID=790925

select SQL_FULLTEXT
from v$sqlarea  where sql_id='2hfqqm3twb35r'

select * from v$active_session_history sh where sh.session_id=1291 and sh.session_serial#=7978

select * from dba_jobs_running

select * from dba_sql_profiles

select * from dba_scheduler_jobs where owner='BARCELONA' AND UPPER(JOB_ACTION) LIKE '%SALDO%'

SELECT * FROM DBA_TRIGGERS WHERE STATUS='ENABLED' AND TABLE_NAME='ASSAI_CLIENTE'

select * from dba_objects where object_name='MFL_DOCTOFISCALIE8'

select * from dba_views where view_name 
in ('VW_PI_REST_CLIENTE','VW_PI_REST_LOJA_PROPRIA','VW_MUNICIPIO','GC_STATE','VW_PI_TIPO')

select * from dba_sequences where sequence_name ='SINM_HIGH_LOAD_SQL_SIMILAR'

alter sequence INM_JBORAP02.SINM_HIGH_LOAD_SQL_SIMILAR cache 100

select * from v$active_session_history ash where ash.sql_id='850qv142qxkh7'

jborap02


select
 count(*)
from 
  gv$open_cursor c
  where c.SQL_ID='5c7czr6430h4f'
  

  Select cache/tot*100 "Session cursor cache%"
 from
 (select value tot from v$sysstat where name='parse count (total)'),
 ( select value cache from sys.v_$sysstat where name = 'session cursor cache hits' );
 
  column parameter format a29
 column value format a7
 column usage format a7
 select 'session_cached_cursors' parameter, lpad(value, 5) value,
    decode(value, 0, ' n/a', to_char(100 * used / value, '9990') || '%') usage
    from ( select max(s.value) used from V$STATNAME n, V$SESSTAT s
    where n.name = 'session cursor cache count' and s.statistic# = n.statistic# ),
    ( select value from V$PARAMETER where name = 'session_cached_cursors' )
    union all
    select 'open_cursors', lpad(value, 5), to_char(100 * used / value, '9990') || '%'
    from ( select max(sum(s.value)) used from V$STATNAME n, V$SESSTAT s
    where n.name in ('opened cursors current', 'session cursor cache count') and s.statistic# = n.statistic# group by s.sid ),
   ( select value from V$PARAMETER where name = 'open_cursors' );
   
   select 'session_cached_cursors' parameter, lpad(value, 5) value,
decode(value, 0, ' n/a', to_char(100 * used / value, '990') || '%') usage 
from ( select max(s.value) used from V$STATNAME n, V$SESSTAT s
where n.name = 'session cursor cache count' and s.statistic# = n.statistic# ),
( select value from V$PARAMETER where name = 'session_cached_cursors' )
union all
select 'open_cursors', lpad(value, 5), to_char(100 * used / value, '990') || '%' 
from ( select max(sum(s.value)) used from V$STATNAME n, V$SESSTAT s
where n.name in ('opened cursors current', 'session cursor cache count') and s.statistic# = n.statistic# group by s.sid ),
( select value from V$PARAMETER where name = 'open_cursors' );


select max(value) from v$sesstat
 where STATISTIC# in (select STATISTIC# from v$statname where name='session cursor cache count');
 
 select round(sum(bytes)/1024/1024/1024,2) from v$sgastat where name <> 'free memory';

select snap_id,  sum(bytes/1024/1024/1024) from dba_hist_sgastat
where
 name <> 'free memory'
group by snap_id
order by snap_id desc

select * from v$sgastat

select * from gv$sqlarea sf where sf.SQL_FULLTEXT like 'SELECT GCP99L.EFFECTIVE_DATE PERIODO%'

select distinct sql_id from gv$active_session_history where machine = 'jborap04'

SELECT * FROM DBA_HIST_SQLTEXT WHERE sql_text like 'SELECT GCP99L.EFFECTIVE_DATE PERIODO%'
(
select DISTINCT SQL_ID from dba_hist_sql_plan where object_name='HISTORY_ENTRY_PK'
)

select * from v$asm_diskgroup
 
 
select * from
(
select  current_obj#,count(*)
 from dba_hist_active_sess_history
 group by current_obj#
 order by 2 desc
)
where rownum < 21
 )
 select * from dba_objects where object_id=41153',
 
linkerdev 
zatix_clone
zatix_clone

select * from dba_hist_snapshot order by snap_id desc
