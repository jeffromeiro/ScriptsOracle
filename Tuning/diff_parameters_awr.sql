select b.instance_number ,b.parameter_name, b.value, e.value
         from dba_hist_parameter b
            , dba_hist_parameter e
        where b.snap_id         = &snap_inicial --9516
		  and e.snap_id = 	    &snap_final --13243
		  --and b.instance_number = 1
          and b.parameter_hash  = e.parameter_hash
		  and b.parameter_name = e.parameter_name
		  and b.instance_number = e.instance_number
		  and b.value <> e.value
		  order by 1;