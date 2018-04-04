set pages 0

select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ';'
from dba_tab_privs
where grantee = '&grantee';
 
 
select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ';'
from dba_tab_privs
where grantor = '&grantee';
 
 
select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ';'
from dba_tab_privs
where owner = '&grantee';
 
 
select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ' with grant option;'
from dba_tab_privs
where owner = '&grantee' and grantable='YES';

set pages 500