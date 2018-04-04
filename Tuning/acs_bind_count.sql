select distinct sql_id, bind_count from (
select sql_id, child_number, count(*) bind_count from v$sql_bind_capture
where sql_id in (
select sql_id from v$sqlarea where is_bind_aware = 'Y')
group by sql_id, child_number
)
order by bind_count
/
