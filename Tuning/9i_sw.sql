--------------------------------------------------------------------------------
--
-- File name:   9i_sw.sql
-- Purpose:     Display current Session Wait info
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sw <sid>
--              @sw 52,110,225
--              @sw "select sid from v$session where username = 'XYZ'"
--              @sw &mysid
--              @sw.sql "select sid from v$session where type != 'BACKGROUND'"
--		@sw.sql "select sid from v$session where type != 'BACKGROUND' and status='ACTIVE'"
--------------------------------------------------------------------------------

set verify off
set lines 170
set pages 90
col sw_event    head EVENT for a29 truncate
col sw_p1transl head P1TRANSL for a42
col sw_sid      head SID for 99999
col seq#        head SEQ for 99999
col seconds_in_wait head Wait_Sec for 9999
col state format a7

col sw_p1       head P1 for a18 justify left word_wrap
col sw_p2       head P2 for a18 justify left word_wrap
col sw_p3       head P3 for a18 justify left word_wrap
def _sid="&1"

select 
    sid sw_sid,
    CASE WHEN state != 'WAITING' THEN 'WORKING'
         ELSE 'WAITING'
    END AS state, 
    CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
         ELSE event
    END AS sw_event, 
    seq#, 
    seconds_in_wait, 
    NVL2(p1text,p1text||'= ',null)||CASE WHEN P1 < 536870912 THEN to_char(P1) ELSE '0x'||rawtohex(P1RAW) END SW_P1,
    NVL2(p2text,p2text||'= ',null)||CASE WHEN P2 < 536870912 THEN to_char(P2) ELSE '0x'||rawtohex(P2RAW) END SW_P2,
    NVL2(p3text,p3text||'= ',null)||CASE WHEN P3 < 536870912 THEN to_char(P3) ELSE '0x'||rawtohex(P3RAW) END SW_P3,
    CASE 
        WHEN event like 'cursor:%' THEN
            '0x'||trim(to_char(p1, 'XXXXXXXXXXXXXXXX'))
                WHEN event like 'enq%' AND state = 'WAITING' THEN 
            '0x'||trim(to_char(p1, 'XXXXXXXXXXXXXXXX'))||': '||
            chr(bitand(p1, -16777216)/16777215)||
            chr(bitand(p1,16711680)/65535)||
            ' mode '||bitand(p1, power(2,14)-1)
        WHEN event like 'latch%' AND state = 'WAITING' THEN 
              '0x'||trim(to_char(p1, 'XXXXXXXXXXXXXXXX'))||': '||(
                    select name||'[par' 
                        from v$latch_parent 
                        where addr = hextoraw(trim(to_char(p1,rpad('0',length(rawtohex(addr)),'X'))))
                    union all
                    select name||'[c'||child#||']' 
                        from v$latch_children 
                        where addr = hextoraw(trim(to_char(p1,rpad('0',length(rawtohex(addr)),'X'))))
              )
        WHEN event like 'library cache pin' THEN
              '0x'||RAWTOHEX(p1raw)
    ELSE NULL END AS sw_p1transl
FROM 
    v$session_wait
WHERE 
    sid IN (&_sid)
    and sid != (select sid from v$mystat where rownum=1)
ORDER BY
    state,
    sw_event,
    p1,
    p2,
    p3
/
--BLOCKING_SESSION
col username format a15
col osuser format a20
col sid format 999999
col module format a40
col machine format a25 justify left word_wrap
col RESOURCE_CONSUMER_GROUP HEAD R_Manager format a15
col BLOCKING_SESSION HEAD B_Sess format 9999 justify left word_wrap
col logon_time format a18

select To_char(logon_time, 'DD/MM/YYYY HH24:MI') logon_time,
       sid,
       username,
       osuser,
       module,
       machine
from v$session
where sid in (&_sid)
  and sid != (select sid from v$mystat where rownum=1);

undef _sid
