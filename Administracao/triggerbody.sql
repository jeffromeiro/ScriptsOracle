SET PAGES 0
SET LONG 100000
SET TRIMSPOO ON

SELECT 'CREATE OR REPLACE TRIGGER '||description , DECODE(when_clause,null,null,'WHEN ('||when_clause||')') 
     , trigger_body 
  FROM dba_triggers 
 WHERE trigger_name like UPPER('%&pname%')
   and owner  like UPPER('%&powner%');
   
