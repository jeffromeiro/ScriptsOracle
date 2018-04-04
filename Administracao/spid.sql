-- Script que apresenta o spid de um processo oracle

COLUMN USERNAME FORMAT A20
COLUMN OSUSER   FORMAT A20
COLUMN MACHINE  FORMAT A20
COLUMN sid FORMAT 9999999999

select a.sid, a.serial#,a.sql_id, b.spid, a.username, a.terminal, a.machine, to_char(a.logon_time,'dd/mm/yyyy hh24:mi'),a.inst_id, a.status
from   gv$session a,
       gv$process b
where  a.paddr = b.addr
and    a.username is not null
and    b.spid=&spid
/
