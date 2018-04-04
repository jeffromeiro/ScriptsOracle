set lines 220
set pagesize 3000
col c1 for a9
col c1 heading "OS User"
col c2 for a9
col c2 heading "Oracle User"
col b1 for a9
col b1 heading "Unix PID"
col b2 for 9999 justify left
col b2 heading "SID"
col b3 for 99999 justify left
col b3 heading "SERIAL#"
col sql_text for a75
col d2 for a35 heading "Event"
col d1 heading "Inst_id"
--break on d1 nodup on b1 nodup on c1 nodup on c2 nodup on b2 nodup on b3 skip 3
select b.inst_id d1,b.event d2,c.spid b1, b.osuser c1, b.username c2, b.sid b2, b.serial# b3,
a.sql_text
  from gv$sqltext a, gv$session b, gv$process c
   where a.address    = b.sql_address
   and b.status     = 'ACTIVE'
   and b.paddr      = c.addr
   and a.hash_value = b.sql_hash_value
  and a.inst_id = b.inst_id
  and b.username='SCAPACITY01'
  and b.wait_class != 'Idle'
and b.inst_id = c.inst_id 
 order by b.inst_id,c.spid,a.hash_value,a.piece
/ 

