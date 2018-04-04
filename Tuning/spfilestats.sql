select a.snap_id, b.snap_time,FILENAME,PHYRDS,PHYWRTS        from STATS$FILESTATXS a, stats$snapshot b
where a.snap_id = b.snap_id and a.snap_id  between 21659 and 21871