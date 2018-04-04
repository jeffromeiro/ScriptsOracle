spool /home/oracle/chklist/log/check_maxextents_&1

set serveroutput on size 2000

set head off
set feed off
set echo off
set trimspool on

declare
v_count   number(5);
v_name    v$database.name%type;
v_date    char(20);

 BEGIN

 select name into v_name from v$database;

 select count(*) into v_count from dba_segments where extents>= max_extents - 5 and segment_type not in ('CACHE','TEMPORARY');

 if v_count>0 then
 select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;
 dbms_output.put_line('BDORACLE_' || v_name || '_MAXEXTENTS_NOK_'||v_date);
 else
 dbms_output.put_line('BDORACLE_' || v_name || '_MAXEXTENTS_OK');
 end if;

 END;
 /

 spool off

