CREATE OR REPLACE PROCEDURE run_query(p_sql IN VARCHAR2
                                    ,p_dir IN VARCHAR2
                                    ,p_header_file IN VARCHAR2
                                    ,p_data_file IN VARCHAR2 := NULL) IS
  v_finaltxt  VARCHAR2(4000);
  v_v_val    VARCHAR2(4000);
  v_n_val    NUMBER;
  v_d_val    DATE;
  v_ret      NUMBER;
  c          NUMBER;
  d          NUMBER;
  col_cnt    INTEGER;
  f          BOOLEAN;
  rec_tab    DBMS_SQL.DESC_TAB;
  col_num    NUMBER;
  v_fh        UTL_FILE.FILE_TYPE;
  v_samefile  BOOLEAN := (NVL(p_data_file,p_header_file) = p_header_file);
BEGIN
  c := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(c, p_sql, DBMS_SQL.NATIVE);
  d := DBMS_SQL.EXECUTE(c);
  DBMS_SQL.DESCRIBE_COLUMNS(c, col_cnt, rec_tab);
  FOR j in 1..col_cnt
  LOOP
    CASE rec_tab(j).col_type
      WHEN 1 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_v_val,2000);
      WHEN 2 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_n_val);
      WHEN 12 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_d_val);
    ELSE
      DBMS_SQL.DEFINE_COLUMN(c,j,v_v_val,2000);
    END CASE;
  END LOOP;
  -- This part outputs the HEADER
  v_fh := UTL_FILE.FOPEN(upper(p_dir),p_header_file,'w',32767);
  FOR j in 1..col_cnt
  LOOP
    v_finaltxt := ltrim(v_finaltxt||','||lower(rec_tab(j).col_name),',');
  END LOOP;
  --  DBMS_OUTPUT.PUT_LINE(v_finaltxt);
  UTL_FILE.PUT_LINE(v_fh, v_finaltxt);
  IF NOT v_samefile THEN
    UTL_FILE.FCLOSE(v_fh);
  END IF;
  --
  -- This part outputs the DATA
  IF NOT v_samefile THEN
    v_fh := UTL_FILE.FOPEN(upper(p_dir),p_data_file,'w',32767);
  END IF;
  LOOP
    v_ret := DBMS_SQL.FETCH_ROWS(c);
    EXIT WHEN v_ret = 0;
    v_finaltxt := NULL;
    FOR j in 1..col_cnt
    LOOP
      CASE rec_tab(j).col_type
        WHEN 1 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_v_val);
                    v_finaltxt := ltrim(v_finaltxt||',"'||v_v_val||'"',',');
        WHEN 2 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_n_val);
                    v_finaltxt := ltrim(v_finaltxt||','||v_n_val,',');
        WHEN 12 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_d_val);
                    v_finaltxt := ltrim(v_finaltxt||','||to_char(v_d_val,'DD/MM/YYYY HH24:MI:SS'),',');
      ELSE
        DBMS_SQL.COLUMN_VALUE(c,j,v_v_val);
        v_finaltxt := ltrim(v_finaltxt||',"'||v_v_val||'"',',');
      END CASE;
    END LOOP;
  --  DBMS_OUTPUT.PUT_LINE(v_finaltxt);
    UTL_FILE.PUT_LINE(v_fh, v_finaltxt);
  END LOOP;
  UTL_FILE.FCLOSE(v_fh);
  DBMS_SQL.CLOSE_CURSOR(c);
END;
/
--exec run_query('select * from emp','TEST_DIR','output.csv');