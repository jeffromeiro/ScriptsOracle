SET LINESIZE 200
SET PAGESIZE 60
CLEAR SCRE
-----
-- V$ASM_FILE
-- Lists each ASM file in every ASM disk group mounted by the ASM instance
-----
TTITLE 'ASM Files (From V$ASM_FILE)'
COL group_number        FORMAT 99999999 HEADING 'ASM|File #' 
COL file_number         FORMAT 99999999 HEADING 'File #'
COL compound_index      FORMAT 9999999999 HEADING 'Cmp|Idx|#'
COL incarnation         FORMAT 9999999999 HEADING 'In#'
COL block_size          FORMAT 99999999 HEADING 'Block|Size'
COL blocks              FORMAT 99999999 HEADING 'Blocks'
COL bytes_mb            FORMAT 99999999 HEADING 'Size|(MB)'
COL space_alloc_mb      FORMAT 99999999 HEADING 'Space|Alloc|(MB)'
COL type                FORMAT A32      HEADING 'ASM File Type' WRAP
COL redundancy          FORMAT A06      HEADING 'Redun-|dancy'
COL striped             FORMAT A07      HEADING 'Striped'
COL creation_date       FORMAT A12      HEADING 'Created On'
COL modification_date   FORMAT A12      HEADING 'Last|Modified'
SELECT
     group_number
    ,file_number
    ,compound_index
    ,incarnation
    ,block_size
    ,blocks
    ,(bytes / (1024*1024)) bytes_mb
    ,(space / (1024*1024)) space_alloc_mb
    ,type
    ,redundancy
    ,striped
    ,creation_date
    ,modification_date    
  FROM v$asm_file
;
