#!/bin/bash

#
#
#
set -x

ORACLE_BASE=/opt/ora11g  
ORACLE_SID=audkeydb 
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1 
PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE ORACLE_SID ORACLE_HOME PATH

echo $PATH
echo current path is:`pwd` 
echo current time is:`date`

# 
sqlplus -s '/ as sysdba' << EOF 
set feed off 
set linesize 300
set pagesize 50
col file_id for 9
col TABLESPACE_NAME for a20
col status for a10
col autoextensible for a10
col file_name for a60
col online_status for a10
col f#	for 99
host echo -e "\n***************basic info***************"
select file_id as f#,file_name, tablespace_name, status, autoextensible, online_status from dba_data_files order by file_id;

#
col name for a20
col FLASHBACK_ON for a15
col ENCRYPT_IN_BACKUP for a15
col BIGFILE   for a8
col INCLUDED_IN_DATABASE_BACKUP  for a20
col TS# for 99
select * from v\$tablespace;

#
col IS_RECOVERY_DEST_FILE for a10
col ARCHIVED for a10
col type for a10
col MEMBER for a50
col grp	for 9
select s.group# as grp, s.type, s.member, s.IS_RECOVERY_DEST_FILE, t.thread#, t.status, t.ARCHIVED
from v\$logfile s left join v\$log t 
     on s.group#=t.group#;

host echo -e "\n***************tbs usage**************"
col "USED (MB)" for a10 
col "FREE (MB)" for a10 
col "TOTAL (MB)" for a10 
col PER_FREE for a10 
col tablespace_name for a20

SELECT F.TABLESPACE_NAME, 
TO_CHAR ((T.TOTAL_SPACE - F.FREE_SPACE),'999,999') "USED (MB)", 
TO_CHAR (F.FREE_SPACE, '999,999') "FREE (MB)", 
TO_CHAR (T.TOTAL_SPACE, '999,999') "TOTAL (MB)", 
TO_CHAR ((ROUND ((F.FREE_SPACE/T.TOTAL_SPACE)*100)),'999')||' %' PER_FREE 
FROM ( 
        SELECT TABLESPACE_NAME, 
        ROUND (SUM (BLOCKS*(SELECT VALUE/1024 
        FROM V\$PARAMETER 
        WHERE NAME = 'db_block_size')/1024) 
        ) FREE_SPACE 
FROM DBA_FREE_SPACE 
GROUP BY TABLESPACE_NAME 
) F, 
( 
SELECT TABLESPACE_NAME, 
ROUND (SUM (BYTES/1048576)) TOTAL_SPACE 
FROM DBA_DATA_FILES 
GROUP BY TABLESPACE_NAME 
) T 
WHERE F.TABLESPACE_NAME = T.TABLESPACE_NAME 
order by PER_FREE;


host echo -e "\n**************object info**************"
col object_name for a30
col object_type for a10
col owner	for a10
SELECT  OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS
FROM    DBA_OBJECTS
WHERE   STATUS = 'INVALID'
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME; 

SELECT   SID, DECODE(BLOCK, 0, 'NO', 'YES' ) BLOCKER,
              DECODE(REQUEST, 0, 'NO','YES' ) WAITER
FROM     V\$LOCK
WHERE    REQUEST > 0 OR BLOCK > 0
ORDER BY block DESC; 

host echo -e "\n**************backup info**************"
col name for a60
SELECT NAME,
ROUND(SPACE_LIMIT / (1024*1024)) SPACE_LIMIT_MB,
ROUND(SPACE_USED / (1024*1024)) SPACE_USED_MB,
ROUND( (SPACE_USED * 100) / SPACE_LIMIT, 2) PRC_USED
FROM V\$RECOVERY_FILE_DEST; 

exit 
EOF


echo -e  "\n**************disk usage**************\n"
df -h | head -1 && df -h | tail -n +2 | sort -nrk 5
