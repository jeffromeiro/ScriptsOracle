set echo off
set verify off
set markup html on
set lines 250 pages 5000
set arraysize 5000
accept dt_inicio char prompt 'Data inicial yyyymmddhh24mi: '
accept dt_fim   char prompt 'Data final yyyymmddhh24mi: '
set term off
set feed off


ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ', .';
spool top_sqlid_breakdown.xls

select to_char (sn.BEGIN_INTERVAL_TIME, 'dd/mm/yyyy hh24:mi:ss') INTERVAL_TIME,
ST.PARSING_SCHEMA_NAME,
st.sql_id,
SUM(CPU_TIME_DELTA)/1000000/60/60 CPU_TIME_HORAS,
SUM (BUFFER_GETS_DELTA),
SUM (DISK_READS_DELTA) leituras
from
dba_hist_sqlstat st,
dba_hist_snapshot sn
 where sn.snap_id = st.snap_id and
 to_date('&dt_inicio','yyyymmddhh24mi') <  sn.BEGIN_INTERVAL_TIME
                    AND sn.BEGIN_INTERVAL_TIME         <= to_date('&dt_fim','yyyymmddhh24mi')
 GROUP BY to_char (sn.BEGIN_INTERVAL_TIME, 'dd/mm/yyyy hh24:mi:ss') , ST.PARSING_SCHEMA_NAME, st.sql_id;


 spool off
set markup html off
set term on
set echo off
set feed on
set verify off




