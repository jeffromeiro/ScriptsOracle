SET LINES 500
SET PAGES 100
SET LONG 10000

prompt INFO: bind variable

SELECT	SQL_ID,
	T.SQL_TEXT SQL_TEXT,
	B.NAME BIND_NAME,
	B.VALUE_STRING BIND_STRING 
FROM  	V$SQL T  JOIN V$SQL_BIND_CAPTURE B  USING (SQL_ID)
WHERE  	B.VALUE_STRING IS NOT NULL  
AND 	SQL_ID='<sql_id>' ;

