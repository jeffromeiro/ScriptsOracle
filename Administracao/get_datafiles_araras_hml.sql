set head off
set pages 1000
set lines 105
set feed off
set serveroutput on 
spool script_restore_araras_hml.sh

declare

	v_datafiles_sys varchar2(999);
	v_datafiles_data varchar2(999);

	begin
	dbms_output.put_line('/oracle/product/102/db_1/bin/rman nocatalog target / log=/rman/refresh/dbhom01/restore_db_araras_hml.log <<EOF');
	dbms_output.put_line('run {');
	dbms_output.put_line('ALLOCATE CHANNEL c1 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c2 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c3 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c4 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c5 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c6 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c7 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c8 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c9 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c10 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c11 DEVICE TYPE DISK;');
	dbms_output.put_line('ALLOCATE CHANNEL c12 DEVICE TYPE DISK;');
	
	for datafiles_sys in (
	
		select 
			'set newname for datafile ' || d.file# || ' to ''' || '+SYS_DBHOM01' || ''';' line
		into
			v_datafiles_sys
		from 
			v$datafile d, v$tablespace t  
		where
			d.TS# = t.TS#
			and t.name in ('SYSTEM','SYSAUX')
	) loop
			
		dbms_output.put_line(datafiles_sys.line);
	
	end loop;	
	
	for datafiles_data in (
	
		select 
			'set newname for datafile ' || d.file# || ' to ''' || '+DATA_DBHOM01' || ''';' line
		into
			v_datafiles_sys
		from 
			v$datafile d, v$tablespace t  
		where
			d.TS# = t.TS#
			and t.name not in ('SYSTEM','SYSAUX')
	) loop
			
		dbms_output.put_line(datafiles_data.line);
	
	end loop;	
	
	dbms_output.put_line('RESTORE DATABASE CHECK READONLY;');
	dbms_output.put_line('SWITCH DATAFILE ALL;');
	dbms_output.put_line('release channel c1;');
	dbms_output.put_line('release channel c2;');
	dbms_output.put_line('release channel c3;');
	dbms_output.put_line('release channel c4;');
	dbms_output.put_line('release channel c5;');
	dbms_output.put_line('release channel c6;');
	dbms_output.put_line('release channel c7;');
	dbms_output.put_line('release channel c8;');
	dbms_output.put_line('release channel c9;');
	dbms_output.put_line('release channel c10;');
	dbms_output.put_line('release channel c11;');
	dbms_output.put_line('release channel c12;');
	dbms_output.put_line('}');
	dbms_output.put_line('exit');
	dbms_output.put_line('<<EOF');
	dbms_output.put_line('exit ?');
	

end;
/
spool off;
set head on
set feed on
