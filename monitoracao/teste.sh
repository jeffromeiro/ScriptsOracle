export DATA=`date +%d/%m/%Y`

/bin/mailx -s "Checklist 3152 - Conta em lock por 45 dias no PROD - $DATA" "jefferson.romeiro@atosorigin.com breno.tozo@atosorigin.com roberto.veiga@atosorigin.com vera.rodrigues@atosorigin.com debora.valente@atosorigin.com mario.macedo@atosorigin.com marcio.santos@atosorigin.com  " <  /home/oracle/chklist/log/checklist_3152_prod.lst

/bin/mailx -s "Checklist 3151 - Sem logon por 60 dias no PROD - $DATA" "jefferson.romeiro@atosorigin.com breno.tozo@atosorigin.com roberto.veiga@atosorigin.com vera.rodrigues@atosorigin.com debora.valente@atosorigin.com mario.macedo@atosorigin.com marcio.santos@atosorigin.com  " <  /home/oracle/chklist/log/checklist_3151_prod.lst

