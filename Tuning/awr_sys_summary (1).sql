select dbid,
min(begin_time), max(end_time),
sum(case metric_name when 'Physical Read Total Bytes Per Sec' then average end) Physical_Read_Total_Bps,
sum(case metric_name when 'Physical Write Total Bytes Per Sec' then average end) Physical_Write_Total_Bps,
sum(case metric_name when 'Redo Generated Per Sec' then average end) Redo_Bytes_per_sec,
sum(case metric_name when 'Physical Read Total IO Requests Per Sec' then average end) Physical_Read_IOPS,
sum(case metric_name when 'Physical Write Total IO Requests Per Sec' then average end) Physical_write_IOPS,
sum(case metric_name when 'Redo Writes Per Sec' then average end) Physical_redo_IOPS,
sum(case metric_name when 'Current OS Load' then average end) OS_LOad,
sum(case metric_name when 'CPU Usage Per Sec' then average end) DB_CPU_Usage_per_sec,
sum(case metric_name when 'Host CPU Utilization (%)' then average end) Host_CPU_util, --NOTE 100% = 1 loaded RAC node
sum(case metric_name when 'Network Traffic Volume Per Sec' then average end) Network_bytes_per_sec,
sum(case metric_name when 'Current Logons Count' then average end) Current_Logons_Count,
sum(case metric_name when 'Average Active Sessions' then average end) Average_Active_Sessions,
sum(case metric_name when 'User Transaction Per Sec' then average end) User_Transaction_Per_Sec,
snap_id
from dba_hist_sysmetric_summary
group by snap_id,dbid
order by dbid,snap_id;