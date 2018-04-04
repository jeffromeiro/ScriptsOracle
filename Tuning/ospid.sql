select s.sid sid,
       s.serial# serial#,
       s.username username,
       optimizer_mode,
       cpu_time/1000000 cpu,
       elapsed_time/1000000 elapsed,
       sql_text
  from v$sqlarea a, v$session s, v$process p
 where s.sql_hash_value = a.hash_value
   and s.sql_address    = a.address
   and s.username is not null
and p.addr = s.paddr
and p.spid = nvl('&os_pid',p.spid);