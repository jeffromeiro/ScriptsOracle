select name||' = '||value 
from v$sysstat 
where name = 'redo log space requests'
/ 
 
prompt 
prompt Esse valor deve ser perto de 0. Caso este valor aumente constantemente
prompt alguns processos podem esperar at� que exista espa�o livre na LOG_BUFFER.
prompt Caso isto ocorra frequentemente, recomenda-se aumentar o par�metro LOG_BUFFER.
prompt