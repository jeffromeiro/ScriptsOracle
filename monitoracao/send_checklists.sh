# Script que envia os checklists por email
# Data: 04/03/2010
# Criado por Jefferson Romeiro
# Atos Origin


rm /home/oracle/chklist/log/checklists.txt

echo "Chamado para a Equipe AO Professional Services - ICT Compliance - Security Management" >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo "Cliente Sodexo" >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo "Favor verificar os checklists 3151 e 3152" >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo "Checklist 3151 - Sem logon por 60 dias no PROD" >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
cat /home/oracle/chklist/log/checklist_3151_prod.lst >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt

echo "Checklist 3152 - Conta em lock por 30 dias no PROD " >> /home/oracle/chklist/log/checklists.txt
cat /home/oracle/chklist/log/checklist_3152_prod.lst >>  /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt
echo ""  >> /home/oracle/chklist/log/checklists.txt

/bin/mailx -s "Checklists PROD - [AO Professional Services - ICT Compliance - Security Management] " "jefferson.romeiro@atosorigin.com breno.tozo@atosorigin.com roberto.veiga@atosorigin.com vera.rodrigues@atosorigin.com debora.valente@atosorigin.com mario.macedo@atosorigin.com marcio.santos@atosorigin.com " <  /home/oracle/chklist/log/checklists.txt

