spool /home/oracle/chklist/log/check_offline_tablespace
set serveroutput on size 2000

set head off
set feed off
set echo off
set trimspool on
declare v_count number := 0;
v_base varchar2(50);
begin
select upper(name) into v_base from v$database;
select count(*) into v_count
  from dba_tablespaces
 where status='OFFLINE';
if v_count > 0 then 
	dbms_output.put_line('TABLESPACES_'||v_base||'_OFFLINE_NOK');
else
	dbms_output.put_line('TABLESPACES_'||v_base||'_OFFLINE_OK');
end if;
end;
/
spool off

