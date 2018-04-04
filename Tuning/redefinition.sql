--Primeiro de tudo fazer o backup da tabela original

  --VT_LANC_FAT_TRANSP_DET

  --Verificar se é candidata ao redefinition


  BEGIN
  DBMS_REDEFINITION.CAN_REDEF_TABLE(uname => 'SQLDBA', tname => 'VT_LANC_FAT_TRANSP_DET'); --Redefinition via PK caso não tiver pk adicionar a opção OPTIONS_FLAG=>DBMS_REDEFINITION.CONS_USE_ROWID
  END;
  /

  --Criar tabela iterina


  CREATE TABLE "SQLDBA"."VT_LANC_FAT_TRANSP_DET_ITERIM"
   (    "COD_EMPR" VARCHAR2(1 BYTE),
    "COD_ORG_PROD" NUMBER(3,0),
    "COD_RAMO" NUMBER(5,0),
    "APOLICE" NUMBER(10,0),
    "ENDOSSO" NUMBER(6,0),
    "IND_NAC_INT" VARCHAR2(1 BYTE),
    "COD_ITEM" NUMBER(10,0),
    "COD_SUB_RAMO" NUMBER(5,0),
    "COD_COB_EMPR" NUMBER(3,0),
    "COD_DIV_RISCO" NUMBER(3,0),
    "DT_MOV_FAT" DATE,
    "IND_DET_PARC" VARCHAR2(2 BYTE),
    "TARIFARIO_S_N" VARCHAR2(1 BYTE),
    "VALOR_PERC_DET" NUMBER(15,5),
    "VALOR_LANC_DET" NUMBER(20,7),
    "VALOR_PERC_TI_DET" NUMBER(15,5),
    "VALOR_LANC_TI_DET" NUMBER(20,7)
   )
