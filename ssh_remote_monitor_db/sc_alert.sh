#!/bin/bash

#
#
#

dir_trace=/opt/ora11g/diag/rdbms/audkeydb/audkeydb/trace
file_alert=$dir_trace/alert_audkeydb.log
sz_trace=`du -h $dir_trace | awk '{print $1}'`
echo "path of trace file:$dir_trace"
echo "size of trace file:$sz_trace"

#
file_alert_work=$dir_trace/alert_work.log
file_alert_hist=$dir_trace/alert_audkeydb.hist
declare -i sum=`wc -l $file_alert | awk '{print $1}'`
declare -i ln=0
if [ -e $file_alert_hist ]; then
	ln=`wc -l $file_alert_hist | awk '{print $1}'`
	sum=$((sum + ln)) 
fi
echo "lines of alert log :$sum"

#
mv $file_alert $file_alert_work
touch $file_alert
cat $file_alert_work >> $file_alert_hist
grep "ORA-" -B5 -A1 $file_alert_work

#CAUTION!!
rm $file_alert_work
