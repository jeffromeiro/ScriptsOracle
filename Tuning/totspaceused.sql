set serveroutput on size 1000000
set verify off
set echo off
accept v_owner char format a30 prompt 'Nome do Schema: '
declare
v_segment_name varchar2(30);
v_segment_type varchar2(30);
v_total_blocks number;
v_total_bytes number;
v_unused_blocks number;
v_unused_bytes number;
v_last_used_extent_file_id number;
v_last_used_extent_block_id number;
v_last_used_block number;
bytes_total number := 0;

cursor cs1 is select segment_name, segment_type from user_segments
where segment_type IN ('TABLE','INDEX') and segment_name in ('TFK033D','TFK033D~0')
order by segment_type, segment_name;

begin
for i in cs1 loop
begin
v_segment_name:=i.segment_name;
v_segment_type:=i.segment_type;
dbms_space.unused_space(upper('&v_owner'),
			v_segment_name,
			v_segment_type,
			v_total_blocks,
			v_total_bytes,
			v_unused_blocks,
			v_unused_bytes,
			v_last_used_extent_file_id,
			v_last_used_extent_block_id,
			v_last_used_block
			);	
bytes_total := (v_total_bytes-v_unused_bytes)+bytes_total;
end;
end loop;
dbms_output.put_line('Total de bytes realmente ocupados: '||bytes_total);
end;
/
