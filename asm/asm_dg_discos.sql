SET LINESIZE 250
SET PAGESIZE 60
CLEAR SCRE

-----
-- V$ASM_DISK
-- Lists each disk discovered by the ASM instance, including disks 
-- that are not part of any ASM disk group
-----
TTITLE 'ASM Disks - General Information (From V$ASM_DISK)'
COL group_number        FORMAT 99999999 HEADING 'ASM|Disk|Grp #' 
COL disk_number         FORMAT 99999999 HEADING 'ASM|Disk|#'
COL name                FORMAT A32      HEADING 'ASM Disk Name' WRAP
COL total_mb            FORMAT 99,999,999 HEADING 'Total|Disk|Space(MB)'
COL compound_index      FORMAT 99999999999 HEADING 'Cmp|Idx|#'
COL incarnation         FORMAT 99999999999 HEADING 'In#'
COL mount_status        FORMAT A07      HEADING 'Mount|Status'
COL header_status       FORMAT A12      HEADING 'Header|Status'
COL mode_status         FORMAT A08      HEADING 'Mode|Status'
COL state               FORMAT A07      HEADING 'Disk|State'
COL redundancy          FORMAT A07      HEADING 'Redun-|dancy'
COL path                FORMAT A32      HEADING 'OS Disk Path Name' WRAP
SELECT
     group_number
    ,disk_number
    ,name
    ,total_mb
    ,compound_index
    ,incarnation
    ,mount_status
    ,header_status
    ,mode_status
    ,state
    ,redundancy
    ,path
  FROM v$asm_disk
order by name
;
