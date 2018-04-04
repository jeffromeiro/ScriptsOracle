#!/bin/bash
#
# Script para verificacao de tablespaces offline 
# Data: 14/10/2008
# Criado por Jefferson Romeiro 
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
@/home/oracle/chklist/scripts/check_offline_tablespace.sql 
EOF
cat /home/oracle/chklist/log/check_offline_tablespace.lst >> /home/oracle/chklist/log/chklist_db.log
rm /home/oracle/chklist/log/check_offline_tablespace.lst

