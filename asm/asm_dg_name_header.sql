SET LINESIZE 150
SET PAGESIZE 60
CLEAR SCRE

-----
-- V$ASM_DISK
-- Lists each disk discovered by the ASM instance, including disks 
-- that are not part of any ASM disk group
-----
TTITLE 'ASM Disks - General Information 2 (From V$ASM_DISK)'
COL name                FORMAT A32      HEADING 'ASM Disk Name' WRAP
COL header_status       FORMAT A12      HEADING 'Header|Status'
COL path                FORMAT A32      HEADING 'OS Disk Path Name' WRAP
COL free                FORMAT 99,99    HEADING '% Free'
 
select name,
       path,
       header_status , 
       state ,
       total_mb ,
       free_mb ,
       round( ( free_mb / total_mb ),2) * 100 as free
from   v$asm_disk
order by name
/
