col name format a30 
col gets format 9,999,999 
col waits format 9,999,999 
 
prompt GETS - # of gets on the rollback segment header 
prompt WAITS - # of waits for the rollback segment header 
 
set head on; 
 
select name, waits, gets 
from v$rollstat, v$rollname 
where v$rollstat.usn = v$rollname.usn 
/ 
 
set head off
 
select 'The average of waits/gets is '|| 
round((sum(waits) / sum(gets)) * 100,2)||'%'
From v$rollstat 
/ 
 
prompt 
prompt Caso o ratio de waits e gets esteja maior que 1% ou 2% 
prompt considerar criar mais segmentos de Rollback (Caso 9i)
 
prompt Outra maneira de medir utilização de segmentos UNDO:
prompt 
 
column xn1 format 9999999 
column xv1 new_value xxv1 noprint 
 
set head on
 
select class, count
from v$waitstat 
where class in ('system undo header', 'system undo block', 
'undo header', 'undo block' ) 
/ 
 
set head off
 
select 'Total requests = '||sum(count) xn1, sum(count) xv1 
from v$waitstat 
/ 
 
select 'Contention for system undo header = '|| 
(round(count/(&xxv1+0.00000000001),4)) * 100||'%'
from v$waitstat 
where class = 'system undo header'
/ 
 
select 'Contention for system undo block = '|| 
(round(count/(&xxv1+0.00000000001),4)) * 100||'%'
from v$waitstat 
where class = 'system undo block'
/ 
 
select 'Contention for undo header = '|| 
(round(count/(&xxv1+0.00000000001),4)) * 100||'%'
from v$waitstat 
where class = 'undo header'
/ 
 
select 'Contention for undo block = '|| 
(round(count/(&xxv1+0.00000000001),4)) * 100||'%'
from v$waitstat 
where class = 'undo block' ; 