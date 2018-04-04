rem ------------------------------------------------------
rem Autor   : Jefferson Romeiro
rem Assunto : Sessions - Acessos
rem Objetivo: Verificar objs sendo acessados nos schemas
rem ------------------------------------------------------

col owner    format a10
col type     format a15
col osuser   format a20
col username format a10
col program  format a30
col module   format a30

prompt
prompt =======================================
prompt SESSION ACCESS
prompt =======================================
prompt


select  sid
      , serial#
      , username
      , osuser
      , status 
      , server
      , terminal
      , to_char(logon_time, 'dd.mm.yyyy hh24:mi:ss')
   from v$session
  where username = '&username'
order by 3,8

/

select a.owner
     , substr(a.object,1,25) object
     , a.type
     , a.sid
     , b.username
     , b.osuser
     , b.program
     , b.module
  from v$access a
     , v$session b
 where a.sid   = b.sid
   and b.sid = '&sid'
 /
