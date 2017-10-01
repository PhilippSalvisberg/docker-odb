#!/bin/bash

if [ $ORDS == "true" ]; then
	rm -f /tmp/ords.pid
	LOGFILE=${ORACLE_HOME}/ords/logs/console.log
	echo "Starting ORDS. See $LOGFILE for details."
	cd ${ORACLE_HOME}/ords
	nohup java -Dorg.eclipse.jetty.server.Request.maxFormContentSize=1000000 -jar ords.war standalone >> $LOGFILE 2>&1 &
	echo $! > /tmp/ords.pid
fi