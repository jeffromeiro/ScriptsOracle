======= 
Script: 
======= 
 
SET ECHO off 
REM NAME:   TFSFSSUM.SQL 
REM USAGE:"@path/tfsfssum" 
REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM  SELECT ON DBA_FREE_SPACE< DBA_DATA_FILES 
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Cary Millsap,  Oracle  Corporation      
REM    (c)1994 Oracle Corporation      
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Displays tablespace free space and fragmentation for each 
REM    tablespace,  Prints the total size, the amount of space available, 
REM    and a summary of freespace fragmentation in that tablespace. 
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM     
REM        Database Freespace Summary  
REM 
REM                       Free     Largest       Total      Available   Pct  
REM       Tablespace     Frags    Frag (KB)       (KB)         (KB)     Used 
REM    ---------------- -------- ------------ ------------ ------------ ----  
REM    DES2                    1       30,210    40,960       30,210     26 
REM    DES2_I                  1       22,848    30,720       22,848     26 
REM    RBS                    16       51,198    59,392       55,748      6 
REM    SYSTEM                  3        4,896    92,160        5,930     94 
REM    TEMP                    5          130       550          548      0  
REM    TOOLS                  10       76,358   117,760       87,402     26 
REM    USERS                   1           46     1,024           46     96 
REM                     --------              ------------ ------------ 
REM    sum                    37                342,566      202,732 
REM  
REM ------------------------------------------------------------------------ 
REM DISCLAIMER: 
REM    This script is provided for educational purposes only. It is NOT  
REM    supported by Oracle World Wide Technical Support. 
REM    The script has been tested and appears to work as intended. 
REM    You should always run new scripts on a test instance initially. 
REM ------------------------------------------------------------------------ 
REM Main text of script follows: 
 
ttitle - 
   center  'Database Freespace Summary'  skip 2 
 
comp sum of nfrags totsiz avasiz on report 
break on report 
 
col tsname  format         a16 justify c heading 'Tablespace' 
col nfrags  format     999,990 justify c heading 'Free|Frags' 
col mxfrag  format 999,999,990 justify c heading 'Largest|Frag (KB)' 
col totsiz  format 999,999,990 justify c heading 'Total|(KB)' 
col avasiz  format 999,999,990 justify c heading 'Available|(KB)' 
col pctusd  format         990 justify c heading 'Pct|Used' 
 
select 
  total.tablespace_name                       tsname, 
  count(free.bytes)                           nfrags, 
  nvl(max(free.bytes)/1024,0)                 mxfrag, 
  total.bytes/1024                            totsiz, 
  nvl(sum(free.bytes)/1024,0)                 avasiz, 
  (1-nvl(sum(free.bytes),0)/total.bytes)*100  pctusd 
from 
  dba_data_files  total, 
  dba_free_space  free 
where 
  total.tablespace_name = free.tablespace_name(+) 
  and total.file_id=free.file_id(+)
group by 
  total.tablespace_name, 
  total.bytes 
/ 
