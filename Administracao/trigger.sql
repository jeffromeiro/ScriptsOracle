select owner
     , trigger_name
     , status 
     , trigger_body 
  from dba_triggers 
 where table_name like upper('%&ptable%')
   and owner  like upper('%&powner%')
/
