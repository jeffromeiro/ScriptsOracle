select distinct(snap_id), min(sample_time) "Inicio", max(sample_time) "Fim",
 count(session_id) "Total Sessoes"
 from dba_hist_active_sess_history group by snap_id order by 1;