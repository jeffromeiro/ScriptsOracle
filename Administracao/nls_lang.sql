SET SERVEROUTPUT ON SIZE 1000000
declare
nls_1 varchar (20);
nls_2 varchar (20);
nls_3 varchar (20);
so varchar (100);
begin
select banner into so from v$version
where banner like '%TNS%';
                select value INTO nls_1
from nls_database_parameters
where parameter in ('NLS_CHARACTERSET');
select value INTO nls_3
from nls_database_parameters
where parameter in ('NLS_TERRITORY');
select value INTO nls_2
from nls_database_parameters
where parameter in ('NLS_LANGUAGE');
if so  like '%Win%' then
dbms_output.put_line('set NLS_LANG='||nls_2||'_'||nls_3||'.'||nls_1);
else
dbms_output.put_line('export NLS_LANG='||nls_2||'_'||nls_3||'.'||nls_1);
end if;
end;
/
