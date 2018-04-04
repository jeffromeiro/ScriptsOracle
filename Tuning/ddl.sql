set long 50000 
set lines 200
set longchunksize 200
set head off

 begin
dbms_metadata.set_transform_param
           ( DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS_AS_ALTER', true );
            dbms_metadata.set_transform_param
          ( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false );
            dbms_metadata.set_transform_param
          ( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE );
  end;
/
spool ddl_&&name..txt
select dbms_metadata.get_ddl(upper('table'),upper('&&name'),upper('&&owner')) from dual;


select dbms_metadata.get_ddl( 'INDEX', index_name, upper('&owner') ) as create_index
  from dba_indexes
 where owner = upper('&owner')
   and table_name = upper('&name');

set long 10000
set head on
set echo off
undefine type name owner 
spool off
