col instance_name for a20
col host_name for a30
col status for a10
select instance_name, host_name, status from v$instance;

col file_name form a60
set pages 1200 lin 500
break on SET_STAMP skip 1 on BACKUP_SET 
  select bc.SET_STAMP
       , bc.SET_COUNT        as BACKUP_SET
       , bc.FILE#
       , df.NAME             as FILE_NAME
       , bc.CORRUPTION_TYPE
       , bc.MARKED_CORRUPT
       , sum(bc.BLOCKS)      as BLOCKS
    from v$backup_corruption    bc
       , v$datafile             df
   where bc.file# = df.file#
     and bc.FILE# != 0  ---Conforme note 399113.1, retira o Controlfile do SELECT
   group by bc.SET_STAMP, bc.SET_COUNT, bc.FILE#, df.NAME, bc.CORRUPTION_TYPE, bc.MARKED_CORRUPT
   order by bc.SET_STAMP, bc.SET_COUNT, bc.FILE#, df.NAME, bc.CORRUPTION_TYPE, bc.MARKED_CORRUPT;



break on COMPLETION_DATE skip 1 on SET_STAMP on BACKUP_SET
select trunc(bdf.COMPLETION_TIME)                 as COMPLETION_DATE
     , bdf.SET_STAMP
     , bdf.SET_COUNT                              as BACKUP_SET
     , count(bdf.FILE#)                           as ARQUIVOS
     , sum(bdf.BLOCKS * bdf.BLOCK_SIZE)/1024/1024 as MBYTES
     , sum(bdf.MARKED_CORRUPT)                    as MARKED_CORRUPT
     , sum(bdf.MEDIA_CORRUPT)                     as MEDIA_CORRUPT
     , sum(bdf.LOGICALLY_CORRUPT)                 as LOGICALLY_CORRUPT
  from v$backup_datafile bdf
 where bdf.FILE# != 0  ---Conforme note 399113.1, retira o Controlfile do SELECT
 group by trunc(bdf.COMPLETION_TIME)
     , bdf.SET_STAMP
     , bdf.SET_COUNT
having sum(MARKED_CORRUPT)    > 0
    or sum(MEDIA_CORRUPT)     > 0
    or sum(LOGICALLY_CORRUPT) > 0
 order by COMPLETION_DATE
        , bdf.SET_STAMP
        , bdf.SET_COUNT;
        
        
        
break on SET_STAMP skip 1 on BACKUP_SET on FILE_NAME 
select /*+ rule */
       bc.SET_STAMP
     , bc.SET_COUNT        as BACKUP_SET
     , bc.FILE#
     , bc.BLOCK#
     , bc.BLOCKS
     , bc.CORRUPTION_TYPE
     , bc.MARKED_CORRUPT
     , ex.OWNER
     , ex.SEGMENT_NAME
     , ex.TABLESPACE_NAME
  from v$backup_corruption bc
     , dba_extents         ex
 where bc.FILE# = ex.FILE_ID
   and bc.BLOCK# = ex.BLOCK_ID
   and bc.FILE# != 0  ---Conforme note 399113.1, retira o Controlfile do SELECT
 order by bc.SET_STAMP , bc.SET_COUNT , bc.FILE# , bc.BLOCK#;
 
 
 
select a.DB_NAME
     , a.BS_KEY
     , b.START_TIME START_BKP
     , b.COMPLETION_TIME END_BKP
     , a.PIECE#
     , a.FILE#
     , a.BLOCK#
     , a.BLOCKS
     , a.CORRUPTION_CHANGE#
     , a.MARKED_CORRUPT
     , a.CORRUPTION_TYPE 
  from RC_BACKUP_CORRUPTION a
     , RC_BACKUP_SET b
 where a.DB_KEY = b.DB_KEY
   and a.BS_KEY = b.BS_KEY
   order by START_TIME ;
   