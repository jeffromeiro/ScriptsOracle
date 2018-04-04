-- chkasmdiskstat.sql
-- Show ASM disks status
set pagesize 100
set linesize 200
col path for a15
col name for a15
col failgroup for a15
select disk_number,name,path,mount_status,header_status,mode_status,state,failgroup,repair_timer
from v$asm_disk;

-- dg_attribs.sql
-- show disk group attributes
col "dg name" for a20
col "attrib name" for a30
col value for a20
set pagesize 20
select dg.name  "dg name"
      ,a.name   "attrib name"
      ,a.value
      ,read_only
from v$asm_diskgroup dg,
     v$asm_attribute a
where dg.name = 'DG1'
and   dg.group_number = a.group_number;