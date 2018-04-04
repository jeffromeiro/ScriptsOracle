# Script para coleta de dados sobre o ASM
# Data: 22/01/2010
# Criado por Marcio Santos
# Atos Origin

export       ORACLE_SID=+ASM1
export      ORACLE_BASE=/oracle/product/102
export         ASM_HOME=$ORACLE_BASE/asm_1
export      ORACLE_HOME=$ASM_HOME
export        TNS_ADMIN=$DB_HOME/network/admin
export      ORACLE_TERM=xterm
export  LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:$ORACLE_HOME/rdbms/lib:$ASM_HOME/lib:$ORA_CRS_HOME/lib
export             PATH=$PATH:$ORACLE_HOME/bin:$ORA_CRS_HOME/bin:$ASM_HOME/bin:$HOME/bin:i/usr/bin:.
export        CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib

export DATA=`date +%d/%m/%Y`

$ORACLE_HOME/bin/sqlplus -S <<EOF
conn / as sysdba
@/home/oracle/chklist/scripts/monitora_espaco_ASM.sql
EOF

/bin/mailx -s "Relatorio de Backup da base PROD em  $DATA" marcio.santos@atosorigin.com < /home/oracle/chklist/log/saida_PROD.log
