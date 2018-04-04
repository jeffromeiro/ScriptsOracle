#!/bin/bash
#
# Script para verificar se as tabelas estão sendo monitoradas 
# Data: 16/12/2008
# Criado por Jefferson Romeiro
# Atos Origin

export ORACLE_SID=$1
ORACLE_HOME=/oracle/product/102/db_1; export ORACLE_HOME
ORACLE_BASE=/oracle/product/102; export ORACLE_BASE
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1 ; export NLS_LANG

$ORACLE_HOME/bin/sqlplus "/as sysdba"<<EOF
set head off
set feed off
set echo off
@/home/oracle/chklist/scripts/check_table_monit.sql 
EOF
cat /home/oracle/chklist/log/check_table_monit.lst >> /home/oracle/chklist/log/chklist_db.log
rm /home/oracle/chklist/log/check_table_monit.lst

