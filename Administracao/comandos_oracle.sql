#######################para saber qual o processo do sistema Operacional:

select spid from v$process where addr=(select paddr from v$session where sid=59);


select s.sid, spid, osuser, s.program, s.status
from v$process p, v$session s where p.addr=s.paddr
and s.program <> 'ORACLE.EXE' order by s.sid;

S.O. - Windows 2000
orakill instance_name spid

Para saber qual p THREADID ********************
select s.sid, s.serial#, s.username, s.status,p.spid THREADID, s.osuser, s.program ,
to_char(s.logon_time, 'dd.mm.yyyy hh24:mi:ss') from v$process p, v$session s
where p.addr=s.paddr
and s.sid=378;

######################## Para saber qual o SID atravres do SPID

select a.sid, a.serial#, b.spid, a.username, a.osuser, a.status,
to_char(logon_time, 'dd.mm.yyyy hh24:mi:ss') from v$session a, v$process b
where b.addr=a.paddr
and b.spid =3531;


select a.sid, a.serial#, b.spid, a.username, a.osuser, a.status, a.SQL_ID,
to_char(logon_time, 'dd.mm.yyyy hh24:mi:ss') from v$session a, v$process b
where b.addr=a.paddr
and a.username = 'AO_PRD_JOB';

#######################################################

ps -ef | grep pmon    |    |    |    |  

sqlplus "/ as sysdba"

############################## Para saber qual o texto que está em execucao

select sid, serial#, username, osuser, status, SQL_ID, to_char(logon_time, 'dd.mm.yyyy hh24:mi:ss') from v$session
where sid=

select * from V$OPEN_CURSOR where sid=230;

select SQL_TEXT from v$sqltext where sql_id = '5c5a9sb2ygxux';

select SQL_FULLTEXT from v$sqlarea where sql_id = 'f33smf1701jvs';


exec sys.dbms_system.set_ev(712, 11271, 10046, 12, '')

######################################## Para pegar o Auto trace da query

set autot trace expl stat

####################################### Memoria Livre


select * from v$sgastat where name = 'free memory';


######################################SQL TUNE

DECLARE
  ret_val VARCHAR2(4000);
BEGIN
  ret_val := dbms_sqltune.create_tuning_task(
  task_name=>'6favjcy579xrp',
  sql_id=>'6favjcy579xrp');
  dbms_sqltune.execute_tuning_task('6favjcy579xrp');
END;
/
set long 10000
SELECT dbms_sqltune.report_tuning_task('6favjcy579xrp')
FROM   dual;



################################### SCP (Igual FTP - Unix)

Ir no servidor de destino e executar o comando:

scp oracle@brbsocc53:/oracle/result_misp.txt .

scp FP0033.rdf oracle@brcsaocdc1lx001:/app/ias10g/node1/cas/perphil/bin/

scp oracle@brcsaocdc1lx010:/app/ias10g/cas/concex/bin/cnx_rdf0011.rdf .

############################Para ver login e data/hora no banco:##########################

select sid, serial#, username, status ,osuser,
to_char(logon_time,'dd.mm.yy hh24:mi:ss') as logon_time
from v$session
order by 4 desc;

####################################################### Alterar o schema (User) (LOGIN)

alter session set current_schema = owner


############################# Para verificar a QUota e alterar de um usuário###################

SQL> desc dba_ts_quotas
 Name                                                  Null?    Type
 ----------------------------------------------------- -------- ------------------------------------
 TABLESPACE_NAME                                       NOT NULL VARCHAR2(30)
 USERNAME                                              NOT NULL VARCHAR2(30)
 BYTES                                                          NUMBER
 MAX_BYTES                                                      NUMBER
 BLOCKS                                                NOT NULL NUMBER
 MAX_BLOCKS                                                     NUMBER

select * from dba_ts_quotas
where tablespace_name = 'APPL_DATA';

TABLESPACE_NAME                USERNAME                  BYTES  MAX_BYTES     BLOCKS    MAX_BLOCKS
------------------------------ -------------------- ---------- ---------- ----------    ----------
APPL_DATA                      ORFINANC              274849792         -1      33551            -1
                               TESTE                   1351680         -1        165            -1
                               MIOBAK                  1925120         -1        235            -1
APPL_DATA                      ALEXSANDRA                    0         -1           0            -1
                               FINPAC                        0         -1          0            -1
                               FINPAC_DIS              6340608         -1        774            -1

SQL> alter user finpac quota unlimited on appl_data;
User altered.

SQL> alter user ORFINANC  quota unlimited on appl_data;
User altered.

SQL> select * from dba_ts_quotas
  2  where tablespace_name = 'APPL_DATA';

TABLESPACE_NAME                USERNAME                  BYTES  MAX_BYTES     BLOCKS    MAX_BLOCKS
------------------------------ -------------------- ---------- ---------- ----------    ----------
APPL_DATA                      ORFINANC              274849792         -1      33551            -1
                               TESTE                   1351680         -1        165            -1
                               MIOBAK                  1925120         -1        235            -1
APPL_DATA                      ALEXSANDRA                    0         -1          0            -1
                               FINPAC                        0         -1          0            -1
                               FINPAC_DIS              6340608         -1        774            -1

SQL>  alter user TESTE quota unlimited on appl_data;
User altered.

SQL> alter user MIOBAK quota unlimited on appl_data;
User altered.

SQL> alter user ALEXSANDRA quota unlimited on appl_data;
User altered.

SQL> alter user FINPAC_DIS quota unlimited on appl_data;
User altered.

SQL> select distinct owner from dba_segments
  2  where tablespace_name = 'APPL_DATA';

OWNER
----------
FINPAC_DIS
MIOBAK
ORFINANC
SDIMIO
TESTE

SQL> alter user SDIMIO quota unlimited on appl_data;
User altered.

#####################Criaçao de Tablespace ##################

CREATE TABLESPACE "TS_NORTEL01_DATA"
    LOGGING
    DATAFILE '/msaf/nortel/data/db_data01/ts01_nortel01.dbf' SIZE
    2000M EXTENT MANAGEMENT LOCAL UNIFORM SIZE 64K


CREATE TABLESPACE "TEMP"
LOGGING
DATAFILE '/u03/biosdes/temp/temp_01.dbf' SIZE 1071296K REUSE,
'/u04/biosdes/temp/temp_02.dbf' SIZE 1100M REUSE,
'/u04/biosdes/temp/temp_03.dbf' SIZE 400M REUSE,
'/u05/biosdes/temp/temp_04.dbf' SIZE 10M REUSE AUTOEXTEND ON NEXT 51200K MAXSIZE  1200M
DEFAULT STORAGE ( INITIAL 256K NEXT 256K MINEXTENTS 1 MAXEXTENTS 0 PCTINCREASE 0 ) TEMPORARY


##################### Criaçao de Tablespace TEMP ##################


CREATE
    TEMPORARY TABLESPACE "TEMP01" TEMPFILE '/u01/PROD/temp_0101.dbf' SIZE 200M REUSE AUTOEXTEND
    ON NEXT  640K MAXSIZE  2000M EXTENT MANAGEMENT LOCAL UNIFORM
    SIZE 5m;


ALTER DATABASE DEFAULT TEMPORARY TABLESPACE "TEMP01";

select * from database_properties where property_name like '%TEMP%';


CREATE TEMPORARY TABLESPACE "TS_TEMP_01"
TEMPFILE '/oracle/sgeb/temp/TS_TEMP_01.dbf' SIZE 5M
AUTOEXTEND ON NEXT 20m MAXSIZE 1200m
EXTENT MANAGEMENT LOCAL segment space management auto;


################### Recriação de tablespace temp após migração ###############################


Após migrar um banco usar o comando para a tablespace temp funcionar

ALTER TABLESPACE "TEMP"
    ADD TEMPFILE '/msaf/sodexho/data/des/ts_temp_01.dbf' SIZE 5M REUSE


############################ MOvimentação de Datafiles de uma tablespace ############

1º) Verificar se os nenhum login esta usando dados da tablespace
2º) verificar se a tablespace não está em modo de begin backup

