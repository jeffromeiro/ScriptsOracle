
-- Início do Script

whenever sqlerror exit sql.sqlcode;

spool extract.log

-- Início da Configuração de Conexão

prompt
prompt ********************************************************************************
prompt *                                                                              *
prompt *  Script de Extração de Estatísticas de Base de Dados Oracle                  *
prompt *    (Testado na versão 11g)                                                   *
prompt *                                                                              *
prompt *  Versão 1.7.2 - Inmetrics 2015                                               *
prompt *                                                                              *
prompt ********************************************************************************
prompt
prompt ********************************************************************************
prompt *                                                                              *
prompt *  Versionamento do Script                                                     *
prompt *                                                                              *
prompt ********************************************************************************
prompt *  Versão  *  Data        *  Analista         *  Comentários                   *
prompt ********************************************************************************
prompt *  1.0     *  12/02/2015  *  Gelder Carvalho  *  Consolidação do Script        *
prompt *  1.1     *  13/02/2015  *  Gelder Carvalho  *  Melhorias Diversas            *
prompt *  1.2     *  20/02/2015  *  Gelder Carvalho  *  Outer Join (hw_config.log)    *
prompt *  1.3.1   *  25/02/2015  *  Gelder Carvalho  *  Nova conexão por extração     *
prompt *  1.3.2   *  25/02/2015  *  Gelder Carvalho  *  Extração de latch opcional    *
prompt *  1.3.3   *  25/02/2015  *  Gelder Carvalho  *  Escolha de caracter decimal   *
prompt *  1.3.4   *  25/02/2015  *  Gelder Carvalho  *  Datafiles por tipo            *
prompt *  1.3.5   *  25/02/2015  *  Gelder Carvalho  *  Ordenação dos resultados      *
prompt *  1.3.6   *  25/02/2015  *  Gelder Carvalho  *  Erro no Join (sga_timeline)   *
prompt *  1.4.1   *  31/03/2015  *  Gelder Carvalho  *  Fator de advisor com 1 dígito *
prompt *  1.4.2   *  31/03/2015  *  Gelder Carvalho  *  Resumo dos advisors           *
prompt *  1.5     *  07/04/2015  *  Rodrigo Pelúcio  *  Shared Pool Reserved          *
prompt *  1.5.1   *  07/04/2015  *  Rodrigo Pelúcio  *  Plan Hash Value no SQL Track  *
prompt *  1.6     *  13/04/2015  *  Emerson Silva    *  Alteração lag(parse/hitratio) *
prompt *  1.6.1   *  01/12/2015  *  Danilo Mendes    *  Inclusão datafile write time  *
prompt *  1.7     *  23/12/2015  *  Thiago Maciel    *  Nova coleta de I/O Latency    *
prompt *  1.7.1   *  23/12/2015  *  Thiago Maciel    *  Extensão .csv e Ajuste TopQ   *
prompt *  1.7.2   *  04/01/2016  *  Gelder Carvalho  *  Validação de login para erro  *
prompt ********************************************************************************
prompt
pause Pressione enter para continuar

ACCEPT ScriptInstance PROMPT '   Instância da Base : '
ACCEPT ScriptUser     PROMPT '   Usuário           : '
ACCEPT ScriptPasswd   PROMPT '   Senha             : ' HIDE
prompt

CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

-- Término da Configuração de Conexão

-- Início da Configuração do SQL*Plus

set pages 0;
set lines 32767;
set serveroutput on size unlimited;
set trimspool on;
set verify off;
set feedback off;

-- Término da Configuração do SQL*Plus

prompt
select '   Horário da base   : ' || to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') from dual;
prompt

-- Início da Configuração do Script

prompt ********************************************************************************
prompt *                                                                              *
prompt *  Configuração dos parâmetros para início da extração de estatísticas         *
prompt *                                                                              *
prompt *  !! ATENÇÃO !! Para os valores de texto, deve-se utilizar aspas simples ''   *
prompt *                                                                              *
prompt ********************************************************************************
prompt *                                                                              *
prompt *  Período de análise                                                          *
prompt *                                                                              *
prompt *  Máscara de data                                     (com aspas simples '')  *
prompt *  Valor default: 'dd/mm/yyyy'                (deixar em branco para aceitar)  *
ACCEPT date_mask PROMPT '*  Novo valor : ' DEFAULT '''dd/mm/yyyy'''
prompt *                                                                              *
prompt *  Data de início                                      (com aspas simples '')  *
ACCEPT begin_date PROMPT '*  Valor : '
prompt *                                                                              *
prompt *  Data de término                                     (com aspas simples '')  *
ACCEPT end_date PROMPT '*  Valor : '
prompt *                                                                              *
prompt *  Configuração para a saída dos arquivos                                      *
prompt *                                                                              *
prompt *  Máscara de data                                     (com aspas simples '')  *
prompt *  Valor default: 'dd/mm/yyyy hh24:mi:ss'     (deixar em branco para aceitar)  *
ACCEPT extract_mask PROMPT '*  Novo valor : ' DEFAULT '''dd/mm/yyyy hh24:mi:ss'''
prompt *                                                                              *
prompt *  Caractere para decimal                              (com aspas simples '')  *
prompt *  Valor default: '.'                         (deixar em branco para aceitar)  *
ACCEPT decimal_caract PROMPT '*  Novo valor : ' DEFAULT '''.'''
prompt *                                                                              *
prompt *  Demais parâmetros da extração                                               *
prompt *                                                                              *
prompt *  Máscara de agregação (média do período)             (com aspas simples '')  *
prompt *      mi => minuto                                                            *
prompt *    hh24 => hora                                                              *
prompt *      dd => dia                                                               *
prompt *      mm => mês                                                               *
prompt *    yyyy => ano                                                               *
prompt *  Valor default: 'mi'                        (deixar em branco para aceitar)  *
ACCEPT date_trunc PROMPT '*  Novo valor : ' DEFAULT '''mi'''
prompt *                                                                              *
prompt *  Quantidade de itens para Top Itens                                          *
prompt *  Valor default: 25                          (deixar em branco para aceitar)  *
ACCEPT top_items PROMPT '*  Novo valor : ' DEFAULT 25
prompt *                                                                              *
prompt *  Threshold para o tempo médio de resposta de datafile/tempfile (ms)          *
prompt *  Valor default: 20                          (deixar em branco para aceitar)  *
ACCEPT datafile_th PROMPT '*  Novo valor : ' DEFAULT 20
prompt *                                                                              *
prompt *  Realizar coleta de eventos de latch?                (com aspas simples '')  *
prompt *  Valor default: 'N' (deixar em branco para aceitar, 'S' > sim ou 'N' > não)  *
ACCEPT get_latch PROMPT '*  Novo valor : ' DEFAULT '''N'''
prompt *                                                                              *
prompt *  Threshold de fragmentação de tabelas (%)                                    *
prompt *  Valor default: 20                          (deixar em branco para aceitar)  *
ACCEPT table_frag PROMPT '*  Novo valor : ' DEFAULT 20
prompt *                                                                              *
prompt *  Threshold para a relação em vezes de "Clustering Factor" x "Distinct Keys"  *
prompt *    Melhor cenário quando "CF" for o mais próximo possível de "LB"            *
prompt *    Pior cenário quando "CF" for o mais próximo possível de "DK"              *
prompt *  Valor default: 20                          (deixar em branco para aceitar)  *
ACCEPT index_clust PROMPT '*  Novo valor : ' DEFAULT 20
prompt *                                                                              *
prompt ********************************************************************************
prompt

-- Término da Configuração do Script

spool off;

-- Início das extrações

prompt ********************************************************************************
prompt *                                                                              *
prompt *  Início das extrações                                                        *
prompt *                                                                              *
prompt ********************************************************************************
prompt *                                                                              *
prompt *  Lista de arquivos gerados                                                   *
prompt *                                                                              *

set termout off;

spool hw_config.csv

select 'INST_ID;INSTANCE;THREAD;HOSTNAME;CPUS;CORES;CPU_BY_CORE;SOCKETS;MEMORY_GB;VERSION;STATUS;STARTUP_TIME' extraction from dual
union all
select i.inst_id||';'||i.instance_number||';'||i.thread#||';'||upper(i.host_name)||';'||
       o1.value||';'||o2.value||';'||trunc(o1.value/o2.value)||';'||o3.value||';'||
       trim(to_char(ceil(o4.value/1024/1024/1024),'999990'))||';'||
       i.version||';'||i.status||';'||to_char(i.startup_time,&extract_mask) hw_config
  from gv$instance i, gv$osstat o1, gv$osstat o2, gv$osstat o3, gv$osstat o4
 where i.INST_ID = o1.inst_id (+)
   and i.INST_ID = o2.inst_id (+)
   and i.INST_ID = o3.inst_id (+)
   and i.INST_ID = o4.inst_id (+)
   and o1.stat_name (+) = 'NUM_CPUS'
   and o2.stat_name (+) = 'NUM_CPU_CORES'
   and o3.stat_name (+) = 'NUM_CPU_SOCKETS'
   and o4.stat_name (+) = 'PHYSICAL_MEMORY_BYTES';

spool off;

set termout on;
prompt *    hw_config.csv                                                             *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool awr_config.csv

select 'DBID;INTERVAL;RETENTION' extraction from dual
union all
select dbid||';'||substr(snap_interval, instr(snap_interval, ' ')+1, 8)||';'||to_number(substr(retention, instr(retention, '+')+1, 6))
from dba_hist_wr_control;

spool off;

set termout on;
prompt *    awr_config.csv                                                            *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool parameter.csv

select 'PARAMETER;INSTANCE;VALUE;DEFAULT' extraction from dual
union all
select * from (
  select name||';'||inst_id||';'||value||';'||isdefault
    from gv$parameter
   order by name, inst_id);

spool off;

set termout on;
prompt *    parameter.csv                                                             *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool redo_log.csv

select 'SWITCH_DATE;INSTANCE;MIN_INTERVAL;AVG_INTERVAL;P90_INTERVAL;P95_INTERVAL;P99_INTERVAL;MAX_INTERVAL' extraction from dual
union all
select * from (
select to_char(trunc(first_time,&date_trunc),&extract_mask)||';'||thread#||';'||
       replace(trim(to_char(min(interval_min),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(interval_min),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by interval_min),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by interval_min),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by interval_min),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(interval_min),'999999990.00')),'.',&decimal_caract)
  from
   (select first_time, thread#, round((first_time - lag(first_time,1) over (partition by thread# order by sequence#))*24*60) interval_min
     from v$loghist
    where first_time >= to_date(&begin_date,&date_mask)
      and first_time <= to_date(&end_date,&date_mask))
 where interval_min is not null
 group by trunc(first_time,&date_trunc), thread#
 order by trunc(first_time,&date_trunc), thread#);

spool off;

set termout on;
prompt *    redo_log.csv                                                              *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool redo_config.csv

