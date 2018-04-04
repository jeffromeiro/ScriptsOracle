spool /home/oracle/chklist/log/check_trs_hst_&1

set serveroutput on size 2000
set head off
set feed off
set echo off
set trimspool on

declare

   v_num_last_ptt varchar2(6); -- numero ultima particao
   v_dt_last_ptt varchar2(8); -- mes da ultima particao
   v_atual varchar2(8); -- variavel que recebera mes atual somado a mais 2 meses
   v_base varchar2(50); -- nome do db

begin

   select upper(name)
   into v_base
   from v$database;

   -- retorna valor da coluna HIGH_VALUE da ultima particao
   select distinct t.column_value as column_value
   into v_num_last_ptt
   from table(cast(a149072.f_long('PROD_DBA', 'TRS_HST') as t_long)) t;

  -- retorna data correspondente ao numero encontrado na query anterior
   select to_char(add_months (L_DIA_DT_DIA,-1),'MON-YYYY')
   into v_dt_last_ptt
   from PROD_DBA.d_data
   where  L_DIA_SK_DATA = to_number(v_num_last_ptt);

   -- retorna o mês correspondente + 2
   SELECT to_char(sysdate,'MON-YYYY')
   into v_atual
   from dual;

   if  to_date(v_dt_last_ptt,'MON-YYYY') >= to_date(v_atual,'MON-YYYY') then

      dbms_output.put_line('TRS_HST_' || v_base || '_OK');

   else
      dbms_output.put_line('TRS_HST_' || v_base || '_NOK');

   end if;

end;
/
spool off

exit
