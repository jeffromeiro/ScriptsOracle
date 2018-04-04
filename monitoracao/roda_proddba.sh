#!/bin/ksh
export ORACLE_SID=prod
export ORACLE_HOME=/oracle/product/102/db_1
export ORA_CRS_HOME=/oracle/product/102/crs
export ASM_HOME=/oracle/product/102/asm_1
export DB_HOME=/oracle/product/102/db_1
export AGENT_HOME=/oracle/product/102/agent10g
export TNS_ADMIN=/oracle/product/102/db_1/network/admin

$ORACLE_HOME/bin/sqlplus -s <<EOF
sqlplus / as sysdba
conn prod_dba/<SENHA>@prod
spoo /home/oracle/chklist/scripts/roda_prod_dba.log
select instance_name, host_name from v\$instance;
set lines 500 pages 0 time on feed on term on
show user
select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data from dual;

@/home/oracle/chklist/scripts/MIDIA_AL_657381.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657318.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657440.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657373.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657445.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657311.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657473.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657476.SQL
@/home/oracle/chklist/scripts/MIDIA_AL_657485.SQL

select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data from dual;
spoo off
exit
EOF