select 'INSTANCE;GROUPS;MEMBERS_PER_GROUP;SIZE_MB' extraction from dual
union all
select thread#||';'||count(*)||';'||members||';'||trunc(bytes/1024/1024)
  from gv$log
 group by thread#, members, bytes;

spool off;

set termout on;
prompt *    redo_config.csv                                                           *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool parse.csv

with
  t1 as (select a.snap_id, b.end_interval_time snap_time,
                a.instance_number, a.stat_name, a.value
           from dba_hist_sysstat a, dba_hist_snapshot b
          where a.dbid = b.dbid
            and a.instance_number = b.instance_number
            and a.snap_id = b.snap_id
            and b.end_interval_time >= to_date(&begin_date,&date_mask)
            and b.end_interval_time <= to_date(&end_date,&date_mask)
            and stat_name in ('parse count (total)','parse count (hard)','session cursor cache hits')),
  t2 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'parse count (total)'),
  t3 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'parse count (hard)'),
  t4 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'session cursor cache hits'),
  t5 as (select t2.snap_id, t2.snap_time, t2.instance_number, t2.value total_parses, t3.value hard_parses, t4.value session_cursor_cache_hit
           from t2, t3, t4
          where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id
            and t2.instance_number = t3.instance_number and t3.instance_number = t4.instance_number),
  t6 as (select snap_id, snap_time, instance_number, total_parses, hard_parses, session_cursor_cache_hit,
           lag(total_parses,1,0) over (PARTITION BY instance_number order by snap_id) total_parses_prev,
           lag(hard_parses,1,0) over (PARTITION BY instance_number order by snap_id) hard_parses_prev,
           lag(session_cursor_cache_hit,1,0) over (PARTITION BY instance_number order by snap_id) sess_cur_cache_hit_prev
         from t5),
  t7 as (select snap_id, snap_time, instance_number, total_parses, hard_parses, session_cursor_cache_hit,
           case when (total_parses < total_parses_prev) then total_parses else total_parses - total_parses_prev end total_parses_delta,
           case when (hard_parses < hard_parses_prev) then hard_parses else hard_parses - hard_parses_prev end hard_parses_delta,
           case when (session_cursor_cache_hit < sess_cur_cache_hit_prev) then session_cursor_cache_hit else session_cursor_cache_hit - sess_cur_cache_hit_prev end session_cursor_cache_hit_delta
         from t6),
  t8 as (select rownum rn, t7.*,
           round(session_cursor_cache_hit_delta / total_parses_delta * 100,2) perc_cursor_cache_hits,
           round(((total_parses_delta - session_cursor_cache_hit_delta - hard_parses_delta) / total_parses_delta) * 100,2) perc_soft_parses,
           round(hard_parses_delta / total_parses_delta * 100,2) perc_hard_parses
         from t7 order by snap_time, instance_number)
select 'PARSE_DATE;INSTANCE;AVG_CACHE;AVG_SOFT;AVG_HARD' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||
       replace(trim(to_char(avg(perc_cursor_cache_hits),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc_soft_parses),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc_hard_parses),'990.00')),'.',&decimal_caract)
from t8 where rn > 1 and not (perc_cursor_cache_hits < 0 or perc_soft_parses < 0 or perc_hard_parses < 0)
group by trunc(snap_time,&date_trunc), instance_number
order by trunc(snap_time,&date_trunc), instance_number);

spool off;

set termout on;
prompt *    parse.csv                                                                 *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool db_hit_ratio.csv

with
  t1 as
   (select a.snap_id, b.end_interval_time snap_time,
           a.instance_number, a.stat_name, a.value
      from dba_hist_sysstat a, dba_hist_snapshot b
     where a.dbid = b.dbid and a.instance_number = b.instance_number and a.snap_id = b.snap_id
            and b.end_interval_time >= to_date(&begin_date,&date_mask)
            and b.end_interval_time <= to_date(&end_date,&date_mask)
       and stat_name in ('db block gets','consistent gets','physical reads')),
  t2 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'db block gets'),
  t3 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'consistent gets'),
  t4 as (select snap_id, snap_time, instance_number, stat_name, value from t1 where stat_name = 'physical reads'),
  t5 as (select t2.snap_id, t2.snap_time, t2.instance_number, t2.value db_block_gets, t3.value consistent_gets, t4.value physical_reads
           from t2, t3, t4
          where t2.snap_id = t3.snap_id and t3.snap_id = t4.snap_id
            and t2.instance_number = t3.instance_number and t3.instance_number = t4.instance_number),
  t6 as (select snap_id, snap_time, instance_number, db_block_gets, consistent_gets, physical_reads,
                lag(db_block_gets,1,0) over (PARTITION BY instance_number order by snap_id) db_block_gets_prev,
                lag(consistent_gets,1,0) over (PARTITION BY instance_number order by snap_id) consistent_gets_prev,
                lag(physical_reads,1,0) over (PARTITION BY instance_number order by snap_id) physical_reads_prev
         from t5),
  t7 as (select snap_id, snap_time, instance_number, db_block_gets, consistent_gets, physical_reads,
            case when (db_block_gets < db_block_gets_prev) then db_block_gets else db_block_gets - db_block_gets_prev end db_block_gets_delta,
            case when (consistent_gets < consistent_gets_prev) then consistent_gets else consistent_gets - consistent_gets_prev end consistent_gets_delta,
            case when (physical_reads < physical_reads_prev) then physical_reads else physical_reads - physical_reads_prev end physical_reads_delta
          from t6),
  t8 as (select snap_time, instance_number, round((1-(physical_reads_delta / (db_block_gets_delta + consistent_gets_delta)))*100,2) value
         from t7 order by snap_time, instance_number)
select 'DB_HIT_RATIO_DATE;INSTANCE;MIN_PERC;P01_PERC;P05_PERC;P10_PERC;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||
       replace(trim(to_char(min(value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(value),'990.00')),'.',&decimal_caract)
from t8
group by trunc(snap_time,&date_trunc), instance_number
order by trunc(snap_time,&date_trunc), instance_number);

spool off;

set termout on;
prompt *    db_hit_ratio.csv                                                          *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool library_hit_ratio.csv

WITH
  t1 AS (
    SELECT b.instance_number, a.snap_id, b.end_interval_time snap_time,
           SUM(a.pins) pins,
           SUM(reloads) reloads
      FROM dba_hist_librarycache a, dba_hist_snapshot b
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       and b.end_interval_time >= to_date(&begin_date,&date_mask)
       and b.end_interval_time <= to_date(&end_date,&date_mask)
     GROUP BY b.instance_number, a.snap_id, b.end_interval_time),
  t2 AS (
    SELECT instance_number, snap_id, snap_time, pins, reloads,
           pins - LAG(pins,1,0) OVER (PARTITION BY instance_number ORDER BY snap_id) pins_prev,
           reloads - LAG(reloads,1,0) OVER (PARTITION BY instance_number ORDER BY snap_id) reloads_prev
      FROM t1),
  t3 AS (
    SELECT instance_number, snap_id, snap_time, pins, reloads,
           CASE WHEN pins < pins_prev THEN pins ELSE pins - pins_prev END pins_delta,
           CASE WHEN reloads < reloads_prev THEN reloads ELSE reloads - reloads_prev END reloads_delta
      FROM t2),
  t4 as (select snap_time, instance_number, round((pins_delta / (pins + reloads)) * 100,2) value
         from t3 where pins_delta > 0 order by snap_time, instance_number)
select 'LIBRARY_HIT_RATIO_DATE;INSTANCE;MIN_PERC;P01_PERC;P05_PERC;P10_PERC;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||
       replace(trim(to_char(min(value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(value),'990.00')),'.',&decimal_caract)
from t4
group by trunc(snap_time,&date_trunc), instance_number
order by trunc(snap_time,&date_trunc), instance_number);

spool off;

set termout on;
prompt *    library_hit_ratio.csv                                                     *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool dictionary_hit_ratio.csv

WITH
  t1 AS (
    SELECT b.instance_number, a.snap_id, b.end_interval_time snap_time,
           SUM(a.gets) gets,
           SUM(getmisses) getmisses
      FROM dba_hist_rowcache_summary a, dba_hist_snapshot b
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       and b.end_interval_time >= to_date(&begin_date,&date_mask)
       and b.end_interval_time <= to_date(&end_date,&date_mask)
     GROUP BY b.instance_number, a.snap_id, b.end_interval_time),
  t2 AS (
    SELECT instance_number, snap_id, snap_time, gets, getmisses,
           gets - LAG(gets,1,0) OVER (PARTITION BY instance_number ORDER BY snap_id) gets_prev,
           getmisses - LAG(getmisses,1,0) OVER (PARTITION BY instance_number ORDER BY snap_id) getmisses_prev
      FROM t1),
  t3 AS (
    SELECT instance_number, snap_id, snap_time, gets, getmisses,
           CASE WHEN gets < gets_prev THEN gets ELSE gets - gets_prev END gets_delta,
           CASE WHEN getmisses < getmisses_prev THEN getmisses ELSE getmisses - getmisses_prev END getmisses_delta
      FROM t2),
  t4 AS (
    SELECT snap_time, instance_number, round((gets_delta / (gets + getmisses)) * 100,2) value
      FROM t3 where gets_delta > 0 ORDER BY snap_time, instance_number)
