select opname, elapsed_seconds, sql_id, sofar/totalwork*100 pct from v$session_longops where sofar < totalwork

/
