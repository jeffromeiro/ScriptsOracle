
-- -----------------------------------------------------------
-- verifica se a coleta de estatistica esta utilizando stale
-- -----------------------------------------------------------
clear breaks
clear computes
set pages 1200 lin 400 trimspool on
break on own on report

select u.name own
     , o.name tab
  from mon_mods$ m 
     , tab$  t
     , obj$  o
     , user$ u
 where m.obj#=t.obj# 
   and t.obj# = o.obj#
   and o.owner# = u.user# 
   and bitand(t.flags,16) =16
   and ((bitand(m.flags,1) =1)
    or ((m.inserts+m.updates+m.deletes) > (.1* t.rowcnt)))
 order by own, tab;
 
clear breaks
clear computes