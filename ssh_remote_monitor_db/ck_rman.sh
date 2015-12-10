#!/bin/bash
#
#
#
mail_list="for_monitor@xxx.com"
set -x

curpath=/home/tendyron/sql_check
script_for_backup=$curpath/sc_rman_backup.sh
report_for_backup=$curpath/rp_rman_backup.txt

ssh oracle@172.16.10.xxx 'bash -s' < $script_for_backup > $report_for_backup

if [ `cat $report_for_backup | wc -l` -gt 0 ]; then
        cat $report_for_backup | mutt -s "rman backup for auddb"  $mail_list
else
        mutt -s "rman backup for auddb" $mail_list < "no result present.maybe error occurs!"
fi
