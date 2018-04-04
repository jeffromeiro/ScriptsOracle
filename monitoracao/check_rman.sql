spool /home/oracle/chklist/log/check_rman
set serveroutput on size 2000
set head off
set feed off
set echo off
set trimspool on
declare
v_base varchar2(50);
v_tempo number;
begin
select upper(name) into v_base from v$database;
select max(SYSDATE - logon_time) into v_tempo from v$session
where program like 'rman%';
if v_tempo > 1 then
  dbms_output.put_line('RMAN_'||v_base||'_LOGADO_NOK');
else
  dbms_output.put_line('RMAN_'||v_base||'_LOGADO_OK');
end if;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
  dbms_output.put_line('RMAN_'||v_base||'_LOGADO_OK');
end;
/
spool off
