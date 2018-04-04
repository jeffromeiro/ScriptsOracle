#!/bin/bash
#
# Script para compactar traces mais velhos que 1 dia
# Data: 15/03/2010
# Criado por Jefferson Romeiro
# Atos Origin


PATH=/usr/bin:/usr/ccs/bin:/usr/contrib/bin:/usr/contrib/Q4/bin:/opt/perl/bin:/opt/ipf/bin:/opt/hparray/bin:/opt/nettladm/bin:/opt/fcms/bin:/opt/sas/bin:/opt/wbem/bin:/opt/wbem/sbin:/usr/bin/X11:/opt/resmon/bin:/usr/contrib/kwdb/bin:/opt/graphics/common/bin:/opt/sfm/bin:/opt/hpsmh/bin:/opt/upgrade/bin:/opt/gvsd/bin:/opt/sec_mgmt/bastille/bin:/opt/drd/bin:/opt/dsau/bin:/opt/dsau/sbin:/opt/firefox:/opt/gnome/bin:/opt/ignite/bin:/opt/mozilla:/opt/perl_32/bin:/opt/perl_64/bin:/opt/sec_mgmt/spc/bin:/opt/ssh/bin:/opt/swa/bin:/opt/thunderbird:/opt/gwlm/bin:/usr/contrib/bin/X11:/opt/cfg2html:/opt/hp-gcc/bin:/opt/networker/bin:/usr/local/bin:/usr/local/sbin:/nsm/atech/services/bin:/nsm/atech/services/tools:/nsm/atech/agents/bin:/oracle/product/102/db_1/bin:/oracle/product/102/asm_1/bin:/home/oracle/bin:i/usr/bin:.
export PATH
export ORACLE_SID=$1


find /oracle/product/102/admin/$1/udump/ -ctime +1 |awk '{print "gzip -f ",$1}' > /oracle/product/102/admin/$1/udump/gzip_$1_udump.sh
sh /oracle/product/102/admin/$1/udump/gzip_$1_udump.sh

find /oracle/product/102/admin/$1/bdump/ -ctime +1 |awk '{print "gzip -f ",$1}' > /oracle/product/102/admin/$1/bdump/gzip_$1_bdump.sh
sh /oracle/product/102/admin/$1/bdump/gzip_$1_bdump.sh

find /oracle/product/102/admin/$1/bdump/ -mtime +30 |awk '{print "rm ",$1}' > /oracle/product/102/admin/$1/bdump/rm_$1_bdump.sh
sh /oracle/product/102/admin/$1/bdump/rm_$1_bdump.sh

find /oracle/product/102/admin/$1/udump/ -mtime +30 |awk '{print "rm ",$1}' > /oracle/product/102/admin/$1/udump/rm_$1_udump.sh
sh /oracle/product/102/admin/$1/udump/rm_$1_udump.sh

