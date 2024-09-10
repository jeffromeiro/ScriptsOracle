--> PROCESSO PARA COLETAR ESTATÍSTICAS DO BANCO



-- Cria programs para coletar estatísticas do database
BEGIN
  DBMS_SCHEDULER.create_program(
  program_name => 'DB_STATS_PROGRAM',
  program_type => 'PLSQL_BLOCK',
  program_action => 'BEGIN DBMS_STATS.gather_database_stats; END;',
  enabled => TRUE,
  comments => 'Program to gather database statistics');
  DBMS_SCHEDULER.enable (name=>'db_stats_program');
END;
/

-- Criar schedules para cada coleta

BEGIN
  dbms_scheduler.CREATE_SCHEDULE( 
  schedule_name => 'database_stats_sched',
  start_date => SYSTIMESTAMP,
  repeat_interval => 'FREQ=DAILY; BYDAY=SAT; BYHOUR=4',
  end_date => NULL,
  comments => 'Run every mon at 04');
END;

-- Criar o job para a coleta

BEGIN
DBMS_SCHEDULER.create_job (
  job_name => 'db_stats_program_job',
  program_name => 'db_stats_program',
  schedule_name => 'database_stats_sched',
  enabled => TRUE,
  comments => 'job que coleta estatisticas do banco');
END;
/
#################################################################################
===============================================

--CRIA PROCESSO PARA COLETAR ESTATÍSTICAS DE SYSTEMA

-- Cria programs para coletar estatísticas de sistema

BEGIN
  DBMS_SCHEDULER.create_program(
  program_name => 'system_stats_program',
  program_type => 'PLSQL_BLOCK',
  program_action => 'BEGIN DBMS_STATS.gather_system_stats; END;',
  enabled => TRUE,
  comments => 'Program to gather system statistics');
  DBMS_SCHEDULER.enable (name=>'system_stats_program');
END;
/

 --Criar schedules para coleta
 
BEGIN
  dbms_scheduler.CREATE_SCHEDULE( 
  schedule_name => 'database_system_stats_sched',
  start_date => SYSTIMESTAMP,
  repeat_interval => 'FREQ=DAILY; BYDAY=SUN; BYHOUR=4',
  end_date => NULL,
  comments => 'Run every SUN at 04');
END;


-- Criar o job para coleta

BEGIN
DBMS_SCHEDULER.create_job (
  job_name => 'system_stat_program_job',
  program_name => 'system_stats_program',
  schedule_name => 'database_system_stats_sched',
  enabled => TRUE,
  comments => 'job que coleta estatisticas de sistema do banco');
END;
/

#################################################################################


--CRIA PROCESSO PARA COLETAR ESTATÍSTICAS DE FIXED OBJECTS

 --Criar program para coleta

BEGIN
  DBMS_SCHEDULER.create_program(
  program_name => 'fixed_objects_stats_program',
  program_type => 'PLSQL_BLOCK',
  program_action => 'BEGIN DBMS_STATS.gather_fixed_objects_stats; END;',
  enabled => TRUE,
  comments => 'Program to gather fixed object statistics');
  DBMS_SCHEDULER.enable (name=>'fixed_objects_stats_program');
END;
/

 --Criar schedules para coleta

BEGIN
  dbms_scheduler.CREATE_SCHEDULE( 
  schedule_name => 'database_fixed_obj_stats_sched',
  start_date => SYSTIMESTAMP,
  repeat_interval => 'FREQ=DAILY; BYDAY=SUN; BYHOUR=6',
  end_date => NULL,
  comments => 'Run every SUN at 06');
END;

-- Criar o job para coleta

BEGIN
DBMS_SCHEDULER.create_job (
  job_name => 'fixed_objects_program_job',
  program_name => 'fixed_objects_stats_program',
  schedule_name => 'database_fixed_obj_stats_sched',
  enabled => TRUE,
  comments => 'job que coleta estatisticas de sistema do banco');
END;
/


#################################################################################
--CRIA PROCESSO PARA COLETAR ESTATÍSTICAS DO DICIONÁRIO DE DADOS


BEGIN
  DBMS_SCHEDULER.create_program(
  program_name => 'dictionary_stats_program',
  program_type => 'PLSQL_BLOCK',
  program_action => 'BEGIN DBMS_STATS.gather_system_stats; END;',
  enabled => TRUE,
  comments => 'Program to gather dictionary statistics');
  DBMS_SCHEDULER.enable (name=>'dictionary_stats_program');
END;
/

 --Criar schedules para coleta

BEGIN
  dbms_scheduler.CREATE_SCHEDULE( 
  schedule_name => 'database_dictionary_stats_sched',
  start_date => SYSTIMESTAMP,
  repeat_interval => 'FREQ=DAILY; BYDAY=SUN; BYHOUR=8',
  end_date => NULL,
  comments => 'Run every SUN at 08');
END;

 --Criar job para coleta

BEGIN
DBMS_SCHEDULER.create_job (
  job_name => 'dictionary_stats_program_job',
  program_name => 'dictionary_stats_program',
  schedule_name => 'database_dictionary_stats_sched',
  enabled => TRUE,
  comments => 'job que coleta estatisticas de sistema do banco');
END;
/


