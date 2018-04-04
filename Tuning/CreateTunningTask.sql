set serveroutput on
declare
  l_sql_tune_task_id  varchar2(100);
begin
  l_sql_tune_task_id := dbms_sqltune.create_tuning_task (
						  begin_snap  => 184145,
                          end_snap    => 184625,
                          sql_id      => '411khrsmraf5d',
                          scope       => dbms_sqltune.scope_comprehensive,
                          time_limit  => 120,
                          task_name   => 'inm_411khrsmraf5d',
                          description => 'tuning task for statement your_sql_id.');
  dbms_output.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
end;
/


-- executing the tuning task

exec dbms_sqltune.execute_tuning_task(task_name => 'inm_411khrsmraf5d');

-- displaying the recommendations

set long 100000;
set longchunksize 1000
set pagesize 10000
set linesize 100
select dbms_sqltune.report_tuning_task('inm_411khrsmraf5d') as recommendations from dual;


