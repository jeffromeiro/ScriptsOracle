COL GROUP_NAME FOR A15
break on report on disk_group_name skip 1
compute sum label "Grand Total" of total_mb used_mb on report

SELECT
    name                                     group_name
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , free_mb                                  free_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
FROM
    v$asm_diskgroup
ORDER BY
    name
/
