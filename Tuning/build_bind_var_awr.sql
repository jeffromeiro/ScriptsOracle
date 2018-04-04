set linesize 255;
set pagesize 50000;
--
accept sql_id char prompt "Enter SQL ID ==> "

--
-- Create variable statements
--
select distinct
'variable ' ||
   case null when 1 then replace(name,':','N') else substr(name,2,30) end || ' ' ||
replace(datatype_string,'CHAR(','VARCHAR2(') txt
from
dba_hist_sqlbind
where
sql_id='&&sql_id' and snap_id = (select max(snap_id) from dba_hist_sqlbind where sql_id='&&sql_id');

--
-- Set variable values from V$SQL_BIND_CAPTURE
--
select distinct
   'exec '||case null when 1 then replace(name,':',':N') else name end ||
   ' := ' ||
   case datatype_string when 'NUMBER' then null else '''' end ||
   value_string ||
   case datatype_string when 'NUMBER' then null else '''' end ||
   ';'
from
   dba_hist_sqlbind
where
   sql_id='&&sql_id' and snap_id =  (select max(snap_id) from dba_hist_sqlbind where sql_id='&&sql_id');

undef sql_id

