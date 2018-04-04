spool /home/oracle/chklist/log/check_ind_monit
set serveroutput on size 2000

set head off
set feed off
set echo off
set trimspool on

declare

v_count number;
v_name    v$database.name%type;
v_date    char(20);

begin

select name into v_name from v$database;

select count(*) into v_count
from sys.user$ u,  sys.obj$ io,  sys.obj$ t,  sys.ind$ i,  sys.object_usage ou
         where i.obj# = ou.obj#
         and io.obj# = ou.obj#
         and t.obj# = i.bo#
         and u.user# = io.owner#
         and decode(bitand(i.flags, 65536), 0, 'NO', 'YES') = 'NO'
         and u.name not in ('SYS','SYSTEM','DBSNMP','OUTLN','SYSMAN');

if v_count>0 then
select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;
dbms_output.put_line('BDORACLE_' || v_name || '_IND_MONIT_NOK_'||v_date);
else
dbms_output.put_line('BDORACLE_' || v_name || '_IND_MONIT_OK');
end if;

end;
/
spool off

