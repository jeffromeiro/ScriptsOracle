select a.snap_id, a.snap_time, 1 - (physical_reads / (db_block_gets + consistent_gets)) from
stats$snapshot a, STATS$BUFFER_POOL_STATISTICS b
where b.snap_id between 21659 and 21871
and a.snap_id = b.snap_id
/
