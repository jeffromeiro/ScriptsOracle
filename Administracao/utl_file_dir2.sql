prompt
prompt Teste de UTL_FILE_DIR - v.0.1a
prompt
define dir_lido=&dir
define arq_lido=&arq
prompt
declare
 fhandler utl_file.file_type;
begin
 fhandler :=  UTL_FILE.FOPEN ( '&dir_lido', '&arq_lido', 'w' );
 UTL_FILE.PUT ( fhandler, to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss') );
 UTL_FILE.FCLOSE ( fhandler );
end;
/
