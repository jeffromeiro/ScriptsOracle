Rem 
Rem    NAME
Rem     check.sql - Script para monitorar o banco de dados
Rem 
Rem    NOTE - Coleta varias informacoes do banco e gera um relatorio
Rem           
Rem	       
Rem    DESCRIPTION
Rem     Guardar um historico do banco de dados para posterior comparacao
Rem     e utilizacao dos dados gerados para disponibilizar relatorios com 
Rem     saida grafica.
Rem     
Rem
Rem
Rem


Rem    NOTES
Rem
Rem    MODIFIED   	(MM/DD/YYYY)
Rem    roberto.veiga    01/06/2005  - versao inicial
Rem    roberto.veiga    02/06/2005  - alteracao para mostrar os Hot Blocks
Rem    roberto.veiga    06/06/2005  - alteracao para mostrar archives por dia e horario
Rem    roberto.veiga    07/06/2005  - alteracao para mostrar cursores abertos
Rem    roberto.veiga    09/06/2005  - alteracao para mostrar informacoes sobre o audit trail
Rem    roberto.veiga    10/08/2005  - alteracao para mostrar informacoes sobre NLS
Rem    roberto.veiga    15/08/2005  - alteracao para mostrar informacoes sobre PROFILES
Rem    roberto.veiga    24/08/2005  - alteracao para mostrar informacoes sobre dba_free_space






set lines 	200
set pages 	900
set trimout 	on
set trimspool  	on
set feed 	on
set term 	off

col col1 new_value sp

set feed off

-- !!!!OBSERVACAO IMPORTANTE!!!!!
--
-- Para este Insert nao eh necessario TRUNCATE ou DELETE,
-- pois a table TB_FREE_SPACE eh do tipo temporary
--
--insert into sys.tb_free_space select * from dba_free_space;


ttitle left 'INICIO DO RELATÓRIO ' skip 2

select upper(instance_name)||'_'||host_name||'_'||to_char(sysdate,'ddmmyyyy_hh24mi')  col1  
from v$instance
/

--select upper(instance_name)||'_'||to_char(sysdate,'ddmmyyyy_hh24mi')  col1
--from v$instance
--/

set feed on

spool /home/oracle/chklist/log/&sp

------------------------------------------------------------------------------------------------------------

ttitle left  'INSTANCE HOSTNAME VERSAO' skip 2

col versao form a23

select 	upper(instance_name)||'_'||host_name||'['|| substr(version,1,3)||']' VERSAO,
to_char(sysdate,'DD/MM/YYYY HH24:MI') DATA_ATUAL, 
to_char(STARTUP_TIME,'DD/MM/YYYY HH24:MI') STARTUP_TIME,
ROUND(sysdate-startup_time,1) DIAS_ATIVOS 
from v$instance
/


------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------

clear break

ttitle left  'USUARIOS DO BANCO DE DADOS ' skip 2


select 
username, 
account_status, 
lock_date, 
expiry_date, 
profile
from dba_users
order by username
/

select
account_status,
count(*) 
from dba_users
group by account_status
/

------------------------------------------------------------------------------------------------------------


break on profile skip 1 on resource_type skip 1

ttitle left  'POLITICA DE SENHAS ' skip 2

