spool /home/oracle/chklist/log/check_profile
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
 from dba_users
 where profile ='DEFAULT';

select name into v_name from v$database;

if v_count>0 then
select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;
dbms_output.put_line('BDORACLE_' || v_name || '_PROFILE_NOK_'||v_date);
else
dbms_output.put_line('BDORACLE_' || v_name || '_PROFILE_OK');
end if;

end;
/
spool off

