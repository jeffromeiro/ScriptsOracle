SET LINESIZE 100
SET PAGESIZE 60
CLEAR SCRE

-----
-- V$ASM_CLIENT
-- Shows which database instance(s) are using any ASM disk groups 
-- that are being mounted by this ASM instance
-----
TTITLE 'ASM Client Database Instances (From V$ASM_CLIENT)'
COL group_number    FORMAT 99999999 HEADING 'ASM|File #' 
COL instance_name   FORMAT A32      HEADING 'Serviced Database Client' WRAP 
COL db_name         FORMAT A08      HEADING 'Database|Name'
COL status          FORMAT A12      HEADING 'Status'
SELECT
     group_number
    ,instance_name
    ,db_name
    ,status
  FROM v$asm_client
;
