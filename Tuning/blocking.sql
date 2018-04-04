col Event format a25
col DML_BLOCKING format a45
col DML_In_Waiting format a45
set linesize 400
set pagesize 3000

-- LABEL: STATEMENT A
select  distinct
        a.sid                     as Waiting_SID
       ,d.sql_text                as DML_In_Waiting
       ,o.Owner                   as Object_Owner
       ,o.Object_Name             as Locked_Object
       ,a.Blocking_Session        as Blocking_SID
       ,c.sql_text                as DML_Blocking
from
        v$session                 a
       ,v$active_session_history  b
       ,v$sql                     c
       ,v$sql                     d
       ,all_objects               o
where
        a.event                   = 'enq: TX - row lock contention'
and     a.sql_id                  = d.sql_id
and     a.blocking_session        = b.session_id
and     c.sql_id                  = b.sql_id
and     a.Row_Wait_Obj#           = o.Object_ID
and     b.Current_Obj#            = a.Row_Wait_Obj#
and     b.Current_File#           = a.Row_Wait_File#
and     b.Current_Block#          = a.Row_Wait_Block#

-- LABEL: STATEMENT B
select  distinct
        a.sid                     as Waiting_SID
       ,a.event                   as Event
       ,c.sql_text                as DML_Blocking
       ,b.sid                     as Blocking_SID
       ,b.event                   as Event
       ,b.sql_id                  as Blocking_SQL_ID
       ,b.prev_sql_id             as Blocking_Prev_SQL_ID
       ,d.sql_text                as DML_Blocking
from
        v$session                 a
       ,v$session                 b
       ,v$sql                     c
       ,v$sql                     d
where
        a.event                   = 'enq: TX - row lock contention'
and     a.blocking_session        = b.sid
and     c.sql_id                  = a.sql_id
and     d.sql_id                  = nvl(b.sql_id,b.prev_sql_id);

