COLUMN TEXTO FORM A80

select 'Exec sys.dbms_system.set_ev(' || s.sid ||','|| s.serial# || ',10046,12,'''');' TEXTO, s.sid, p.spid, substr(s.OSUSER,1,10) osuser, substr(s.username,1,20) username
from v$session s, v$process p
where s.paddr=p.addr
AND s.username like upper('%&USER%');
