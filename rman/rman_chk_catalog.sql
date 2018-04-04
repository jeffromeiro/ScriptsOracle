/**********************************************************************
 * File:        rman_chk_catalog.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        15-Oct-01
 *
 * Description:
 *      SQL*Plus script to create the RMAN_CHK package for use with
 *      the RMAN data repository in the "recovery catalog" database.
 *
 * Notes:
 *      The "redundancy check" functionality is not yet working, so
 *	whatever you enter to the parameter IN_REDUNDANCY does not
 *	yet make a difference.  I'll get that working soon...
 *
 *	If IN_DEBUG_FLAG is set to TRUE (default: FALSE), then debug
 *	output will be generated using DBMS_OUTPUT -- be sure to set
 *	SERVEROUTPUT ON when running from SQL*Plus...
 *
 * Installation:
 *	Create this package within the schema owning the RMAN "recovery
 *	catalog".
 *
 * Modifications:
 *      BBaker	22jul04 corrected problems in calls to FOLLOW_LOG_RECOVERY
 *			procedure...
 *      TGorman 23jul04 added support for multi-instance OPS/RAC
 *                      environments...
 *********************************************************************/
set echo on feedback on timing on

spool rman_chk_catalog

set termout off
create or replace package rman_chk
as
	procedure recoverability (
			out_highest_bkup_time	out VARCHAR2,
			out_last_redo_start	out VARCHAR2,
			out_bkup_type		out VARCHAR2,
			in_dbname		in VARCHAR2,
			in_requested_pitr	in DATE default NULL,
			in_redundancy		in INTEGER default 1,
			in_debug_flag		in BOOLEAN default FALSE);
end rman_chk;
/
set termout on
show errors

