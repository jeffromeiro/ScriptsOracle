-- Modified version of Dion Cho's script - http://dioncho.wordpress.com/?s=v%24sql_shared_cursor
--
-- Modified by Kerry Osborne
-- I just changed the output columns (got rid of sql_text and address columns and added last_load_time)
-- I also ordered the output by last_load_time.
-- 
declare
  c         number;
  col_cnt   number;
  col_rec   dbms_sql.desc_tab;
  col_value varchar2(4000);
  ret_val    number;
begin
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c,
      'select q.sql_text, q.last_load_time, s.*
      from v$sql_shared_cursor s, v$sql q
      where s.sql_id = q.sql_id
          and s.child_number = q.child_number
          and q.sql_id like ''&sql_id''
      order by last_load_time',
      dbms_sql.native);
  dbms_sql.describe_columns(c, col_cnt, col_rec);

  for idx in 1 .. col_cnt loop
    dbms_sql.define_column(c, idx, col_value, 4000);
  end loop;

  ret_val := dbms_sql.execute(c);

  while(dbms_sql.fetch_rows(c) > 0) loop
    for idx in 1 .. col_cnt loop
      dbms_sql.column_value(c, idx, col_value);
      if col_rec(idx).col_name in ('SQL_ID', 'CHILD_NUMBER','LAST_LOAD_TIME') then
        dbms_output.put_line(rpad(col_rec(idx).col_name, 30) ||
                ' = ' || col_value);
      elsif col_value = 'Y' then
        dbms_output.put_line(rpad(col_rec(idx).col_name, 30) ||
                ' = ' || col_value);
      end if;

    end loop;

    dbms_output.put_line('--------------------------------------------------');

   end loop;

  dbms_sql.close_cursor(c);

end;
/
