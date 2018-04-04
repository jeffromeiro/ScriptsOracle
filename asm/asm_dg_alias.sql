SET LINESIZE 150
SET PAGESIZE 60
CLEAR SCRE

-----
-- V$ASM_ALIAS
-- Shows every alias for every disk group mounted by the ASM instance
-----
TTITLE 'ASM Disk Group Aliases (From V$ASM_ALIAS)'
COL name                FORMAT A48              HEADING 'Disk Group Alias' 
COL group_number        FORMAT 99999            HEADING 'ASM|File #' 
COL file_number         FORMAT 999999999            HEADING 'File #'
COL file_incarnation    FORMAT 9999999999            HEADING 'ASM|File|Inc#'
COL alias_index         FORMAT 99999            HEADING 'Alias|Index'
COL alias_incarnation   FORMAT 99999            HEADING 'Alias|Incn#'
COL parent_index        FORMAT 999999999            HEADING 'Parent|Index'
COL reference_index     FORMAT 999999999            HEADING 'Ref|Idx'
COL alias_directory     FORMAT A4               HEADING 'Ali|Dir?'
COL system_created      FORMAT A4               HEADING 'Sys|Crt?'
SELECT
     name
    ,group_number
    ,file_number
    ,file_incarnation
    ,alias_index
    ,alias_incarnation
    ,parent_index
    ,reference_index
    ,alias_directory
    ,system_created
  FROM v$asm_alias
;
