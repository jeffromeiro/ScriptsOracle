Rem 
Rem    NAME
Rem     sw.sql - Session Wait
Rem 
Rem    NOTE - Script para verificar se o usuario esta em Wait
Rem           
Rem	       
Rem    DESCRIPTION
Rem     Script pede que se informe um determinado SID e mostra
Rem     informacoes relativas a espera que ele esta tendo e em
Rem     qual objeto esta ocorrendo esta espera
Rem     
Rem
Rem
Rem


Rem    NOTES
Rem
Rem    MODIFIED   	(MM/DD/YYYY)
Rem    roberto.veiga    13/05/2005  - versao inicial
Rem 

set lines 		300
set term 		on
set feed 		on
set verify 		off
set head		on
set pages		50

col sid 		form 9999
col LAST_CALL_ET	form 99999
col Lcall	form 99999
col serial# 		form 99999
col event 		form a20 trunc
col wait_time 		form 999,999,999
col seconds_in_wait 	form 999,999,999
col state 		form a18 trunc
col username 		form a12 trunc
col osuser 		form a10 trunc
col program 		form a12 trunc
col status 		form a8 trunc
col machine 		form a12 trunc
col p1			new_value pp1 
col p2			new_value pp2 
col sa 			new_value vsa  noprint
col shv 		new_value vshv noprint 

col segment_name	form a25
col segment_type 	form a12 trunc
col tablespace_name 	form a20 
col owner 		form a30
col sql_text		form a195
col IO			form 999,999,999,999
col executions		form 999999999
col rows_processed	form 9999999

undef sid
undef pp1
undef pp2
undef vshv
undef vsa

ttitle left 'USUARIOS EM WAIT ' skip 2

select 
	sw.sid, 
	s.serial#,
	s.username, 
	sw.event, 
	s.sql_id,
--	sw.wait_time, 
--	sw.seconds_in_wait, 
--	sw.state,
	s.LAST_CALL_ET LCall, 
	s.osuser, 
	s.program,
	substr(s.machine,1,20) machine, 
	s.sql_address sa,
	s.sql_hash_value shv,
	sw.p1,
	sw.p2,
	to_char(logon_time, 'dd/mm/yyyy hh24:mi:ss') logon_time
from 	gv$session_wait sw, gv$session s
where 	sw.sid = s.sid
and 	sw.event not like 'SQL%'
and 	sw.event not like 'rdbms%'
and     sw.event not like '%timer'
and s.username is not null
and s.status='ACTIVE'
/

undef Sid

accept Sid prompt 'Qual o SID que deseja verificar ? '

set term off
select 
	sw.sid, 
	s.serial#,
	s.username, 
	sw.event, 
--	sw.wait_time, 
--	sw.seconds_in_wait, 
--	sw.state,
	s.status, 
	s.osuser, 
	substr(s.machine,1,20) machine, 
	s.sql_address sa,
	s.sql_hash_value shv,
	sw.p1,
	sw.p2,
	to_char(logon_time, 'dd/mm/yyyy hh24:mi:ss') logon_time
from 	v$session_wait sw, v$session s
where 	sw.sid = s.sid
and 	sw.event not like 'SQL%'
and 	sw.event not like 'rdbms%'
and     sw.event not like '%timer'
and     sw.sid=&&Sid
and s.sql_id is not null
/
set term on

/*
select 	
	owner, 	
	segment_name, 
	segment_type, 
	tablespace_name
from 	dba_extents 
where 	file_id = &&pp1
and   	&&pp2 between block_id and block_id + blocks-1
/
*/

SELECT A.SQL_ID,plan_hash_value,
round(a.BUFFER_GETS / a.EXECUTIONS, 4) buffer_gets_exec,
a.parse_calls,a.invalidations,A.EXECUTIONS,A.FETCHES/a.EXECUTIONS,plan_hash_value,
       round(A.ELAPSED_TIME / 1000000 / a.EXECUTIONS, 4) tempo_exec_seg,
       round(A.CPU_TIME / 1000000 / a.EXECUTIONS, 4) temp_cpu_seg,
       round(a.DISK_READS / a.EXECUTIONS, 4) disk_reads_exec, A.ROWS_PROCESSED/A.EXECUTIONS,
       A.LAST_LOAD_TIME,
       a.LAST_ACTIVE_TIME
  FROM gV$SQLAREA A 
  where	A.hash_value= &&vshv
and	A.address='&&vsa'
/


ttitle off
