column sum         for 9999999999 head 'Total #| Rows'
column cnt         for 9999999999 head 'Total #| Dist Values'
column bsel        for 999999     head 'Min #| of Rows'
column avgsel      for 999999     head 'Avg #| of Rows'
column wsel        for 9999999    head 'Max #| of Rows'
column bsel_perc   for 999999.99  head 'Best|Selectivity [%]'
column avgsel_perc for 999999.99  head 'Avg|Selectivity [%]'
column wsel_perc   for 999999.99  head 'Worst|Selectivity [%]'

select	sum(a) sum,
	count(a) cnt,
	min(a) bsel,
	round(avg(a),1) avgsel,
	max(a) wsel,
	round(min(a)/sum(a)*100,2) as bsel_perc,
	round(avg(a)/sum(a)*100,2) as avgsel_perc,
	round(max(a)/sum(a)*100,2) as wsel_perc
from (select count(*) a from "&owner"."&table" group by &column);


