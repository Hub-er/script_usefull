#!/bin/bash
#set -x

#parameter num
#echo $#
if (( $# < 1 )) 
    then echo "需要传递URL文件路径！"
    exit 1
fi
dstpath=$1
echo  "url path:$dstpath"

merge_file="$dstpath/url_merge.out"
imgs_path="$dstpath/../../../out/"
download_failed="$dstpath/failed_url.out"
result_file="$dstpath/result.out"

#判断合并文件是否存在？
file_ls=""

if [ ! -f "$merge_file" ]
then
#合并文件
  file_ls=`find $dstpath  -maxdepth 1 -type f -name "*.txt"`
  for file in $file_ls; do
    sub=`basename $file`
    filename="${sub%.*}"
    #echo $filename
    while read line; do
      #echo "This is a line : $line"
      newline="$filename $line"
      `echo $newline >> $merge_file`
    done < $file
  done
fi

#图像文件夹
file_ls=`find $dstpath  -maxdepth 1 -type f -name "*.txt"`
for file in $file_ls; do
    sub=`basename $file`
    filename="${sub%.*}"
    folder="$imgs_path$filename"
    echo $folder
    `mkdir -p $folder`
done

#上一次下载到哪里？
declare -i line_no
if [ -f $result_file ]
then
#从上一次下载的记录开始
  line_no=`cat $result_file | awk -F':' '{print $2;}' ` 
else
  line_no=0
fi
echo $line_no

#从固定位置下载
declare -i cur_no=0
while read line; do
   cur_no=$(( cur_no + 1 ))
   #echo $cur_no
  
   if (( cur_no <= line_no ))
   then
      continue
   fi

   seqnum=`echo $line | awk '{print $2;}'`
   url=`echo $line | awk '{print $3;}'`
   file=`basename $url`
   ext="${file##*.}"
   folder=`echo $line | awk '{print $1;}'`
   pathname="$imgs_path$folder/$seqnum.$ext"
   #echo $url

   #下载
   echo "***wget  -O $pathname $url"
   wget -nv -t 1  --timeout=30 -O $pathname $url
   if [ $? -ne 0 ]
   then
     echo $line >> $download_failed
     #else
     #获取文件大小
     #file_sz=`stat --printf="%s" $pathname`
     #if [ file_sz == "0" ]
     #then
     #  echo $line >> $download_failed
     #fi
   fi
   
   #判断文件大小
   sz=`stat --printf="%s" $pathname`
   #echo "$sz length: ${#sz}"
   if [ $sz == "0" ]
   then
      echo $line >> $download_failed
      echo "rm $pathname"
      rm $pathname
   fi
  
   #记录当前下载行 
   echo "last download:$cur_no" > $result_file
  
done < $merge_file
