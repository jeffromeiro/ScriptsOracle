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
 sn.BEGIN_INTERVAL_TIME >
 to_date ('16/03/2014 00:00:00', 'dd/mm/yyyy hh24:mi:ss')
 GROUP BY to_char (sn.BEGIN_INTERVAL_TIME, 'dd/mm/yyyy hh24:mi:ss') , ST.PARSING_SCHEMA_NAME, st.sql_id;
