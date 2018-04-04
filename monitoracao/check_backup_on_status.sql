Rem
Rem
Rem Verifica se o backup on line esta ativo
Rem
Rem

spool /home/oracle/chklist/log/check_backup_on_status_&1
set serveroutput on size 2000
set head off
set feed off
set echo off
set trimspool on



declare
 v_count   number(2);
 v_name    v$database.name%type;
 v_date    char(20);

 cursor count is
 select count(*)
 from v$backup
 where status ='ACTIVE';

 cursor instance is
 select name from v$database;

BEGIN
 open instance;
 fetch instance into v_name;

 open count;
 fetch count into v_count;

 select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;

 if v_count>0 then
  dbms_output.put_line('BDORACLE_' || v_name || '_BACKUP_ON_LINE_ATIVO_'||v_date);
 else
  dbms_output.put_line('BDORACLE_' || v_name || '_BACKUP_ON_LINE_DESATIVADO_'||v_date);
 end if;

 close count;
 close instance;
END;

/

spool off

exit