select 'DICTIONARY_HIT_RATIO_DATE;INSTANCE;MIN_PERC;P01_PERC;P05_PERC;P10_PERC;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||
       replace(trim(to_char(min(value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(value),'990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(value),'990.00')),'.',&decimal_caract)
from t4
group by trunc(snap_time,&date_trunc), instance_number
order by trunc(snap_time,&date_trunc), instance_number);

spool off;

set termout on;
prompt *    dictionary_hit_ratio.csv                                                  *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool pga_timeline.csv

select 'PGA_DATE;INSTANCE;MIN_SIZE;AVG_SIZE;P90_SIZE;P95_SIZE;P99_SIZE;MAX_SIZE' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||snap.instance_number||';'||
       replace(trim(to_char(min(pgas.value)/1024/1024,'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(pgas.value)/1024/1024,'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by pgas.value/1024/1024),'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by pgas.value/1024/1024),'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by pgas.value/1024/1024),'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(pgas.value)/1024/1024,'999990.00')),'.',&decimal_caract)
  from dba_hist_pgastat pgas, dba_hist_snapshot snap
 where snap.instance_number = pgas.instance_number
   and snap.dbid = pgas.dbid
   and snap.end_interval_time >= to_date(&begin_date, &date_mask)
   and snap.end_interval_time <= to_date(&end_date, &date_mask)
   and pgas.snap_id = snap.snap_id
   and pgas.name = 'total PGA allocated'
 group by trunc(snap.end_interval_time,&date_trunc), snap.instance_number
 order by trunc(snap.end_interval_time,&date_trunc), snap.instance_number);

spool off;

set termout on;
prompt *    pga_timeline.csv                                                          *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool sga_timeline.csv

select 'SGA_DATE;INSTANCE;POOL;MIN_SIZE;AVG_SIZE;P90_SIZE;P95_SIZE;P99_SIZE;MAX_SIZE' extraction from dual
union all
select * from (
select to_char(trunc(end_interval_time,&date_trunc),&extract_mask)||';'||instance_number||';'||pool||';'||
       replace(trim(to_char(min(bytes)/1024/1024,'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(bytes)/1024/1024,'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by bytes/1024/1024),'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by bytes/1024/1024),'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by bytes/1024/1024),'999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(bytes)/1024/1024,'999990.00')),'.',&decimal_caract)
  from (
select snap.end_interval_time, snap.instance_number,
       case when sgas.name = 'free memory'
       then nvl2(sgas.pool,sgas.pool, sgas.name) || ' (free)'
       else nvl2(sgas.pool,sgas.pool, sgas.name) end pool,
       sum(sgas.bytes) bytes
  from dba_hist_sgastat sgas, dba_hist_snapshot snap
 where sgas.snap_id = snap.snap_id
   and sgas.instance_number = snap.instance_number
   and sgas.dbid = snap.dbid
   and snap.end_interval_time >= to_date(&begin_date, &date_mask)
   and snap.end_interval_time <= to_date(&end_date, &date_mask)
 group by snap.end_interval_time,
       snap.instance_number,
       case when sgas.name = 'free memory'
       then nvl2(sgas.pool,sgas.pool, sgas.name) || ' (free)'
       else nvl2(sgas.pool,sgas.pool, sgas.name) end)
 group by trunc(end_interval_time,&date_trunc),instance_number,pool
 order by trunc(end_interval_time,&date_trunc),instance_number,pool);

spool off;

set termout on;
prompt *    sga_timeline.csv                                                          *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool pga_advisor_timeline.csv

select 'PGA_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_OVERALLOC;MAXOVERALLOC' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||pga.instance_number||';'||
       replace(trim(to_char(trunc(max(pga.pga_target_for_estimate)/1024/1024,2),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(pga.pga_target_factor,'999999990.0')),'.',&decimal_caract)||';'||
       min(pga.estd_overalloc_count)||';'||
       max(pga.estd_overalloc_count)
  from sys.dba_hist_pga_target_advice pga, sys.dba_hist_snapshot snap
 where pga.dbid = snap.dbid and pga.snap_id = snap.snap_id and pga.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), pga.instance_number, replace(trim(to_char(pga.pga_target_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), pga.instance_number, replace(trim(to_char(pga.pga_target_factor,'999999990.0')),'.',&decimal_caract));

spool off;

set termout on;
prompt *    pga_advisor_timeline.csv                                                  *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool pga_advisor.csv

select 'PGA_INSTANCE;MB_SIZE;FACTOR;MIN_GAIN;AVG_GAIN;P90_GAIN;MAX_GAIN' extraction from dual
union all
select * from (
with extract as (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask) snap_time, pga.instance_number,
       trunc(max(pga.pga_target_for_estimate)/1024/1024,2) area_size,
       replace(trim(to_char(pga.pga_target_factor,'999999990.0')),'.',&decimal_caract) factor,
       min(pga.estd_overalloc_count) min,
       max(pga.estd_overalloc_count) max
  from sys.dba_hist_pga_target_advice pga, sys.dba_hist_snapshot snap
 where pga.dbid = snap.dbid and pga.snap_id = snap.snap_id and pga.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), pga.instance_number, replace(trim(to_char(pga.pga_target_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), pga.instance_number, replace(trim(to_char(pga.pga_target_factor,'999999990.0')),'.',&decimal_caract))
select instance_number||';'||replace(trim(to_char(max(area_size),'999999990.00')),'.',&decimal_caract)||';'||factor||';'||
       replace(trim(to_char(min(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.0')),'.',&decimal_caract)
 from (select e.snap_time, e.instance_number, e.area_size, e.factor,
              decode(decode(e1.max,0,e.max,trunc(((e1.max - e.max) / e1.max) * 100, 2)),100,0,decode(e1.max,0,e.max,trunc(((e1.max - e.max) / e1.max) * 100, 2))) perc
         from extract e, extract e1
        where e.snap_time = e1.snap_time and e.instance_number = e1.instance_number and e1.factor = '1.0')
        group by instance_number, factor
        order by instance_number, factor);

spool off;

set termout on;
prompt *    pga_advisor.csv                                                           *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool sga_advisor_timeline.csv

select 'SGA_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_PHYS_READ;MAX_PHYS_READ' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||sga.instance_number||';'||
       replace(trim(to_char(trunc(max(sga.sga_size),2),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(sga.sga_size_factor,'999999990.0')),'.',&decimal_caract)||';'||
       min(sga.estd_physical_reads)||';'||
       max(sga.estd_physical_reads)
  from sys.dba_hist_sga_target_advice sga, sys.dba_hist_snapshot snap
 where sga.dbid = snap.dbid and sga.snap_id = snap.snap_id and sga.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), sga.instance_number, replace(trim(to_char(sga.sga_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), sga.instance_number, replace(trim(to_char(sga.sga_size_factor,'999999990.0')),'.',&decimal_caract));

spool off;

set termout on;
prompt *    sga_advisor_timeline.csv                                                  *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool sga_advisor.csv

select 'SGA_INSTANCE;MB_SIZE;FACTOR;MIN_GAIN;AVG_GAIN;P90_GAIN;MAX_GAIN' extraction from dual
union all
select * from (
with extract as (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask) snap_time, sga.instance_number,
       max(sga.sga_size) area_size,
       replace(trim(to_char(sga.sga_size_factor,'999999990.0')),'.',&decimal_caract) factor,
       min(sga.estd_physical_reads) min,
       max(sga.estd_physical_reads) max
  from sys.dba_hist_sga_target_advice sga, sys.dba_hist_snapshot snap
 where sga.dbid = snap.dbid and sga.snap_id = snap.snap_id and sga.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), sga.instance_number, replace(trim(to_char(sga.sga_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), sga.instance_number, replace(trim(to_char(sga.sga_size_factor,'999999990.0')),'.',&decimal_caract))
select instance_number||';'||replace(trim(to_char(max(area_size),'999999990.00')),'.',&decimal_caract)||';'||factor||';'||
       replace(trim(to_char(min(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.0')),'.',&decimal_caract)
 from (select e.snap_time, e.instance_number, e.area_size, e.factor, 100 - trunc((e.max / greatest(e1.max, 1)) * 100, 2) perc
         from extract e, extract e1
        where e.snap_time = e1.snap_time and e.instance_number = e1.instance_number and e1.factor = '1.0')
        group by instance_number, factor
        order by instance_number, factor);

spool off;

set termout on;
prompt *    sga_advisor.csv                                                           *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool db_cache_advisor_timeline.csv

select 'DB_CACHE_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_PHYS_READ;MAX_PHYS_READ' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||db.instance_number||';'||
       replace(trim(to_char(trunc(max(db.size_for_estimate)),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(db.size_factor,'999999990.0')),'.',&decimal_caract)||';'||
       min(db.physical_reads)||';'||
       max(db.physical_reads)
  from sys.dba_hist_db_cache_advice db, sys.dba_hist_snapshot snap
 where db.dbid = snap.dbid and db.snap_id = snap.snap_id and db.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), db.instance_number, replace(trim(to_char(db.size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), db.instance_number, replace(trim(to_char(db.size_factor,'999999990.0')),'.',&decimal_caract));

spool off;

set termout on;
prompt *    db_cache_advisor_timeline.csv                                             *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool db_cache_advisor.csv

select 'DB_CACHE_INSTANCE;MB_SIZE;FACTOR;MIN_GAIN;AVG_GAIN;P90_GAIN;MAX_GAIN' extraction from dual
union all
select * from (
with extract as (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask) snap_time, db.instance_number,
       max(db.size_for_estimate) area_size,
       replace(trim(to_char(db.size_factor,'999999990.0')),'.',&decimal_caract) factor,
       min(db.physical_reads) min,
       max(db.physical_reads) max
  from sys.dba_hist_db_cache_advice db, sys.dba_hist_snapshot snap
 where db.dbid = snap.dbid and db.snap_id = snap.snap_id and db.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), db.instance_number, replace(trim(to_char(db.size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), db.instance_number, replace(trim(to_char(db.size_factor,'999999990.0')),'.',&decimal_caract))
select instance_number||';'||replace(trim(to_char(max(area_size),'999999990.00')),'.',&decimal_caract)||';'||factor||';'||
       replace(trim(to_char(min(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.0')),'.',&decimal_caract)
 from (select e.snap_time, e.instance_number, e.area_size, e.factor, 100 - trunc((e.max / greatest(e1.max, 1)) * 100, 2) perc
         from extract e, extract e1
        where e.snap_time = e1.snap_time and e.instance_number = e1.instance_number and e1.factor = '1.0')
        group by instance_number, factor
        order by instance_number, factor);

spool off;

set termout on;
prompt *    db_cache_advisor.csv                                                      *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool shared_pool_advisor_timeline.csv

select 'SHARED_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_OBJ_HITS;MAX_OBJ_HITS' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||shared.instance_number||';'||
       max(shared.shared_pool_size_for_estimate)||';'||
       replace(trim(to_char(shared.shared_pool_size_factor,'999999990.0')),'.',&decimal_caract)||';'||
       min(shared.estd_lc_memory_object_hits)||';'||
       max(shared.estd_lc_memory_object_hits)
  from sys.dba_hist_shared_pool_advice shared, sys.dba_hist_snapshot snap
 where shared.dbid = snap.dbid and shared.snap_id = snap.snap_id and shared.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), shared.instance_number, replace(trim(to_char(shared.shared_pool_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), shared.instance_number, replace(trim(to_char(shared.shared_pool_size_factor,'999999990.0')),'.',&decimal_caract));

spool off;

set termout on;
prompt *    shared_pool_advisor_timeline.csv                                          *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool shared_pool_advisor.csv

select 'SHARED_INSTANCE;MB_SIZE;FACTOR;MIN_GAIN;AVG_GAIN;P90_GAIN;MAX_GAIN' extraction from dual
union all
select * from (
with extract as (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask) snap_time, shared.instance_number,
       max(shared.shared_pool_size_for_estimate) area_size,
       replace(trim(to_char(shared.shared_pool_size_factor,'999999990.0')),'.',&decimal_caract) factor,
       min(shared.estd_lc_memory_object_hits) min,
       max(shared.estd_lc_memory_object_hits) max
  from sys.dba_hist_shared_pool_advice shared, sys.dba_hist_snapshot snap
 where shared.dbid = snap.dbid and shared.snap_id = snap.snap_id and shared.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), shared.instance_number, replace(trim(to_char(shared.shared_pool_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), shared.instance_number, replace(trim(to_char(shared.shared_pool_size_factor,'999999990.0')),'.',&decimal_caract))
select instance_number||';'||replace(trim(to_char(max(area_size),'999999990.0')),'.',&decimal_caract)||';'||factor||';'||
       replace(trim(to_char(min(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.0')),'.',&decimal_caract)
 from (select e.snap_time, e.instance_number, e.area_size, e.factor, trunc((e.max / greatest(e1.max, 1)) * 100, 2) - 100 perc
         from extract e, extract e1
        where e.snap_time = e1.snap_time and e.instance_number = e1.instance_number and e1.factor = '1.0')
        group by instance_number, factor
        order by instance_number, factor);

spool off;

set termout on;
prompt *    shared_pool_advisor.csv                                                   *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool shared_pool_reserved.csv

select 'SHARED_RESERVED_SIZE;FREE_SPACE;FREE_PIECES;LARGEST_FREE_PIECE;USED_SPACE;USED_PIECES;LARGEST_USED_PIECE;MISSES;FAILURES_AFTER_FLUSH' extraction from dual
union all
select
replace(trim(to_char(trunc(p.value/1024/1024,2),'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(trunc(s.free_space/1024/1024,2),'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(s.free_count,'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(trunc(s.max_free_size/1024/1024,2),'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(trunc(s.used_space/1024/1024,2),'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(s.used_count,'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(trunc(s.max_used_size/1024/1024,2),'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(s.request_misses,'999999999990.00')),'.',&decimal_caract)||';'||
replace(trim(to_char(s.request_failures,'999999999990.00')),'.',&decimal_caract)
from v$parameter p, v$shared_pool_reserved s
where p.name = 'shared_pool_reserved_size';

spool off;

set termout on;
prompt *    shared_pool_reserved.csv                                                  *
set termout off;

DISC
/*
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool memory_target_advisor_timeline.csv

select 'MEMORY_TARGET_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_DB_TIME;MAX_DB_TIME' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||mem.instance_number||';'||
       replace(trim(to_char(trunc(max(mem.memory_size)),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(mem.memory_size_factor,'999999990.0')),'.',&decimal_caract)||';'||
       min(mem.estd_db_time)||';'||
       max(mem.estd_db_time)
  from sys.dba_hist_memory_target_advice mem, sys.dba_hist_snapshot snap
 where mem.dbid = snap.dbid and mem.snap_id = snap.snap_id and mem.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), mem.instance_number, replace(trim(to_char(mem.memory_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), mem.instance_number, replace(trim(to_char(mem.memory_size_factor,'999999990.0')),'.',&decimal_caract));

spool off;

set termout on;
prompt *    memory_target_advisor_timeline.csv                                        *
set termout off;

DISC

CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool memory_target_advisor.csv

select 'MEMORY_TARGET_INSTANCE;MB_SIZE;FACTOR;MIN_GAIN;AVG_GAIN;P90_GAIN;MAX_GAIN' extraction from dual
union all
select * from (
with extract as (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask) snap_time, mem.instance_number,
       max(mem.memory_size) area_size,
       replace(trim(to_char(mem.memory_size_factor,'999999990.0')),'.',&decimal_caract) factor,
       min(mem.estd_db_time) min,
       max(mem.estd_db_time) max
  from sys.dba_hist_memory_target_advice mem, sys.dba_hist_snapshot snap
 where mem.dbid = snap.dbid and mem.snap_id = snap.snap_id and mem.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), mem.instance_number, replace(trim(to_char(mem.memory_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), mem.instance_number, replace(trim(to_char(mem.memory_size_factor,'999999990.0')),'.',&decimal_caract))
select instance_number||';'||replace(trim(to_char(max(area_size),'999999990.0')),'.',&decimal_caract)||';'||factor||';'||
       replace(trim(to_char(min(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.0')),'.',&decimal_caract)
 from (select e.snap_time, e.instance_number, e.area_size, e.factor, trunc((e.max / greatest(e1.max, 1)) * 100, 2) - 100 perc
         from extract e, extract e1
        where e.snap_time = e1.snap_time and e.instance_number = e1.instance_number and e1.factor = '1.0')
        group by instance_number, factor
        order by instance_number, factor);

spool off;

set termout on;
prompt *    memory_target_advisor.csv                                                 *
set termout off;

DISC
*/
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool java_pool_advisor_timeline.csv

select 'JAVA_DATE;INSTANCE;MB_SIZE;FACTOR;MIN_OBJ_HITS;MAX_OBJ_HITS' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||java.instance_number||';'||
       max(java.java_pool_size_for_estimate)||';'||
       replace(trim(to_char(java.java_pool_size_factor,'999999990.0')),'.',&decimal_caract)||';'||
       min(java.estd_lc_memory_object_hits)||';'||
       max(java.estd_lc_memory_object_hits)
  from sys.dba_hist_java_pool_advice java, sys.dba_hist_snapshot snap
 where java.dbid = snap.dbid and java.snap_id = snap.snap_id and java.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), java.instance_number, replace(trim(to_char(java.java_pool_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), java.instance_number, replace(trim(to_char(java.java_pool_size_factor,'999999990.0')),'.',&decimal_caract));

spool off;

set termout on;
prompt *    java_pool_advisor_timeline.csv                                            *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool java_pool_advisor.csv

select 'JAVA_INSTANCE;MB_SIZE;FACTOR;MIN_GAIN;AVG_GAIN;P90_GAIN;MAX_GAIN' extraction from dual
union all
select * from (
with extract as (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask) snap_time, java.instance_number,
       max(java.java_pool_size_for_estimate) area_size,
       replace(trim(to_char(java.java_pool_size_factor,'999999990.0')),'.',&decimal_caract) factor,
       min(java.estd_lc_memory_object_hits) min,
       max(java.estd_lc_memory_object_hits) max
  from sys.dba_hist_java_pool_advice java, sys.dba_hist_snapshot snap
 where java.dbid = snap.dbid and java.snap_id = snap.snap_id and java.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), java.instance_number, replace(trim(to_char(java.java_pool_size_factor,'999999990.0')),'.',&decimal_caract)
 order by trunc(snap.end_interval_time,&date_trunc), java.instance_number, replace(trim(to_char(java.java_pool_size_factor,'999999990.0')),'.',&decimal_caract))
select instance_number||';'||replace(trim(to_char(max(area_size),'999999990.0')),'.',&decimal_caract)||';'||factor||';'||
       replace(trim(to_char(min(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by perc),'999999990.0')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.0')),'.',&decimal_caract)
 from (select e.snap_time, e.instance_number, e.area_size, e.factor, trunc((e.max / greatest(e1.max, 1)) * 100, 2) - 100 perc
         from extract e, extract e1
        where e.snap_time = e1.snap_time and e.instance_number = e1.instance_number and e1.factor = '1.0')
        group by instance_number, factor
        order by instance_number, factor);

spool off;

set termout on;
prompt *    java_pool_advisor.csv                                                     *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool mttr_advisor_timeline.csv

select 'MTTR_DATE;INSTANCE;MTTR_TARGET;MIN_CACHE_PHYS;MAX_CACHE_PHYS;MIN_TOTAL_PHYS;MAX_TOTAL_PHYS' extraction from dual
union all
select * from (
select to_char(trunc(snap.end_interval_time,&date_trunc),&extract_mask)||';'||mttr.instance_number||';'||
       replace(trim(to_char(mttr.mttr_target_for_estimate,'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(mttr.estd_cache_write_factor),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(mttr.estd_cache_write_factor),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(mttr.estd_total_write_factor),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(mttr.estd_total_write_factor),'999999990.00')),'.',&decimal_caract)
  from sys.dba_hist_mttr_target_advice mttr, sys.dba_hist_snapshot snap
 where mttr.dbid = snap.dbid and mttr.snap_id = snap.snap_id and mttr.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
 group by trunc(snap.end_interval_time,&date_trunc), mttr.instance_number, mttr.mttr_target_for_estimate
 order by trunc(snap.end_interval_time,&date_trunc), mttr.instance_number, mttr.mttr_target_for_estimate);

spool off;

set termout on;
prompt *    mttr_advisor_timeline.csv                                                 *
set termout off;

DISC
/*
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool memory_resize.csv

select 'RESIZE_DATE;INSTANCE;MEMORY_AREA;OPER_TYPE;INITIAL;TARGET;FINAL' extraction from dual
union all
select * from (
select to_char(ops.end_time, &extract_mask)||';'||ops.instance_number||';'||ops.parameter||';'||ops.oper_type||';'||
       replace(trim(to_char(trunc(ops.initial_size/1024/1024),'999990')),'.',&decimal_caract)||';'||
       replace(trim(to_char(trunc(ops.target_size/1024/1024),'999990')),'.',&decimal_caract)||';'||
       replace(trim(to_char(trunc(ops.final_size/1024/1024),'999990')),'.',&decimal_caract)
  from dba_hist_memory_resize_ops ops, dba_hist_snapshot snap
 where ops.snap_id = snap.snap_id
   and ops.dbid = snap.dbid
   and ops.instance_number = snap.instance_number
   and snap.end_interval_time >= to_date(&begin_date,&date_mask)
   and snap.end_interval_time <= to_date(&end_date,&date_mask)
   and ops.end_time between snap.begin_interval_time and snap.end_interval_time
   and status = 'COMPLETE'
   order by ops.end_time, ops.instance_number);

spool off;

set termout on;
prompt *    memory_resize.csv                                                         *
set termout off;

DISC
*/
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool io_latency.csv

with
  t0 as (
    select e.instance_number, e.event_name, s.end_interval_time snap_time, 
	         decode(startup_time, lag(startup_time,1) over (partition by s.instance_number, e.event_name order by s.end_interval_time),
           e.time_waited_micro/1000 - lag(e.time_waited_micro/1000) over (partition by s.instance_number, e.event_name order by s.end_interval_time),
           e.time_waited_micro/1000) delta_tim,           
           decode(startup_time, lag(startup_time,1) over (partition by s.instance_number, e.event_name order by s.end_interval_time),
           e.total_waits- lag(e.total_waits) over (partition by s.instance_number, e.event_name order by s.end_interval_time), e.total_waits) delta_count
      from dba_hist_snapshot s, dba_hist_system_event e
     where s.snap_id = e.snap_id and e.dbid = s.dbid
       and e.instance_number = s.instance_number
		   and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)
       and e.event_name in ('db file sequential read', 'db file scattered read',
                            'direct path read temp', 'direct path write temp',
                            'direct path read', 'direct path write',
                            'log file parallel write')
     order by e.instance_number, e.event_name,end_interval_time),
  t1 as (select instance_number,event_name,snap_time,delta_tim/delta_count avg_time_ms
           from t0 where delta_count > 0)
  select 'IOLATENCY_DATE;INSTANCE;EVENT;MIN_MS;AVG_MS;P90_MS;P95_MS;P99_MS;MAX_MS;THRESHOLD' extraction from dual
   union all
  select * from (
    select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||event_name||';'||
           replace(trim(to_char(min(avg_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
           replace(trim(to_char(avg(avg_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
           replace(trim(to_char(percentile_disc(0.90) within group (order by avg_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
           replace(trim(to_char(percentile_disc(0.95) within group (order by avg_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
           replace(trim(to_char(percentile_disc(0.99) within group (order by avg_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
           replace(trim(to_char(max(avg_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
           replace(trim(to_char(&datafile_th,'990.00')),'.',&decimal_caract)
    from t1
    group by trunc(snap_time,&date_trunc), instance_number, event_name
    order by trunc(snap_time,&date_trunc), instance_number, event_name);

spool off;

set termout on;
prompt *    io_latency.csv                                                            *
set termout off;

DISC
/*
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool datafile_response.csv

with
  t0 as (
       SELECT s.instance_number,s.snap_id,s.end_interval_time snap_time,t.contents,f.filename,startup_time,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.readtim - lag(f.readtim,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.readtim) delta_readtim,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.writetim - lag(f.writetim,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.writetim) delta_writetim,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phyrds  - lag(f.phyrds,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phyrds) delta_phyrds,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phywrts  - lag(f.phywrts,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phywrts) delta_phywrts
       FROM dba_hist_filestatxs f,
         dba_hist_snapshot s,
         dba_hist_tablespace t
       WHERE f.snap_id          = s.snap_id
       AND f.instance_number    = s.instance_number
       AND f.dbid               = s.dbid
       AND f.dbid               = t.dbid
       AND f.ts#                = t.ts#
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)
       ),
  t1 as (
    select instance_number, snap_id, snap_time, contents, filename,
           delta_readtim / delta_phyrds * 10 avg_read_time_ms,
           delta_writetim / delta_phywrts * 10 avg_write_time_ms
      from t0
     where delta_phyrds > 0
     and delta_phywrts > 0),
  t2 as (
  select instance_number, snap_id, snap_time, contents, filename, avg_read_time_ms,avg_write_time_ms,
         rank() over (partition by instance_number, snap_id, contents order by avg_read_time_ms desc) rank_read,
         rank() over (partition by instance_number, snap_id, contents order by avg_write_time_ms desc) rank_write
    from t1),
  t3 as (
    select instance_number, snap_time, contents, filename, avg_read_time_ms,avg_write_time_ms from t2 where (rank_read <= &top_items or rank_write <= &top_items))
    select 'DATAFILE_DATE;INSTANCE;TYPE;FILENAME;MINREAD_MS;AVGREAD_MS;P90READ_MS;P95READ_MS;P99READ_MS;MAXREAD_MS;MINWRITE_MS;AVGWRITE_MS;P90WRITE_MS;P95WRITE_MS;P99WRITE_MS;MAXWRITE_MS;THRESHOLD' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||contents||';'||replace(filename,'+','')||';'||
       replace(trim(to_char(min(avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(&datafile_th,'990.00')),'.',&decimal_caract)
     from t3
     group by trunc(snap_time,&date_trunc), instance_number, contents, filename
     order by trunc(snap_time,&date_trunc), instance_number, contents, filename);

spool off;

set termout on;
prompt *    datafile_response.csv                                                     *
set termout off;

DISC

CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool tempfile_response.csv

with
  t0 as (
       SELECT s.instance_number,s.snap_id,s.end_interval_time snap_time,t.contents,f.filename,startup_time,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.readtim - lag(f.readtim,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.readtim) delta_readtim,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.writetim - lag(f.writetim,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.writetim) delta_writetim,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phyrds  - lag(f.phyrds,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phyrds) delta_phyrds,
         DECODE(startup_time,lag(startup_time,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phywrts  - lag(f.phywrts,1) over (partition BY s.instance_number, f.filename order by s.end_interval_time), f.phywrts) delta_phywrts
       FROM dba_hist_tempstatxs f,
         dba_hist_snapshot s,
         dba_hist_tablespace t
       WHERE f.snap_id          = s.snap_id
       AND f.instance_number    = s.instance_number
       AND f.dbid               = s.dbid
       AND f.dbid               = t.dbid
       AND f.ts#                = t.ts#
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)
       ),
  t1 as (
    select instance_number, snap_id, snap_time, contents, filename,
           decode(delta_phyrds,0,0,delta_readtim / delta_phyrds) * 10 avg_read_time_ms,
           decode(delta_phywrts,0,0,delta_writetim / delta_phywrts) * 10 avg_write_time_ms
      from t0
     where delta_phyrds > 0
     or delta_phywrts > 0),
  t2 as (
  select instance_number, snap_id, snap_time, contents, filename, avg_read_time_ms,avg_write_time_ms,
         rank() over (partition by instance_number, snap_id, contents order by avg_read_time_ms desc) rank_read,
         rank() over (partition by instance_number, snap_id, contents order by avg_write_time_ms desc) rank_write
    from t1),
  t3 as (
    select instance_number, snap_time, contents, filename, avg_read_time_ms,avg_write_time_ms from t2 where (rank_read <= &top_items or rank_write <= &top_items))
    select 'TEMPFILE_DATE;INSTANCE;TYPE;FILENAME;MINREAD_MS;AVGREAD_MS;P90READ_MS;P95READ_MS;P99READ_MS;MAXREAD_MS;MINWRITE_MS;AVGWRITE_MS;P90WRITE_MS;P95WRITE_MS;P99WRITE_MS;MAXWRITE_MS;THRESHOLD' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||contents||';'||replace(filename,'+','')||';'||
       replace(trim(to_char(min(avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(avg_read_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(avg_write_time_ms),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(&datafile_th,'990.00')),'.',&decimal_caract)
     from t3
     group by trunc(snap_time,&date_trunc), instance_number, contents, filename
     order by trunc(snap_time,&date_trunc), instance_number, contents, filename);

spool off;

set termout on;
prompt *    tempfile_response.csv                                                     *
set termout off;

DISC
*/
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool wait_event.csv

with
  t1 as (
    select s.instance_number, s.snap_id, s.end_interval_time snap_time,
           e.event_name event, e.wait_class, nvl(e.time_waited_micro,0)/1000000 time, e.total_waits,
           startup_time
      from dba_hist_snapshot s,
           dba_hist_system_event e
     where s.snap_id = e.snap_id
       and s.instance_number = e.instance_number
       and s.dbid = e.dbid
       and e.wait_class not in ('Idle')
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)
     union all
    select s.instance_number, s.snap_id, s.end_interval_time snap_time,
           'CPU' event, 'CPU' wait_class, nvl(c.value,0)/1000000 time, 0 total_waits, startup_time
      from dba_hist_snapshot s,
           dba_hist_sys_time_model c
     where s.snap_id = c.snap_id
       and s.instance_number = c.instance_number
       and s.dbid = c.dbid
       and c.stat_name = 'DB CPU'
       and s.end_interval_time >= to_date(&begin_date, &date_mask)
       and s.end_interval_time <= to_date(&end_date, &date_mask)),
  t2 as (
    select instance_number, snap_id, snap_time, event, wait_class, time time_s,
           lag(time,1) over (partition by instance_number, event, wait_class order by snap_id) pre_time_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, event, wait_class order by snap_id),
           time - (lag(time,1) over (partition by instance_number, event, wait_class order by snap_id)), time) delta_s,
           startup_time
      from t1),
  t3 as (
    select instance_number, snap_id, snap_time, event, wait_class, time_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t2
      where pre_time_s is not null)
select 'WAIT_DATE;INSTANCE;EVENT;WAIT_CLASS;MIN_WAIT;AVG_WAIT;P90_WAIT;P95_WAIT;P99_WAIT;MAX_WAIT' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||event||';'||wait_class||';'||
       replace(trim(to_char(min(delta_s),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(delta_s),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.90) within group (order by delta_s),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by delta_s),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by delta_s),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(delta_s),'999999999990.00')),'.',&decimal_caract)
from t3
where rank <= &top_items
group by trunc(snap_time,&date_trunc), instance_number, event, wait_class
order by trunc(snap_time,&date_trunc), instance_number, event, wait_class);

spool off;

set termout on;
prompt *    wait_event.csv                                                            *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool latch.csv

with
  t1 as (
    select snap.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           lat.latch_name latch, nvl(lat.wait_time,0)/1000000 time_s, startup_time
      from dba_hist_snapshot snap,
           dba_hist_latch lat
     where lat.dbid = snap.dbid and lat.snap_id = snap.snap_id and lat.instance_number = snap.instance_number
       and snap.end_interval_time >= to_date(&begin_date, &date_mask)
       and snap.end_interval_time <= to_date(&end_date, &date_mask)
       and upper(&get_latch) = 'S'),
  t2 as (
    select instance_number,
           snap_id,
           snap_time,
           latch,
           time_s,
           lag(time_s,1) over (partition by instance_number, latch order by snap_id) pre_time_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, latch order by snap_id),
           time_s - (lag(time_s,1) over (partition by instance_number, latch order by snap_id)), time_s) delta_s,
           startup_time
      from t1),
  t3 as (
    select instance_number, snap_id, snap_time, latch, time_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t2
     where pre_time_s is not null),
  t4 as (
    select instance_number, snap_time, latch, delta_s from t3 where rank <= &top_items),
  t5 as (
    select instance_number, trunc(snap_time,&date_trunc) snap_time, latch,
           min(delta_s) min_latch,
           avg(delta_s) avg_latch,
           percentile_disc(0.90) within group (order by delta_s) p90_latch,
           percentile_disc(0.95) within group (order by delta_s) p95_latch,
           percentile_disc(0.99) within group (order by delta_s) p99_latch,
           max(delta_s) max_latch
      from t4
     group by instance_number, trunc(snap_time,&date_trunc), latch
     order by instance_number, trunc(snap_time,&date_trunc), 6 desc)
select 'LATCH_DATE;INSTANCE;LATCH;MIN_LATCH;AVG_LATCH;P90_LATCH;P95_LATCH;P99_LATCH;MAX_LATCH' extraction from dual
union all
select * from (
select to_char(snap_time,&extract_mask)||';'||instance_number||';'||latch||';'||
       replace(trim(to_char(min_latch,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg_latch,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p90_latch,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p95_latch,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p99_latch,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max_latch,'999999999990.00')),'.',&decimal_caract)
from t5
where min_latch > 0.01 or avg_latch > 0.01 or p90_latch > 0.01 or p95_latch > 0.01 or p99_latch > 0.01 or max_latch > 0.01
order by snap_time, instance_number, latch);

spool off;

set termout on;
prompt *    latch.csv                                                                 *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool top_queries_by_stats.csv

select 'RANK_BG;PCT_BG;RANK_DR;PCT_DR;RANK_CPU;PCT_CPU;RANK_ELAP;PCT_ELAP;RANK_PARSE;PCT_PARSE;RANK_EXEC;PCT_EXEC;'||
       'FLAG;SQL_ID;INSTANCE;BG;DR;CPU;ELAP;PARSE;EXEC;MODULE;SCHEMA' extraction from dual
union all
select * from (
select rank_buffer_gets||';'||trim(to_char(pct_buffer_gets,'990.00'))||';'||rank_disk_reads||';'||trim(to_char(pct_disk_reads,'990.00'))||';'||
       rank_cpu_time||';'||trim(to_char(pct_cpu_time,'990.00'))||';'||rank_elapsed||';'||trim(to_char(pct_elapsed,'990.00'))||';'||
       rank_parses||';'||trim(to_char(pct_parses,'990.00'))||';'||rank_executions||';'||trim(to_char(pct_executions,'990.00'))||';'||
       case when pct_buffer_gets > 5 or pct_disk_reads > 5 or pct_cpu_time > 5 or pct_elapsed > 5 or pct_executions > 5 then 1 else 0 end||';'||
       sql_id||';'||instance_number||';'||buffer_gets||';'||disk_reads||';'||cpu_time||';'||elapsed||';'||parses||';'||executions||';'||module||';'||schema
  from (select /*+ ordered use_nl (b st) */
          dense_rank() over (partition by t.instance_number order by buffer_gets desc, rownum) rank_buffer_gets,
          ratio_to_report(nvl(buffer_gets,0)) over (partition by t.instance_number)*100 pct_buffer_gets,
          dense_rank() over (partition by t.instance_number order by disk_reads desc, rownum) rank_disk_reads,
          ratio_to_report(nvl(disk_reads,0)) over (partition by t.instance_number)*100 pct_disk_reads,
          dense_rank() over (partition by t.instance_number order by cpu_time desc, rownum) rank_cpu_time,
          ratio_to_report(nvl(cpu_time,0)) over (partition by t.instance_number)*100 pct_cpu_time,
          dense_rank() over (partition by t.instance_number order by elapsed desc, rownum) rank_elapsed,
          ratio_to_report(nvl(elapsed,0)) over (partition by t.instance_number)*100 pct_elapsed,
          dense_rank() over (partition by t.instance_number order by parses desc, rownum) rank_parses,
          ratio_to_report(nvl(parses,0)) over (partition by t.instance_number)*100 pct_parses,
          dense_rank() over (partition by t.instance_number order by executions desc, rownum) rank_executions,
          ratio_to_report(nvl(executions,0)) over (partition by t.instance_number)*100 pct_executions,
          t.sql_id, t.instance_number, t.buffer_gets, t.disk_reads, t.cpu_time, t.elapsed, t.parses, t.executions, t.module, t.schema
        from (select sqls.sql_id, sqls.instance_number, max(sqls.module) module, max(sqls.parsing_schema_name) schema,
                     sum(nvl(sqls.buffer_gets_delta,0)) buffer_gets, sum(nvl(sqls.disk_reads_delta,0)) disk_reads,
                     trunc(sum(nvl(sqls.cpu_time_delta,0))/1000000,2) cpu_time, trunc(sum(nvl(sqls.elapsed_time_delta,0))/1000000,2) elapsed,
                     sum(nvl(sqls.parse_calls_delta,0)) parses, sum(nvl(sqls.executions_delta,0)) executions
                from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
               where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
                 and snap.end_interval_time >= to_date(&begin_date,&date_mask)
                 and snap.end_interval_time <= to_date(&end_date,&date_mask)
               group by sqls.sql_id, sqls.instance_number) t)
 where rank_buffer_gets <= &top_items
    or rank_disk_reads <= &top_items
    or rank_cpu_time <= &top_items
    or rank_elapsed <= &top_items
    or rank_parses <= &top_items
    or rank_executions <= &top_items
order by instance_number, rank_buffer_gets, rank_disk_reads, rank_cpu_time, rank_elapsed, rank_parses, rank_executions, instance_number);

spool off;

set termout on;
prompt *    top_queries_by_stats.csv                                                  *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool top_queries_by_event.csv

WITH
  t0 AS (
    SELECT COUNT(*) cnt, a.instance_number, a.sql_id, a.module, c.username,
           case when session_state in ('WAITING') then a.event
                when session_state in ('ON CPU')  then 'CPU'
           end event,
           SUM(d.buffer_gets_delta) buffer_gets, SUM(d.disk_reads_delta) disk_reads, SUM(d.cpu_time_delta)/1000000 cpu_time_s,
           SUM(d.elapsed_time_delta)/1000000 elap_time_s, SUM(d.parse_calls_delta) parses, SUM(d.executions_delta) execs
      FROM dba_hist_active_sess_history a,
           dba_hist_snapshot b,
           dba_users c,
           dba_hist_sqlstat d,
           dba_hist_sqltext e
     WHERE a.dbid = b.dbid
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id
       and b.end_interval_time >= to_date(&begin_date,&date_mask)
       and b.end_interval_time <= to_date(&end_date,&date_mask)
       AND a.sql_id IS NOT NULL
       AND a.session_state in ('WAITING','ON CPU')
       -- AND a.event = :event
       AND a.user_id = c.user_id
       AND d.dbid = a.dbid
       AND d.instance_number = a.instance_number
       AND d.sql_id = a.sql_id
       AND d.dbid = b.dbid
       AND d.instance_number = b.instance_number
       AND d.snap_id = a.snap_id
       AND d.sql_id = a.sql_id
       AND e.dbid = b.dbid
       AND e.sql_id = a.sql_id
       AND e.command_type IN (3, 2, 6, 7)
     GROUP BY a.instance_number, a.sql_id, a.module, c.username, case when session_state in ('WAITING') then a.event
                                                                      when session_state in ('ON CPU')  then 'CPU' end
     ORDER BY COUNT(*) DESC)
select 'PERC;INSTANCE;EVENT;MODULE;SCHEMA;SQL_ID;BG;BG_BY_EXEC;DR;DR_BY_EXEC;CPU;CPU_BY_EXEC;ELAP;ELAP_BY_EXEC;PARSE;EXEC;SQL_TEXT_SHORT' extraction from dual
union all
select * from (
SELECT replace(trim(to_char(ratio_to_report(t0.cnt) over(partition by t0.event) * 100,'990.00')),'.',&decimal_caract)||';'||
       t0.instance_number||';'||t0.event||';'||t0.module||';'||t0.username||';'||t0.sql_id||';'||
       replace(trim(to_char(t0.buffer_gets,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(decode(t0.execs,0,0,t0.buffer_gets/t0.execs),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(t0.disk_reads,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(decode(t0.execs,0,0,t0.disk_reads/t0.execs),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(t0.cpu_time_s,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(decode(t0.execs,0,0,t0.cpu_time_s/t0.execs),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(t0.elap_time_s,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(decode(t0.execs,0,0,t0.elap_time_s/t0.execs),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(t0.parses,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(t0.execs,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(replace(to_char(substr(t1.sql_text,1,32)),chr(13),null),chr(10),null) sql_text
  FROM t0, dba_hist_sqltext t1
 WHERE t0.sql_id = t1.sql_id
order by t0.instance_number, t0.event, ratio_to_report(t0.cnt) over(partition by t0.event) desc, t0.buffer_gets desc);

spool off;

set termout on;
prompt *    top_queries_by_events.csv                                                 *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool sql_tracking.csv

with
  t0 as (
  select snap.end_interval_time snap_time, sqls.instance_number, sqls.sql_id, sqls.plan_hash_value, sqls.module, sqls.parsing_schema_name username,
         elapsed_time_delta/1000000 elap, buffer_gets_delta bg, cpu_time_delta/1000000 cpu,
         executions_delta execs, invalidations_delta inv, parse_calls_delta parse,
         disk_reads_delta dr, physical_read_bytes_delta phys_read, physical_write_bytes_delta phys_write,
         --io_interconnect_bytes_delta/1024/1024 interconnect_mb, 
		 rows_processed_delta rows_proc
    from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
   where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
     and snap.end_interval_time >= to_date(&begin_date,&date_mask)
     and snap.end_interval_time <= to_date(&end_date,&date_mask))
--select 'TRACKING_DATE;INSTANCE;SQL_ID;PLAN_HASH_VALUE;MODULE;USERNAME;ELAP;BG;CPU;EXECS;INV;PARSE;DR;PHYS_READ;PHYS_WRITE;INTERCONNECT_MB;ROWS' extraction from dual
select 'TRACKING_DATE;INSTANCE;SQL_ID;PLAN_HASH_VALUE;MODULE;USERNAME;ELAP;BG;CPU;EXECS;INV;PARSE;DR;PHYS_READ;PHYS_WRITE;ROWS' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||sql_id||';'||plan_hash_value||';'||module||';'||username||';'||
       replace(trim(to_char(avg(elap),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(bg),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(cpu),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(execs),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(inv),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(parse),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(dr),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(phys_read),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(phys_write),'999999999990.00')),'.',&decimal_caract)||';'||
       --replace(trim(to_char(avg(interconnect_mb),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(rows_proc),'999999999990.00')),'.',&decimal_caract)
from t0
group by trunc(snap_time,&date_trunc), instance_number, sql_id, plan_hash_value, module, username
order by trunc(snap_time,&date_trunc), instance_number, sql_id, plan_hash_value, module, username);

spool off;

set termout on;
prompt *    sql_tracking.csv                                                          *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool sql_plans.csv

with
  t0 as (
  select snap.end_interval_time snap_time, sqls.instance_number, sqls.sql_id, sqls.module, sqls.parsing_schema_name username, plan_hash_value
    from sys.dba_hist_sqlstat sqls, sys.dba_hist_snapshot snap
   where sqls.dbid = snap.dbid and sqls.snap_id = snap.snap_id and sqls.instance_number = snap.instance_number
     and snap.end_interval_time >= to_date(&begin_date,&date_mask)
     and snap.end_interval_time <= to_date(&end_date,&date_mask)
     and sqls.sql_id in (select sql_id from (
                           select sqlsi.sql_id, count(distinct(sqlsi.plan_hash_value))
                             from sys.dba_hist_sqlstat sqlsi, sys.dba_hist_snapshot snapi
                            where sqlsi.dbid = snapi.dbid and sqlsi.snap_id = snapi.snap_id and sqlsi.instance_number = snapi.instance_number
                              and snapi.end_interval_time >= to_date(&begin_date,&date_mask)
                              and snapi.end_interval_time <= to_date(&end_date,&date_mask)
                            group by sqlsi.sql_id
                           having count(distinct(sqlsi.plan_hash_value)) > 1)))
select 'PLAN_DATE;INSTANCE;SQL_ID;MODULE;USERNAME;PLAN_HASH' extraction from dual
union all
select * from (
select to_char(snap_time,&extract_mask)||';'||instance_number||';'||sql_id||';'||module||';'||username||';'||plan_hash_value
from t0
order by snap_time, instance_number, sql_id, plan_hash_value);

spool off;

set termout on;
prompt *    sql_plans.csv                                                             *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool enqueue.csv

with
  t0 as (
    select s.instance_number, s.snap_id, s.end_interval_time snap_time,
           e.eq_type || ': ' || e.req_reason enqueue, nvl(e.cum_wait_time,0)/1000 time_s,
           startup_time
      from dba_hist_snapshot s,
           dba_hist_enqueue_stat e
     where e.snap_id = s.snap_id
       and e.instance_number = s.instance_number
       and e.dbid = s.dbid
       and s.end_interval_time >= to_date(&begin_date,&date_mask)
       and s.end_interval_time <= to_date(&end_date,&date_mask)),
  t1 as (
    select instance_number, snap_id, snap_time, enqueue, time_s,
           lag(time_s,1) over (partition by instance_number, enqueue order by snap_id) pre_time_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, enqueue order by snap_id),
           time_s - (lag(time_s,1) over (partition by instance_number, enqueue order by snap_id)), time_s) delta_s,
           startup_time
      from t0),
  t2 as (
    select instance_number, snap_id, snap_time, enqueue, time_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t1 where pre_time_s is not null),
  t3 AS (
    select instance_number, snap_time, enqueue, delta_s from t2 where rank <= &top_items),
  t4 as (
    select instance_number, trunc(snap_time,&date_trunc) snap_time, enqueue,
           min(delta_s) min_enq,
           avg(delta_s) avg_enq,
           percentile_disc(0.90) within group (order by delta_s) p90_enq,
           percentile_disc(0.95) within group (order by delta_s) p95_enq,
           percentile_disc(0.99) within group (order by delta_s) p99_enq,
           max(delta_s) max_enq
      from t3
     group by instance_number, trunc(snap_time,&date_trunc), enqueue
     order by instance_number, trunc(snap_time,&date_trunc), 6 desc)
select 'ENQUEUE_DATE;INSTANCE;ENQUEUE;MIN_ENQ;AVG_ENQ;P90_ENQ;P95_ENQ;P99_ENQ;MAX_ENQ' extraction from dual
union all
select * from (
select to_char(snap_time,&extract_mask)||';'||instance_number||';'||enqueue||';'||
       replace(trim(to_char(min_enq,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg_enq,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p90_enq,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p95_enq,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p99_enq,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max_enq,'999999999990.00')),'.',&decimal_caract)
from t4
order by snap_time, instance_number, enqueue);

spool off;

set termout on;
prompt *    enqueue.csv                                                               *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool io_wait.csv

with
  t0 as (
    select io.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           io.function_name, io.filetype_name, io.wait_time/1000 wait_s, startup_time
      from dba_hist_iostat_detail io, dba_hist_snapshot snap
     where io.dbid = snap.dbid
       and io.instance_number = snap.instance_number
       and io.snap_id = snap.snap_id
       and snap.end_interval_time >= to_date(&begin_date,&date_mask)
       and snap.end_interval_time <= to_date(&end_date,&date_mask)),
  t1 as (
    select instance_number, snap_id, snap_time, function_name, filetype_name, wait_s,
           lag(wait_s,1) over (partition by instance_number, function_name, filetype_name order by snap_id) pre_wait_s,
           decode(startup_time,lag(startup_time,1) over (partition by instance_number, function_name, filetype_name order by snap_id),
           wait_s - (lag(wait_s,1) over (partition by instance_number, function_name, filetype_name order by snap_id)), wait_s) delta_s,
           startup_time
      from t0),
  t2 as (
    select instance_number, snap_id, snap_time, function_name, filetype_name, wait_s, delta_s, startup_time,
           rank() over (partition by instance_number, snap_id order by delta_s desc) rank
      from t1
     where pre_wait_s is not null),
  t3 AS (
    select instance_number, snap_time, function_name, filetype_name, delta_s from t2 where rank <= &top_items),
  t4 as (
    select instance_number, trunc(snap_time,&date_trunc) snap_time, function_name, filetype_name,
           min(delta_s) min_wait,
           avg(delta_s) avg_wait,
           percentile_disc(0.90) within group (order by delta_s) p90_wait,
           percentile_disc(0.95) within group (order by delta_s) p95_wait,
           percentile_disc(0.99) within group (order by delta_s) p99_wait,
           max(delta_s) max_wait
      from t3
     group by instance_number, trunc(snap_time,&date_trunc), function_name, filetype_name
     order by instance_number, trunc(snap_time,&date_trunc), 7 desc)
select 'IO_WAIT_DATE;INSTANCE;FUNCTION;FILETYPE;MIN_WAIT;AVG_WAIT;P90_WAIT;P95_WAIT;P99_WAIT;MAX_WAIT' extraction from dual
union all
select * from (
select to_char(snap_time,&extract_mask)||';'||instance_number||';'||function_name||';'||filetype_name||';'||
       replace(trim(to_char(min_wait,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg_wait,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p90_wait,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p95_wait,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(p99_wait,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max_wait,'999999999990.00')),'.',&decimal_caract)
from t4
order by snap_time, instance_number, function_name, filetype_name);

spool off;

set termout on;
prompt *    io_wait.csv                                                               *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool seg_stat.csv

with
  t0 as (
    select snap.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           obj.owner, obj.object_name, obj.subobject_name,
           seg.logical_reads_delta,
           seg.buffer_busy_waits_delta,
           seg.db_block_changes_delta,
           seg.physical_reads_delta,
           seg.physical_writes_delta
      from dba_hist_seg_stat seg, dba_hist_snapshot snap, dba_objects obj
      where seg.dbid = snap.dbid and seg.snap_id = snap.snap_id
        and seg.instance_number = snap.instance_number
        and snap.end_interval_time >= to_date(&begin_date, &date_mask)
        and snap.end_interval_time <= to_date(&end_date, &date_mask)
        and seg.obj# = obj.object_id),
  t1 as (
    select instance_number, snap_id, snap_time, owner, object_name, subobject_name,
           logical_reads_delta, buffer_busy_waits_delta, db_block_changes_delta, physical_reads_delta, physical_writes_delta,
           rank() over (partition by instance_number, snap_id order by logical_reads_delta desc) lr_rank,
           rank() over (partition by instance_number, snap_id order by buffer_busy_waits_delta desc) bb_rank,
           rank() over (partition by instance_number, snap_id order by db_block_changes_delta desc) bc_rank,
           rank() over (partition by instance_number, snap_id order by physical_reads_delta desc) pr_rank,
           rank() over (partition by instance_number, snap_id order by physical_writes_delta desc) pw_rank
      from t0),
  t2 as (
    select instance_number, snap_id, snap_time, owner, object_name, subobject_name,
           logical_reads_delta, buffer_busy_waits_delta, db_block_changes_delta, physical_reads_delta, physical_writes_delta
      from t1 where lr_rank <= &top_items or bb_rank <= &top_items or bc_rank <= &top_items or pr_rank <= &top_items or pw_rank <= &top_items)
select 'SEG_DATE;INSTANCE;OWNER;OBJECT;SUBOBJECT;LOGICAL_READS;BUFFER_BUSY;BLOCK_CHANGES;PHYS_READ;PHYS_WRITE' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||owner||';'||object_name||';'||subobject_name||';'||
       replace(trim(to_char(avg(logical_reads_delta),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(buffer_busy_waits_delta),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(db_block_changes_delta),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(physical_reads_delta),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(physical_writes_delta),'999999990.00')),'.',&decimal_caract)
  from t2
group by trunc(snap_time,&date_trunc), instance_number, owner, object_name, subobject_name
order by trunc(snap_time,&date_trunc), instance_number, owner, object_name, subobject_name);

spool off;

set termout on;
prompt *    seg_stat.csv                                                              *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool os_stat.csv

select 'OS_DATE;INSTANCE;STAT_NAME;MIN_VAL;P01_VAL;P05_VAL;P10_VAL;AVG_VAL;P90_VAL;P95_VAL;P99_CAL;MAX_VAL' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||stat_name||';'||
       replace(trim(to_char(min(value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(value),'999999990.00')),'.',&decimal_caract)
from (select snap_time, instance_number, stat_name,
             case when stat_id in (0, 15, 16, 17) then value else delta_value end value
        from (select snap.end_interval_time snap_time, os.instance_number, os.stat_id, os.stat_name,
                     os.value - lag(os.value, 1) over (partition by os.instance_number, os.stat_name order by snap.end_interval_time) delta_value, os.value
                from sys.dba_hist_osstat os, sys.dba_hist_snapshot snap
               where os.dbid = snap.dbid and os.snap_id = snap.snap_id
                 and os.instance_number = snap.instance_number
                 and snap.end_interval_time >= to_date(&begin_date, &date_mask)
                 and snap.end_interval_time <= to_date(&end_date, &date_mask)
                 and os.stat_id in (0, 1, 2, 3, 4, 5, 6, 15, 16, 17)))
where value is not null
group by trunc(snap_time,&date_trunc), instance_number, stat_name
order by trunc(snap_time,&date_trunc), instance_number, stat_name);

spool off;

set termout on;
prompt *    os_stat.csv                                                               *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool sys_metric.csv

select 'METRIC_DATE;INSTANCE;METRIC_NAME;MIN_VAL;P01_VAL;P05_VAL;P10_VAL;AVG_VAL;P90_VAL;P95_VAL;P99_CAL;MAX_VAL;MIN_STDDEV;AVG_STDDEV;MAX_STDDEV' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||metric_name||';'||
       replace(trim(to_char(min(value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(value),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(std),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(std),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(std),'999999999990.00')),'.',&decimal_caract)
from (select snap.end_interval_time snap_time, metric.instance_number, metric.metric_id, metric.metric_name,
             metric.average value, metric.standard_deviation std
        from sys.dba_hist_sysmetric_summary metric, sys.dba_hist_snapshot snap
       where metric.dbid = snap.dbid and metric.snap_id = snap.snap_id
         and metric.instance_number = snap.instance_number
         and snap.end_interval_time >= to_date(&begin_date, &date_mask)
         and snap.end_interval_time <= to_date(&end_date, &date_mask)
         and metric_name in ('Active Parallel Sessions','Active Serial Sessions','Average Active Sessions',
                             'Background Checkpoints Per Sec','Buffer Cache Hit Ratio',
                             'Consistent Read Changes Per Sec','Consistent Read Gets Per Sec','Current Logons Count',
                             'Current Open Cursors Count','Current OS Load','Cursor Cache Hit Ratio',
                             'Database Time Per Sec','Database Wait Time Ratio','DB Block Gets Per Sec',
                             'DBWR Checkpoints Per Sec','DDL statements parallelized Per Sec','DML statements parallelized Per Sec',
                             'Executions Per Sec','I/O Megabytes per Second','I/O Requests per Second',
                             'Library Cache Hit Ratio','Library Cache Miss Ratio','Logical Reads Per Sec',
                             'Open Cursors Per Sec','Parse Failure Count Per Sec','PGA Cache Hit %',
                             'Physical Reads Per Sec','Physical Writes Per Sec','Process Limit %',
                             'Queries parallelized Per Sec','Recursive Calls Per Sec','Session Count','Session Limit %',
                             'Shared Pool Free %','Temp Space Used','Total Parse Count Per Sec',
                             'Total PGA Allocated','Total PGA Used by SQL Workareas','Total Table Scans Per Sec',
                             'User Commits Per Sec','User Rollbacks Per Sec','User Transaction Per Sec'))
group by trunc(snap_time,&date_trunc), instance_number, metric_name
order by trunc(snap_time,&date_trunc), instance_number, metric_name);

spool off;

set termout on;
prompt *    sys_metric.csv                                                            *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool resource.csv

with
  t0 as (
    select snap.instance_number, snap.snap_id, snap.end_interval_time snap_time,
           res.resource_name, res.current_utilization curr, res.max_utilization, res.limit_value
      from dba_hist_resource_limit res, dba_hist_snapshot snap
      where res.dbid = snap.dbid and res.snap_id = snap.snap_id
        and res.instance_number = snap.instance_number
        and snap.end_interval_time >= to_date(&begin_date, &date_mask)
        and snap.end_interval_time <= to_date(&end_date, &date_mask))
select 'RES_DATE;INSTANCE;RESOURCE;MIN_VAL;P01_VAL;P05_VAL;P10_VAP;AVG_VAL;P90_VAL;P95_VAL;P99_VAL;MAX_VAL;MAX_MAX;MIN_LIMIT;MAX_LIMIT' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||resource_name||';'||
       replace(trim(to_char(min(curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(curr),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(max_utilization),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(limit_value),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(limit_value),'999999990.00')),'.',&decimal_caract)
  from t0
group by trunc(snap_time,&date_trunc), instance_number, resource_name
order by trunc(snap_time,&date_trunc), instance_number, resource_name);

spool off;

set termout on;
prompt *    resource.csv                                                              *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool interconnect.csv

WITH
  t1 AS (
select snap.snap_id, snap.end_interval_time snap_time,
       ic.instance_number, ic.target_instance,
       ic.cnt_500b, ic.wait_500b, ic.cnt_8k, ic.wait_8k
        from sys.dba_hist_interconnect_pings ic, sys.dba_hist_snapshot snap
       where ic.dbid = snap.dbid and ic.snap_id = snap.snap_id
         and ic.instance_number = snap.instance_number
         and snap.end_interval_time >= to_date(&begin_date,&date_mask)
         and snap.end_interval_time <= to_date(&end_date,&date_mask)
         and ic.instance_number <> ic.target_instance),
  t2 AS (
    SELECT snap_id, snap_time, instance_number, target_instance, cnt_500b, wait_500b, cnt_8k, wait_8k,
           cnt_500b - LAG(cnt_500b,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) cnt_500b_prev,
           wait_500b - LAG(wait_500b,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) wait_500b_prev,
           cnt_8k - LAG(cnt_8k,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) cnt_8k_prev,
           wait_8k - LAG(wait_8k,1,0) OVER (PARTITION BY instance_number, target_instance ORDER BY snap_id) wait_8k_prev
      FROM t1),
  t3 AS (
    SELECT instance_number, target_instance, snap_id, snap_time,
           CASE WHEN cnt_500b < cnt_500b_prev THEN cnt_500b ELSE cnt_500b - cnt_500b_prev END cnt_500b_delta,
           CASE WHEN wait_500b < wait_500b_prev THEN wait_500b ELSE wait_500b - wait_500b_prev END wait_500b_delta,
           CASE WHEN cnt_8k < cnt_8k_prev THEN cnt_8k ELSE cnt_8k - cnt_8k_prev END cnt_8k_delta,
           CASE WHEN wait_8k < wait_8k_prev THEN wait_8k ELSE wait_8k - wait_8k_prev END wait_8k_delta
      FROM t2),
  t4 as (select snap_time, instance_number, target_instance,
                round((wait_500b_delta / cnt_500b_delta) * 100,2) ic_500b,
                round((wait_8k_delta / cnt_8k_delta) * 100,2) ic_8k
         from t3 where cnt_500b_delta > 0 or cnt_8k_delta > 0
        order by snap_time, instance_number, target_instance)
select 'INTERCONNECT_DATE;SOURCE;TARGET;MIN_500B;AVG_500B;P90_500B;P95_500B;P99_500B;MAX_500B;MIN_8K;AVG_8K;P90_8K;P95_8K;P99_8K;MAX_8K' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||instance_number||';'||target_instance||';'||
       replace(trim(to_char(min(ic_500b),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(ic_500b),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by ic_500b),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by ic_500b),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by ic_500b),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(ic_500b),'9999999999900.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(min(ic_8k),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(ic_8k),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by ic_8k),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by ic_8k),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by ic_8k),'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(ic_8k),'999999999990.00')),'.',&decimal_caract)
from t4
group by trunc(snap_time,&date_trunc), instance_number, target_instance
order by trunc(snap_time,&date_trunc), instance_number, target_instance);

spool off

set termout on;
prompt *    interconnect.csv                                                          *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool tablespace_usage.csv

with
  t0 as (
    select snap.snap_id, snap.end_interval_time snap_time,
           tab.tsname, trunc(((tsu.tablespace_usedsize * dba_tab.block_size) / (tsu.tablespace_size * dba_tab.block_size))*100, 2) perc,
           trunc((tsu.tablespace_size * dba_tab.block_size)/1024/1024/1024) total_gb
      from dba_hist_tbspc_space_usage tsu, dba_hist_tablespace tab, dba_hist_snapshot snap, dba_tablespaces dba_tab
      where tsu.dbid = snap.dbid and tsu.snap_id = snap.snap_id
        and tab.dbid = snap.dbid
        and tsu.tablespace_id = tab.ts#
        and tab.tsname = dba_tab.tablespace_name
        and snap.end_interval_time >= to_date(&begin_date, &date_mask)
        and snap.end_interval_time <= to_date(&end_date, &date_mask))
select 'TBS_DATE;TABLESPACE;MIN_PERC;P01_PERC;P05_PERC;P10_VAP;AVG_PERC;P90_PERC;P95_PERC;P99_PERC;MAX_PERC;MAX_SIZE' extraction from dual
union all
select * from (
select to_char(trunc(snap_time,&date_trunc),&extract_mask)||';'||tsname||';'||
       replace(trim(to_char(min(perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.01) within group (order by perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.05) within group (order by perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.1) within group (order by perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(avg(perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.9) within group (order by perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.95) within group (order by perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(percentile_disc(0.99) within group (order by perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(perc),'999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(max(total_gb),'999999990.00')),'.',&decimal_caract)
  from t0
group by trunc(snap_time,&date_trunc), tsname
order by trunc(snap_time,&date_trunc), tsname);

spool off;

set termout on;
prompt *    tablespace_usage.csv                                                      *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool table_fragmentation.csv

select 'OWNER;TABLE;PARTITION;SUB_PARTITION;ACTUAL;EXPECTED;REDUCTION;REDUCTION_PERC' extraction from dual
union all
select * from (
select owner||';'||table_name||';'||partition||';'||sub_partition||';'||
       replace(trim(to_char(actual_size,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(expected_size,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(reduction_size,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(reduction_perc,'999999999990.00')),'.',&decimal_caract)
  from (select * from (select owner, table_name, '' partition, '' sub_partition,
                              round((blocks*8/1024),2) actual_size, round((num_rows*avg_row_len/1024/1024),2) expected_size,
                              round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2) reduction_size,
                              ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 reduction_perc
                         from dba_tables
                        where num_rows > 0)
         union all
        select * from (select table_owner, table_name, partition_name, '' sub_partition,
                              round((blocks*8/1024),2) actual_size, round((num_rows*avg_row_len/1024/1024),2) expected_size,
                              round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2) reduction_size,
                              ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 reduction_perc
                         from dba_tab_partitions
                        where num_rows > 0)
         union all
        select * from (select table_owner, table_name, partition_name, subpartition_name,
                              round((blocks*8/1024),2) actual_size, round((num_rows*avg_row_len/1024/1024),2) expected_size,
                              round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2) reduction_size,
                              ((round((blocks*8/1024),2)-round((num_rows*avg_row_len/1024/1024),2))/round((blocks*8/1024),2))*100 -10 reduction_perc
                         from dba_tab_subpartitions
                        where num_rows > 0))
 where owner not in ('SYS', 'SYSTEM', 'WMSYS', 'EXFSYS', 'CTXSYS', 'MDSYS', 'XDB', 'ORDDATA', 'ORDSYS', 'DBSNMP', 'OLAPSYS', 'SYSMAN')
   and reduction_perc >= &table_frag
   and actual_size > 1
   order by owner, table_name, partition, sub_partition);

spool off;

set termout on;
prompt *    table_fragmentation.csv                                                   *
set termout off;

DISC
CONN &ScriptUser/&ScriptPasswd@&ScriptInstance

spool clustering_factor.csv

-- Melhor cenário quando "Clustering Factor" for o mais próximo possível de "Leaf Blocks"
-- Pior cenário quando "Clustering Factor" for o mais próximo possível de "Distinct Keys"

select 'OWNER;INDEX;PARTITION;SUB_PARTITION;TYPE;STATUS;CLUSTERING_FACTOR;DISTINCT_KEYS;LEAF_BLOCKS;CLUSTERING_X_DISTINCT;CLUSTERING_X_LEAF' extraction from dual
union all
select * from (
select owner||';'||index_name||';'||partition||';'||sub_partition||';'||index_type||';'||status||';'||clustering_factor||';'||distinct_keys||';'||leaf_blocks||';'||
       replace(trim(to_char(clustering_factor / distinct_keys,'999999999990.00')),'.',&decimal_caract)||';'||
       replace(trim(to_char(clustering_factor / leaf_blocks,'999999999990.00')),'.',&decimal_caract)
  from (select owner, index_name, '' partition, '' sub_partition, index_type, status, leaf_blocks, clustering_factor, distinct_keys
          from dba_indexes
         union all
        select index_owner, index_name, partition_name, '' sub_partition, '' index_type, status, leaf_blocks, clustering_factor, distinct_keys
          from dba_ind_partitions
         union all
        select index_owner, index_name, partition_name, '' sub_partition, '' index_type, status, leaf_blocks, clustering_factor, distinct_keys
          from dba_ind_subpartitions)
         where distinct_keys > 0 and leaf_blocks > 0
            and owner not in ('SYS', 'SYSTEM', 'WMSYS', 'EXFSYS', 'CTXSYS', 'MDSYS', 'XDB', 'ORDDATA', 'ORDSYS', 'DBSNMP', 'OLAPSYS', 'SYSMAN')
            and clustering_factor / distinct_keys >= (&index_clust/100)
order by owner, index_name, partition, sub_partition);

spool off;

set termout on;
prompt *    clustering_factor.csv                                                     *
set termout off;

set termout on;
prompt *                                                                              *
prompt ********************************************************************************
prompt *                                                                              *
prompt *  Término das extrações                                                       *
prompt *                                                                              *
prompt ********************************************************************************
prompt

-- Término das extrações

-- Término do Script
