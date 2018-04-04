select
   blocking_session,
   sid,
   serial#,
   wait_class,
   seconds_in_wait
from
   gv$session
where
   blocking_session is not NULL
order by
   blocking_session
/