spoo /home/oracle/chklist/log/saida_PROD.log;

SET LINESIZE 150;
SET PAGESIZE 58;

TTITLE LEFT 'Total de Espaco Alocado x Usado no Storage - Sodexo' SKIP 2;
BTITLE LEFT 'Page:' SQL.PNO;

COL group_number        FORMAT 99999999   HEADING 'ASM|Disk|Grp #';
COL name                FORMAT A12        HEADING 'ASM Disk|Group Name' WRAP;
COL total_mb            FORMAT 99,999,999 HEADING 'Espaco|Alocado(MB)';
COL usado               FORMAT 99,999,999 HEADING 'Espaco|Usado(MB)';
COL free_mb             FORMAT 99,999,999 HEADING 'Espaco|Livre(MB)';
COL percent             FORMAT 99,999,999 HEADING '30%|Garantia';

BREAK ON report SKIP 1;

COMPUTE SUM LABEL 'TOTAL' OF total_mb ON report;
COMPUTE SUM LABEL 'TOTAL' OF free_mb  ON report;
COMPUTE SUM LABEL 'TOTAL' OF usado    ON report;

SELECT
     group_number
    ,name
    ,total_mb
    ,total_mb-free_mb as usado
    ,free_mb
    ,(( total_mb-free_mb ) * 0.3) as percent
  FROM v$asm_diskgroup
ORDER BY name;
spoo off;
exit;
