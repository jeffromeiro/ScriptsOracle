spool create_tempfiles.txt

set lines 2000
set pages 100
set feed off
set head off

SELECT 'ALTER TABLESPACE '
 || TABLESPACE_NAME
 || ' ADD TEMPFILE  '
 || '''+DATA_DBDEV02'''
 || ' size 256m autoextend on maxsize 10g;'
FROM V$TEMPFILE TMP,
 DBA_TEMP_FILES DT
WHERE tmp.file#=dt.file_id;

set head on
set feed on
spool off;
