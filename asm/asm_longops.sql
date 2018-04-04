SET LINESIZE 100
SET PAGESIZE 60
-----
-- V$ASM_OPERATION 	
-- Like its counterpart, V$SESSION_LONGOPS, it shows each long-running 
-- ASM operation in the ASM instance
-----
TTITLE 'Long-Running ASM Operations (From V$ASM_OPERATIONS)'
COL group_number        FORMAT 99999    HEADING 'ASM|Disk|Grp #' 
COL operation           FORMAT A08      HEADING 'ASM|Oper-|ation' 
COL state               FORMAT A08      HEADING 'ASM|State'
COL power               FORMAT 999999   HEADING 'ASM|Power|Rqstd'
COL actual              FORMAT 999999   HEADING 'ASM|Power|Alloc'
COL est_work            FORMAT 999999   HEADING 'AUs|To Be|Moved'
COL sofar               FORMAT 999999   HEADING 'AUs|Moved|So Far'
COL est_rate            FORMAT 999999   HEADING 'AUs|Moved|PerMI'
COL est_minutes         FORMAT 999999   HEADING 'Est|Time|Until|Done|(MM)'
SELECT 
     group_number
    ,operation
    ,state
    ,power
    ,actual
    ,est_work
    ,sofar
    ,est_rate
    ,est_minutes  
  FROM v$asm_operation
;
