#!/bin/sh
CheckProcess()
{
	if [ "$1" = "" ];
	then
		return 1
	fi

	PROCESS_NUM=$(ps -ef|grep "$1"|grep -v "grep"|wc -l)
	if [ "$PROCESS_NUM" = "1" ];
	then
		return 0
	else
		return 1
	fi
}

CheckProcess "/usr/bin/fdfs_storaged"
CheckQQ_RET=$?
if [ "$CheckQQ_RET" = "0" ];
then
	echo "restart fastdfs storage ..."
	kill -9 $(ps -ef|grep /usr/bin/fdfs_storaged |gawk '$0 !~/grep/ {print $2}' |tr -s '\n' ' ')
	sleep 1
	exec /usr/bin/fdfs_storaged /etc/fdfs/storage.conf &
	echo "restart fastdfs storage success..."
else
	echo "restart fastdfs storage..."
	exec /usr/bin/fdfs_storaged /etc/fdfs/storage.conf &
	echo "restart fastdfs storage success..."
fi
