--
--
--  NAME
--    ecss.sql
--
--  DESCRIPTION
--    Exibe o comando SQL completo a partir do Hash Value.
--
--  HISTORY
--    02/06/2008 => Eduardo Chinelatto
--
-------------------------------------------------------------------------------
set wrap off
set lines 130
set pages 100

prompt
accept hv number prompt 'Informe o hash value do SQL: '

col sql_text     for A100  heading Sql     word wrap
col child_number for 99999 heading Child#

select s.child_number, t.sql_text
  from v$sqltext t, v$sql s
  where s.hash_value = &hv
    and s.address = t.address
    and s.hash_value = t.hash_value
  order by s.child_number, t.piece;

--
-- Fim
--
