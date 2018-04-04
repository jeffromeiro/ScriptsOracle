-- Executa a consulta dos sqlids informados.

set lines 100 pages 5000 feed off term Off

spool exec.sql
set long 3000000
SET SERVEROUTPUT ON;
DECLARE
  VAL_DBID      number;
  TEXTO_PARTE   varchar2(30000);
  DIVISOR number;
  TAMANHO_LOB   number;
  TIRA_SET   number;
  TIRA_SETII   number;
  FORMATA_FORUPDATE   number;
  CONTADOR      NUMBER;
  FORMATA_TEXTO NUMBER;
  ISNOTSELECT  char(3);
  TEXTO_DML   varchar2(30000);
  BINDS_VAR   varchar2(30000);
  BINDS_EXEC   varchar2(30000);

BEGIN
  
   CONTADOR := 1;
   SELECT DISTINCT dbid
    into VAL_DBID
    from dba_hist_database_instance;
   --where db_name = 'CP1';  -- ALTERAR PARA O BANCO DE DADOS CORRESPONDENTE (CP1,EP1 E EP2)
   
   DBMS_OUTPUT.PUT_LINE('set lines 100 pages 5000 feed off term off head off echo on');
  
  FOR VAL_SQLID IN (SELECT a.sql_id, a.sql_text
                      FROM dba_hist_sqltext a
                     where a.sql_id in
                           (select b.sql_id
                              from dba_hist_sqlstat b
                             WHERE --b.PARSING_SCHEMA_NAME = 'SAPSR3' -- NOME DO SCHEMA
                               --and 
							   a.sql_id = b.sql_id
                               and a.dbid = b.dbid)
                          --and b.snap_id between 55515 and 56223 )
                       --and a.command_type in ( 3,7, 6)    -- select,  delete e update respectivamente
                       and a.sql_id IN ('7hzddw6azmr2w')
)
					   
  
   LOOP
  
	
    -- Busca as binds da úa execuç
	FOR VAL_BINDS IN
	(
     select  VARIAVEL  from(
    SELECT 'VARIABLE '||SUBSTR(NAME,2,1000)||' '||DECODE(SUBSTR(DATATYPE_STRING,1,4),'CHAR','VARCHAR2(2000)',DATATYPE_STRING) AS VARIAVEL
    FROM DBA_HIST_SQLBIND
     WHERE SQL_ID=VAL_SQLID.SQL_ID  AND SNAP_ID in (SELECT MAX(SNAP_ID)  FROM DBA_HIST_SQLBIND where WAS_CAPTURED='YES' AND SQL_ID=VAL_SQLID.SQL_ID)
    UNION ALL
    SELECT 'EXEC '||NAME||' := '||DECODE(DATATYPE_STRING,'NUMBER',VALUE_STRING,''''||VALUE_STRING||'''')||';' AS EXECUCAO
     FROM DBA_HIST_SQLBIND WHERE SQL_ID=VAL_SQLID.SQL_ID  AND   SNAP_ID in (SELECT MAX(SNAP_ID)  FROM DBA_HIST_SQLBIND where WAS_CAPTURED='YES' AND SQL_ID=VAL_SQLID.SQL_ID)
    ))
	
	
	LOOP
	    DBMS_OUTPUT.PUT_LINE(VAL_BINDS.VARIAVEL);
	END LOOP;
  	
	
	DBMS_OUTPUT.PUT_LINE('--');
	DBMS_OUTPUT.PUT_LINE('set timing on');
	DBMS_OUTPUT.PUT_LINE('set echo off');
	DBMS_OUTPUT.PUT_LINE('set term off');
	DBMS_OUTPUT.PUT_LINE('set trimspool off');
	DBMS_OUTPUT.PUT_LINE('set linesize 130');
	DBMS_OUTPUT.PUT_LINE('set autot trace expl stat');
	DBMS_OUTPUT.PUT_LINE('--');
    DBMS_OUTPUT.PUT_LINE('SPOOL ' || VAL_SQLID.SQL_ID || '.lst');
    DBMS_OUTPUT.PUT_LINE('--');
    
	DBMS_OUTPUT.PUT_LINE(' ');
	
	ISNOTSELECT :=  UPPER(dbms_lob.substr(VAL_SQLID.SQL_TEXT, 3, 1));
	TAMANHO_LOB  := lengthB(VAL_SQLID.sql_text);
	FORMATA_FORUPDATE  := instr(dbms_lob.substr(VAL_SQLID.SQL_TEXT, 30000, 1),'FOR UPDATE',-1);
	
	IF FORMATA_FORUPDATE <> 0 THEN -- FOR UPDATE
	     TEXTO_PARTE := dbms_lob.substr(VAL_SQLID.SQL_TEXT, FORMATA_FORUPDATE-1, 1);
		 DBMS_OUTPUT.PUT_LINE(TEXTO_PARTE||' /*FOR UPDATE*/ ');
		 ISNOTSELECT := 'F';
	 END IF;
	 
	 IF ISNOTSELECT = 'DEL' OR ISNOTSELECT = ' DE' OR ISNOTSELECT = '  D' THEN
	     TEXTO_DML := 'SELECT * /*DELETE*/ ';
		 TEXTO_PARTE := TEXTO_DML||dbms_lob.substr(VAL_SQLID.SQL_TEXT, 32000, 8);
		 DBMS_OUTPUT.PUT_LINE(TEXTO_PARTE);
		 
	 ELSIF ISNOTSELECT = 'UPD' OR ISNOTSELECT = ' UP' OR ISNOTSELECT = '  U' THEN
	     TEXTO_DML := 'SELECT * FROM /*UPDATE*/ ';
		 TIRA_SET  := instr(dbms_lob.substr(VAL_SQLID.SQL_TEXT, 30000, 1),' SET ',1);
		 TIRA_SETII  := instr(dbms_lob.substr(VAL_SQLID.SQL_TEXT, 30000, 1),'WHERE',1);
		 TEXTO_PARTE := TEXTO_DML||dbms_lob.substr(VAL_SQLID.SQL_TEXT, TIRA_SET-8, 8)||' '||dbms_lob.substr(VAL_SQLID.SQL_TEXT, 32000, TIRA_SETII);
		 DBMS_OUTPUT.PUT_LINE(TEXTO_PARTE);
	 			 
     ELSIF ISNOTSELECT = 'SEL' OR ISNOTSELECT = ' SE' OR ISNOTSELECT = '  S' THEN
	  
	-- DBMS_OUTPUT.PUT_LINE('COMANDO!; '||ISNOTSELECT);
	
    TAMANHO_LOB  := lengthB(VAL_SQLID.sql_text);
    DIVISOR := CEIL(TAMANHO_LOB / 30000); -- divide o lob por 30000 devido a limitaç do varchar2 e arredonda o resultado para cima
   
  
    FOR PARTE_DO_TEXTO IN 1 .. DIVISOR LOOP
	  
	  FORMATA_TEXTO := instr(dbms_lob.substr(VAL_SQLID.SQL_TEXT, 30000, CONTADOR),',',-1); -- RETORNA A QUANTIDADE DE CARACTERES ATÉA ULTIMA VIRGULA
      
	 -- IF ABC == 1
	  
	  TEXTO_PARTE := dbms_lob.substr(VAL_SQLID.SQL_TEXT, FORMATA_TEXTO, CONTADOR); -- 30000 E 1 /  30000 E 30001 / 30000 
	  
	  CONTADOR := CONTADOR + FORMATA_TEXTO;
      DBMS_OUTPUT.PUT_LINE(TEXTO_PARTE);
    END LOOP;
	
	  TEXTO_PARTE := dbms_lob.substr(VAL_SQLID.SQL_TEXT, 30000, CONTADOR); -- 30000 E 1 /  30000 E 30001 / 30000 
	  DBMS_OUTPUT.PUT_LINE(TEXTO_PARTE);
	 END IF;
	  
	  DBMS_OUTPUT.PUT_LINE('/');
	  DBMS_OUTPUT.PUT_LINE('--');
	  DBMS_OUTPUT.PUT_LINE('SPOOL off');
	  DBMS_OUTPUT.PUT_LINE(' ');
	  DBMS_OUTPUT.PUT_LINE('SPOOL ' || VAL_SQLID.SQL_ID || '.txt');
      DBMS_OUTPUT.PUT_LINE('/');
	  DBMS_OUTPUT.PUT_LINE('--');
      DBMS_OUTPUT.PUT_LINE('SPOOL off');
	  DBMS_OUTPUT.PUT_LINE('--');
      CONTADOR := 1;
  END LOOP;
END;
/
spool off
--@exec



