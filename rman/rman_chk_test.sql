/**********************************************************************
 * File:	rman_chk_nocatalog.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	15-Oct-01
 *
 * Description:
 *	SQL*Plus script to test the RMAN_CHK package, whether it is
 *	the version created within a "recovery catalog" database or
 *	the version created with the SYS schema of a target database.
 *
 * Notes:
 *	Un-comment the version you are testing, below...
 *
 * Modifications:
 *********************************************************************/
set echo on feedback on timing on pages 100 lines 130
set serveroutput on size 1000000
column b1 heading "Latest Recovery|From Backups"
column b2 heading "Latest Recovery|From Backups|And Non-backed-up|Archivelogs"
column b3 heading "Latest Backup was|Consistent (cold)|or Inconsistent (hot)"

variable b1 varchar2(20)
variable b2 varchar2(20)
variable b3 varchar2(20)

spool rman_chk_test

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

REM
REM Parameter for DBNAME required for package used with "recovery catalog"...
REM
REM exec rman_chk.recoverability(:b1, :b2, :b3, 'PROD1', sysdate-(6/24), 1, True)

REM
REM Parameter for DBNAME not required for package used in NOCATALOG..
REM
exec rman_chk.recoverability(:b1, :b2, :b3, sysdate-(5/1440), 1, True)

select	sysdate, :b1 b1, :b2 b2, :b3 b3 from dual;

spool off
