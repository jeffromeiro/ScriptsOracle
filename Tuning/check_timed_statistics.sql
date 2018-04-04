select p.INST_ID, p.NAME, p.VALUE from gv$parameter p where p.name='timed_statistics';

select p.INST_ID, p.NAME, p.VALUE from gv$parameter p where p.name='statistics_level';