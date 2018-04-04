spool /home/oracle/chklist/log/checklist_3151_prod
set serveroutput on size 2000
set lines 250
set pages 50000
set head on

select
du.username, 'SEM LOGON 60 DIAS' User_60DIAS,
du.created,
du.account_status, 
du.lock_date, 
du.expiry_date,
du.profile,
a133230.last_logon(du.username)
from dba_users du
where du.username not in
(select username from prod_dba.reglogon where logon_time >= trunc(sysdate) -60)
order by username
/

spool off
exit;
