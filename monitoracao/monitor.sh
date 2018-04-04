#!/bin/bash
#
# Script para MONITORAR DATABASE
# Data: 09/05/2006
# Atos Origin


export ORACLE_SID=$1
ORACLE_HOME=/prod/oracle/product/10.2; export ORACLE_HOME
ORACLE_BASE=/prod/oracle; export ORACLE_BASE
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1 ; export NLS_LANG


ps -ef | grep -v "grep" |grep pmon_$1 > /dev/null 2>&1
if [ $? -ne 0 ]; then
exit
fi

$ORACLE_HOME/bin/sqlplus "/as sysdba"<<EOF
@/home/oracle/chklist/scripts/monitor.sql
EOF

