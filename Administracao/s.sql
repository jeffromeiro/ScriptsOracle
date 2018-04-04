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
col serial# 		form 99999
col event 		form a20 trunc
col wait_time 		form 999,999,999
col seconds_in_wait 	form 999,999,999
col state 		form a18 trunc
col username 		form a12 trunc
col osuser 		form a18 trunc
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
        s.sql_id,
	sw.event, 
--	sw.wait_time, 
--	sw.seconds_in_wait, 
--	sw.state,
	s.status, 
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
and     sw.inst_id = s.inst_id
AND     S.OSUSER='Jefferson'
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
from 	gv$session_wait sw, gv$session s
where 	sw.sid = s.sid
and 	sw.event not like 'SQL%'
and 	sw.event not like 'rdbms%'
and     sw.event not like '%timer'
and     sw.sid=&&Sid
and     sw.inst_id = s.inst_id
AND     S.OSUSER='Jefferson'
/
set term on
select
	sql_text, 
	executions,
	rows_processed,
        disk_reads,
        buffer_gets,
	disk_reads + buffer_gets IO
from 	gv$sqlarea
where	hash_value= &&vshv
and	address='&&vsa'
/
ttitle off
/
