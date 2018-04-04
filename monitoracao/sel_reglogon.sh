#!/bin/bash
#
# Script para coleta de REGLOGON
# Data: 26/11/2008
# Criado por Roberto Veiga / Vera Rodrigues
# Atos Origin



export ORACLE_SID=prod
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
@/home/oracle/chklist/scripts/sel_reglogon.sql
EOF


uuencode /oracle/reglogon/PROD_gauss04_REGLOGON.html PROD_gauss04_REGLOGON.html |mailx -s "RELATORIO DE ACESSO" -m segurancadainformacao@sodexhopass.com.br roberto.veiga@atosorigin.com 




