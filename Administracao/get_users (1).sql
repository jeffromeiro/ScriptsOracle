set head off
set feed off
set pages 0
set lines 300
set serveroutput on
col text for a100 wrap

spool create_users.txt


declare 
v_output varchar2(999);
v_sql varchar2(999);
begin
for i in (select * from dba_users) loop
	v_sql := 'SELECT DBMS_METADATA.GET_DDL(''USER'',''' || upper(i.username) || ''')text FROM DUAL';
	execute immediate v_sql into v_output;
	dbms_output.put_line(v_output);
	dbms_output.put_line(';');
end loop;
end;
/

spool off;

set head on
set feed on

  
