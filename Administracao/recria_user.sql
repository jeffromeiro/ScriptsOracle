select 'create user ' || username || ' identified by xxx default tablespace ' || default_tablespace || ' temporary tablespace ' || temporary_tablespace || ';' || chr(13) ||
       ' alter user ' || username || ' quota unlimited on ' || default_tablespace || ';' as x
  from dba_users
 where username not in ('SYS', 'SYSTEM') ;

