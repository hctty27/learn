#!/bin/bash

number=30
backup_dir=/data/csp/mysqlbackup
dd=`date +%Y-%m-%d-%H-%M-%S`
tool=mysqldump
username=root
password=Vlinkall@2018credit
database_name=vlink-csp

if [ ! -d $backup_dir ]; 
then     
    mkdir -p $backup_dir; 
fi

$tool -u $username -p$password $database_name --ignore-table=$database_name.sys_operation_log | gzip > $backup_dir/$database_name-$dd.sql.gz

echo "create $backup_dir/$database_name-$dd.dupm" >> $backup_dir/log.txt

delfile=`ls -l -crt  $backup_dir/*.sql.gz | awk '{print $9 }' | head -1`

count=`ls -l -crt  $backup_dir/*.sql.gz | awk '{print $9 }' | wc -l`

if [ $count -gt $number ]
then
  rm $delfile
  echo "delete $delfile" >> $backup_dir/log.txt
fi
