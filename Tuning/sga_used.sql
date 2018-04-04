compute sum of sgasize on report
compute sum of bytes on report
compute "% Free" of bytes on report
BREAK ON REPORT
COLUMN pool    HEADING "Pool"
COLUMN name    HEADING "Name"
COLUMN sgasize HEADING "Allocated" FORMAT 999,999,999,999
COLUMN bytes   HEADING "Free" FORMAT 999,999,999,999

SELECT
    f.pool
  , f.name
  , s.sgasize
  , f.bytes
  , ROUND(f.bytes/s.sgasize*100, 2) "% Free"
FROM
    (SELECT SUM(bytes) sgasize, pool FROM v$sgastat GROUP BY pool) s
  , v$sgastat f
WHERE
    f.name = 'free memory'
  AND f.pool = s.pool
/