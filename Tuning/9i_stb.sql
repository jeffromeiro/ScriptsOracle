set lines 120
col destination for a25
col error for a30

select dest_id, status, target, ARCHIVER, DESTINATION, LOG_SEQUENCE, REOPEN_SECS, DELAY_MINS, NET_TIMEOUT
from v$archive_dest
where status <> 'INACTIVE';

select dest_id, PROCESS, FAIL_DATE, FAIL_SEQUENCE, FAIL_BLOCK, MAX_FAILURE, ERROR
from v$archive_dest
where status <> 'INACTIVE';

select dest_id, mountid, TRANSMIT_MODE, ASYNC_BLOCKS, AFFIRM, TYPE
from v$archive_dest
where status <> 'INACTIVE';

select dest_id, database_mode, STANDBY_LOGFILE_COUNT, APPLIED_THREAD#, APPLIED_SEQ#, srl, error
from v$archive_dest_status
where status <> 'INACTIVE';
