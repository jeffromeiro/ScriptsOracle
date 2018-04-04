#!/bin/bash
## Script para dispara SQL's em todas as instancias
# Exemplo da linha de comando para disparar o script
#      
#
#########

PATH=/usr/bin:/usr/ccs/bin:/usr/contrib/bin:/usr/contrib/Q4/bin:/opt/perl/bin:/opt/ipf/bin:/opt/hparray/bin:/opt/nettladm/bin:/opt/fcms/bin:/opt/sas/bin:/opt/wbem/bin:/opt/wbem/sbin:/usr/bin/X11:/opt/resmon/bin:/usr/contrib/kwdb/bin:/opt/graphics/common/bin:/opt/sfm/bin:/opt/hpsmh/bin:/opt/upgrade/bin:/opt/gvsd/bin:/opt/sec_mgmt/bastille/bin:/opt/drd/bin:/opt/dsau/bin:/opt/dsau/sbin:/opt/firefox:/opt/gnome/bin:/opt/ignite/bin:/opt/mozilla:/opt/perl_32/bin:/opt/perl_64/bin:/opt/sec_mgmt/spc/bin:/opt/ssh/bin:/opt/swa/bin:/opt/thunderbird:/opt/gwlm/bin:/usr/contrib/bin/X11:/opt/cfg2html:/opt/hp-gcc/bin:/opt/networker/bin:/usr/local/bin:/usr/local/sbin:/nsm/atech/services/bin:/nsm/atech/services/tools:/nsm/atech/agents/bin:/oracle/product/102/db_1/bin:/oracle/product/102/asm_1/bin:/home/oracle/bin:i/usr/bin:.
export PATH

export DIR_INSTANCIA=/home/oracle/chklist/scripts/instances.txt
export DIR_SCRIPTS=/home/oracle/chklist/scripts


ORACLE_HOME=/oracle/product/102/db_1; export ORACLE_HOME
ORACLE_BASE=/oracle/product/102; export ORACLE_BASE
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1 ; export NLS_LANG
DT=$(date +%d%m%Y); export DT
rm  /home/oracle/chklist/log/dados*gauss04_*.txt


cat $DIR_INSTANCIA|grep -v \# | while read linha
do
export ORACLE_SID=$linha
    echo $linha
    $ORACLE_HOME/bin/sqlplus -s "/as sysdba" @$DIR_SCRIPTS/relatorio.sql linha
done

cat  /home/oracle/chklist/log/dadosPROD_gauss04_$DT_*.txt > /home/oracle/chklist/log/relatorio_gauss04.txt

cat /home/oracle/chklist/log/relatorio_gauss04.txt >> /home/oracle/chklist/log/envia_relatorio.txt
cat /home/oracle/chklist/log/relatorio_gauss12.txt >> /home/oracle/chklist/log/envia_relatorio.txt
cat /home/oracle/chklist/log/relatorio_gauss21.txt >> /home/oracle/chklist/log/envia_relatorio.txt
cat /home/oracle/chklist/log/relatorio_gauss05.txt >> /home/oracle/chklist/log/envia_relatorio.txt
cat /home/oracle/chklist/log/relatorio_gauss06.txt >> /home/oracle/chklist/log/envia_relatorio.txt


/bin/mailx -s "Relatorio de usuarios administrativos, default e contas de servico - sodexo " "jefferson.romeiro@atosorigin.com breno.tozo@atosorigin.com roberto.veiga@atosorigin.com vera.rodrigues@atosorigin.com debora.valente@atosorigin.com mario.macedo@atosorigin.com marcio.santos@atosorigin.com marcos.freire@atosorigin.com " < /home/oracle/chklist/log/envia_relatorio.txt 

mv /home/oracle/chklist/log/envia_relatorio.txt /home/oracle/chklist/log/envia_relatorio.txt..$DT
rm /home/oracle/chklist/log/relatorio_gauss*.txt
   
exit
