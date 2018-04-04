#!/bin/bash
#

export ORACLE_SID=EP1
ORACLE_HOME=/oracle/EP1/102_64; export ORACLE_HOME
ORACLE_BASE=/oracle; export ORACLE_BASE


$ORACLE_HOME/bin/sqlplus fernando/inm#2014@EP1<<EOF
set head off
set feed off
set echo off
@/export/home/fernando/scripts/active.sql 
EOF
cat /home/oracle/chklist/log/check_asm.lst >> /home/oracle/chklist/log/chklist_db.log
rm /home/oracle/chklist/log/check_asm.lst

