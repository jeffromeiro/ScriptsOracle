set serverouput on
set feed off
set head off
set pages 1000
col host for a40
col owner for a30
set line 300



spool create_dblinks.txt


SELECT * FROM dba_db_links;

declare
  v_sql varchar2(999);
  v_output varchar2(999);
  cursor cur_tab is select * from dba_db_links;
begin
   for x in cur_tab loop
	v_sql := 'select dbms_metadata.get_ddl(''DB_LINK'','''|| x.db_link || ''','''|| x.owner || ''') from dual';
	--dbms_output.put_line(v_sql);
	execute immediate v_sql into v_output;
	dbms_output.put_line(v_output);
   end loop;
end;
/
spool off;

set feed on
set head on

