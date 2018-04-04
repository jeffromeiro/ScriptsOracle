/* 
Set up a SQL Baseline using known-good plan, sourced from AWR snapshots
https://rnm1978.wordpress.com/
 
In this example, sql_id is 939abmqmvcc4d and the plan_hash_value of the good plan that we want to force is 1239572551
*/
 
-- Drop SQL Tuning Set (STS)
BEGIN
  DBMS_SQLTUNE.DROP_SQLSET(
    sqlset_name => 'TBS01');
END;
 
-- Create SQL Tuning Set (STS)
BEGIN
  DBMS_SQLTUNE.CREATE_SQLSET(
    sqlset_name => 'TBS01',
    description => 'SQL Tuning Set for loading plan into SQL Plan Baseline ag60z143w8bnd');
END;
 
-- Populate STS from AWR, using a time duration when the desired plan was used
--  List out snapshot times using :   SELECT SNAP_ID, BEGIN_INTERVAL_TIME, END_INTERVAL_TIME FROM dba_hist_snapshot ORDER BY END_INTERVAL_TIME DESC;
--  Specify the sql_id in the basic_filter (other predicates are available, see documentation)
DECLARE
  cur sys_refcursor;
BEGIN
  OPEN cur FOR
    SELECT VALUE(P)
    FROM TABLE(
       dbms_sqltune.select_workload_repository(begin_snap=>1104, end_snap=>4723,basic_filter=>'sql_id = ''ag60z143w8bnd''',attribute_list=>'ALL')
              ) p;
     DBMS_SQLTUNE.LOAD_SQLSET( sqlset_name=> 'TBS01', populate_cursor=>cur);
  CLOSE cur;
END;
/
 
-- List out SQL Tuning Set contents to check we got what we wanted
SELECT
  first_load_time          ,
  executions as execs              ,
  parsing_schema_name      ,
  elapsed_time  / 1000000 as elapsed_time_secs  ,
  cpu_time / 1000000 as cpu_time_secs           ,
  buffer_gets              ,
  disk_reads               ,
  direct_writes            ,
  rows_processed           ,
  fetches                  ,
  optimizer_cost           ,
  sql_plan                ,
  plan_hash_value          ,
  sql_id                   ,
  sql_text
   FROM TABLE(DBMS_SQLTUNE.SELECT_SQLSET(sqlset_name => 'TBS01')
             );
 
-- List out the Baselines to see what's there
SELECT * FROM dba_sql_plan_baselines ;
 
-- Load desired plan from STS as SQL Plan Baseline
-- Filter explicitly for the plan_hash_value here if you want
DECLARE
my_plans pls_integer;
BEGIN
  my_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
    sqlset_name => 'TBS01', 
    basic_filter=>'plan_hash_value = ''1239572551'''
    );
END;
/
 
-- List out the Baselines
SELECT * FROM dba_sql_plan_baselines ;