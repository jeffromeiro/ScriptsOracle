SPO coe_xfr_sql_profile_event,sql_id_action=.log;
SET ECHO ON TERM ON LIN 2000 TRIMS ON NUMF 99999999999999999999;
REM
REM $Header: 215187.1 coe_xfr_sql_profile_event,sql_id_action=.sql 11.4.1.4 2017/09/29 csierra $
REM
REM Copyright (c) 2000-2010, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM SCRIPT
REM   coe_xfr_sql_profile_event,sql_id_action=.sql
REM
REM DESCRIPTION
REM   This script is generated by coe_xfr_sql_profile.sql
REM   It contains the SQL*Plus commands to create a custom
REM   SQL Profile for SQL_ID event,sql_id based on plan hash
REM   value action=.
REM   The custom SQL Profile to be created by this script
REM   will affect plans for SQL commands with signature
REM   matching the one for SQL Text below.
REM   Review SQL Text and adjust accordingly.
REM
REM PARAMETERS
REM   None.
REM
REM EXAMPLE
REM   SQL> START coe_xfr_sql_profile_event,sql_id_action=.sql;
REM
REM NOTES
REM   1. Should be run as SYSTEM or SYSDBA.
REM   2. User must have CREATE ANY SQL PROFILE privilege.
REM   3. SOURCE and TARGET systems can be the same or similar.
REM   4. To drop this custom SQL Profile after it has been created:
REM      EXEC DBMS_SQLTUNE.DROP_SQL_PROFILE('coe_event,sql_id_action=');
REM   5. Be aware that using DBMS_SQLTUNE requires a license
REM      for the Oracle Tuning Pack.
REM
WHENEVER SQLERROR EXIT SQL.SQLCODE;
REM
VAR signature NUMBER;
REM
DECLARE
sql_txt CLOB;
h       SYS.SQLPROF_ATTR;
BEGIN
sql_txt := q'[
]';
h := SYS.SQLPROF_ATTR(
q'[BEGIN_OUTLINE_DATA]',
DECLARE
*
ERROR at line 1:
ORA-06502: PL/SQL: numeric or value error
ORA-06512: at "SYS.XMLTYPE", line 272
ORA-06512: at line 1
ORA-06512: at line 66