3º) estar conectado no sqlplus dentro do servidor (Não fazer da maquina local)

4º) Colocar a tablespace em modo offline;
alter tablespace tc_cc07_data offline;

5º) mover o datafile

!mv /msaf/ccorrea/data1/data/tc_cc07_data01 /msaf/ccorrea/data2/data/tc_cc07_data01

6º) Atualizar o controlfile
alter database rename file '/msaf/ccorrea/data1/data/tc_cc07_data01' to '/msaf/ccorrea/data2/data/tc_cc07_data01';

7º) Colocar a tablespace em modo online;
alter tablespace ts_cc07_data online;

8º) Fazer 2 backups do controlfile

alter database backup controlfile to trace;
alter database backup controlfile to '/oracle/bkp_controlfile_ccorrea.bkp';


################### Para executar um Snapshot ###############################################

exec dbms_snapshot.refresh('bios.snp_horas_atividades24','C');

################### Habilitar o modo Archive do banco ###########################################

acrescentar os parametros do INIT

# ArchiveLOG Mode
log_archive_start = true
log_archive_format = arch_nortel%s.arc
log_archive_dest = /archive/nortel

Baixar o banco

shutdown immediate

startup mount
alter database archivelog (Noarchivelog)
alter database open

archive log list

###############################################################################################

select owner, segment_name, segment_type, (bytes/1024)/1024 from dba_segments
 where owner = 'CCORREA04' and segment_name = 'INT_SAIDA_GER';

OWNER        SEGMENT_NAME        SEGMENT_TYPE       (BYTES/1024)/1024
CCORREA04    INT_SAIDA_GER        TABLE                     17716.5625

############################### Para matar somente os dados de uma tabela#############

truncate table ccorrea04.INT_SAIDA_GER reuse storage
 
set time on     #### coloca a hora no prompt################
set timing on    ##### Mostra quanto tempo demorou o processo#####
truncate table ccorrea04.INT_SAIDA_GER reuse storage;
Table truncated.

select owner, segment_name, segment_type, (bytes/1024)/1024 from dba_segments
where owner = 'CCORREA04' and segment_name = 'INT_SAIDA_GER';

OWNER        SEGMENT_NAME        SEGMENT_TYPE       (BYTES/1024)/1024       
CCORREA04    INT_SAIDA_GER        TABLE                     17716.5625

select count(*) from ccorrea04.INT_SAIDA_GER;

  COUNT(*)
----------
         0

@c:\debora\unused_space
Owner: ccorrea04
Nome do Segmento: int_saida_ger
Tipo Segmento ( p.ex. Table ): table
==============================================
Owner   : CCORREA04
Segmento: INT_SAIDA_GER
Tipo    : TABLE
----------------------------------------------
Total blocos     :        2,267,723.00
Total Bytes      :   18,577,186,816.00
Blocos nao usados:        2,267,451.00
Bytes nao usados :   18,574,958,592.00
% nao usada      :               99.99
==============================================

select owner, segment_name, segment_type, (bytes/1024)/1024, extents from dba_segments
where owner = 'CCORREA04' and segment_name = 'INT_SAIDA_GER';

OWNER        SEGMENT_NAME        SEGMENT_TYPE       (BYTES/1024)/1024    EXTENTS   
CCORREA04    INT_SAIDA_GER        TABLE                     17716.5625     275718

########Aumenta o Min Extent ##############

alter table ccorrea04.INT_SAIDA_GER storage(minextents 270000);

#################Aumentar o Max extent de uma tabela

select owner, SEGMENT_TYPE from dba_segments
where SEGMENT_NAME = 'CP_R067LPR' and TABLESPACE_NAME = 'TS_CA_DAD';

OWNER      SEGMENT
---------- -------
VETORH     INDEX

alter index vetorh.CP_R067LPR storage(MAXEXTENTS 1500);
Index altered.

################## Trunca a Tabela e reorganiza os extents#########################

truncate table ccorrea04.INT_SAIDA_GER;
Elapsed: 03:10:12.07

####################Aumenta o next para 10M ############

alter table ccorrea04.INT_SAIDA_GER storage(next 10M);
Elapsed: 00:00:00.02
truncate table ccorrea04.int_historico;
Elapsed: 00:00:00.02
truncate table ccorrea04.int_dados_dump;
 
########################### Une os extents que estão ao lado, virando um só (Coalesce)###########

alter tablespace ts_cc04_index coalesce;


###############################Para ver o conteudo de uma view###############

SELECT TEXT FROM dba_views
WHERE VIEW_NAME = 'DBA_USERS';

#################Para criar DATABASE LINK - DBLINK #################[

CREATE PUBLIC DATABASE LINK C2D2
CONNECT TO SWBAPPS IDENTIFIED BY cgdes03
USING 'C2D2';

swapps e senha é da instance C2D2

########################Dropar Database LInk ##################

Drop public database link QAS_HOM.WORLD;

OWNER   DB_LINK        USERNAME    HOST    CREATED
PUBLIC    QAS_HOM.WORLD    INTERSAP    C3H1    29-JUN-04

################################ Para saber qual a senha do DB_link. ##############

Se conectar no banco com o user SYS

select * from sys.link$
where name = 'QAS.WORLD';

######################################### DB_LINK (DICAS) - Privado e Publico

Quando alguem não conseguir consultar algo via DB_link, Verificar qual o login e se logar na instance e fazer o teste:

select * from v$instance@ODS_HOMOLOG.SODEXHOPASS.COM.BR

Caso ocorra o erro:
ERROR at line 1:
ORA-01017: invalid username/password; logon denied
ORA-02063: preceding line from ODS_HOMOLOG

Se logar com o SYS no banco e efetuar o seguinte select:

select * from sys.link$
where name like 'ODS_HOM%';

Com isso irá aparecer o login e a senha.
Verificar pois o login publico não deve ter a senha.
Para resolver o problema, criar um privado, digitando o login e a senha conforme modelo

create database link
ODS_HOMOLOG.SODEXHOPASS.COM.BR
connect to prod_dba_lnk
identified by teste;

Ele faz um join dos dois DB_links para conexão no outor banco.

############################################### Para criar snapshot de log############

Se logar com o OWNER (sapr3) e criar o snapshot log

CREATE SNAPSHOT LOG ON "SAPR3"."ZPMT020"
TABLESPACE "PSAPBTABD"
 STORAGE ( INITIAL 1K NEXT 1K PCTINCREASE 0)
WITH ROWID;

Dar grant de select para os snapshots logs criados para o user swbapps e para a tabela.

SQL> @veprivs
SQL> SET echo off
"Verifica os privilégios de um usuário informado"
Digite o usuário :swbapps
"Privilégios de SISTEMA"

Usuário    Privilégio
---------- -------------------------
SWBAPPS    CREATE SESSION

"privilégios de OBJETO"

Usuário    Objeto                    Proprietário    Privilégio
---------- ------------------------- --------------- -------------------------
SWBAPPS    ZMMT007                   SAPR3           SELECT
SWBAPPS    ZMMT006                   SAPR3           SELECT
SWBAPPS    MLOG$_ZMMT0061            SAPR3           SELECT
SWBAPPS    MLOG$_ZMMT0071            SAPR3           SELECT
SWBAPPS    ZMMT009                   SAPR3           SELECT
SWBAPPS    MLOG$_ZMMT009             SAPR3           SELECT

6 rows selected.

"Privilégios de ROLE"

Usuário    Role
---------- --------------------
SWBAPPS    CONNECT

Para ver se o snapshot_log foi criado ver>:

select * from ALL_SNAPSHOT_LOGS;

######################################### Para criar snapshot############


create materialized view v734_data_files refresh complete with rowid 
  as select * from dba_data_files@V734;


############################################Para verificar se o snapshot log tem relacionamento


select * from DBA_REGISTERED_SNAPSHOTS
where owner = 'RESTORE'


###################Para gerar o comando para criar sinonimo publico##################