select 
	profile, 
		resource_type, 
			resource_name, 
				limit 
				from 	dba_profiles 
				where  	profile in (select profile from dba_users) 
				order by 1,2
				/

				clear breaks


				------------------------------------------------------------------------------------------------------------


				break on owner skip 1

				ttitle left  'NUMERO DE OBJETOS POR USUARIO' skip 2

				select owner, object_type,count(*)
				from dba_objects
				group by owner, object_type
				/
				clear break

				------------------------------------------------------------------------------------------------------------

				col value new_value dbs noprint

				set echo off
				set feed off
				set verify off
				select value from v$parameter where name='db_block_size'
				/

				set feed on

				col value print

				ttitle left  'DATAFILES POR TABLESPACE' skip 2

				break on report on tablespace_name skip 1
				comp sum of bytes on report
				comp sum of bytes on tablespace_name skip 1

				col tablespace_Name form a30
				col file_name form a51
				col bytes form 999,999,999,999
				col "MAXEXTEND(MB)" form 999,999
				col "INCREMENT(MB)" form 999,999
				col "INCREASE(MB)" form 9,999,999,999

				select 
				tablespace_name, 
				file_name, bytes, 
				TRUNC(maxextend*&&dbs/1024/1024) 		"MAXEXTEND(MB)" , 
				TRUNC(inc*&&dbs/1024/1024) 			"INCREMENT(MB)" ,
				( (MAXEXTEND*&&dbs) - BYTES )/1024/1024 	"INCREASE(MB)"
				from dba_data_files ddf, sys.filext$ f
				where ddf.file_id= f.file#(+)
				order by 1,2
				/

				clear break
				clear comp

				------------------------------------------------------------------------------------------------------------


				ttitle left 'ESTATISTICAS DAS TABELAS - ANALYZE ' skip 2

				col num_rows	form	999,999,999
				col sample_size	form	999,999,999
				col "%"		form	999.99
				select 
				table_Name, 
				num_rows, 
				last_analyzed, 
				sample_size, 
				round((sample_size/num_rows)*100,2) "%" 
				from 	dba_tables
				where 	sample_size >0
				order by 5 desc
				/



				-------------------------------------------------------------------------------------------------------


				clear break 

				ttitle left  'NUMERO DE BYTES POR TABLESPACE' skip 2

				col tablespace_Name form a30 head TABLESPACE
				col bytes form 999,999,999,999

				break on report
				comp sum of bytes on report

				select tablespace_name, sum(bytes) bytes
				from dba_data_files
				group by tablespace_name
				order by 1
				/

				clear break

				------------------------------------------------------------------------------------------------------------

				col owner form a30
				col object_name form a30
				col status form a30

				ttitle left  'OBJETOS INVALIDOS' skip 2

				break on owner skip 1

				select owner, object_name, object_type, status
				from dba_objects
				where status <> 'VALID'
				order by 1,3,2
				/

				clear break

				------------------------------------------------------------------------------------------------------------

				break on owner skip 1

				ttitle left  'CONSTRAINTS DESABILITADAS' skip 2

				select owner, constraint_type, constraint_name,  
				table_name, status, r_owner, r_constraint_name
				from dba_constraints
				where status <> 'ENABLED'
				order by 1,2,3
				/

				clear break

				------------------------------------------------------------------------------------------------------------

				break on owner skip 1

				ttitle left  'TRIGGERS DESABILITADOS' skip 2

				select owner, trigger_name,  table_owner, table_name,  trigger_type, 
				 status
				 from dba_triggers
				 where status <> 'ENABLED'
				 order by 1,2,3,4
				 /

				 clear break

				 ------------------------------------------------------------------------------------------------------------


				 ttitle left  'INDICES INVALIDOS' skip 2

				 break on owner skip 1

				 select owner, index_name, table_owner, table_name, status
				 from dba_indexes
				 where status <> 'VALID'
				 order by 1,2,3,4
				 /

				 clear break

				 ------------------------------------------------------------------------------------------------------------


				 break on tablespace_name skip 1

				 ttitle left  'STATUS DOS DATAFILES ( DBA_DATA_FILES)  ' skip 2

				 select tablespace_name, file_name, file_id, bytes, status
				 from dba_data_files
				 where status <> 'AVAILABLE'
				 order by 1,2
				 /

				 clear break

				 ------------------------------------------------------------------------------------------------------------



				 col name form a51
				 ttitle left  'STATUS DOS DATAFILES (V$DATAFILE) ' skip 2

				 select name, file#, bytes, status, to_char(last_time,'ddmmyyyy hh24:mi:ss') last_time,
				 last_change#
				 from v$datafile
				 where status <> 'ONLINE'
				 order by 1
				 /

				 ------------------------------------------------------------------------------------------------------------


				 col member form a40
				 col status form a20

				 break on report
				 comp sum of bytes on report

				 ttitle left  'STATUS DOS LOGFILES ' skip 2

				 select f.group#, f.member, l.status, l.bytes, l.archived, f.status
				 from v$log l , v$logfile f
				 where l.group# = f.group#
				 /

				 clear breaks

				 ------------------------------------------------------------------------------------------------------------

				 col host_name form a20
				 col instance_number form 999 head INUMBER 
				 col instance_name   form a10 head INAME

				 ttitle left 'HORARIO DA ATIVACAO DA INSTANCE ' skip 2

				 select 
				 instance_number, 
				 instance_name, 
				 host_name, 
				 version, 
				 to_char(startup_time,'DD/MM/YYYY DY HH24:MI:SS') startup_time, 
				 status, 
				 logins, 
				 shutdown_pending, 
				 database_status, 
				 instance_role
				 from v$instance
				 /

				 ------------------------------------------------------------------------------------------------------------

				 ttitle left  'VERSOES' skip 2

				 select * 
				 from v$version
				 /

				 ------------------------------------------------------------------------------------------------------------

				 ttitle left  'USUARIOS ATIVOS' SKIP 2

				 col np noprint

				 select 
				 substr(s.username,1,20) username, 
				 s.sid, 
				 to_char(logon_time,'DD/MM/YYYY HH24:MI:SS') logon_time
				 from 	v$session s
				 where 	status='ACTIVE'
				 and 	s.username is not null
				 order by logon_time
				 /
				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'DATA DA CRIACAO DO BANCO DE DADOS' skip 2

				 select name, to_char(created,'dd/mm/yyyy hh24:mi:ss') created, log_mode, open_resetlogs
				 from v$database
				 /


				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'MEDIA DE I/O ' skip 2

				 col phyrds form 999,999,999,999
				 col phyblkrd form 999,999,999,999
				 col phywrts form 999,999,999,999
				 col phyblkwrt form 999,999,999,999
				 col AvgRD form 999.99
				 col AvgWT form 999.99
				 col AvgBLKWT form 999.99
				 col AvgBLKRD form 999.99

				 break on report

				 comp avg of avgrd on report
				 comp avg of avgwt on report
				 comp avg of avgblkwt on report
				 comp avg of avgblkrd on report

				 comp sum of phyrds on report
				 comp sum of phyblkrd on report
				 comp sum of phyblkwrt on report
				 comp sum of phywrts on report




				 select 
				 substr(df.file_name,1,3) drive, 
				 sum(f.phyrds) phyrds, 
				 sum(f.phyblkrd) phyblkrd , 
				 sum(f.phyrds) /  sum(phyrds+phywrts) AvgRD,
				 sum(f.phywrts) /  sum(phyrds+phywrts) AvgWT,
				 sum(f.phywrts) phywrts, 
				 sum(f.phyblkwrt) phyblkwrt,
				 sum(f.phyblkwrt) /  sum(f.phyblkrd + f.phyblkwrt) AvgBLKWT,
				 sum(f.phyblkrd) /  sum(f.phyblkrd + f.phyblkwrt)  AvgBLKRD
				 from 	v$filestat f , dba_data_files df
				 where 	f.file#=df.file_id
				 group 	by substr(df.file_name,1,3)
				 /

				 clear breaks
				 ------------------------------------------------------------------------------------------------------------


				 ------------------------------------------------------------------------------------------------------------

				 clear breaks

				 break on report 
				 compu sum of mbytes on report

				 col segment_type heading SEG_TYPE format a12
				 col mbytes form 999,999,999

				 ttitle left 'TAMANHO DOS TIPOS DE SEGMENTOS' skip 2


				 select 
				 segment_type, 
				 sum(bytes)/1024/1024 mbytes
				 from 	dba_segments
				 group by segment_type
				 order by 2
				 /

				 clear breaks
				 clear computes
				 ------------------------------------------------------------------------------------------------------------

				 break on owner skip 1

				 col bytes format 999,999,999,999

				 ttitle left 'TAMANHO DOS TIPOS DE SEGMENTOS POR USUARIO ' skip 2

				 select 
				 owner, 
				 segment_type, 
				 sum(bytes) bytes
				 from 	dba_segments
				 group by owner, segment_type
				 /

				 clear breaks

				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'MAIORES SEGMENTOS (TAMANHO E NUMERO DE EXTENTS)  ' skip 2

				 clear break

				 break on owner skip 1 on segment_type skip 1 on report
				 compute sum of mbytes on report

				 col mbytes form 99,999,999,999

				 select
				 owner,
				 segment_type,
				 segment_name,
				 tablespace_name,
				 bytes/1024/1024 mbytes,
				 extents,
				 buffer_pool
				 from 	dba_segments
				 where 	( bytes > 100*1024*1024
				 or
				 extents > 50 )
				 order by 1,2,5 desc , 6
				 /

				 clear breaks

				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'NAO PODE ALOCAR O PROXIMO EXTENT POR FALTA DE ESPACO ' skip 2


				 col 	owner		form 	a16
				 col	segment_name	form	a30
				 col	next_extent	form	9,999,999,999
				 col	ext_bytes	form	9,999,999,999
				 col	bytes		form	9,999,999,999


				 select
				 ds.owner,
				 ds.segment_name,
				 substr(ds.tablespace_name,1,26) tablespace_name,
				 ds.next_extent,
				 ds.bytes,
				 -- ds.blocks,
				 -- ds.header_file,
				 -- ds.header_block,
				 bb.bytes EXT_BYTES
				 from 	dba_segments ds,
				 (
				 select tablespace_name , max(bytes) bytes
				 from 
				 (
				 select
				 tablespace_name,
				 max(bytes) bytes
				 --from 	tb_free_space
				 from dba_free_space
				 group 	by tablespace_name
				 union all
				 select
				 tablespace_name,
				 max(maxbytes - bytes) bytes
				 from 	dba_data_files
				 group 	by tablespace_name
				 ) aa
				 group by tablespace_name
				 ) bb
				 where
				 ds.tablespace_name = bb.tablespace_name
				 and	ds.next_extent > bb.bytes
				 /



				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'OBJETOS COM STATUS DE ERRO ' skip 2

				 col text form a50 trunc

				 break on owner skip 1

				 select owner, name, text 
				 from dba_errors
				 order by owner
				 /

				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'OBJETOS MODIFICADOS NOS ULTIMOS 3 DIAS ' skip 2

				 rem 	ctime	object create time
				 rem	stime	object re-create time
				 rem	mtime	object compile time

				 col 	nc 		noprint
				 col	owner 		form 	a14
				 col	name		form	a30
				 col 	object_type	form	a20 trunc	heading TYPE
				 col	CREATED		form	a30
				 col	MODIFIED	form 	a30
				 select 
				 owner, 
				 name, 
				 object_type, 
				 to_char(ctime,'DD-MON-YYYY-DY HH24:MI:SS') CREATED,
				 --to_char(mtime,'DD-MON-YYYY HH24:MI:SS') MTIME,
				 to_char(stime,'DD-MON-YYYY-DY HH24:MI:SS') MODIFIED , 
				 stime nc
				 from 	sys.obj$ , dba_objects
				 where 	trunc(sysdate) - trunc(stime) <= 3
				 and 	obj#=object_id
				 order 	by 6
				 /




				 ------------------------------------------------------------------------------------------------------------


				 ttitle left 'PARAMETROS DE INICIALIZACAO DO ORACLE ' skip 2

				 show parameter

				 ------------------------------------------------------------------------------------------------------------

				 clear break

				 col db_link form a30
				 col host form a40

				 break on owner skip 1

				 ttitle left 'RELACAO DOS DB LINKS ' skip 2

				 select owner, username, db_link, host, created 
				 from dba_db_links
				 order by owner, username
				 /

				 clear break

				 ------------------------------------------------------------------------------------------------------------


				 ------------------------------------------------------------------------------------------------------------

				 clear break 


				 col np 	  noprint
				 col "00"  form 099 
				 col "01"  form 099 
				 col "02"  form 099
				 col "03"  form 099 
				 col "04"  form 099 
				 col "05"  form 099
				 col "06"  form 099 
				 col "07"  form 099 
				 col "08"  form 099
				 col "09"  form 099 
				 col "10"  form 099 
				 col "11"  form 099
				 col "12"  form 099 
				 col "13"  form 099 
				 col "14"  form 099
				 col "15"  form 099 
				 col "16"  form 099 
				 col "17"  form 099
				 col "18"  form 099 
				 col "19"  form 099 
				 col "20"  form 099
				 col "21"  form 099 
				 col "22"  form 099 
				 col "23"  form 099

				 ttitle left 'NUMERO DE REDO LOGS ESCRITOS POR DIA DO MES' skip 2

				 select 	trunc(first_time) np, to_char(first_time,'DD/MM-DY') "DIA",
				 sum(decode(to_char(first_time,'HH24'),'00',1,0)) "00" , 
				 sum(decode(to_char(first_time,'HH24'),'01',1,0)) "01" , 
				 sum(decode(to_char(first_time,'HH24'),'02',1,0)) "02" , 
				 sum(decode(to_char(first_time,'HH24'),'03',1,0)) "03" , 
				 sum(decode(to_char(first_time,'HH24'),'04',1,0)) "04" , 
				 sum(decode(to_char(first_time,'HH24'),'05',1,0)) "05" , 
				 sum(decode(to_char(first_time,'HH24'),'06',1,0)) "06" , 
				 sum(decode(to_char(first_time,'HH24'),'07',1,0)) "07" , 
				 sum(decode(to_char(first_time,'HH24'),'08',1,0)) "08" , 
				 sum(decode(to_char(first_time,'HH24'),'09',1,0)) "09" , 
				 sum(decode(to_char(first_time,'HH24'),'10',1,0)) "10" , 
				 sum(decode(to_char(first_time,'HH24'),'11',1,0)) "11" , 
				 sum(decode(to_char(first_time,'HH24'),'12',1,0)) "12" , 
				 sum(decode(to_char(first_time,'HH24'),'13',1,0)) "13" , 
				 sum(decode(to_char(first_time,'HH24'),'14',1,0)) "14" , 
				 sum(decode(to_char(first_time,'HH24'),'15',1,0)) "15" , 
				 sum(decode(to_char(first_time,'HH24'),'16',1,0)) "16" , 
				 sum(decode(to_char(first_time,'HH24'),'17',1,0)) "17" , 
				 sum(decode(to_char(first_time,'HH24'),'18',1,0)) "18" , 
				 sum(decode(to_char(first_time,'HH24'),'19',1,0)) "19" , 
				 sum(decode(to_char(first_time,'HH24'),'20',1,0)) "20" , 
				 sum(decode(to_char(first_time,'HH24'),'21',1,0)) "21" , 
				 sum(decode(to_char(first_time,'HH24'),'22',1,0)) "22" , 
				 sum(decode(to_char(first_time,'HH24'),'23',1,0)) "23" 
				 from v$loghist
				 group by trunc(first_time), to_char(first_time,'DD/MM-DY')
				 /

				 clear break
				 ttitle off

				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'NUMERO DE REDO LOGS TOTAL ESCRITOS POR DIA DA SEMANA' skip 2

				 col total forma 999,999
				 col np noprint
				 col data_inicial form a22
				 col data_final   form a22

				 select trunc(min(first_time)) DATA_INICIAL , trunc(max(first_time)) DATA_FINAL
				 from v$loghist
				 /


				 SELECT 	to_char(first_time,'D') np , to_char(first_time,'DY') "DIA", COUNT(*) TOTAL
				 FROM 	V$LOGHIST
				 GROUP BY to_char(first_time,'D'), to_char(first_time,'DY')
				 order by 1
				 /


				 clear break

				 ------------------------------------------------------------------------------------------------------------


				 ttitle left 'NUMERO DE REDO LOGS ESCRITOS POR DIA DA SEMANA POR HORARIO ' skip 2

				 col total forma 999,999
				 col np noprint
				 col "00"  form 0999 
				 col "01"  form 0999 
				 col "02"  form 0999
				 col "03"  form 0999 
				 col "04"  form 0999 
				 col "05"  form 0999
				 col "06"  form 0999 
				 col "07"  form 0999 
				 col "08"  form 0999
				 col "09"  form 0999 
				 col "10"  form 0999 
				 col "11"  form 0999
				 col "12"  form 0999 
				 col "13"  form 0999 
				 col "14"  form 0999
				 col "15"  form 0999 
				 col "16"  form 0999 
				 col "17"  form 0999
				 col "18"  form 0999 
				 col "19"  form 0999 
				 col "20"  form 0999
				 col "21"  form 0999 
				 col "22"  form 0999 
				 col "23"  form 0999


				 select trunc(min(first_time)) DATA_INICIAL , trunc(max(first_time)) DATA_FINAL
				 from v$loghist
				 /

				 select 
				 to_char(first_time,'D') np ,
				 to_char(first_time,'DY') "DIA SEMANA",
				 sum(decode(to_char(first_time,'HH24'),'00',1,0)) "00" ,
				 sum(decode(to_char(first_time,'HH24'),'01',1,0)) "01" ,
				 sum(decode(to_char(first_time,'HH24'),'02',1,0)) "02" ,
				 sum(decode(to_char(first_time,'HH24'),'03',1,0)) "03" ,
				 sum(decode(to_char(first_time,'HH24'),'04',1,0)) "04" ,
				 sum(decode(to_char(first_time,'HH24'),'05',1,0)) "05" ,
				 sum(decode(to_char(first_time,'HH24'),'06',1,0)) "06" ,
				 sum(decode(to_char(first_time,'HH24'),'07',1,0)) "07" ,
				 sum(decode(to_char(first_time,'HH24'),'08',1,0)) "08" ,
				 sum(decode(to_char(first_time,'HH24'),'09',1,0)) "09" ,
				 sum(decode(to_char(first_time,'HH24'),'10',1,0)) "10" ,
				 sum(decode(to_char(first_time,'HH24'),'11',1,0)) "11" ,
				 sum(decode(to_char(first_time,'HH24'),'12',1,0)) "12" ,
				 sum(decode(to_char(first_time,'HH24'),'13',1,0)) "13" ,
				 sum(decode(to_char(first_time,'HH24'),'14',1,0)) "14" ,
				 sum(decode(to_char(first_time,'HH24'),'15',1,0)) "15" ,
				 sum(decode(to_char(first_time,'HH24'),'16',1,0)) "16" ,
				 sum(decode(to_char(first_time,'HH24'),'17',1,0)) "17" ,
				 sum(decode(to_char(first_time,'HH24'),'18',1,0)) "18" ,
				 sum(decode(to_char(first_time,'HH24'),'19',1,0)) "19" ,
				 sum(decode(to_char(first_time,'HH24'),'20',1,0)) "20" ,
				 sum(decode(to_char(first_time,'HH24'),'21',1,0)) "21" ,
				 sum(decode(to_char(first_time,'HH24'),'22',1,0)) "22" ,
				 sum(decode(to_char(first_time,'HH24'),'23',1,0)) "23"
				 from v$loghist
				 group by to_char(first_time,'D'), to_char(first_time,'DY')
				 /

				 clear break
				 ------------------------------------------------------------------------------------------------------------
				 ttitle left 'ARCHIVES GERADOS' skip 2

				 col "ARCHIVES" for 9999
				 select to_char(completion_time , 'dd-mm-yyyy') DATA, count(*) "ARCHIVES"
				 from V$ARCHIVED_LOG
				 group by to_char(completion_time , 'dd-mm-yyyy')
				 order by 1
				 /

				 ------------------------------------------------------------------------------------------------------------

				 clear break

				 ttitle left 'STATUS DO BACKUP ONLINE (V$BACKUP)' skip 2

				 col file_name form a55
				 col file# form 999
				 col status form a12
				 col MBYTES form 99,999
				 col tablespace_name form a14

				 break on tablespace_name skip 1

				 select b.tablespace_name, a.file#, a.status, b.file_name, round(b.bytes/1024/1024) MBYTES, 
				 a.change#, to_char(a.time,'dd/mm/yyyy hh24:mi:ss') time
				 from v$backup a, dba_data_files b
				 where a.file#=b.file_id
				 order by tablespace_name, file_name
				 /


				 clear break


				 ------------------------------------------------------------------------------------------------------------



				 ------------------------------------------------------------------------------------------------------------

				 ttitle left 'AUDIT TRAIL ' skip 2


				 select * from sys.dba_priv_audit_opts;

				 ------------------------------------------------------------------------------------------------------------

				 ------------------------------------------------------------------------------------------------------------

				 clear break 

				 ttitle left  'INFORMACOES DA V$LICENSE' skip 2

				 select * from v$license;


				 ------------------------------------------------------------------------------------------------------------

				 ttitle left  'INFORMACOES DE NLS ( CHARACTER SET ) ' skip 2

				 select * from nls_instance_parameters;
				 select * from nls_database_parameters;

				 ------------------------------------------------------------------------------------------------------------

				 ttitle ' FREE TABLESPACE ' skip 2

				 break on report
				 comp sum of ocup on report
				 comp sum of aloc on report
				 comp sum of free on report
				 col tablespace_name 	format a20
				 col ocup 		format 999,999,999,999
				 col aloc 		format 999,999,999,999
				 col free 		format 99,999,999,999
				 col max_bytes_free 	format 99,999,999,999
				 col "%FREE"  		format 999.99

				 select
				 a.TABLESPACE_NAME,a.bytes-b.bytes ocup ,
				 a.bytes aloc ,b.bytes free ,B.MAX_BYTES_FREE, B.COUNT_FREE,
				 to_char(round((b.bytes/a.bytes)*100,2),'999.99') "%FREE"
				 from (     select sum(bytes) bytes,tablespace_name
				 from dba_data_files
				 group by tablespace_name ) a,
				 ( select sum(bytes) bytes , max(bytes) MAX_BYTES_FREE, COUNT(*) COUNT_FREE, tablespace_name
				 --from tb_free_space
				 from dba_free_space
				 group by tablespace_name ) b
				 where a.tablespace_name=b.tablespace_name
				 order by 4
				 /


				 clear break
				 ttitle off


				 ------------------------------------------------------------------------------------------------------------

				 ttitle ' SNAPSHOTS REGISTRADOS ' skip 2

				 col owner form a14
				 col name form a30
				 col snapshot_site form a20
				 col can_use_log form a10
				 col snapshot_id form 999
				 col version form a20
				 col query_txt forma a40 trunc
				 select snapshot_site, owner, name, can_use_log, snapshot_id, version, query_txt from dba_registered_snapshots
				 order by  snapshot_site, owner
				 /
				 ------------------------------------------------------------------------------------------------------------

				 ------------------------------------------------------------------------------------------------------------

				 ------------------------------------------------------------------------------------------------------------


				 ------------------------------------------------------------------------------------------------------------


				 ------------------------------------------------------------------------------------------------------------


				 ------------------------------------------------------------------------------------------------------------



				 ------------------------------------------------------------------------------------------------------------


				 clear break

				 set head off

				 ttitle left 'InstanceName_HostName[ VersaoBanco ] ' skip 2

				 select upper(instance_name)||'_'||host_name||'['|| substr(version,1,3)||']  '|| 
				 '{'||to_char(sysdate,'DD/MM/YYYY HH24:MI:SS') ||'}'  DATA
				 from v$instance
				 /
				 set head on

				 break on drive skip 1 

				 ttitle left 'ARQUIVOS NECESSARIOS PARA O BACKUP DO BANCO ' skip 2


				 select substr(file_name,1,3) drive, file_name from dba_data_files
				 union
				 select substr(member,1,3) drive, member from v$logfile
				 union
				 select substr(name,1,3) drive, name from v$controlfile
				 order by 1,2
				 /
				 clear break

				 ------------------------------------------------------------------------------------------------------------


				 ------------------------------------------------------------------------------------------------------------
				 set pages 30

				 btitle left 'FINAL DO RELATÓRIO ' skip 2

				 select upper(instance_name)||'_'||to_char(sysdate,'ddmmyyyy_hh24mi')  col1
				 from v$instance
				 /

				 ------------------------------------------------------------------------------------------------------------



				 clear break
				 ttitle off

				 spool off


				 exit





