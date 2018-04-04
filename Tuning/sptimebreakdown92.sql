set serveroutput on size 1000000  feedback off   lines 2000 trimspool on pages 0  verify off


-- alter session set nls_numeric_characters=',.';

accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
accept p_qtdd_events number prompt '  Quantidade de Eventos: '

create table inm_mediana(x number);
truncate table inm_mediana;


create function inm_median(p_pct in number default 1) return number as
    v_median number;
begin
    select x into v_median 
      from ( select rownum rn, x from (select x from inm_mediana where x is not null order by x ) )
     where rn = ( select floor((count(*)/2)*p_pct) from inm_mediana where x is not null );
    return v_median;
end;
/

column file_name new_val filename format a50
select 'db-waitevent-'||to_char(sysdate,'YYYYMMDD-HH24MISS')||'.csv' file_name from dual;

spool &&filename 
declare
   v_btimeslice date := to_date('&p_btime','yyyymmddhh24mi');
   v_etimeslice date := to_date('&p_etime','yyyymmddhh24mi');

   v_btime date;
   v_etime date;
   v_elasecs integer;

   v_bcpu integer;
   v_ecpu integer;
   v_cpusecs integer;

   v_total number;

   cursor c_snaps is
          select s.snap_id snap_id , to_char(s.snap_time,'yy/mm/dd-HH24:mi') snapdat
            from stats$snapshot s
           where s.snap_time between v_btimeslice and v_etimeslice
           order by s.snap_time;

   cursor c_data (v_bid in integer, v_eid in integer) is
        select event , time time_s
                  from (  select e.event, (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000 time
                         from stats$system_event b
                            , stats$system_event e
                        where b.snap_id(+)          = v_bid
                          and e.snap_id             = v_eid
                          and b.event(+)            = e.event
                          and e.total_waits         > nvl(b.total_waits,0)
                          and e.event not in (select event from stats$idle_event)
                        UNION ALL 
                       select 'CPU' event, (e.value-b.value)/100 time
                         from stats$sysstat b, stats$sysstat e
                        where e.snap_id         = v_eid
                          and b.snap_id         = v_bid
                          and e.name            = 'CPU used by this session'
                          and b.name            = 'CPU used by this session'
                        order by time desc 
                      ) where time > 0
         and rownum <= &p_qtdd_events;







begin
   dbms_output.put_line('SnapID;DataHora;Evento;Tempo(s)');
   for r_snap in c_snaps loop
      v_total := 0;
      for r_data in c_data(r_snap.snap_id, r_snap.snap_id+1) loop
          v_total := v_total + r_data.time_s;
          dbms_output.put_line(r_snap.snap_id||';'||r_snap.snapdat||';'||r_data.event||';'||r_data.time_s);
      end loop;   -- for r_data in c_data loop
      if v_total > 0 then insert into inm_mediana values (v_total); end if;
   end loop;      -- for r_snap in c_snaps loop
end;
/

spool off


prompt
prompt
prompt
prompt Mediana com ajustes na posição:

select ' 75%: '||to_char(inm_median(0.75),'99999999990.9') from dual; 
select ' 80%: '||to_char(inm_median(0.80),'99999999990.9') from dual; 
select ' 85%: '||to_char(inm_median(0.85),'99999999990.9') from dual; 
select ' 90%: '||to_char(inm_median(0.90),'99999999990.9') from dual; 
select ' 95%: '||to_char(inm_median(0.95),'99999999990.9') from dual; 
select '100%: '||to_char(inm_median(1.00),'99999999990.9') from dual; 
select '105%: '||to_char(inm_median(1.05),'99999999990.9') from dual; 
select '110%: '||to_char(inm_median(1.10),'99999999990.9') from dual; 
select '115%: '||to_char(inm_median(1.15),'99999999990.9') from dual; 
select '120%: '||to_char(inm_median(1.20),'99999999990.9') from dual; 
select '125%: '||to_char(inm_median(1.25),'99999999990.9') from dual; 


set feedback on
drop table inm_mediana;
drop function inm_median;

undef p_btime p_etime

prompt
prompt
prompt
prompt   *******************   CERTIFIQUE-SE QUE 1 TABELA e 1 FUNCTION FORAM EXCLUIDAS ACIMA   ***************************

