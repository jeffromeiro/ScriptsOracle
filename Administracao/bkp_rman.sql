RMAN> run {
2> backup as compressed backupset database;
3> sql 'alter system archive log current';
4> backup as compressed backupset archivelog all;
5> backup current controlfile;
6> }
