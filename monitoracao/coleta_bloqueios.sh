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
spoo /home/oracle/chklist/scripts/log_coleta_bloqueios.log
select instance_name, host_name from v\$instance;
set lines 500 pages 0 time on feed on term on
show user
select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data from dual;
exec a126037.PRC_SYS_BLOCKING10G;
select to_char(sysdate, 'dd/mm/yyyy hh24:mi:ss') data from dual;
spoo off
exit
EOF
