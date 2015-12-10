#!/bin/bash

#
#
#
set -x

export ORACLE_SID=audkeydb
export ORACLE_BASE=/opt/ora11g
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

date

flash_recover_path=/oracle_backups/flash_recovery_area
echo "flash recovery path:$flash_recover_path"
echo "used:`du -hs $flash_recover_path | awk '{print $1}'`"
echo -e "\n"
du -h $flash_recover_path

#basic backup info
rman target /
show all;
exit
