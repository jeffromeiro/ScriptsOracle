set lines 250
set pages 5000
col event form a50
select count(*), event from gv$session where status='ACTIVE' group by event order by 1
/
