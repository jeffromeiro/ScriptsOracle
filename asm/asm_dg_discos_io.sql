SET LINESIZE 200
SET PAGESIZE 60
CLEAR SCRE

-----TTITLE 'ASM Disks - I/O Status (From V$ASM_DISK)'
COL group_number        FORMAT 99999999 HEADING 'ASM|Disk|Grp #' 
COL disk_number         FORMAT 99999999 HEADING 'ASM|Disk|#'
COL name                FORMAT A20      HEADING 'ASM|Name'
COL mount_status        FORMAT A07      HEADING 'Mount|Status'
COL total_mb            FORMAT 99,999,999 HEADING 'Total|Disk|Space(MB)'
COL free_mb             FORMAT 99,999,999 HEADING 'Free|Disk|Space(MB)'
COL reads               FORMAT 9,999,999,999 HEADING 'Disk|Reads'
COL mb_read             FORMAT 9,999,999,999 HEADING 'Reads|(MB)'
COL read_time           FORMAT 99999999 HEADING 'Read|Time'
COL read_errs           FORMAT 99999999 HEADING 'Read|Errors'
COL writes              FORMAT 99999999 HEADING 'Disk|Writes'
COL write_errs          FORMAT 99999999 HEADING 'Write|Errors'
COL write_time          FORMAT 99999999 HEADING 'Write|Time'
SELECT
     group_number
    ,disk_number
    ,name
    ,mount_status
    ,total_mb
    ,free_mb
    ,reads
    ,(bytes_read / (1024*1024)) mb_read
    ,read_errs
    ,read_time
    ,writes
    ,write_errs
    ,write_time
  FROM v$asm_disk
;
