#!/bin/sh
# ---------------------------------------------------------------------------
#                       hot_bkp_hsa_prd_full_m.sh
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Determine the user which is executing this script.
# ---------------------------------------------------------------------------

CUSER=`id |cut -d"(" -f2 | cut -d ")" -f1`

# ---------------------------------------------------------------------------
# Define the log file and delete so that backup information does
# not accumulate.
# ---------------------------------------------------------------------------

DH=`date +%Y%m%d-%H%M`
RMAN_LOG_FILE=/db00/oracle/app/product/9.2.0/scripts/logs/hot_bkp_hsa_prd_mensal_$DH.log

if [ -f "$RMAN_LOG_FILE" ]
then
    rm -f "$RMAN_LOG_FILE"
fi

# -----------------------------------------------------------------
# Initialize the log file.
# -----------------------------------------------------------------

echo >> $RMAN_LOG_FILE
chmod 666 $RMAN_LOG_FILE

# ---------------------------------------------------------------------------
# Log the start of this script.
# ---------------------------------------------------------------------------

echo Script $0 >> $RMAN_LOG_FILE
echo ==== started on `date` ==== >> $RMAN_LOG_FILE
echo >> $RMAN_LOG_FILE

ORACLE_USER=oracle

ORACLE_HOME=/db00/oracle/app/product/9.2.0
export ORACLE_HOME
RMAN=$ORACLE_HOME/bin/rman

# ---------------------------------------------------------------------------
# Set the target and catalog connect string.
# ---------------------------------------------------------------------------

CATALOG_TNS="@rmancat"
CATALOG_USER="bungehsa_prd/bungehsa_prd"
TARGET_TNS=""
TARGET_USER="/"

# ---------------------------------------------------------------------------
# Set the NetBackup variables (Optional)
# ---------------------------------------------------------------------------

if [ "x$NB_ORA_POLICY" = "x" ]
then
  POLICY_NAME="bnge_bge2_db_ora_hsa_prd_hot_full_men"
else
  POLICY_NAME=$NB_ORA_POLICY
fi

if [ "x$NB_ORA_SCHED" = "x" ]
then
  SCHED_NAME="Default-Application-hsa_prd-db-full-men"
else
  SCHED_NAME=$NB_ORA_SCHED
fi

# ---------------------------------------------------------------------------
# Print out the value of the variables set by this script.
# ---------------------------------------------------------------------------

echo >> $RMAN_LOG_FILE
echo "RMAN: $RMAN" >> $RMAN_LOG_FILE
echo "ORACLE_USER: $ORACLE_USER" >> $RMAN_LOG_FILE
echo "ORACLE_HOME: $ORACLE_HOME" >> $RMAN_LOG_FILE
echo "CATALOG_TNS: $CATALOG_TNS" >> $RMAN_LOG_FILE
echo " TARGET_TNS: $TARGET_TNS"  >> $RMAN_LOG_FILE

# ---------------------------------------------------------------------------
# Print out the value of the variables set by bphdb.
# ---------------------------------------------------------------------------

echo >> $RMAN_LOG_FILE
echo "NB_ORA_FULL: $NB_ORA_FULL" >> $RMAN_LOG_FILE
echo "NB_ORA_INCR: $NB_ORA_INCR" >> $RMAN_LOG_FILE
echo "NB_ORA_CINC: $NB_ORA_CINC" >> $RMAN_LOG_FILE
echo "NB_ORA_SERV: $NB_ORA_SERV" >> $RMAN_LOG_FILE
echo "NB_ORA_POLICY: $POLICY_NAME" >> $RMAN_LOG_FILE
echo "NB_ORA_SCHED : $SCHED_NAME"  >> $RMAN_LOG_FILE

echo >> $RMAN_LOG_FILE

if [ "$NB_ORA_FULL" = "1" ]
then
    echo "Full backup requested" >> $RMAN_LOG_FILE
    BACKUP_TYPE="INCREMENTAL LEVEL=0"

