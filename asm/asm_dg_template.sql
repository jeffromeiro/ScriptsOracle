SET LINESIZE 100
SET PAGESIZE 60
CLEAR SCRE
-----
-- V$ASM_TEMPLATE
-- Lists each template present in every ASM disk group mounted 
-- by the ASM instance
-----
TTITLE 'ASM Templates (From V$ASM_TEMPLATE)'
COL group_number        FORMAT 99999    HEADING 'ASM|Disk|Grp #' 
COL entry_number        FORMAT 99999    HEADING 'ASM|Entry|#'
COL redundancy          FORMAT A06      HEADING 'Redun-|dancy'
COL stripe              FORMAT A06      HEADING 'Stripe'
COL system              FORMAT A03      HEADING 'Sys|?'
COL name                FORMAT A30      HEADING 'ASM Template Name' WRAP
SELECT
     group_number
    ,entry_number
    ,redundancy
    ,stripe
    ,system
    ,name
  FROM v$asm_template
;
