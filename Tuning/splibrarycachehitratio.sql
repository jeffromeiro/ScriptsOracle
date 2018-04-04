select a.snap_id, b.snap_time, (sum(pins) / (sum(pins) + sum(reloads)))*100 
from STATS$LIBRARYCACHE a, stats$snapshot b
where a.snap_id = b.snap_id and
a.SNAP_ID        between 21659 and 21871
group by a.snap_id, b.snap_time
/
