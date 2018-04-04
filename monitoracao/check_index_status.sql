spool /home/oracle/chklist/log/check_index_status
set serveroutput on size 2000

set head off
set feed off
set echo off
set trimspool on
declare v_count number := 0;
v_count1  number := 0;
v_base varchar2(50);
begin
select upper(name) into v_base from v$database;
select count(*) into v_count
  from dba_indexes 
 where status='UNUSABLE'; 
select count(*) into v_count1
  from dba_ind_partitions
 where status='UNUSABLE'; 

if v_count > 0 or v_count1 > 0 then 
	dbms_output.put_line('INDICES_'||v_base||'_NOK');
else
	dbms_output.put_line('INDICES_'||v_base||'_OK');
end if;
end;
/
spool off

