set lines 250 pages 50000
set termout on 

alter session set nls_date_format='yyyy_mm_dd hh24:mi';
alter session set NLS_NUMERIC_CHARACTERS = ',.';

col METRIC_NAME_UNIT for a75
-- reduce white space waste by sql*plus, the calculated max length for this on 11.2.0.3 is 73
set colsep ';'
accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt 'Fim (yyyymmddhh24mi): '
set termout off feed off verify off
column myfilesuffix new_value myfilesuffix 
select sys_context('USERENV','DB_NAME')||to_char(sysdate,'_yyyy-mm-dd_hh24_mi') myfilesuffix from dual;

spool active_sessions_&myfilesuffix..csv

select cast(min(sn.begin_interval_time) over (partition by sn.dbid,sn.snap_id) as date) snap_time,  --workaround to uniform snap_time over all instances in RAC
	--ss.dbid,  --uncomment if you have multiple dbid in your AWR
	sn.instance_number,
	ss.metric_name||' - '||ss.metric_unit metric_name_unit,
	ss.maxval,
	ss.average,
	ss.standard_deviation
from dba_hist_sysmetric_summary ss,
     dba_hist_snapshot sn
where
  sn.snap_id = ss.snap_id
 and sn.dbid = ss.dbid
 and sn.instance_number = ss.instance_number
 and sn.begin_interval_time between to_date('&p_btime','yyyymmddhh24mi') and to_date('&p_etime','yyyymmddhh24mi') 
 and ss.metric_name='Average Active Sessions'
order by sn.snap_id;

spool off
undef p_btime p_etime

