--UTILIZAÇÃO DAS COLUNAS DE UMA TABELA, A VIEW SYS.COL_USAGE$ É POPULADA APENAS QUANDO É FEITO COLETA DE ESTATÍSTICAS

SELECT c.name, cu.timestamp,
 cu.equality_preds AS equality, cu.equijoin_preds AS equijoin,
 cu.nonequijoin_preds AS noneequijoin, cu.range_preds AS range,
 cu.like_preds AS "LIKE", cu.null_preds AS "NULL"
 FROM sys.col$ c, sys.col_usage$ cu, sys.obj$ o, sys.user$ u
 WHERE c.obj# = cu.obj# (+)
 AND c.intcol# = cu.intcol# (+)
 AND c.obj# = o.obj#
 AND o.owner# = u.user#
 AND o.name = '&TABLE'
 AND U.NAME='&OWNER'
 AND u.name = user
 ORDER BY c.col#;