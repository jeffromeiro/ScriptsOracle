alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

col value form a50

select * from v$rman_configuration
/

TTITLE OFF
BTITLE OFF

SELECT INSTANCE_NAME, HOST_NAME FROM V$INSTANCE;

COL STATUS FORM A21

COL INPUT_BYTES FORM 999,999,999,999
COL OUTPUT_BYTES FORM 999,999,999,999
COL MBYTES_PROCESSED FORM 999,999,999
col output_device_type head OUTPUT_DEVICE FORM A13

--select recid, command_id, operation, status, start_time, end_time, 
--object_type, output_device_type 
--from v$rman_status
--where start_time between sysdate-1 and sysdate
--order by start_time
--/

SELECT OPERATION
, STATUS
, MBYTES_PROCESSED
--, INPUT_BYTES
--, OUTPUT_BYTES
, OPTIMIZED
, OBJECT_TYPE
, OUTPUT_DEVICE_TYPE
, START_TIME
, END_TIME 
, round ((end_time - start_time) *1440 ,2) Minutos
from V$RMAN_STATUS 
where start_time between sysdate-1 and sysdate
order by START_TIME
/

