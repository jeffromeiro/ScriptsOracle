spool /home/oracle/chklist/log/checklist_3152_prod
set serveroutput on size 2000
set lines 250
set pages 50000
set head on

select
du.username, '30 DIAS LOCKED' User_30Locked,  
trunc( trunc(sysdate)-du.lock_date) Dias,
du.created "created",
du.account_status "account status", 
du.lock_date "lock date", 
du.expiry_date "expire date", 
du.profile "profile",
a133230.last_logon(du.username) "Ultimo Logon"
from dba_users du
where ( trunc(sysdate) - du.lock_date) > 30 
order by 3
/

spool off
exit;
