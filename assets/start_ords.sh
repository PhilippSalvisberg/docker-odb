#!/bin/bash

if [ $ORDS == "true" ]; then
	rm -f /tmp/ords.pid
	LOGFILE=/opt/ords/logs/console.log
	echo "Starting ORDS. See $LOGFILE for details."
	nohup java -Dorg.eclipse.jetty.server.Request.maxFormContentSize=1000000 -jar /opt/ords/ords.war standalone >> $LOGFILE 2>&1 &
	echo $! > /tmp/ords.pid
fi