/**************************************************
**						 **
** PHASE -IN 			 **
** 						 **
**************************************************/

-- VERS�O DO BANCO DE DADOS
PRINT 'VERS�O DO BANCO DE DADOS'
PRINT ''
SELECT @@VERSION
PRINT ''

-- CONFIGURA��ES DO SERVIDOR

USE master
EXEC sp_configure 'show advanced option', '1'
go
reconfigure
go
sp_configure
go

-- LEVANTAMENTO DOS DATABASES

SP_HELPDB

-- LEVANTAMENTO DOS ARQUIVOS QUE FORMAM AS BASES


select database_id,name,physical_name,size,max_size,growth,is_percent_growth from sys.master_files -- n�o � t�o preciso
select (size * 8) /1024 ,name from sysaltfiles compute sum((size*8) /1024)


-- LISTA DOS LOGINS E PERMISSOES

select loginname,
denylogin,hasaccess,
isntname,isntgroup,isntuser,isntgroup,sysadmin,
securityadmin,serveradmin,setupadmin,processadmin,
diskadmin,dbcreator from syslogins

-- DETALHE DOS LOGINS

select loginname,name,createdate,dbname from syslogins


sp_help syslogins

-- LOGINS ADMINISTRADORES




-- VERIFICA��O DE JOBS

select name,description,date_created from msdb..sysjobs

-- VERIFICA��ES DO LINK DO PROPRIO BANCO

exec sp_helplinkedsrvlogin
PRINT ''


-- VERIFICAR DTS ( packages ) CRIADOS

select * from msdb..sysdtspackages -- 2000

select * from msdb..sysdtspackages90 -- 2000

-- VERIFICAR COLLATION

sp_helpsort
go

-- INTAKE ------

-- Levantamento do tamanho dos dbs 

select name,(size * 8) /1024 from sysaltfiles
compute sum((size*8) /1024)