select 'create public synonym'||' '||table_name ||' '||'for'||' '||owner||'.'||table_name||';' from dba_tables where owner ='ADMDW';


##########################  Para criar um sinonimo publico de uma procedure de outro banco#########


Verificar se existe db para a outra base
verificar se a proceudre term permissão de select para o usuário do dblink (swbapps)

desc cgsp_interface_sap_atividades@c2d2.world
PROCEDURE ace_sap_atividades@c2d2.world
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_SWNAME                       VARCHAR2                IN
 P_SWCODATIVR3                  NUMBER(7)               IN
 P_SWSTATUS                     VARCHAR2                IN
 P_STRMSGRETORNO                VARCHAR2                OUT

SQL> create synonym swbapps.cgsp_interface_sap_atividades for cgsp_interface_sap_atividades@c2d2.world;

Synonym created.

SQL> conn swbapps@cg1
Enter password: *******
Connected.
SQL> desc cgsp_interface_sap_atividades
PROCEDURE cgsp_interface_sap_atividades
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_SWNAME                       VARCHAR2                IN
 P_SWCODATIVR3                  NUMBER(7)               IN
 P_SWSTATUS                     VARCHAR2                IN
 P_STRMSGRETORNO                VARCHAR2                OUT

SQL> create public synonym cgsp_interface_sap_atividades for cgsp_interface_sap_atividades@c2d2.world;
create public synonym cgsp_interface_sap_atividades for cgsp_interface_sap_atividades@c2d2.world
                                                                                      *
ERROR at line 1:
ORA-01031: insufficient privileges

SQL> conn system@cg1
Enter password: *******
Connected.
SQL> create public synonym cgsp_interface_sap_atividades for cgsp_interface_sap_atividades@c2d2.world;

Synonym created.


############################Para inserir dados em uma tabela ########################

insert into LF_PATHS
(cod_holding,cod_matriz,cod_filial,id_path,path)
values ('ETERBR','BM24', '%', 'DCTF', '/interfaces/saidas/sgeb/txt');

Tabela - LF_PATHS
cod_holding = ETERBR
cod_matriz     = BM24
cod_filial     = %
id_path     = DCTF
path         = /interfaces/saidas/sgeb/txt


######################################## Configurar NLS_DATE e NLS_LANGUAGE

alter session set nls_date_format = 'DD-MON-YY';

alter session set nls_language = 'AMERICAN';


############## Movendo arquivos de dados para Balancear a E/S de arquivo #######

Coloque a tablespace em modo offline
alter tablespace ORDERS offline;

Copie o arquivo de dados para o novo local do disco
cp /u01/orders.dbf /u02/orders.dbf

Troque o nome do arquivo de dados para refletir o novo local da tablespace
alter tablespace ORDERS
rename datafile '/u01/orders.dbf' to '/u02/orders.dbf';

Coloque a tablespace on-line
alter tablespace ORDERS online;

Apague o arquivo de dados antigo
rm /u01/orders.dbf


########################## Criando uma tabela a partir de outra ###################

create table customers1
tablespace ts_customers
as select * from customers;

##renomeando uma tabela
Rename customers1 to customers;


##########################3##### Alterando a tabela

alter table customer move tablespace ts_customers nologging;

########################### Exibindo  informações sobre logs e redo #############

select a.member, a.group#, b.thread#, b.bytes, b.members, b.status
from v$logfile a, v$log b
where a.group#=b.group#

############################ Para que uma transação use um det segmento de rollback ###############

set transaction user rollback segment rb_big;
delet from big_table;

################### Determinando qual segmento de rollback está processando cada transação ###########

select a.name, b.xacts,c.sid,c.serial#,c.username, d.sql_text
from v$rollname a, v$rollstat b, v$session c, v$sqltext d, v$transaction e
where a.usn=b.usn
and b.usn=e.xidusn
and c.taddr=e.addr
and c.sql_address=d.address
and c.sql_hash_value=d.hash_value
order by a.name, c.sid, d.piece;

################### Para ver qual processo está consumind CPU no banco) #############

select a.username, a.sid, a.status, a.terminal, a.osuser, b.spid from v$session a, v$process b
where a.paddr=b.addr and b.spid=53216;   (b.spid=id do sistema operacional)

select a.username, a.sid, a.status, a.terminal, a.osuser, b.spid from v$session a, v$process b
where a.paddr=b.addr and a.sid=13;        (a.sid=13 DO ORACLE)

############################# Para ativar o trace #############

sempre utilizar a package dbms_system para ativar o trace em uma sessão.
Ativar com o nível 8 pois ele mostra os eventos de Wait.
 
exec sys.dbms_system.set_ev (&sid, &serial, 10046, 8, '');
 
-----------------------------------------------------------------

