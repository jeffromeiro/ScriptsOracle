spool /home/oracle/chklist/log/check_df_&1
set serveroutput on size 2000

declare
v_count   number(2);
v_name    v$database.name%type;
v_date    char(20);
cursor count is
select count(*) from v$datafile where status not in ('ONLINE','SYSTEM');

 cursor instance is
  select name from v$database;
  BEGIN
   open instance;
    fetch instance into v_name;

     open count;
      fetch count into v_count;


       if v_count>0 then
	  select to_char(sysdate, 'DDMMYYYY_HH24MISS') into v_date from dual;
	     dbms_output.put_line('BDORACLE_' || v_name || '_DF_OFF_'||v_date);
	       else
		  dbms_output.put_line('BDORACLE_' || v_name || '_DF_ON');
		   end if;

		    close count;
		     close instance;
		      END;
		      /

		      spool off

