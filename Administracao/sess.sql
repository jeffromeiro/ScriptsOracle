COLUMN OSUSER FORMAT A20
COLUMN USERNAME FORMAT A20
COLUMN TERMINAL FORMAT A20
col machine form a30

select a.sid, a.serial#, b.spid, a.username, a.osuser, a.status ,a.server,  a.machine,
to_char(a.logon_time, 'dd.mm.yyyy hh24:mi:ss') logon_time
from v$session a, v$process b
Where	a.paddr = b.addr
and a.username is not null
order by 4,9
/
