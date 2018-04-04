-- Count da data do analyze por dia e por owner --
-- Jefferson Romeiro
-- 13/07/2010

set lines 250 pages 250

select owner,trunc(last_analyzed),count(*)
,to_char(trunc(sysdate),'DD-MM-RR')
   from dba_tables
 where owner not in ('SYS','SYSTEM')
   and temporary <> 'Y'
   group by owner, trunc(last_analyzed)
order by 2,1
/
