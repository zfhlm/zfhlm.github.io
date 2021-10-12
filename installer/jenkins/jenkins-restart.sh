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

CheckProcess "/usr/local/jenkins/jenkins.war"
CheckQQ_RET=$?
if [ "$CheckQQ_RET" = "0" ];
then
	echo "restart jenkins ..."
	kill -9 $(ps -ef|grep /usr/local/jenkins/jenkins.war |gawk '$0 !~/grep/ {print $2}' |tr -s '\n' ' ')
	sleep 1
	exec nohup java -jar /usr/local/jenkins/jenkins.war &
	echo "restart jenkins success..."
else
	echo "restart jenkins..."
	exec nohup java -jar /usr/local/jenkins/jenkins.war &
	echo "restart jenkins success..."
fi
