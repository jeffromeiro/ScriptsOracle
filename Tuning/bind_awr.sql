/**************************************************************************************************/
/* EXIBE AS VARIAVEIS BIND DE UM COMANDO, COLETADAS PELO AWR, DADO UM SQL_ID E UM PERIODO DE DIAS */
/**************************************************************************************************/

SET TIME OFF TIMI OFF FEEDBACK OFF
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';
SET TIME ON TIMI ON FEEDBACK ON

SET VERIFY OFF

PROMPT 
ACCEPT sql_id PROMPT "Type the SQL_ID: "
ACCEPT days   PROMPT "Type the PERIOD in DAYS: "


REPHEADER LEFT COL 2 '***********************************************************************' SKIP 1 -
               COL 2 '* ' _date ' BIND VARIABLES IN AWR FOR SQL_ID: ' &sql_id ' *' SKIP 1 -
               COL 2 '***********************************************************************' SKIP 2

COL instance_name       FOR a1 HEAD 'INST'
COL name                FOR a8
COL begin_interval_time FOR a25
COL last_captured       FOR a21
COL value_string        FOR a20

BREAK ON last_captured SKIP 1

SELECT b.snap_id
,      a.begin_interval_time
,      b.instance_number      
,      b.name
,      b.position
,      b.value_string 
,      b.last_captured
  FROM dba_hist_snapshot a
,      dba_hist_sqlbind  b
 WHERE a.dbid                = b.dbid
   AND a.instance_number     = b.instance_number
   AND a.snap_id             = b.snap_id
   AND b.was_captured        = 'YES'
   AND b.sql_id              = '&sql_id' 
   AND a.begin_interval_time > TRUNC(SYSDATE - &days)
 ORDER BY b.snap_id
,         b.instance_number
,         b.last_captured
,         b.position
/

REPHEADER OFF
SET VERIFY ON