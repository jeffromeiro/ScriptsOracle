spool /home/oracle/chklist/log/check_table_monit
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

select count(*) into v_count
from   dba_tables a
where  a.monitoring ='NO'
and    a.temporary='N'
and    not exists (select 1 from dba_external_tables b where b.table_name = a.table_name );
select name into v_name from v$database;

if v_count>0 then
select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;
dbms_output.put_line('BDORACLE_' || v_name || '_TABLE_MONIT_NOK_'||v_date);
else
dbms_output.put_line('BDORACLE_' || v_name || '_TABLE_MONIT_OK');
end if;

end;
/
spool off

