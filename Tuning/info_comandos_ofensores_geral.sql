SET LINES 500
SET PAGES 100
COL COLUMN_NAME FOR A50
COL SEGMENT_NAME FOR A50

prompt INFO: tabelas

select	owner,
	table_name,
	to_char(last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed,
	num_rows,
	cache,
	buffer_pool,
	degree
from 	dba_tables
where 	table_name IN ('<tabelas>');


prompt INFO: indices

select	owner,
	table_name,
	index_name,
	index_type,
	to_char(last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed,
	num_rows
from 	dba_indexes
where 	table_name IN ('tabelas');

prompt INFO: colunas

select 	index_owner
	table_name,
	index_name,
	column_name,
	column_position
from 	dba_ind_columns
where 	table_name IN ('tabelas')
order by 2,3,5;


select 	owner,
	table_name,
	column_name,
	num_distinct,
	num_nulls,
	num_buckets,
	to_char(last_analyzed,'dd/mm/yyyy hh24:mi:ss') last_analyzed
from 	dba_tab_columns
where 	table_name IN ('tabelas')
order by 1,2;


prompt INFO: tablespaces

select 	owner,
	segment_name,
	tablespace_name,
	initial_extent,
	next_extent,
	extents,
	blocks,
	round(sum(bytes)/1024/1024,0) MB
from 	dba_segments
where 	segment_name IN ('tabelas')
group by owner, 
	segment_name,
	tablespace_name,
	initial_extent,
	next_extent,
	extents,
	blocks;