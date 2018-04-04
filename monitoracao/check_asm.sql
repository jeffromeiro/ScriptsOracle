spool /home/oracle/chklist/log/check_asm
set serveroutput on size 2000

set head off
set feed off
set echo off
set trimspool on
declare v_sev number := 0;
v_limite1 number := 8192; -- limite de severidade maior
v_limite2 number := 12288; -- limite de severidade menor
begin
select count(*) into v_sev
  from v$asm_diskgroup
 where free_mb < v_limite1
 and total_mb <> 0
 and name in ('DGPROD','FRAPROD');
if v_sev > 0 then 
	dbms_output.put_line('ASM_DISKGROUPS_SEV1_NOK');
else
        dbms_output.put_line('ASM_DISKGROUPS_SEV1_OK');
select count(*) into v_sev
  from v$asm_diskgroup
  where free_mb < v_limite2
  and total_mb <> 0
 and name in ('DGPROD','FRAPROD');
  if v_sev > 0 then
        dbms_output.put_line('ASM_DISKGROUPS_SEV2_NOK');
  else
        dbms_output.put_line('ASM_DISKGROUPS_SEV2_OK');
  end if;
end if;
end;
/
spool off

