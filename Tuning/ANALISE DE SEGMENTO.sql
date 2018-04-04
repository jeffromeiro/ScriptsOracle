




REPHEADER LEFT COL 9 '*********************************************' SKIP 1 -
               COL 9 '* TOP 10 SEGMENTOS POR ESPERA POR ITL WAITS *' SKIP 1 -
               COL 9 '*********************************************' SKIP 2
COL begin_interval_time FOR a22
COL object_name         FOR a30
COL object_type         FOR a15
COL instance_number     HEAD "INST"
COL wait                HEAD "ITL WAITS" 
COL dummy               NOPRINT
COMPUTE SUM OF wait ON dummy
BREAK ON dummy SKIP PAGE
SELECT instance_number dummy
,      instance_number
--,      begin_interval_time
,      owner
,      object_name
,      object_type
,      wait
  FROM (
        SELECT seg.instance_number
--        ,      snap.begin_interval_time
        ,      obj.owner
        ,      obj.object_name
        ,      obj.object_type
        ,      SUM(itl_waits_delta) wait
        ,      RANK() OVER (PARTITION BY seg.instance_number ORDER BY SUM(itl_waits_delta) DESC) RANK
          FROM dba_hist_snapshot snap
        ,      dba_hist_seg_stat seg
        ,      dba_objects       obj
         WHERE snap.dbid            = seg.dbid
           AND snap.instance_number = seg.instance_number
           AND snap.snap_id         = seg.snap_id
           AND snap.begin_interval_time BETWEEN TO_DATE('27/06/2011 11:00:00','DD/MM/YYYY HH24:MI:SS') 
                                            AND TO_DATE('27/06/2011 12:01:00','DD/MM/YYYY HH24:MI:SS')
           AND seg.obj#     = obj.object_id
           AND seg.dataobj# = obj.data_object_id
         GROUP BY seg.instance_number
--        ,         snap.begin_interval_time
        ,         obj.owner
        ,         obj.object_name
        ,         obj.object_type
        HAVING SUM(itl_waits_delta) > 0
       )
 WHERE rank < 11
 ORDER BY 1,rank
/

REPHEADER OFF






SELECT seg.instance_number
,      TRUNC(snap.begin_interval_time)
,      obj.owner
,      obj.object_name
,      obj.object_type
,      SUM(itl_waits_delta) wait
  FROM dba_hist_snapshot snap
,      dba_hist_seg_stat seg
,      dba_objects       obj
 WHERE snap.dbid            = seg.dbid
   AND snap.instance_number = seg.instance_number
   AND snap.snap_id         = seg.snap_id
   AND snap.begin_interval_time BETWEEN TO_DATE('01/06/2011 00:00:00','DD/MM/YYYY HH24:MI:SS') 
                                    AND TO_DATE('30/06/2011 12:00:00','DD/MM/YYYY HH24:MI:SS')
   AND seg.obj#     = obj.object_id
   AND seg.dataobj# = obj.data_object_id
   AND owner        = '&OWNER'
   AND object_name  = '&OBJECT_NAME'
 GROUP BY seg.instance_number
,         TRUNC(snap.begin_interval_time)
,         obj.owner
,         obj.object_name
,         obj.object_type
ORDER BY 1, 2