partition by range (COD_RAMO) SUBPARTITION by range (DT_MOV_FAT)
(
partition VT_LANC_LESS_100 values less THAN (100)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_100 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_100 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_100 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_100 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_100 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_100 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_100 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_100 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_200 values less THAN (200)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_200 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_200 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_200 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_200 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_200 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_200 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_200 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_200 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_300 values less THAN (300)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_300 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_300 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_300 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_300 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_300 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_300 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_300 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_300 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_400 values less THAN (400)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_400 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_400 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_400 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_400 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_400 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_400 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_400 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_400 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_500 values less THAN (500)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_500 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_500 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_500 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_500 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_500 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_500 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_500 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_500 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_600 values less THAN (600)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_600 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_600 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_600 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_600 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_600 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_600 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_600 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_600 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_700 values less THAN (700)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_700 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_700 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_700 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_700 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_700 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_700 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_700 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_700 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_800 values less THAN (800)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_800 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_800 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_800 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_800 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_800 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_800 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_800 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_800 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_900 values less THAN (900)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_900 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_900 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_900 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_900 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_900 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_900 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_900 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_900 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_1000 values less THAN (1000)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_1000 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_1000 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_1000 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_1000 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_1000 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_1000 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_1000 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_1000 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_1100 values less THAN (1100)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_1100 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_1100 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_1100 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_1100 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_1100 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_1100 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_1100 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_1100 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_1200 values less THAN (1200)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_1200 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_1200 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_1200 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_1200 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_1200 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_1200 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_1200 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_1200 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_1300 values less THAN (1300)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_1300 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_1300 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_1300 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_1300 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_1300 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_1300 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_1300 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_1300 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_1400 values less THAN (1400)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_1400 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_1400 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_1400 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_1400 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_1400 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_1400 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_1400 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_1400 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_LESS_1500 values less THAN (1500)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_LESS_2011_1500 values less THAN (TIMESTAMP' 2012-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2012_1500 values less THAN (TIMESTAMP' 2013-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2013_1500 values less THAN (TIMESTAMP' 2014-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2014_1500 values less THAN (TIMESTAMP' 2015-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2015_1500 values less THAN (TIMESTAMP' 2016-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2016_1500 values less THAN (TIMESTAMP' 2017-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2017_1500 values less THAN (TIMESTAMP' 2018-01-01 00:00:00'),
subpartition DT_MOVE_FAT_LESS_2018_1500 values less THAN (TIMESTAMP' 2019-01-01 00:00:00')
),
partition VT_LANC_MAXVALUE values less THAN (MAXVALUE)
TABLESPACE "TBS_DATA_SQLDBA_064M"
(
subpartition DT_MOVE_FAT_MAXVALUE values less THAN (MAXVALUE)
)
)TABLESPACE "TBS_DATA_SQLDBA_064M";

--Fazer o particionamento online (start processo)

  BEGIN
  DBMS_REDEFINITION.start_redef_table(
    uname      => 'SQLDBA',
    orig_table => 'VT_LANC_FAT_TRANSP_DET',
    int_table  => 'VT_LANC_FAT_TRANSP_DET_INTERIM',
    OPTIONS_FLAG=>DBMS_REDEFINITION.CONS_USE_ROWID);
  END;
  /

  --Adicionando grants, triggers, constraints, índices e privilégios


  var num_errors number

BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(uname      => 'SQLDBA',
                                            orig_table => 'VT_LANC_FAT_TRANSP_DET',
                                            int_table  => 'VT_LANC_FAT_TRANSP_DET_INTERIM',
                                            num_errors => :num_errors);
END;
/

print num_errors


--INDEX BITMAP Caso houver adicionar aqui, pois o redefinition não faz automatico

--Copiar dependentes

DECLARE
num_errors PLS_INTEGER;
BEGIN
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
   'SQLDBA','VT_LANC_FAT_TRANSP_DET','VT_LANC_FAT_TRANSP_DET_INTERIM',DBMS_REDEFINITION.CONS_ORIG_PARAMS,
    TRUE, TRUE, TRUE, TRUE, num_errors);
END;


--Manter sincronismo entre a tabela origianal e a particionada(Interina) até o finish_redef_table (final na troca de nomes)

BEGIN
DBMS_REDEFINITION.sync_interim_table(
    uname      => 'SQLDBA',
    orig_table => 'VT_LANC_FAT_TRANSP_DET',
    int_table  => 'VT_LANC_FAT_TRANSP_DET_INTERIM');
END;
/

--Coleta das Estatisticas da tabela

BEGIN
DBMS_STATS.GATHER_TABLE_STATS(ownname          => 'SQLDBA',
                                TABNAME          => 'VT_LANC_FAT_TRANSP_DET_INTERIM',
                                estimate_percent => 100,
                                method_opt       => 'FOR ALL COLUMNS SIZE 1',
                                degree           => 16,
                                granularity      => 'ALL',
                                cascade          => TRUE);
END;
/

--Trocar nomes das tabelas (fim processo)

BEGIN
   DBMS_REDEFINITION.finish_redef_table(
     uname      => 'SQLDBA',
     orig_table => 'VT_LANC_FAT_TRANSP_DET',
     int_table  => 'VT_LANC_FAT_TRANSP_DET_INTERIM');
 END;
 /

 --Verificar se as contraints, indices estão iguais

select constraint_name,constraint_type, status
from user_constraints
where table_name='VT_LANC_FAT_TRANSP_DET';

--indices

select index_name,status
from user_indexes
where table_name='VT_LANC_FAT_TRANSP_DET';

--partições criadas

select table_name, partition_name, num_rows
from dba_tab_partitions
where table_name='VT_LANC_FAT_TRANSP_DET';


--Após trocar de nome as tabelas recompilar todos os objetos inválidos

--Confirmar se todas as dependencias estão ok

--Verificar se os comentários estão ok

--caso der algum problema antes do finish, pode ser cancelado tudo que foi feito com 


DBMS_REDEFINITION.ABORT_REDEF_TABLE (
   uname       IN VARCHAR2,
   orig_table  IN VARCHAR2,
   int_table   IN VARCHAR2,
  part_name    IN  VARCHAR2 := NULL);

--e 

DBMS_REDEFINITION.CAN_REDEF_TABLE (
   uname         IN  VARCHAR2,
   tname        IN  VARCHAR2,
   options_flag  IN  PLS_INTEGER := 1,
   part_name     IN  VARCHAR2 := NULL);
