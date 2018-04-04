Rem
Rem
Rem Verifica se existe algum datafile em AUTOEXTENT que ja atingiu o seu tamanho maximo ou que tenha menos de 1 Gb para crescer
Rem
Rem

spool /home/oracle/chklist/log/check_autoextent_df_&1
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
 from dba_data_files
 where tablespace_name not in 
 ( select a.tablespace_name 
   from 
   (select tablespace_Name, sum( (maxbytes-bytes) ) livre
    from dba_data_files
    where autoextensible = 'YES'
    group by tablespace_Name
    having sum((maxbytes-bytes)) >1000000000 
   ) a
 )
 and autoextensible = 'YES';

 cursor instance is
 select name from v$database;

BEGIN
 open instance;
 fetch instance into v_name;

 open count;
 fetch count into v_count;

 select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;

 if v_count>0 then
  dbms_output.put_line('BDORACLE_' || v_name || '_AUTOEXTENTS_DF_NOK_'||v_date);
 else
  dbms_output.put_line('BDORACLE_' || v_name || '_AUTOEXTENTS_DF_OK_'||v_date);
 end if;

 close count;
 close instance;
END;

/

spool off

exit