Ativar o Timed_statistics
sys.dbms_system.set_bool_param_in_session(  sid => 42, serial# => 1215, parnam => 'timed_statistics', bval => true)


Ativar o Max_dump_file_size
sys.dbms_system.set_int_param_in_session(sid => 42, serial# => 1215, parnam => 'max_dump_file_size', intval => 2147483647)

Ativar o Trace
sys.dbms_system.set_ev(&sid, &serial, 10046, 8, '')
4 => bind variable, 8=> Wait events, 12=> bind and wait

Desativar o Trace
sys.dbms_system.set_ev(&sid, &serial, 10046, 0, '')

Exemplo
exec sys.dbms_system.set_ev(119, 2677, 10046, 12, '')

############################# Para ativar o trace #############

Verificar se no init.ora existe os seguintes parametros:

TIMED_STATISTICS = TRUE
MAX_DUMP_FILE_SIZE = 20000 (operating system blocks)
USER_DUMP_DEST = /oracle/admin/ora9i/udump

Ative o trace para uma sessão
alter session set sql_trace true;

Para retirar o trace
alter session set sql_trace false;

Para ativar o trace para todas as sessoes
acrescentar o parametro no init.ora
sql_Trace= true


########### obtendo o numero incluido no nome de arquivo de trace

select spid, s.sid, s.serial#, p.username, p.program
from v$process p, v$session s
where p.addr=s.paddr
and s.sid = (select sid from v$mystat where norum=1);


################## Procurando Objetos que exigem mais de 100 Kb

select name,sharable_mem from v$db_object_cache
where sharable_mem >100000
and type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
and kept = 'NO';

###################### pag 424


################################## Para verificar se a Tablespace está em modo de begin backup############

select a.file_name, a.tablespace_name, b.status from dba_data_files a, v$backup b
where b.file#=a.file_id and b.status = 'ACTIVE'

select distinct 'alter tablespace '||a.tablespace_name||' end backup;' from dba_data_files a, v$backup b
where b.file#=a.file_id and b.status = 'ACTIVE'

select distinct 'alter tablespace '||tablespace_name||' end backup;' from dba_data_files
where file_name like '%G:%' and tablespace_name
in ('JESSE', 'TOOLS', 'TSCHQ01', 'TSCHQ02','TSCHQ03','TSCHQ04', 'TSCHQ05','TSDCTO1P', 'TSDDBM', 'TSDFLT1P', 'TSDCLI1P');

######################################## JOB em status de Broken ######################################

SELECT JOB FROM DBA_JOBS WHERE BROKEN = 'Y';

select job,SCHEMA_USER,log_user, priv_user, BROKEN, FAILURES, WHAT from dba_jobs
order by 5;
 
Para tirar o JOB do status de broken
EXECUTE DBMS_JOB.BROKEN(10,FALSE); 

Para executar o job na mão execute o seguinte comando:
exec dbms_job.run(320);

Para verificar quais os tipos de parametros na dbms_jobs
desc dbms_jobs


########################################### Schedule de Jobs


Caso haja algum job eme execução via SCHEDULE do oracle, o mesmo não ira aparecer em
select * from dba_jobs_running e ira aparecer em
select * from DBA_SCHEDULER_RUNNING_JOBS,
para parar este tipo de job, devemos utilizar a seguinte package.

begin
DBMS_SCHEDULER.STOP_JOB  ( job_name => 'GATHER_STATS_JOB', force => false );
end;

Onde job_name vai ser a coluna JOB_NAME da query
select * from DBA_SCHEDULER_RUNNING_JOBS.


########################## Trocar a senha do internal #########################

orapwd file=D:\oracle\ora817\database\PWDDES.ORA password=sodexho


atribuir as roles de sysdba e sysoper para o usuário OPERADOR ( grant sysdba, sysoper to operador)

######################### SNAPSHOTS ##############################

set long 1000 - para pode ver o campo long

select * from dba_snapshots where name = 'TRS_05';

EXEC DBMS_SNAPSHOT.REFRESH ('TRS_05','F');
exec dbms_refresh.refresh('"WEB_GBS"."TRS_05"');


######################### Fazer um Export
NT
Ir no prompt do dos e acessar o diretório onde será gerado o export e digitar:
Set oracle_sid=homologa
Exp system/designer file=exp_0807_homologa.dmp log=exp_0807_homologa.log full=y statiscs=none
Onde: full = y(tudo), owner=system (login), tables=xpto (tabelas)
statiscs=none (não atualiza analyse)


Unix
Criar um arquivo chamado parfile.par
Parfile.par
userid=br02288/de00bi00 file=pipe log=/areatemp/nortel01_190707.log  full=y buffer=204800000

mknod pipe p
compress <pipe> nortel01_190707.dmp.Z &
export ORACLE_SID=nortel
exp parfile=parfile.par

######################### Fazer import de um usuário

Set oracle_sid=homologa

Imp system file=exp_0807_desenv.dmp log=imp_0807_homologa fromuser=integra touser=integra ignore=y

OBS: Verificar o arquivo de log e se aparece alguns objetos inválidos. Verificar os objetos inválidos da outra instance

######################### Verificar objetos inválidos

Select count(*) from dba_objects
   Where status='INVALID' and owner='INTEGRA';

Select count(*) from user_objects
   Where status='INVALID';

Compilar Objetos inválidos
Select 'alter '||object_type||' '||object_name||' compile;' from user_objects
   Where status='INVALID';


##################################################### EXPORT COM QUERY WHERE - WIN


exp prod_dba/xxxx@prod.world file=c:\exp_cta.dmp log=c:\exp_cta.log tables=cep_loc query="""where CHAVE_LOCAL > 1 and CHAVE_LOCAL < 20"""


########################################### EXPORT COM QUERY NO  - UNIX


exp dw_ods@dbm02 file=/dbm02/flashback/f_consumo_trans.dmp log=/dbm02/flashback/f_consumo_trans.log tables=F_CONSUMO_TRANSACOES query=\" where L_DIA_SK_DATA \>= 19564 and L_DIA_SK_DATA \<= 19701 \"


##################################################### Export de Tabelas

exp system@giso file=c:\dba\sepat_040805.dmp log=c:\dba\sepat_040805.log buffer=2048000 tables=owner.table

exp system@msaf file=h:\temp\sodexho_msaf.dmp log=h:\temp\sodexho_msaf.log buffer=204800000 owner=msaf consistent=n compress=n direct=yes
(direct = yes - não armazena em memoria (Joga direto para o arquivo)

################################Import de tabelas

imp system/creative file=expfull_Mon_bios.dmp tables=tcrd_log_processa_finpac fromuser=bios touser=restore log=tcrd_log_processa_finpac.log


SQL> drop table restore.tcrd_log_processa_finpac;

Table dropped.

SQL> select username from dba_users;
select username from dba_users
                     *
ERROR at line 1:
ORA-01031: insufficient privileges


SQL> conn system@bios
Enter password: ********
Connected.
SQL> /

USERNAME
------------------------------
SYS
SYSTEM
OUTLN
DBSNMP
BIOS_LDAP
LMS
RESTORE
OPERATOR
BIOS2
BACKUP
BIOS4
RELGER
BIOS3
BIOS5
BIOS6
BIOS7
SI
DESENV
BIOS
FUEGO
BSD1
SACADM
PLANTAO
ORAOPER
MARCOS
NOTES
EDELIVERY
TNGAGENT
PDC
29 rows selected.

SQL> select count(*) from restore.tcrd_log_processa_finpac;
  COUNT(*)
----------
      6349

SQL> conn bios@bios
Enter password: ****
Connected.
SQL> create table tcrd_log_processa_finpac as select * from restore.tcrd_log_processa_finpac;
create table tcrd_log_processa_finpac as select * from restore.tcrd_log_processa_finpac
                                                               *
ERROR at line 1:
ORA-01031: insufficient privileges

SQL> conn restore@bios
Enter password: *******
Connected.
SQL> grant all on tcrd_log_processa_finpac to public;

Grant succeeded.

SQL> conn bios@bios
Enter password: ****
Connected.
SQL> select constraint_name, constarint_type from dba_constraints
  2  where table_name = 'TCRD_LOG_PROCESSA_FINPAC';
select constraint_name, constarint_type from dba_constraints
                        *
ERROR at line 1:
ORA-00904: invalid column name


SQL> select constraint_name, constraint_type from dba_constraints
  2  where table_name = 'TCRD_LOG_PROCESSA_FINPAC';

CONSTRAINT_NAME                C
------------------------------ -
SYS_C005025                    C
SYS_C005026                    C
SYS_C005027                    C
SYS_C005029                    C
SYS_C005030                    C
SYS_C005031                    C

6 rows selected.


ALTER TABLE "TCRD_LOG_PROCESSA_FINPAC" ADD CONSTRAINT "PK_LOG_FINPAC" PRIMARY KEY
("NUM_SEQ", "COD_CRE", "DAT_OCOR") USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255
STORAGE(INITIAL 40960) TABLESPACE "TSDBIND0" ENABLE;

select constraint_name, constraint_type from dba_constraints
where table_name = 'TCRD_LOG_PROCESSA_FINPAC';


imp system/creative file=expfull_Mon_bios.dmp tables=t_recurso fromuser=bios touser=marcos log=t_recurso.log commit=y


###################################### Import de tabela em outra Tabela ###############

imp br02288@crm file=exp_crm_300307.dmp log=imp_portifolio_tmp.log tables=portifolio fromuser=AXENT touser=br02288 ignore=yes

SQL> insert into AXENT.portifolio_tmp select * from portifolio;
35622 rows created.

SQL> commit;
Commit complete.

SQL>


#####################################################################

col segment_name a20
select segment_name, segment_type, extents, bytes, b.tablespace_name
from dba_segments a, dba_tablespaces b
where a.extents > 1024
/

1.    Banco de Dados MED (UNIK) utiliza 20,5 GB.
2.    Banco de Dados HC (SPBS) utiliza 64,5 GB.
3.    O banco de Desenvolvimento - utiliza 77 GB.
4.    Servidor WEB - (spbwdb01: banco spb02) soma dos objetos usuários que começam com HC - 6,5 GB. 
5.    Servidor WEB Desenvolvimento - (banco spb02) soma dos objetos usuários que começam com HC - 6,5 GB

1-) select tablespace_name, sum(bytes/1024/1024) from dba_data_files
    group by tablespace_name;
1a-)select sum(bytes/1024/1024) from dba_data_files;
---------------------------------------------------------------------------------

2-) select tablespace_name, sum(bytes/1024/1024) from dba_data_files
    group by tablespace_name;
2a-)select sum(bytes/1024/1024) from dba_data_files;
---------------------------------------------------------------------------------

3-) select tablespace_name, sum(bytes/1024/1024) from dba_data_files
    group by tablespace_name;
3a-)select sum(bytes/1024/1024) from dba_data_files;
----------------------------------------------------------------------------------------

4.)Servidor WEB - (spbwdb01: banco spb02) soma dos objetos usuários que começam com HC - 6,5 GB. 

select sum(bytes/1024/1024) from dba_segments where owner like 'HC%';
------------------------------------------------------------------------------------
5-)    Servidor WEB Desenvolvimento - (banco spb02) soma dos objetos usuários que começam com HC - 6,5 GB

select sum(bytes/1024/1024) from dba_segments where owner like 'HC%';