set termout off
create or replace package body rman_chk
as
	/*======================================================================*
	 * Procedure FIND_EARLIEST_DF_BKUP:
	 *
	 * Finds the CHECKPOINT_CHANGE# (or SCN) and CHECKPOINT_TIME of the
	 * earliest backup of a datafile according to the requested redundancy
	 * of backups (i.e. parameter IN_REDUNDANCY).  Essentially, this procedure
	 * should be very similar to the RMAN "report need backup" command.
	 *======================================================================*/
	procedure find_oldest_df_bkup (
			in_db_name		in VARCHAR2,
			in_redundancy		in INTEGER,
			in_requested_pitr	in DATE,
			out_db_key		out NUMBER,
			out_dbinc_key		out NUMBER,
			out_earliest_scn	out NUMBER, 
			out_earliest_time	out DATE, 
			inout_bkup_type		in out VARCHAR2,
			in_debug_flag		in BOOLEAN)
	is
		v_db_name			rc_database.name%type;
		i				integer;
		found				boolean;
		adequate_bkups			boolean := true;
		consistent_scn			rc_backup_datafile.checkpoint_change#%type;

		cursor cur_df(in_db_key in number, in_dbinc_key in number)
		is
		select	file#,
			creation_change#
		from	rc_datafile 
		where	db_key = in_db_key
		and	dbinc_key = in_dbinc_key
		and	(drop_change# is null
		   or	 drop_change# = creation_change#)
		order by file#;

		cursor cur_bdf(in_db_key in number, in_dbinc_key in number,
				in_file# in number, in_creation_change# in number,
				in_earliest_time in date)
		is
		select	checkpoint_change#,
			checkpoint_time
    		from	rc_backup_datafile
    		where	db_key = in_db_key
    		and	dbinc_key = in_dbinc_key
    		and	file# = in_file#
    		and	creation_change# = in_creation_change#
		and	checkpoint_time <= in_earliest_time
    		and	status = 'A'
    		and	backup_type = 'D'
    		order by checkpoint_change# desc;

	begin

		/*
		 * Initialize with a really high number...
		 */
		out_earliest_scn := power(10,125);

		/*
		 * Retrieve information about the specified DB_NAME...
		 */
		begin
			select	a.name,
				a.db_key,
				dbinc_key
			into	v_db_name,
				out_db_key,
				out_dbinc_key
			from	rc_database a,
				(select	name,
					max(resetlogs_time) latest_reset_tm
				 from	rc_database
				 group by name) b
			where	a.name = upper(in_db_name)
			and	a.name = b.name
			and	a.resetlogs_time = b.latest_reset_tm;

			if in_debug_flag = TRUE then
				dbms_output.put_line('db-name='||v_db_name||', db-key='||out_db_key||', dbinc-key='||out_dbinc_key);
			end if;

		exception
  			when no_data_found then
     				raise_application_error(-20001, '"'||in_db_name||'" not registered in catalog');
		end;

		/*
		 * initialize variables used for detecting whether datafile backup is "consistent"
		 * (i.e. "cold" backup) or "inconsistent" (i.e. "hot" backup)...
		 */
		consistent_scn := -1;

		/*
		 * loop through all of the datafiles...
		 */
		for df in cur_df(out_db_key, out_dbinc_key) loop
 
			i := 1;
			found := false;

			if in_debug_flag = TRUE then
				dbms_output.put_line('file#='||df.file#||',creation_change#='||df.creation_change#);
			end if;
 
			/*
			 * check "i"-th backup for each datafile...
			 */
			for bdf in cur_bdf(out_db_key, out_dbinc_key, df.file#, df.creation_change#, in_requested_pitr) loop
    
				if i < in_redundancy then

					i := i + 1;

				elsif i = in_redundancy then

					found := true;

					/*
					 * reset "consistent_scn" from initialized setting for first time only...
					 */
					if consistent_scn = -1 then
						consistent_scn := bdf.checkpoint_change#;
					end if;

					/*
					 * reset flag if inconsistent backup found...
					 */
					if consistent_scn <> bdf.checkpoint_change# then
						inout_bkup_type := 'INCONSISTENT';
					end if;

					/*
					 * find earliest SCN for datafile...
					 */
					if out_earliest_scn > bdf.checkpoint_change# then
						out_earliest_scn := bdf.checkpoint_change#;
						out_earliest_time := bdf.checkpoint_time;
					end if;

					if in_debug_flag = TRUE then
						dbms_output.put_line('...checkpoint-change#='||
								bdf.checkpoint_change#||
								', earliest-scn='||out_earliest_scn );
					end if;

					exit;

				end if;
 
			end loop;
  
			if not found then

				adequate_bkups := false;
				if in_debug_flag = TRUE then
					dbms_output.put_line('No Backup Datafile for File#='||df.file#); 
				end if;

			end if;
  
		end loop;

		if in_debug_flag = TRUE then
			dbms_output.put_line('db-key='||out_db_key||', dbinc-key='||out_dbinc_key||
				', start-scn='||out_earliest_scn);
		end if;

		if not adequate_bkups then

			raise_application_error(-20002,
				'Datafiles do not have FULL/LEVEL0 backup with redundancy='||in_redundancy);

		end if;

	end find_oldest_df_bkup;

	/*======================================================================*
	 * Procedure FOLLOW_LOG_RECOVERY:
	 *
	 * While the FIND_EARLIEST_DF_BKUP procedure is the same as the
	 * functionality of the RMAN "report need backup" command, this procedure
	 * is functionality that RMAN is missing but which it should have.
	 *
	 * This procedure starts with the SCN returned by the FIND_EARLIEST_DF_BKUP
	 * procedure and ensures that the chain of backed-up redo log files is
	 * unbroken until the requested point-in-time.
	 *
	 * This procedure then will also continue to follow the chain of
	 * archived but not-backed-up redo log files to determine how far the
	 * database could be recovered, if those files are included in the
	 * recovery.
	 *======================================================================*/
	procedure follow_log_recovery( 
			in_db_key		in NUMBER,
			in_dbinc_key		in NUMBER,
			in_start_scn		in NUMBER,
			in_start_time		in DATE,
			in_rdo_redundancy	in NUMBER,
			in_bkup_type		in VARCHAR2,
			out_highest_bkup_time	out VARCHAR2,
			out_last_redo_start	out VARCHAR2,
			in_debug_flag		in BOOLEAN)
	is

		v_scn					rc_backup_redolog.first_change#%type := -1;
		v_seq					rc_backup_redolog.sequence#%type := -1;

		cursor get_redo_threads
		is
		select	thread#,
			enable_change#
		from	v$thread
		where	status = 'OPEN'
		and	enabled in ('PUBLIC','PRIVATE');

		cursor backup_redologs( in_db_key	in NUMBER,
					in_dbinc_key	in NUMBER,
					in_thread	in NUMBER,
					in_scn		in NUMBER)
		is
		select	sequence#,
			first_change#,
			to_char(first_time, 'DD-MON-YYYY HH24:MI:SS') first_time,
			next_change#,
			to_char(next_time, 'DD-MON-YYYY HH24:MI:SS') next_time
		from	rc_backup_redolog
		where	db_key = in_db_key
		and	dbinc_key = in_dbinc_key
		and	thread# = in_thread
		and	first_change# >= in_scn
		order by sequence#;

		cursor redologs(in_db_key		in NUMBER,
				in_dbinc_key		in NUMBER,
				in_thread		in NUMBER,
				in_scn			in NUMBER)
		is
		select	sequence#,
			first_change#,
			to_char(first_time, 'DD-MON-YYYY HH24:MI:SS') first_time,
			next_change#
		from	rc_log_history
		where	db_key = in_db_key
		and	dbinc_key = in_dbinc_key
		and	thread# = in_thread
		and	first_change# >= in_scn
		order by sequence#;

	begin

	    for t in get_redo_threads loop

		/*
		 * Find the earliest backed-up archived redo log file from
		 * which recovery will start...
		 */
		begin
			select	min(first_change#)
			into	v_scn
			from	rc_backup_redolog
			where	db_key = in_db_key
			and	dbinc_key = in_dbinc_key
			and	thread# = t.thread#
			and	first_change# >= t.enable_change#
			and	first_change# <= in_start_scn
			and	next_change# >= in_start_scn;

			if v_scn is null then
				raise no_data_found;
			end if;

		exception

			when no_data_found then

				if in_bkup_type = 'CONSISTENT' then	/* a.k.a. "cold" backup */

					out_highest_bkup_time := to_char(in_start_time, 'DD-MON-YYYY HH24:MI:SS');
					out_last_redo_start := to_char(in_start_time, 'DD-MON-YYYY HH24:MI:SS');

					if in_debug_flag = TRUE then
						dbms_output.put_line('Thread#'||t.thread#||': No backed-up archivelogs following CONSISTENT backup');
					end if;

					return;
					
				else /* ...datafile backup was INCONSISTENT, a.k.a. "hot" backup... */

					raise_application_error(-20002, 'Thread#'||t.thread#||': No backed-up archivelogs found');

				end if;

		end;

		if in_debug_flag = TRUE then
			dbms_output.put_line('Thread#'||t.thread#||': backed-up archivelog: dbf_scn='||in_start_scn||', redo first_scn='||v_scn);
		end if;

		/*
		 * find if there are backed up archive logs to cover all datafile backups...
		 */
		for l in backup_redologs(in_db_key, in_dbinc_key, t.thread#, v_scn) loop

			if in_debug_flag = TRUE then
				dbms_output.put_line('Thread#'||t.thread#||': backed-up archivelog: seq='||l.sequence#||': next_change#='||
					v_scn||', first_change#='||l.first_change#||', first_time="'||
					l.first_time||'", next_time="'||l.next_time||'"');
			end if;

			if l.sequence# > v_seq then
				
				v_seq := l.sequence#;

				if v_scn <> l.first_change# then

					raise_application_error(-20003,
						'Thread#'||t.thread#||': Unrecoverable - gap in backed-up archivelogs from SCN='||
						l.first_change#||' ('||l.first_time||
						') until SCN='|| l.next_change#||' ('||l.next_time||')');

				end if;

				v_scn := l.next_change#;
				out_highest_bkup_time := l.next_time;

			end if;

		end loop;	/* end of "backup_redologs" cursor loop */

		/*
		 * now find out if the unbacked-up redo log files are up-to-date or not...
		 */
		for l in redologs(in_db_key, in_dbinc_key, t.thread#, v_scn) loop

			if in_debug_flag = TRUE then
				dbms_output.put_line('Thread#'||t.thread#||': non-backed-up archivelog: seq='||l.sequence#||': next_change#='||
						v_scn||', first_change#='|| l.first_change#||
						', first_time="'||l.first_time||'"');
			end if;

			if v_scn <> l.first_change# then

				raise_application_error(-20004,
						'Thread#'||t.thread#||': Unrecoverable - gap in non-backed-up archivelogs from SCN='||
						l.first_change#||' ('||l.first_time||
						') until SCN='|| l.next_change#);

			end if;

			v_scn := l.next_change#;
			out_last_redo_start := l.first_time;

		end loop;	/* end of "redologs" cursor loop */

	    end loop;	/* end of "get_redo_threads" cursor loop */

	    if out_last_redo_start is null then
		out_last_redo_start := out_highest_bkup_time;
	    end if;

	end follow_log_recovery;

	procedure recoverability (
			out_highest_bkup_time	out VARCHAR2,
			out_last_redo_start	out VARCHAR2,
			out_bkup_type		out VARCHAR2,
			in_dbname		in VARCHAR2,
			in_requested_pitr	in DATE default NULL,
			in_redundancy		in INTEGER default 1,
			in_debug_flag		in BOOLEAN default FALSE)
	is
		v_db_key			number;
		v_dbinc_key			number;
		v_start_scn			number;
		v_start_time			date;
		v_requested_pitr		date;
	begin 

		if in_requested_pitr is null then
			v_requested_pitr := sysdate - (1/24);
		else
			v_requested_pitr := in_requested_pitr;
		end if;

		out_bkup_type := 'CONSISTENT';

		/*
		 * First, obtain the earliest SCN of the earliest backed-up datafile...
		 */
		find_oldest_df_bkup(in_dbname, in_redundancy, v_requested_pitr,
				v_db_key, v_dbinc_key,
				v_start_scn, v_start_time, out_bkup_type,
				in_debug_flag);

		/*
		 * Then, step forward through the backed-up archived redo log files
		 * until the requested point-in-time...
		 */
		follow_log_recovery(v_db_key, v_dbinc_key, v_start_scn,
				    v_start_time, in_redundancy,
				    out_bkup_type, out_highest_bkup_time,
				    out_last_redo_start, in_debug_flag);

		if to_date(out_last_redo_start, 'DD-MON-YYYY HH24:MI:SS') < v_requested_pitr then

			raise_application_error(-20005, 'Cannot recover to requested point-in-time "' ||
				to_char(v_requested_pitr, 'DD-MON-YYYY HH24:MI:SS') || '"');

		end if;

	end recoverability;

end rman_chk;
/
set termout on
show errors

spool off
