WITH t_raw AS
  ( SELECT TO_CHAR(b.end_interval_time,'DD/MM/YYYY HH24:MI') snap_time,
           tsname,
           '[' || file# || ']...' || SUBSTR(REPLACE(a.filename,'\','/'),INSTR(REPLACE(a.filename,'\','/'),'/',-1),LENGTH(REPLACE(a.filename,'\','/'))) filename,
           filename full_filename,
           block_size,
           phyrds phy_reads,
           phywrts phy_writes,
           phyblkrd blocks_read,
           phyblkwrt blocks_written,
           readtim*10 time_spent_reads_ms,
           writetim*10 time_spent_writes_ms,
           ROUND((readtim*10)/DECODE(SIGN(phyrds),NULL,1,-1,1,0,1,phyrds)) avg_time_per_read_ms,
           ROUND((writetim*10)/DECODE(SIGN(phywrts),NULL,1,-1,1,0,1,phywrts)) avg_time_per_write_ms,
           ROUND(phyblkrd/DECODE(SIGN(phyrds),NULL,1,-1,1,0,1,phyrds)) avg_blocks_per_read,
           ROUND(phyblkwrt/DECODE(SIGN(phywrts),NULL,1,-1,1,0,1,phywrts)) avg_blocks_per_write,           
           DECODE(b.startup_time,LAG(b.startup_time) OVER (PARTITION BY b.instance_number ORDER BY b.snap_id),NULL,'X') restart
      FROM dba_hist_filestatxs a,
           dba_hist_snapshot b
     WHERE a.snap_id BETWEEN 3844 AND 3845
       AND a.instance_number = b.instance_number
       AND a.snap_id = b.snap_id 
       AND a.dbid = b.dbid   
       AND 1=1           
     ORDER BY TO_DATE(snap_time, 'DD/MM/YYYY HH24:MI')  ),
  t_lag AS (     
SELECT snap_time,
       tsname,
       filename,
       block_size,
       phy_reads,
       phy_writes,
       blocks_read,
       blocks_written,
       time_spent_reads_ms,
       time_spent_writes_ms,
       phy_reads - LAG(phy_reads,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_phy_reads,
       phy_writes - LAG(phy_writes,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_phy_writes,
       blocks_read - LAG(blocks_read,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_blocks_read,
       blocks_written - LAG(blocks_written,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_blocks_written,
       time_spent_reads_ms - LAG(time_spent_reads_ms,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_time_spent_reads_ms,
       time_spent_writes_ms - LAG(time_spent_writes_ms,1) OVER (PARTITION BY full_filename ORDER BY snap_time) l_time_spent_writes_ms,      
       restart
  FROM t_raw ),
  t_io AS (  
SELECT snap_time,
       tsname,
       filename,
       DECODE(SIGN(l_phy_reads),-1,phy_reads, l_phy_reads) phy_reads,
       DECODE(SIGN(l_phy_writes),-1,phy_writes, l_phy_writes) phy_writes,
       DECODE(SIGN(l_blocks_read),-1,blocks_read, l_blocks_read) blocks_read,
       DECODE(SIGN(l_blocks_written),-1,blocks_written, l_blocks_written) blocks_written,
       DECODE(SIGN(l_time_spent_reads_ms),-1,time_spent_reads_ms, l_time_spent_reads_ms) time_spent_reads_ms,
       DECODE(SIGN(l_time_spent_writes_ms),-1,time_spent_writes_ms, l_time_spent_writes_ms) time_spent_writes_ms,      
       ROUND(DECODE(SIGN(l_time_spent_reads_ms),-1,time_spent_reads_ms, l_time_spent_reads_ms)/DECODE(SIGN(l_phy_reads),NULL,1,-1,DECODE(phy_reads,NULL,1,0,1,phy_reads),0,1,l_phy_reads)) avg_time_per_read_ms,
       ROUND(DECODE(SIGN(l_time_spent_writes_ms),-1,time_spent_writes_ms, l_time_spent_writes_ms)/DECODE(SIGN(l_phy_writes),NULL,1,-1,DECODE(phy_writes,NULL,1,0,1,phy_writes),0,1,l_phy_writes)) avg_time_per_write_ms,
       ROUND(DECODE(SIGN(l_blocks_read),-1,blocks_read, l_blocks_read)/DECODE(SIGN(l_phy_reads),NULL,1,-1,DECODE(phy_reads,NULL,1,0,1,phy_reads),0,1,l_phy_reads)) avg_blocks_per_read,
       ROUND(DECODE(SIGN(l_blocks_written),-1,blocks_written, l_blocks_written)/DECODE(SIGN(l_phy_writes),NULL,1,-1,DECODE(phy_writes,NULL,1,0,1,phy_writes),0,1,l_phy_writes)) avg_blocks_per_write
  FROM t_lag
 ORDER BY TO_DATE(snap_time,'DD/MM/YYYY HH24:MI'), filename )

SELECT *
  FROM t_io