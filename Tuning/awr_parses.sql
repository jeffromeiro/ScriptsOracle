select a.snap_id,
a.value "HARD PARSES",
b.value "TOTAL PARSES",
B.VALUE - A.VALUE "SOFT PARSES",
round((a.value/b.value)*100,2) "% HARD PARSES",
round((B.VALUE - A.VALUE)/b.value*100,2) "% SOFT PARSES"
from (select snap_id, stat_name, sum(value) value
from dba_hist_sysstat
where stat_name = 'parse count (hard)'
group by snap_id, stat_name) a,
(select snap_id, stat_name, sum(value) value
from dba_hist_sysstat
where stat_name = 'parse count (total)'
group by snap_id, stat_name) b
where a.snap_id = b.snap_id