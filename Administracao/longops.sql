COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 9999999
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.sid,
       s.serial#,
       s.sql_id,
       s.machine,
       TRUNC(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       TRUNC(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct,
       sl.message
FROM   gv$session s,
       gv$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#
and sl.time_remaining > 0;
