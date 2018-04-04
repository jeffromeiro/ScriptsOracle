	set colsep "  "
	col username format a12
	col sid      format 9999
	col serial#  format 99999
	col machine  format a22
	col program  format a15
	col type     format a5
	col Hold     format a10
	col object   format a25

	SELECT
		SUBSTR(s1.username,1,12)           "WAITING USER"
	  , SUBSTR(s1.osuser,1,8)              "OS User"
	  , s1.sql_id "SQL_ID Waiting"
	  , SUBSTR(TO_CHAR(w.session_id),1,5)  "Sid"
	  , p1.spid                            "PID"
	  , SUBSTR(s2.username,1,12)           "HOLDING User"
	  , s1.sql_id "SQL_ID Holding"
	  , SUBSTR(s2.osuser,1,8)              "OS User"
	  , SUBSTR(TO_CHAR(h.session_id),1,5)  "Sid"
	  , p2.spid                            "PID"
	FROM
		sys.gv_$process p1
	  , sys.gv_$process p2
	  , sys.gv_$session s1
	  , sys.gv_$session s2
	  , dba_locks  w
	  , dba_locks  h
	WHERE
		  h.mode_held      != 'None'
	  AND h.mode_held      != 'Null'
	  AND w.mode_requested != 'None'
	  AND w.lock_type  (+)  = h.lock_type
	  AND w.lock_id1   (+)  = h.lock_id1
	  AND w.lock_id2   (+)  = h.lock_id2
	  AND w.session_id      = s1.sid   (+)
	  AND h.session_id      = s2.sid   (+)
	  AND s1.paddr          = p1.addr  (+)
	  AND s2.paddr          = p2.addr  (+);
