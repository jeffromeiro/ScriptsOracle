rem ------------------------------------------------------
 rem Autor   : Jefferson Romeiro
 rem Assunto : Objetos sendo utilizados
 rem Objetivo: Verificar objs sendo acessados 
 rem ------------------------------------------------------
 col owner    format a10
 col type     format a15
 col osuser   format a20
 col username format a10
 col program  format a20 trunc
 col module   format a20 trunc
 prompt
 prompt =======================================
 prompt OBJECT ACCESS
 prompt =======================================
 prompt
 select a.owner
      , substr(a.object,1,25) object
      , a.type
      , a.sid
      , b.username
      , b.osuser
      , b.program
      , b.module
      , to_char(b.logon_time, 'dd.mm.yyyy hh24:mi:ss') logon
   from v$access a
      , v$session b
  where a.sid   = b.sid
    and a.object = '&object';
 