#################################################################################################



############################################## Tamanho da Tablespace


select tablespace_name, file_name, (bytes/1024)/1024
from dba_data_files
where tablespace_name = 'VARGINHA_DADOS';

############################ Criar um novo datafile

alter tablespace tsdusers2
add datafile 'N:\ORACLE\PROD\TSDUSERS2\TSDUSERS215.ORA' size 500M;

##########################Para aumentar um datafile existente

alter database datafile
'/occ61mord6/indices/trimex/indextriton_01.dbf' resize 11000M;

###########################Para saber se exite datafile autoextensivo

select tablespace_name, file_name, bytes/1024/1024,maxbytes from dba_data_files
where tablespace_name = 'TSDUSERS2'

O maxbytes informa qual é o mximo que a tablespace pode crescer;

TABLESPACE_NAME     FILE_NAME                                              BYTES/1024/1024   MAXBYTES
------------------------------ ------------------------------------------------------------ --------
TSDUSERS2           G:\ORACLE\PROD\TSDUSERS2_01\TSDUSERS212.ORA                 5000          0
TSDUSERS2           H:\ORACLE\PROD\TSDUSERS2\TSDUSERS213.ORA                    4900          0
TSDUSERS2           N:\ORACLE\PROD\TSDUSERS2\TSDUSERS214.ORA                    3200          0
TSDUSERS2           N:\ORACLE\PROD\TSDUSERS2\TSDUSERS215.ORA                    500        2097152000


############################## Para criar um datafile autoextensivo

alter tablespace TSIGBS
add datafile 'K:\ORACLE\SPB02\TSIGBS\TSIGBS11.DBF' size 100M autoextend on next 100m maxsize 2000M;

alter tablespace TSITRS_CUR
add datafile 'T:\ORACLE\PROD\TSITRS_CUR13.DBF' size 100m autoextend on next 100m maxsize 2000m;

####### Para recriar um control File

alter database backup  controlfile to trace;

Ir no \udump e pegar o comando que foi gerado no arquivo.

############################## Snapshots

alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS';
column Owner format a10
column Tablename format a30
column Logname format a30
column Youngest format a20
column "Last Refreshed" format a10
column "Last Refreshed" heading "Last|Refreshed"
column "MView ID" format 99999
column "MView ID" heading "Mview|ID"
column Oldest_ROWID format a10
column Oldest_PK format a10
select m.mowner Owner,
m.master Tablename,
m.log Logname,
m.youngest Youngest,
s.snapid "MView ID",
s.snaptime "Last Refreshed",
oldest_pk Oldest_PK
from sys.mlog$ m, sys.slog$ s
WHERE s.mowner (+) = m.mowner
and s.master (+) = m.master;


select m.mowner Owner,
m.master Tablename,
m.log Logname,
m.youngest Youngest,
s.snapid "MView ID",
s.snaptime "Last Refreshed",
oldest Oldest_ROWID
from sys.mlog$ m, sys.slog$ s
WHERE s.mowner (+) = m.mowner
and s.master (+) = m.master;

alter session set nls_date_format = 'DD-MON-YY HH24:MI:SS';
column Owner format a14
column master_owner format a14
select distinct owner,
name snapshot,
master_owner master_owner,
last_refresh
from dba_snapshot_refresh_times

select master, rowids, primary_key from user_snapshot_logs
where master = '<master_table>';


############################## Para ver os indices de uma tabela

desc dba_indexes
select index_name from dba_indexes where table_name = 'CAMPO_FGTS';

aparecerá FGTS_PK
select table_name from dba_tables where table_name = 'CAMP%';

desc dba_ind_colums
select index_name, table_name, column_name from dba_ind_columns where table_name = 'CAMPO_FGTS';


############################# Comandos para ver quais indices estão sendo usados

select t.OWNER#,u.name owner , io.name index_name, t.name table_name,
       decode(bitand(i.flags, 65536), 0, 'NO', 'YES') monitoring,
       decode(bitand(ou.flags, 1), 0, 'NO', 'YES') used,
       ou.start_monitoring,
       ou.end_monitoring
from  sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou, sys.user$ u
where i.obj# = ou.obj#
  and io.obj# = ou.obj#
  and t.obj# = i.bo#
  and io.owner# = u.user#
--  and decode(bitand(ou.flags, 1), 0, 'NO', 'YES') = 'NO'
/

########################### Profile Default

desc dba_profiles

pass_reuse_max 2 usar unlimeted

alter profile default limit pass_reuse_max unlimited;

alter user BRC00059P profile power_user;


######################################## Criar Profile

create profile IT_SODEXHO limit
CPU_PER_CALL                     120000
LOGICAL_READS_PER_CALL           23000000
FAILED_LOGIN_ATTEMPTS            4
PASSWORD_LIFE_TIME               60
PASSWORD_REUSE_TIME              UNLIMITED
PASSWORD_REUSE_MAX               12
PASSWORD_VERIFY_FUNCTION         VERIFY_FUNCTION_ADMIN
PASSWORD_LOCK_TIME               DEFAULT
PASSWORD_GRACE_TIME              0;


##############################      Profile 

set lines 350
set pages 200
break on profile skip 1 on report
select profile,resource_type,resource_name, limit from dba_profiles
where profile in ( select distinct profile from dba_users )
order by 1,2,3

alter profile IT_SODEXHO limit SESSIONS_PER_USER 4;
alter profile IT_SODEXHO limit LOGICAL_READS_PER_CALL 10000000;


################################# Para Dropar coluna de uma tabela

SQL> desc admfac.ttfgld809095
Name Null? Type
----------------------------------------- -------- ----------------------------
T$CONO$C   NOT NULL   NUMBER
T$DIM1$C   NOT NULL   CHAR(6)
T$CNPJ$C   NOT NULL   VARCHAR2(20)
T$PRIN$C   NOT NULL   VARCHAR2(1)
T$CIAM$C   NOT NULL   CHAR(3)
T$DIMM$C   NOT NULL   CHAR(6)
T$BAND$C   NOT NULL   CHAR(3)
T$REFCNTD  NOT NULL   NUMBER
T$REFCNTU  NOT NULL   NUMBER

alter table admfac.ttfgld809094
  drop (T$CIAM$C,T$DIMM$C,T$BAND$C,T$REFCNTD,T$REFCNTU);

alter table admfac.ttfgld809097
  drop (T$CIAM$C,T$DIMM$C,T$BAND$C,T$REFCNTD,T$REFCNTU);

############################## Para adicionar colunas em uma tabela

alter table admfac.ttfgld809094
  add (T$CNPJ$C  VARCHAR2(20) NOT NULL,
       T$PRIN$C  VARCHAR2(1) NOT NULL,
       T$CIAM$C  CHAR(3) NOT NULL,
       T$DIMM$C  CHAR(6) NOT NULL,
       T$BAND$C  CHAR(3) NOT NULL,
       T$REFCNTD NUMBER NOT NULL,
       T$REFCNTU NUMBER NOT NULL)

alter table admfac.ttfgld809097
  add (T$CNPJ$C VARCHAR2(20) NOT NULL,
       T$PRIN$C VARCHAR2(1) NOT NULL,
       T$CIAM$C CHAR(3) NOT NULL,
       T$DIMM$C CHAR(6) NOT NULL,
       T$BAND$C CHAR(3) NOT NULL,
       T$REFCNTD NUMBER NOT NULL,
       T$REFCNTU NUMBER NOT NULL)


########################### Para Ativar o Trace

############################################
## MONITORAÇÃO TRACES/EVENT
############################################

##############
## ATIVAR
############
set lines 200
set pages 100
col tr form a60
col username form a20
col event form a28
select 'exec sys.dbms_system.set_ev('||s.sid||','|| s.serial#||', 10046, 8,'||''''||''''||');' TR,
username, event, to_char(s.logon_time,'dd.mm.yyyy hh24:mi:ss')
from v$session_wait sw, v$session s
where sw.sid = s.sid
and s.username is not null
/

