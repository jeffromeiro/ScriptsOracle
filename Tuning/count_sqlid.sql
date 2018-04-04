select count(*), sql_id from gv$session where status='ACTIVE' group by sql_id order by 1
/
