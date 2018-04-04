prompt 
prompt Atentar para as colunas gethitratio e pinhit ratio 
prompt 
prompt GETHITRATIO é o número de GETHTS/GETS 
prompt PINHIT RATIO é o numero de PINHITS/PINS 
prompt Ambos devem se aproximar de "1"
 
column namespace format a20 heading 'NAME'
column gets format 99999999 heading 'GETS'
column gethits format 99999999 heading 'GETHITS'
column gethitratio format 999.99 heading 'GET HIT|RATIO'
column pins format 99999999 heading 'PINHITS'
column pinhitratio format 999.99 heading 'PIN HIT|RATIO'
 
select namespace, gets, gethits, 
gethitratio, pins, pinhitratio 
from v$librarycache ;

select ((1 - (Sum(GetMisses) / (Sum(Gets) + Sum(GetMisses)))) * 100) "Hit Rate"
from V$RowCache
where Gets + GetMisses <> 0;