ex: exec sys.dbms_system.set_ev(16,7665, 10046, 8,'');

####################
##DESATIVAR
###################
set lines 200
set pages 100
col tr form a60
col username form a17
col event form a20
select 'exec sys.dbms_system.set_ev('||s.sid||','|| s.serial#||', 10046, 0,'||''''||''''||');' TR, username, event,s.osuser
from v$session_wait sw, v$session s
where event not like 'SQL%'
and event not like '%timer%'
and sw.sid = s.sid
and s.username is not null
/

ex:  exec sys.dbms_system.set_ev(410,11992, 10046, 0,'');   

O resultado estará no udump, executar o tkprof

############################################ Para saber qual o arquivo rederente a sessão

Para saber qual é o arquivo referente a sessão

select s.username, s.sid, s.serial#,s.status, p.spid
from v$session s, v$process p
where p.addr = s.paddr
and s.username = 'AO_PRD_JOB'
/

######################## Para colocar o arquivo de Trace no formato legivel

tkprof ora_195.trc rich2.prf explain=system/manager


############################# Utilizando o TKPROF

tkprof c:\sodexho\ORA03984.TRC c:\sodexho\ORA3984_prod.txt explain=prod_dba@prod sys=no sort=prscpu,execpu,fchcpu
       --------------------   --------------------   ------------------------  ------------------------
           arquiv trace       arquivo tkprof-result        usuário              ordenado por cpu

A opção explain estabelece logon no banco de dados com o nome do usuario e senha informados. Em seguida
ele testa o caminho de acesso de cada instrução SQL rastreada e inclui essa informação na saída.

A opção sort é a ordem de classificação das instruções.


############################### Para Ativar o Trace

exec dbms_system.set_ev(&sid,&serial,10046,8,'');


##############################  Como ativa o trace na sessão do usuário

alter session set timed_statistics=true;
alter session set max_dump_file_size=unlimited;
alter session set tracefile_identifier='NomeProcesso';
alter session set events '10046 trace name context forever, level 8';

e depois executar o processo do usuário.....


#####################################Para dar resize em 1 datafile de forma correta

Para poder diminuir o tamanho dos datafiles é necessário que eles tenham espaço livre no FINAL do arquivo.
Para poder identificar estes espaços, executar o script mapa.sql.
Ele irá gerar um arquivo com o mapeamento dos objetos e os espaços livres dentro dos datafiles.
Se existir espaço livre no final do arquivo, poderemos diminuir o datafile.
Por exemplo, no datafile 2, existe espaço no final do arquivo:

   FILE_ID TABLESPACE_NAME                SEGMENT_NAME                     BLOCK_ID           BYTES                                
---------- ------------------------------ ------------------------------ ---------- ---------------                                
         2 TSCHQ02                        CTL_CHQ_02                              2     566,231,040                                
         2 TSCHQ02                        CTL_CHQ_02                         276482     849,346,560                                
         2 TSCHQ02                        CTL_CHQ_02                         691202     524,288,000                                
         2 TSCHQ02                        CTL_CHQ_02                         947202     283,115,520                                
         2 TSCHQ02                        CTL_CHQ_02                        1085442     283,115,520                                
         2 TSCHQ02                        CTL_CHQ_02                        1223682     283,115,520                                
         2 TSCHQ02                        CTL_CHQ_02                        1361922     283,115,520                                
         2 TSCHQ02                        FREE >->->->->->->->              1500162     178,255,872                                

select file_id, file_name, bytes from dba_data_files where file_id=2

   FILE_ID FILE_NAME                                               BYTES
---------- -------------------------------------------------- ----------
         2 G:\ORACLE\PROD\TSCHQ02_01\TSCHQ02_01.ORA           3250585600


Então o datafile 2 pode ser diminuído para o valor (3250585600-178255872)= 3072329728.

=> 3072329728/1024 = 3000322K ( transformando em Kbytes)

SQL> alter database datafile 'G:\ORACLE\PROD\TSCHQ02_01\TSCHQ02_01.ORA'  3000322K;


Veiga

############################################## Para colocar um datafile em modo extent....

ALTER DATABASE DATAFILE
'N:\ORACLE\PROD\TSDFRETE_01\TSDFRETE_02.ORA' AUTOEXTEND ON next 100m MAXSIZE 2000M;

ALTER TABLESPACE TSICHQ05
ADD DATAFILE 'H:\ORACLE\PROD\TSICHQ05_01\TSICHQ05_06.ORA' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 1000M;


*************** Para criar um Tablespace Temporária

If you look for the amount of free space in these tablespaces through
DBA_FREE_SPACE, only information about PERMANENT tablespaces is displayed.
The TEMPORARY tablespaces are not listed.

  SQL> CREATE TEMPORARY TABLESPACE temp_local
    2  TEMPFILE '/u02/oradata/V81764/temp_local.dbf' SIZE 1M REUSE
    3  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 64K;
  Tablespace created.

  SQL> CREATE  TABLESPACE uniform_local
    2  DATAFILE '/u02/oradata/V81764/uniform_local.dbf' SIZE 1M REUSE
    3  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 64K;
  Tablespace created.

  SQL> SELECT distinct tablespace_name from dba_free_space ;

  TABLESPACE_NAME
  ------------------
  SYSTEM
  TOOLS
  UNIFORM_LOCAL
  USERS
 
Solution Description
--------------------
Query the following view : V$TEMP_SPACE_HEADER

 select tablespace_name, file_id, bytes_used, bytes_free
  from v$temp_space_header ;

  TABLESPACE_NAME                   FILE_ID BYTES_USED BYTES_FREE
  ------------------------------ ---------- ---------- ----------
  TEMP_LOCAL                              1      65536     983040   

Explanation
-----------
View V$TEMP_SPACE_HEADER displays aggregate information per file per temporary
tablespace about how much space is currently being used and how much is free as
identified in the space header.

##################### Para saber se a tablespace TEMP está como temporária

select contents from dba_tablespaces
where tablespace_name = 'TEMP'


############################ Colocar uma tablespace temporaria em AUTOEXTEND #################

ver na dba_temp_files

select file_name, tablespace_name, bytes/1024/1024, AUTOEXTENSIBLE, MAXBYTES from dba_temp_files
where tablespace_name = 'TEMP';


alter database tempfile 'N:\ORACLE\ORADATA\DBM02\DBM02TMP02.ORA' AUTOEXTEND ON NEXT 100M MAXSIZE 2000M

alter tablespace temp
add tempfile 'N:\ORACLE\ORADATA\DBM02\DBM02TMP05.DBF' size 500M AUTOEXTEND ON NEXT 100M MAXSIZE 2000M;


************************* Para saber o espaço ocupado na tablespace temp **********************

select tablespace_name, file_id, bytes_used, bytes_free from v$temp_space_header ;


select sum(free_blocks) from gv$sort_segment
 where tablespace_name = 'TEMP'


select inst_id, tablespace_name, total_blocks, used_blocks, free_blocks 
 from gv$sort_segment;

################################### Para retirar do modo autoextent

ALTER DATABASE
DATAFILE 'G:\ORACLE\PROD\TSCHQ04_01\TSCHQ04_07.ORA' AUTOEXTEND OFF;

############################### Para mover uma tabela de uma tablespace para outra


alter table PROD_DBA.CTR_AFL_TXA_CTU move tablespace TSD200M;

############################### Para aumentar a sort area para movimentaçao de tabela entre tablespaces

alter session set sort_area_size=104857600;  # 100Mbytes


################################# Liberar espaço nos datafiles

Para poder diminuir o tamanho dos datafiles é necessário que eles tenham espaço livre no FINAL do arquivo.
Para poder identificar estes espaços, executar o script mapa.sql.
Ele irá gerar um arquivo com o mapeamento dos objetos e os espaços livres dentro dos datafiles.
Se existir espaço livre no final do arquivo, poderemos diminuir o datafile.
Por exemplo, no datafile 2, existe espaço no final do arquivo:


Mapa.sql

