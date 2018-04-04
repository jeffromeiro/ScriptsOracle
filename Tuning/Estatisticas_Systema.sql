-- SETANDO ESTATISTICAS DE SISTEMA MANUALMENTE

PROMPT
PROMPT
PROMPT EXEMPLO DE COMO SETAR AS ESTATISTICAS DE SISTEMA MANUALMENTE
PROMPT
PROMPT
PROMPT dbms_stats.gather_system_stats(gathering_mode => 'noworkload')
PROMPT
PROMPT

PROMPT
PROMPT
PROMPT EXEMPLO DE COMO SETAR AS ESTATISTICAS DE SISTEMA MANUALMENTE
PROMPT
PROMPT
PROMPT BEGIN
PROMPT   dbms_stats.delete_system_stats();
PROMPT   dbms_stats.set_system_stats(pname => 'CPUSPEED', pvalue => <valor>);
PROMPT   dbms_stats.set_system_stats(pname => 'SREADTIM', pvalue => <valor>);
PROMPT   dbms_stats.set_system_stats(pname => 'MREADTIM', pvalue => <valor>);
PROMPT   dbms_stats.set_system_stats(pname => 'MBRC', pvalue => <valor>);
PROMPT   dbms_stats.set_system_stats(pname => 'MAXTHR', pvalue => <valor>);
PROMPT   dbms_stats.set_system_stats(pname => 'SLAVETHR', pvalue => <valor>);
PROMPT END;


col pval2 form a40
SELECT pname, pval1, pval2
 FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_INFO';
 
 
 SELECT pname, pval1
 FROM sys.aux_stats$
 WHERE sname = 'SYSSTATS_MAIN';