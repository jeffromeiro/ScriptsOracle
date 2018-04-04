
set feedback off
set sqlblanklines on

declare
ar_profile_hints sys.sqlprof_attr;
cl_sql_text clob;
l_profile_name varchar2(30);
begin
select
extractvalue(value(d), '/hint') as outline_hints
bulk collect
into
ar_profile_hints
from
xmltable('/*/outline_data/hint'
passing (
select
xmltype(other_xml) as xmlval
from
dba_hist_sql_plan
where
sql_id = '7hzddw6azmr2w'
and plan_hash_value = 2196293274
and other_xml is not null
)
) d;

select
sql_text,
decode('SYS_SQLPROF_7hzddw6azmr2w','X0X0X0X0','PROF_7hzddw6azmr2w'||'_'||'2196293274','SYS_SQLPROF_7hzddw6azmr2w')
into
cl_sql_text, l_profile_name
from
dba_hist_sqltext
where
sql_id = '7hzddw6azmr2w';

dbms_sqltune.import_sql_profile(
sql_text => cl_sql_text,
profile => ar_profile_hints,
category => 'DEFAULT',
name => l_profile_name,
force_match => false
-- replace => true
);


  dbms_output.put_line(' ');
  dbms_output.put_line('SQL Profile '||l_profile_name||' created.');
  dbms_output.put_line(' ');

exception
when NO_DATA_FOUND then
  dbms_output.put_line(' ');
  dbms_output.put_line('ERROR: sql_id: '||'7hzddw6azmr2w'||' Plan: '||'2196293274'||' not found in AWR.');
  dbms_output.put_line(' ');

end;
/

undef sql_id
undef plan_hash_value
undef profile_name
undef category
undef force_matching

set sqlblanklines off
set feedback on
