set verify off

prompt *  Data Inicial                                     (com aspas simples 'DDMMYYYYHH24MISS' )  *
ACCEPT b PROMPT "Begin Interval Time:"
prompt *  Data Final                                    (com aspas simples 'DDMMYYYYHH24MISS')  *
ACCEPT e PROMPT "End Interval Time:"

select MIN(snap_id),MAX(snap_id)
  from 
       dba_hist_snapshot
  where 
   BEGIN_INTERVAL_TIME BETWEEN to_date(&&b, 'DDMMYYYYHH24MISS')  and to_date(&&e, 'DDMMYYYYHH24MISS')
/


