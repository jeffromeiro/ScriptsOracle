



ANALISE DE PLANO DE EXECU��O:

optimizer_index_caching

optimizer_index_cost_adj

_optimizer_invalidation_period



FTS X INDEX

Verificar o n�mero de valores distintos do �ndice:


-- Quanto menor o fator, melhor o �ndice.


Fator coletado pela estat�stica:

SELECT owner
,      index_name
,      num_rows
,      distinct_keys
,      sample_size
,      last_analyzed
,      ROUND(num_rows/distinct_keys) as "FACTOR"
  FROM dba_indexes
 WHERE index_name = '&INDEX_NAME'

Fator real existente na tabela:
 
SELECT COUNT(1) AS "ROWS"
,      COUNT(DISTINCT(&COLUMN_NAME)) AS "DISTINCTS"
,      ROUND(COUNT(*)/COUNT(DISTINCT(&COLUMN_NAME))) as "REAL FACTOR"
  FROM &TABLE_NAME