set pause off
set lines 132
set pages 9000
break on file_id skip page duplicate
col segment_name format a30
col bytes format 99,999,999,999
spool mapa.lis
select file_id,tablespace_name,'FREE >->->->->->->-> ' segment_name , block_id,bytes
from dba_free_space
-- where tablespace_name=upper('&tablespace_name')
union
select file_id,tablespace_name,segment_name,block_id,bytes
from dba_extents
-- where tablespace_name=upper('&tablespace_name')
order by file_id,tablespace_name,block_id asc
/
spool off
set pages 30
set pause on

resultado:

   FILE_ID TABLESPACE_NAME                SEGMENT_NAME                     BLOCK_ID           BYTES                                
---------- ------------------------------ ------------------------------ ---------- ---------------                       2 TSCHQ02                        CTL_CHQ_02                              2     566,231,040                       2 TSCHQ02                        CTL_CHQ_02                         276482     849,346,560                       2 TSCHQ02                        CTL_CHQ_02                         691202     524,288,000                       2 TSCHQ02                        CTL_CHQ_02                         947202     283,115,520                       2 TSCHQ02                        CTL_CHQ_02                        1085442     283,115,520                       2 TSCHQ02                        CTL_CHQ_02                        1223682     283,115,520                               
         2 TSCHQ02                        CTL_CHQ_02                        1361922     283,115,520                               
         2 TSCHQ02                        FREE >->->->->->->->              1500162     178,255,872                                

select file_id, file_name, bytes from dba_data_files where file_id=2

   FILE_ID FILE_NAME                                               BYTES
---------- -------------------------------------------------- ----------
         2 G:\ORACLE\PROD\TSCHQ02_01\TSCHQ02_01.ORA           3250585600


Então o datafile 2 pode ser diminuído para o valor (3250585600-178255872)= 3072329728.

=> 3072329728/1024 = 3000322K ( transformando em Kbytes)

SQL> alter database datafile 'G:\ORACLE\PROD\TSCHQ02_01\TSCHQ02_01.ORA'  3000322K;


############################## Para saber quais datafiles em RECOVER

select a.file_name b.status from dba_data_files a,v$datafile b
where a.file_id=b.file# and b.status in ('RECOVER','OFFLINE');


############################## Recuperar um banco (RECOVER)

Select status from v$datafile;         (verifica qual o status das tables)

Select a.file_name from dba_data_files a, v$datafile b
   Where a.file_id=b.file# and b status in ('RECOVER', 'OFFLINE');

Ir no prompt do Dos :
Set oracle_sid=Q01
Svrmgrl
Connect internal
Recover datafile 'h:\oracle\q01\sapdata5...';
Alter database datafile 'h:\oracle\q01\sapdata5...' online;

Ou RECOVER DATABASE;
E alter database open;


********************************* Para saber as permissões do java no banco (FilePermission)

select * from dba_java_policy
where TYPE_NAME = 'java.io.FilePermission'


Para dar a permissão:
EXEC Dbms_Java.Grant_Permission('PROD_DBA', 'java.io.FilePermission', 'P:\ORACLEIO\*', 'read ,write, execute, delete');


NOTA ORACLE
------------
Connect as SYS or SYSTEM and grant the following privilege to your PROD_DBA user:

SQL> execute dbms_java.grant_permission('PROD_DBA','SYS:java.io.FilePermission','e:\public\oracleio\csu\*', 'read, write, execute');

(OR)

SQL> call dbms_java.grant_permission('PROD_DBA','java.io.FilePermission','e:\public\oracleio\csu\*', 'read, write, execute');
SQL> commit;

Note: Commit is mandatory !!

Logoff as SYS or SYSTEM

2. Also please make sure that PROD_DBA has JAVA user or sys privileges.

JAVAUSERPRIV -- minor permissions, by default includes:

java.net.SocketPermission
java.io.FilePermission
java.lang.RuntimePermission

JAVASYSPRIV --major permissions, including updating JVM protected packages

By default includes:

java.io.SerializablePermission
java.io.FilePermission
java.net.SocketPermission
java.lang.RuntimePermission

In other words PROD_DBA would either need JAVAUSERPRIV or JAVASYSPRIV.

eos (end of section)

##################################### Java policy

select * from DBA_JAVA_POLICY
where upper(type_name) like '%AURORA%'

Para dar o grant

Connect sys/senha as sysdba
call dbms_java.grant_policy_permission( 'PROD_DBA', 'SYS', 'oracle.aurora.rdbms.security.PolicyTablePermission', '0:java.io.FilePermission#*' );


#####################################  Quando executar o SW e aparecer lacth free, veja na p2 e efetue o select *********

Sess                                             W'd So     Time
   ID Wait Event                     Wait State Far (ms) W'd (ms)                P1         P2     P3
----- ------------------------------ ---------- -------- -------- ----------------- ---------- -----
    1 pmon timer                     WAITING        6055        0               300          0      0
    5 smon timer                     WAITING         126        0               300          0      0
   83 db file sequential read        WAITED SHO        0       -1                95     419794      1
  113 db file sequential read        WAITING           0        0               198     272066      1
  206 db file sequential read        WAITING           0        0               186     536945      1
  382 latch free                     WAITED SHO        1       -1         919901912         66      0
  415 db file sequential read        WAITING           0        0               211     607474      1

7 rows selected.

select * from v$latchname where latch#=66;

    LATCH# NAME
---------- ----------------------------------------------------------------
        66 cache buffers chains

1 row selected.


************************** Para fazer uma somatoria de Bytes no fim do relatorio ****************

Select segment_name, segment_type, bytes/1024/1024, extents from dba_segments
where owner = 'PST_HR'
order by bytes
break on report
compute sum of bytes on report
/

********************* Colocando a data no nome do spool gerado **************
col col1 new_value sp
set feed off
select 'Maxext'||'_'||to_char(sysdate,'ddmmyyyy_hh24mi')  col1
from v$instance
/
set feed on
spool c:\temp\Spool\&sp

******************************** PARA PEGAR A QUERY DO USER PARA FAZER EXPLAIN

Ver o address e o hash_value (na v$session)

select SQL_ADDRESS, SQL_HASH_VALUE from v$session
where sid= 344

select sql_text from v$sqltext
where address='&address' and hash_value='&hash' order by piece;


****************************Para fazer verificar o que uma query está fazendo (Explain) versão 8.

delete from plan_table where statement_id='v';
commit;
EXPLAIN PLAN SET STATEMENT_ID='v'
for

acrescentar a query

Depois executar:

select lpad(' ',2*(level-1))||operation||' '||options||' '||
object_name||' '||decode(id,0,'Cost = ' ||position) query
from plan_table
start with id=0 and statement_id='v'
connect by prior id=parent_id and statement_id='v';


Aparecerá o resultado:

QUERY
---------------------------------------------------------------------
SELECT STATEMENT   Cost =
  NESTED LOOPS
    NESTED LOOPS
      NESTED LOOPS
        NESTED LOOPS
          NESTED LOOPS
            NESTED LOOPS
              NESTED LOOPS
                NESTED LOOPS
                  TABLE ACCESS BY INDEX ROWID PSS
                    INDEX UNIQUE SCAN PSS_UK1
                  TABLE ACCESS FULL SNAP$_USR
                TABLE ACCESS BY INDEX ROWID EDR_PSS_TIP_EDR
                  INDEX RANGE SCAN EPTE_TIPE_FK_I
              TABLE ACCESS BY INDEX ROWID EDR_PSS
                INDEX UNIQUE SCAN EDPS_PK
            TABLE ACCESS BY INDEX ROWID EDR_PSS_TIP_EDR
              INDEX RANGE SCAN EPTE_TIPE_FK_I
          TABLE ACCESS BY INDEX ROWID EDR_PSS
            INDEX UNIQUE SCAN EDPS_PK
        TABLE ACCESS BY INDEX ROWID PSS
          INDEX UNIQUE SCAN PSS_PK
      TABLE ACCESS BY INDEX ROWID ATC
        INDEX UNIQUE SCAN ATC_PK
    TABLE ACCESS BY INDEX ROWID CTT_PSS
      INDEX RANGE SCAN CTPS_PSS_FK_I


