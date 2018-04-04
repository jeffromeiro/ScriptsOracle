select name||' = '||value 
from v$sysstat 
where name = 'redo log space requests'
/ 
 
prompt 
prompt Esse valor deve ser perto de 0. Caso este valor aumente constantemente
prompt alguns processos podem esperar até que exista espaço livre na LOG_BUFFER.
prompt Caso isto ocorra frequentemente, recomenda-se aumentar o parâmetro LOG_BUFFER.
prompt