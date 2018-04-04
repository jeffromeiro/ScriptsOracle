clear breaks compute
set feedback 6
undefine topN topStat topUser
 
set feedback off
set linesize 205 pagesize 10000 verify off
 
define topN=3
define topStat=%
define pctMinimo=1
 
set lines 154
column sid format 99999
column statistic_name form a30
column top_stat_name format a30 heading 'STATISTIC_NAME' trunc
column sess_status format a4 heading 'STATUS' truncate
column username_osuser format a20 heading 'USERNAME/OSUSER'
column minutos format 9999 heading 'MIN'
column statistic_value format 9g999g999g990 heading 'STATISTIC_VAL'
column conn_time heading 'LOGADO A'
column rank format 99
 
break on top_stat_name skip 1
compute sum of pct on statistic_name
 
select statistic_name as top_stat_name
, rank
, pct
, sid
, decode( username, null, '('||bg_name||')', username)
|| decode( osuser, null, null, '/')
|| substr( osuser, 1+instr( osuser, '\') )
as username_osuser
, lpad( decode( trunc(sysdate - logon_time)
, 0, null
, trunc(sysdate - logon_time) || 'd, ' )
|| to_char ( to_date( trunc( 86400 * ((sysdate-logon_time) - trunc(sysdate - logon_time)) )
, 'SSSSS' )
, 'hh24"h "mi"m"' )
, 10 )
as conn_time
, round( last_call_et/60, 1) as minutos
, decode( status, 'ACTIVE', 'ATIVO', 'INACTIVE', 'INATIVO', status)
as sess_status
, statistic_value
from ( select sn.name as statistic_name
, row_number() over ( partition by sn.name
order by sn.name, sv.value desc)
as rank
, 100 * ratio_to_report(sv.value) over (partition by sn.name) as pct
, sv.value as statistic_value
, bg.name as bg_name
, ss.*
from v$sesstat sv
, v$statname sn
, v$session ss
, v$bgprocess bg
where sn.statistic# = sv.statistic#
and ss.sid = sv.sid
and ss.paddr = bg.paddr(+)
and ss.type != 'BACKGROUND'
and ( ( status = 'INACTIVE' and last_call_et/60 < 5 ) or status = 'ACTIVE' ) and sv.value > 0
and sn.name
in ( 'consistent gets'
, 'db block gets'
, 'physical reads'
, 'physical writes'
-- , 'physical reads direct'
-- , 'physical writes direct'
-- , 'bytes sent via SQL*Net to client'
-- , 'bytes received via SQL*Net from dblink'
-- , 'bytes sent via SQL*Net to dblink'
-- , 'enqueue releases'
-- , 'enqueue requests'
, 'enqueue waits'
-- , 'recursive cpu usage'
-- , 'session logical reads'
-- , 'session pga memory'
-- , 'session uga memory'
, 'session pga memory max'
, 'session uga memory max'
, 'execute count'
, 'parse count (hard)'
-- , 'parse time cpu'
-- , 'parse time elapsed'
-- , 'parse count (total)'
-- , 'sorts (disk)'
-- , 'sorts (memory)'
, 'sorts (rows)'
, 'table scans (long tables)'
, 'table fetch continued row'
)
)
where trunc(pct) > &pctMinimo -- percentuais maiores que pctMinimo
and rank < 1+&topN -- "N" maiores sessoes que consomem aquele recurso and upper(statistic_name) like upper('%&topStat.%') ; 