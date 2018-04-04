--
-- Segment Advisor for All Segments in Schema
--

-- 1. Grant the ADVISOR and SELECT ANY DICTIONARY roles to the schema owner.
-- 2. Execute the script as the schema owner.
-- 3. Revoke the ADVISOR and SELECT ANY DICTIONARY roles from the schema owner.

set echo off
set feedback off
set verify off
set linesize 80
set serveroutput on size unlimited

declare
    v_task_name   varchar2(100);
    v_task_desc   varchar2(500);
    v_objid       number;
begin
    begin
        v_task_name := 'SEGMENT_ADVISOR_RUN';
        v_task_desc := 'MANUAL SEGMENT ADVISOR RUN';

        -- Create Segment Advisor task.
        dbms_advisor.create_task
        (
            advisor_name => 'Segment Advisor',
            task_name    => v_task_name,
            task_desc    => v_task_desc
        );

        -- Add all segments to the task.
        for s in (select segment_name, segment_type
                  from dba_segments
				  where owner = 'BRAXTS_CFG'
                  and segment_type in ('TABLE', 'INDEX', 'LOB')
                  and segment_name not in (select object_name from dba_recyclebin where owner='BRAXTS_CFG'))
        loop
            dbms_advisor.create_object
            (
                task_name   => v_task_name,
                object_type => s.segment_type,
                attr1       => user,
                attr2       => s.segment_name,
                attr3       => null,
                attr4       => null,
                attr5       => null,
                object_id   => v_objid
            );
        end loop;

        -- Set task parameter to recommend all.
        dbms_advisor.set_task_parameter
        (
            task_name => v_task_name,
            parameter => 'RECOMMEND_ALL',
            value     => 'TRUE'
        );

        -- Run Segment Advisor.
        dbms_advisor.execute_task(v_task_name);

    exception when others then
        dbms_output.put_line('Exception: ' || SQLERRM);
    end;

    -- Output findings.
    dbms_output.put_line(chr(10));
    dbms_output.put_line('Segment Advisor Recommendations');
    dbms_output.put_line('--------------------------------------------------------------------------------');

    for r in (select segment_owner, segment_name, segment_type, partition_name,
                     tablespace_name, allocated_space, used_space,
                     reclaimable_space, chain_rowexcess, recommendations, c1, c2, c3
              from table(dbms_space.asa_recommendations('TRUE', 'TRUE', 'FALSE'))
              where segment_owner = 'BRAXTS_CFG'
              order by reclaimable_space desc)
    loop
        dbms_output.put_line('');
        dbms_output.put_line('Owner              : ' || r.segment_owner);
        dbms_output.put_line('Segment            : ' || r.segment_name);
        dbms_output.put_line('Segment Type       : ' || r.segment_type);
        dbms_output.put_line('Partition Name     : ' || r.partition_name);
        dbms_output.put_line('Tablespace         : ' || r.tablespace_name);
        dbms_output.put_line('Allocated Space    : ' || r.allocated_space);
        dbms_output.put_line('Used Space         : ' || r.used_space);
        dbms_output.put_line('Reclaimable Space  : ' || r.reclaimable_space);
        dbms_output.put_line('Chain Rowexcess    : ' || r.chain_rowexcess);
        dbms_output.put_line('Recommendations    : ' || r.recommendations);
        dbms_output.put_line('Run First          : ' || r.c3);
        dbms_output.put_line('Run Second         : ' || r.c2);
        dbms_output.put_line('Run Third          : ' || r.c1);
        dbms_output.put_line('--------------------------------------------------------------------------------');
    end loop;

    -- Remove Segment Advisor task.
    dbms_advisor.delete_task(v_task_name);
end;
/