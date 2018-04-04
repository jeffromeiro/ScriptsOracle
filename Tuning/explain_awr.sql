set lines 250 pages 5000

select * from table(dbms_xplan.display_awr('&sql_id',null,null,'ALL'));
undef sql_id

