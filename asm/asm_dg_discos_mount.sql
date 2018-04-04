SET LINESIZE 150
SET PAGESIZE 60
CLEAR SCRE
-----
-- V$ASM_DISKGROUP
-- Describes information about ASM disk groups mounted by the ASM instance
-----
TTITLE 'ASM Disk Groups (From V$ASM_DISKGROUP)'
COL group_number        FORMAT 99999999 HEADING 'ASM|Disk|Grp #' 
COL name                FORMAT A20      HEADING 'ASM Disk|Group Name' WRAP
COL sector_size         FORMAT 99999999 HEADING 'Sector|Size'
COL block_size          FORMAT 99999999 HEADING 'Block|Size'
COL au_size             FORMAT 99999999 HEADING 'Alloc|Unit|Size'
COL state               FORMAT A11      HEADING 'Disk|Group|State'
COL type                FORMAT A06      HEADING 'Disk|Group|Type'
COL total_mb            FORMAT 99,999,999 HEADING 'Total|Space(MB)'
COL free_mb             FORMAT 99,999,999 HEADING 'Free|Space(MB)'

break on report
compute sum of total_mb on report
compute sum of free_mb on report

SELECT 
     group_number
    ,name
    ,sector_size
    ,block_size
    ,allocation_unit_size au_size
    ,state
    ,type
    ,total_mb
    ,free_mb
  FROM v$asm_diskgroup
order by name
;
