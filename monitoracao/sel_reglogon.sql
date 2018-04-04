set echo 	off
set lines 	200
set pages 	900
set trimout 	on
set trimspool  	on
set feed 	off
set term 	off

btitle off

col col1 new_value sp

set feed off

ttitle left 'RELATORIO ACESSOS SODEXO' skip 2

select upper(instance_name)||'_'||host_name||'_REGLOGON'||'.html'  col1  
from v$instance
/

set markup html on spool on HEAD '<TITLE> SODEXHOPASS </TITLE>' -
   Body 'TEXT=blue bgcolor=white'-
   TABLE 'align=center width=100% border=3 bordercolor=hotblue bgcolor=white'


set feed off
col npr noprint

spool /oracle/reglogon/&sp

select logon_time npr,  USERNAME, OSUSER, MACHINE, to_char(LOGON_TIME,'DD/MM/YYYY HH24:MI:SS') LOGON_TIME
from  prod_dba.reglogon
where logon_time > trunc(sysdate)-30
and   lower(osuser) not in ('oracle', 'workload','root','iwam_spbweb01','system','caunint')
-- and   upper(username) not in ('SYSMAN','FRETE','PROD_DBA_LNK','PROD_DBA','A115635','A126037','A204376',
--'BR02288','A204101','A138461','A149072','A133230')
and   upper(username) not in ('SYSMAN','FRETE','PROD_DBA_LNK','PROD_DBA')
and   (REGEXP_LIKE(upper(osuser), 'A[^[:digit:]]') or REGEXP_LIKE(upper(osuser), 'BR[^[:digit:]]') )
and   (REGEXP_LIKE(upper(username), 'A[^[:digit:]]') or REGEXP_LIKE(upper(username), 'BR[^[:digit:]]') )
and   lower(osuser) <> lower(username)
order by npr desc
/

spool off
set markup html off

