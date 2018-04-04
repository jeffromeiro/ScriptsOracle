spool /home/oracle/chklist/log/check_nextextent_&1
set serveroutput on size 2000

set head off
set feed off
set echo off
set trimspool on
alter session set sort_area_size=16000000;

-- !!!!OBSERVACAO IMPORTANTE!!!!!
--
-- Para este Insert nao eh necessario TRUNCATE ou DELETE,
-- pois a table TB_FREE_SPACE eh do tipo temporary
--
--insert into sys.tb_free_space select * from dba_free_space;

declare

bloco number;
v_count number;
v_name    v$database.name%type;
v_date    char(20);

begin

select VALUE into bloco FROM V$PARAMETER WHERE NAME='db_block_size';

select name into v_name from v$database;


select count(*) into v_count
 from dba_segments a,
(Select max(maior) maximo, tablespace_name
from
(select max(trunc ( (maxbytes- bytes) / (increment_by*bloco) ) * increment_by * bloco)  maior,
tablespace_name
from dba_data_files
where autoextensible = 'YES'
group by tablespace_name
union
select max(bytes) maior,tablespace_name
--from tb_free_space
from dba_free_space
group by tablespace_name)
group by tablespace_name) b
where a.tablespace_name=b.tablespace_name and a.next_extent>b.maximo;

if v_count>0 then
select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;
dbms_output.put_line('BDORACLE_' || v_name || '_NEXTFREE_NOK_'||v_date);
else
dbms_output.put_line('BDORACLE_' || v_name || '_NEXTFREE_OK');
end if;

end;
/
spool off

