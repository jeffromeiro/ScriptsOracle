#!/bin/bash
#
# Script para verificar se as particoes da tabela F_BENEFICIO_TRANSACOES estao criadas corretamente
# Data: 30/10/2008
# Gabriel Mantovani
# Atos Origin

export ORACLE_SID=$1
ORACLE_HOME=/oracle/product/102/db_1; export ORACLE_HOME
ORACLE_BASE=/oracle/product/102; export ORACLE_BASE
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1 ; export NLS_LANG

ps -ef | grep -v "grep" |grep pmon_$1 > /dev/null 2>&1
if [ $? -ne 0 ]; then
exit
fi

$ORACLE_HOME/bin/sqlplus "/as sysdba"<<EOF
set head off
set feed off
set echo off
@/home/oracle/chklist/scripts/check_rms_adm_emp_srv.sql $1
EOF
cat /home/oracle/chklist/log/check_rms_adm_emp_srv_$1.lst >> /home/oracle/chklist/log/chklist_db.log
rm /home/oracle/chklist/log/check_rms_adm_emp_srv_$1.lst