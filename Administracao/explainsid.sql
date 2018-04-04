delete from plan_table;
commit;
select * from table( dbms_xplan.display_CURSOR( (select sql_id from v$session where sid=&SID) ) );

