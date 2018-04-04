accept snap_inicial number prompt 'Snapshot ID inicial: '
accept snap_final   number prompt 'Snapshot ID inicial: '
accept topn         number prompt ' Top-N (default 25): '
accept opt          number prompt 'Ordenar por (1-BufGets, 2-DskReads, 5-Parses, 6-Execs): '

column pct format 990.9
set pages 1000 lines 160 verify off

select * from (
select /*+ ordered use_nl (b st) */
       case
         when &opt=1 then ratio_to_report(buffer_gets) over ()*100
         when &opt=2 then ratio_to_report(disk_reads) over ()*100
         when &opt=5 then ratio_to_report(parses) over ()*100
         when &opt=6 then ratio_to_report(execs) over ()*100
       end PCT,
      t.* from (
select st.HASH_VALUE
      ,e.BUFFER_GETS-nvl(b.BUFFER_GETS,0) BUFFER_GETS
      ,e.DISK_READS-nvl(b.DISK_READS,0) disk_reads
      ,e.parse_calls-nvl(b.parse_calls,0) parses
      ,e.executions-nvl(b.executions,0) execs
      ,substr(trim(st.sql_text),1,64) sql_text
  from stats$sql_summary e
     , stats$sql_summary b
     , stats$sqltext     st
 where b.snap_id(+)         = &snap_inicial
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = e.instance_number
   and b.hash_value(+)      = e.hash_value
   and b.address(+)         = e.address
   and b.text_subset(+)     = e.text_subset
   and e.snap_id            = &snap_final
   and e.hash_value         = st.hash_value
   and e.text_subset        = st.text_subset
   and e.executions         > nvl(b.executions,0)
   and st.piece = 0    -- garante apenas uma linha da sqltext por hash
  ) t
  order by pct desc
) where rownum <= decode(&topn,0,25,&topn);
