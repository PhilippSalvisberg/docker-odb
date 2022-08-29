#!/bin/bash

if [ $ORDS == "true" ]; then
	export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk
	rm -f /tmp/ords.pid
	LOGFILE=${ORACLE_BASE}/ords/logs/console.log
	echo "Starting ORDS. See $LOGFILE for details."
	cd ${ORACLE_HOME}/ords
	# set JVM and other properties via _JAVA_OPTIONS which is processed by every JVM
	# increase default content size (was 200000).
	export _JAVA_OPTIONS="-Dorg.eclipse.jetty.server.Request.maxFormContentSize=1000000"
	# start ORDS as background process 
	nohup ./bin/ords --config ${ORACLE_BASE}/ords/conf serve >> $LOGFILE 2>&1 &
fi
