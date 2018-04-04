	col start_time form a19
	col end_time  form a19
	col time_taken_display form a8
	col output_device_type form 999,999,999
	col status form a23
	col input_type form a16
	col input_bytes_display head IN_BYTES form a10
	col output_bytes_display head OUT_BYTES form a9
	col input_bytes_per_sec_display head IN_BYTES_SEC form a12
	col output_bytes_per_sec_display head OUT_BYTES_SEC form a13

	select 
		session_key
		,to_char(start_time,'dd/mm/yyyy hh24:mi:ss') start_time
		,to_char(end_time,'dd/mm/yyyy hh24:mi:ss') end_time
		,round ( (end_time-start_time)*1440/60, 2) DIF_HORAS
		,time_taken_display 
		,output_device_type
		,status 
		,input_type 
		,input_bytes_display 
		,output_bytes_display 
		,input_bytes_per_sec_display
		,output_bytes_per_sec_display
	from 	v$rman_backup_job_details 
	where 	start_time between sysdate-30 and sysdate  and input_type <> 'ARCHIVELOG'
	order by start_time;
