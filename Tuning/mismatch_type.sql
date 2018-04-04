SELECT sql_id,inst_id,child_number,
    nonshared_reason,
    COUNT(                                                                *)
  FROM Gv$sql_shared_cursor unpivot (nonshared_value FOR nonshared_reason IN ( UNBOUND_CURSOR AS 'UNBOUND_CURSOR', SQL_TYPE_MISMATCH AS 'SQL_TYPE_MISMATCH', OPTIMIZER_MISMATCH AS 'OPTIMIZER_MISMATCH', OUTLINE_MISMATCH AS 'OUTLINE_MISMATCH', STATS_ROW_MISMATCH AS 'STATS_ROW_MISMATCH', LITERAL_MISMATCH AS 'LITERAL_MISMATCH', FORCE_HARD_PARSE AS 'FORCE_HARD_PARSE', EXPLAIN_PLAN_CURSOR AS 'EXPLAIN_PLAN_CURSOR', BUFFERED_DML_MISMATCH AS 'BUFFERED_DML_MISMATCH', PDML_ENV_MISMATCH AS 'PDML_ENV_MISMATCH', INST_DRTLD_MISMATCH AS 'INST_DRTLD_MISMATCH', SLAVE_QC_MISMATCH AS 'SLAVE_QC_MISMATCH', TYPECHECK_MISMATCH AS 'TYPECHECK_MISMATCH', AUTH_CHECK_MISMATCH AS 'AUTH_CHECK_MISMATCH', BIND_MISMATCH AS 'BIND_MISMATCH', DESCRIBE_MISMATCH AS 'DESCRIBE_MISMATCH', LANGUAGE_MISMATCH AS 'LANGUAGE_MISMATCH', TRANSLATION_MISMATCH AS 'TRANSLATION_MISMATCH', BIND_EQUIV_FAILURE AS 'BIND_EQUIV_FAILURE', INSUFF_PRIVS AS 'INSUFF_PRIVS', INSUFF_PRIVS_REM AS 'INSUFF_PRIVS_REM', REMOTE_TRANS_MISMATCH AS
    'REMOTE_TRANS_MISMATCH', LOGMINER_SESSION_MISMATCH                                       AS 'LOGMINER_SESSION_MISMATCH', INCOMP_LTRL_MISMATCH AS 'INCOMP_LTRL_MISMATCH', OVERLAP_TIME_MISMATCH AS 'OVERLAP_TIME_MISMATCH', EDITION_MISMATCH AS 'EDITION_MISMATCH', MV_QUERY_GEN_MISMATCH AS 'MV_QUERY_GEN_MISMATCH', USER_BIND_PEEK_MISMATCH AS 'USER_BIND_PEEK_MISMATCH', TYPCHK_DEP_MISMATCH AS 'TYPCHK_DEP_MISMATCH', NO_TRIGGER_MISMATCH AS 'NO_TRIGGER_MISMATCH', FLASHBACK_CURSOR AS 'FLASHBACK_CURSOR', ANYDATA_TRANSFORMATION AS 'ANYDATA_TRANSFORMATION', PDDL_ENV_MISMATCH AS 'PDDL_ENV_MISMATCH', TOP_LEVEL_RPI_CURSOR AS 'TOP_LEVEL_RPI_CURSOR', DIFFERENT_LONG_LENGTH AS 'DIFFERENT_LONG_LENGTH', LOGICAL_STANDBY_APPLY AS 'LOGICAL_STANDBY_APPLY', DIFF_CALL_DURN AS 'DIFF_CALL_DURN', BIND_UACS_DIFF AS 'BIND_UACS_DIFF', PLSQL_CMP_SWITCHS_DIFF AS 'PLSQL_CMP_SWITCHS_DIFF', CURSOR_PARTS_MISMATCH AS 'CURSOR_PARTS_MISMATCH', STB_OBJECT_MISMATCH AS 'STB_OBJECT_MISMATCH', CROSSEDITION_TRIGGER_MISMATCH AS
    'CROSSEDITION_TRIGGER_MISMATCH', PQ_SLAVE_MISMATCH                                       AS 'PQ_SLAVE_MISMATCH', TOP_LEVEL_DDL_MISMATCH AS 'TOP_LEVEL_DDL_MISMATCH', MULTI_PX_MISMATCH AS 'MULTI_PX_MISMATCH', BIND_PEEKED_PQ_MISMATCH AS 'BIND_PEEKED_PQ_MISMATCH', MV_REWRITE_MISMATCH AS 'MV_REWRITE_MISMATCH', ROLL_INVALID_MISMATCH AS 'ROLL_INVALID_MISMATCH', OPTIMIZER_MODE_MISMATCH AS 'OPTIMIZER_MODE_MISMATCH', PX_MISMATCH AS 'PX_MISMATCH', MV_STALEOBJ_MISMATCH AS 'MV_STALEOBJ_MISMATCH', FLASHBACK_TABLE_MISMATCH AS 'FLASHBACK_TABLE_MISMATCH', LITREP_COMP_MISMATCH AS 'LITREP_COMP_MISMATCH', PLSQL_DEBUG AS 'PLSQL_DEBUG', LOAD_OPTIMIZER_STATS AS 'LOAD_OPTIMIZER_STATS', ACL_MISMATCH AS 'ACL_MISMATCH', FLASHBACK_ARCHIVE_MISMATCH AS 'FLASHBACK_ARCHIVE_MISMATCH', LOCK_USER_SCHEMA_FAILED AS 'LOCK_USER_SCHEMA_FAILED', REMOTE_MAPPING_MISMATCH AS 'REMOTE_MAPPING_MISMATCH', LOAD_RUNTIME_HEAP_FAILED AS 'LOAD_RUNTIME_HEAP_FAILED', HASH_MATCH_FAILED AS 'HASH_MATCH_FAILED', PURGED_CURSOR AS
    'PURGED_CURSOR', BIND_LENGTH_UPGRADEABLE                                                 AS 'BIND_LENGTH_UPGRADEABLE', USE_FEEDBACK_STATS AS 'USE_FEEDBACK_STATS'))
  WHERE nonshared_value = 'Y'
  --and sql_id ='&sql_id'
  GROUP BY sql_id,inst_id,child_number,
    nonshared_reason order by count(*) desc;