elif [ "$NB_ORA_INCR" = "1" ]
then
    echo "Differential incremental backup requested" >> $RMAN_LOG_FILE
    BACKUP_TYPE="INCREMENTAL LEVEL=1"

elif [ "$NB_ORA_CINC" = "1" ]
then
    echo "Cumulative incremental backup requested" >> $RMAN_LOG_FILE
    BACKUP_TYPE="INCREMENTAL LEVEL=1 CUMULATIVE"

elif [ "$BACKUP_TYPE" = "" ]
then
    echo "Default - Full backup requested" >> $RMAN_LOG_FILE
    BACKUP_TYPE="INCREMENTAL LEVEL=0"
fi

CMD_STR="
ORACLE_HOME=$ORACLE_HOME
export ORACLE_HOME
ORACLE_SID=hsa_prd
export ORACLE_SID
$RMAN target ${TARGET_USER}${TARGET_TNS} catalog ${CATALOG_USER}${CATALOG_TNS} msglog ${RMAN_LOG_FILE} append << EOF
RUN {
ALLOCATE CHANNEL ch00 TYPE 'SBT_TAPE';
ALLOCATE CHANNEL ch01 TYPE 'SBT_TAPE';
send 'NB_ORA_POLICY=$POLICY_NAME';
send 'NB_ORA_SCHED=$SCHED_NAME';
sql 'alter session set optimizer_mode=rule';
BACKUP
    $BACKUP_TYPE
    SKIP INACCESSIBLE
    FILESPERSET 40
    FORMAT 'bkp_dbf_%s_%p_%t'
    DATABASE;
    sql 'alter system archive log current';
RELEASE CHANNEL ch00;
RELEASE CHANNEL ch01;
ALLOCATE CHANNEL ch00 TYPE 'SBT_TAPE';
send 'NB_ORA_POLICY=$POLICY_NAME';
send 'NB_ORA_SCHED=$SCHED_NAME';
sql 'alter session set optimizer_mode=rule';
BACKUP
    FILESPERSET 30
    FORMAT 'bkp_arch_%s_%p_%t'
    ARCHIVELOG ALL DELETE INPUT;
    #ARCHIVELOG ALL;
RELEASE CHANNEL ch00;
ALLOCATE CHANNEL ch00 TYPE 'SBT_TAPE';
send 'NB_ORA_POLICY=$POLICY_NAME';
send 'NB_ORA_SCHED=$SCHED_NAME';
BACKUP
    FORMAT 'bkp_cntrl_%s_%p_%t'
    CURRENT CONTROLFILE;
RELEASE CHANNEL ch00;
ALLOCATE CHANNEL ch00 TYPE 'SBT_TAPE';
send 'NB_ORA_POLICY=$POLICY_NAME';
send 'NB_ORA_SCHED=$SCHED_NAME';
BACKUP
    FORMAT 'bkp_spfile_%s_%p_%t'
    SPFILE;
RELEASE CHANNEL ch00;
sql 'alter system archive log current';
}
EOF
"

# Initiate the command string

if [ "$CUSER" = "root" ]
then
    su - $ORACLE_USER -c "$CMD_STR" >> $RMAN_LOG_FILE
    RSTAT=$?
else
    /bin/sh -c "$CMD_STR" >> $RMAN_LOG_FILE
    RSTAT=$?
fi

# ---------------------------------------------------------------------------
# Log the completion of this script.
# ---------------------------------------------------------------------------

if [ "$RSTAT" = "0" ]
then
    LOGMSG="ended successfully"
else
    LOGMSG="ended in error"
fi

echo >> $RMAN_LOG_FILE
echo Script $0 >> $RMAN_LOG_FILE
echo ==== $LOGMSG on `date` ==== >> $RMAN_LOG_FILE
echo >> $RMAN_LOG_FILE

exit $RSTAT