No caso abaixo ele está fazendo um full scan na tabela..


Caso ocorra erro no primeiro script, (table PLAN_TABLE) executar o utlxplan.sql
que fica no $ORACLE_HOME\rdbms\admin


******************************* Explain Versão 9i

para criar plan_table: @$ORACLE_HOME/rdbms/admin/utlxplan.sql


SQL> explain plan for
  2  SELECT "A7"."EBELN","A3"."ASNUM","A2"."ASKTX","A4"."BRTWR","A3"."SPART",
  3  "A6"."EBELP","A1"."DATAB" FROM "SAPR3"."EKKO" "A7","SAPR3"."EKPO" "A6",
  4  "SAPR3"."ESLL" "A5","SAPR3"."ESLL" "A4","SAPR3"."ASMD" "A3","SAPR3"."ZMMT008" "A2",
  5  "SAPR3"."A081" "A1" WHERE "A7"."BSTYP"='K' AND "A7"."FLVAN"='X'
  6  AND "A6"."MANDT"="A7"."MANDT" AND "A6"."EBELN"="A7"."EBELN"
  7  AND "A5"."MANDT"="A6"."MANDT" AND "A5"."PACKNO"="A6"."PACKNO"
  8  AND "A4"."MANDT"="A5"."MANDT" AND "A4"."PACKNO"="A5"."SUB_PACKNO"
  9  AND "A3"."MANDT"="A4"."MANDT" AND "A3"."ASNUM"="A4"."SRVPOS"
 10  AND "A2"."MANDT"="A3"."MANDT" AND "A2"."ASNUM"="A3"."ASNUM"
 11  AND "A1"."MANDT"="A2"."MANDT" AND "A1"."KONT_PACK"="A4"."PACKNO"
 12  AND "A1"."KONT_ZEILE"="A4"."INTROW"
 13  AND ("A3"."SPART"='02' OR "A3"."SPART"='17' OR "A3"."SPART"='18')
 14  AND "A6"."LOEKZ"=' ' AND "A5"."DEL"=' ' AND "A4"."DEL"=' '
 15  AND "A1"."KAPPL"='MS' AND "A1"."KSCHL"='PRS' AND "A1"."WERKS"='CG02'
 16  AND "A1"."DATAB"<=TO_CHAR(SYSDATE@!,'YYYYMMDD') AND "A1"."DATBI">=TO_CHAR(SYSDATE@!,'YYYYMMDD')
 17  AND "A7"."MANDT"='200';

Explained.

SQL> select * from table(dbms_xplan.display);

USUARIOS EM WAIT

PLAN_TABLE_OUTPUT
---------------------------------------------------------------------------------
| Id  | Operation                         |  Name       | Rows  | Bytes | Cost  |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                  |             |     1 |   215 |     2 |
|   1 |  NESTED LOOPS                     |             |     1 |   215 |     2 |
|   2 |   NESTED LOOPS                    |             |     1 |   200 |     2 |
|   3 |    NESTED LOOPS                   |             |     1 |   171 |     1 |
|   4 |     NESTED LOOPS                  |             |     1 |   147 |     1 |
|   5 |      NESTED LOOPS                 |             |     1 |    96 |     1 |
|   6 |       NESTED LOOPS                |             |     1 |    78 |     1 |
|*  7 |        TABLE ACCESS BY INDEX ROWID| ESLL        |     1 |    32 |     0 |
|*  8 |         INDEX RANGE SCAN          | ESLL~0      |     1 |       |     3 |
|*  9 |        TABLE ACCESS BY INDEX ROWID| A081        |     1 |    46 |     0 |
|* 10 |         INDEX RANGE SCAN          | A081~0      |     1 |       |     2 |
|* 11 |       TABLE ACCESS BY INDEX ROWID | ASMD        |     1 |    18 |     0 |
|* 12 |        INDEX UNIQUE SCAN          | ASMD~0      |     1 |       |       |
|  13 |      TABLE ACCESS BY INDEX ROWID  | ZMMT008     |     1 |    51 |     0 |
|* 14 |       INDEX UNIQUE SCAN           | ZMMT008~0   |     1 |       |       |
|* 15 |     TABLE ACCESS BY INDEX ROWID   | ESLL        |     1 |    24 |     0 |
|* 16 |      INDEX RANGE SCAN             | ESLL~0      |     1 |       |     2 |
|* 17 |    TABLE ACCESS BY INDEX ROWID    | EKPO        |     1 |    29 |     0 |
|* 18 |     INDEX RANGE SCAN              | EKPO~SRV    |     1 |       |     2 |
|* 19 |   TABLE ACCESS BY INDEX ROWID     | EKKO        |     1 |    15 |     0 |
|* 20 |    INDEX UNIQUE SCAN              | EKKO~0      |     1 |       |       |

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   7 - filter("A4"."DEL"=' ')
   8 - access("A4"."MANDT"='200')
   9 - filter("A1"."DATAB"<=TO_CHAR(SYSDATE@!,'YYYYMMDD'))
  10 - access("A1"."MANDT"='200' AND "A1"."KAPPL"='MS' AND "A1"."KSCHL"='PRS'
              AND "A1"."KONT_PACK"="A4"."PACKNO" AND "A1"."KONT_ZEILE"="A4"."INTROW" AND
              "A1"."WERKS"='CG02' AND "A1"."DATBI">=TO_CHAR(SYSDATE@!,'YYYYMMDD'))
       filter("A1"."DATBI">=TO_CHAR(SYSDATE@!,'YYYYMMDD'))
  11 - filter("A3"."SPART"='02' OR "A3"."SPART"='17' OR "A3"."SPART"='18')
  12 - access("A3"."MANDT"='200' AND "A3"."ASNUM"="A4"."SRVPOS")
  14 - access("A2"."MANDT"='200' AND "A2"."ASNUM"="A3"."ASNUM")
  15 - filter("A4"."PACKNO"="A5"."SUB_PACKNO" AND "A5"."DEL"=' ')
  16 - access("A5"."MANDT"='200')
  17 - filter("A6"."LOEKZ"=' ')
  18 - access("A6"."MANDT"='200' AND "A5"."PACKNO"="A6"."PACKNO")
  19 - filter("A7"."BSTYP"='K' AND "A7"."FLVAN"='X')
  20 - access("A7"."MANDT"='200' AND "A6"."EBELN"="A7"."EBELN")

Note: cpu costing is off

48 rows selected.


************************** Para Setar a Instance no SQLPLUS

set instance prod_des

******************************


With Oracle 9i version 9.2, Oracle supplies a utility called dbms_xplan.  It is
created by dbmsutil.sql which is called by catproc.sql.  As such it should
already be installed on most 9.2 databases.

To generate a formatted explain plan of the query that has just been 'explained':

        SQL> set lines 130
        SQL> set head off
        SQL> spool <spool file>
        SQL> alter session set cursor_sharing=EXACT;
        SQL> select plan_table_output from table(dbms_xplan.display('PLAN_TABLE',null,'ALL'));
        SQL> spool off


*********************************VER QUAIS OS INDICES QUE A TABELA TEM

col column_name form a30
break on index_name skip 1
select INDEX_NAME, TABLE_NAME, COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH, DESCEND from dba_ind_columns
where table_name = 'RMS_ADM_EMP_SRV'

Script @index_table.sql


******************************* Para fazer analyze de uma tabela

execute dbms_stats.gather_table_stats -
       (OWNNAME=>'DW_ODS', -
        TABNAME=>'D_DATA', -
        ESTIMATE_PERCENT=>10, -
        CASCADE=>true, -
        METHOD_OPT=>'FOR ALL COLUMNS SIZE AUTO');


********************************** Para Ver qual sessão está ativa com TRACE


select s.username, s.sid, s.serial#,s.status, p.spid
from v$session s, v$process p
where p.addr = s.paddr
and s.username = 'SSILVA'
/


################################## Matar sessões do Banco


select 'alter system kill session '||''''||sid|
...

