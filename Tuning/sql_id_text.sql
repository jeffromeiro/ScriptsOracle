select t.sql_text
from gv$sqltext t
where t.sql_id = '&1'
order by inst_id, piece
/
