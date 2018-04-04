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
SET LONG 20000
select dbms_metadata.get_ddl( 'VIEW', VIEW_name, upper('sys') ) as create_VIEW
  from dba_VIEWS
  WHERE VIEW_NAME LIKE 'DBA_HIST_%'
 AND owner = upper('SYS');
   

set long 10000
set head on
set echo off
undefine type name owner 
spool off
