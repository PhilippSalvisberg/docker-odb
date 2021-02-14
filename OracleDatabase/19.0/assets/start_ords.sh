#!/bin/bash

if [ $ORDS == "true" ]; then
	rm -f /tmp/ords.pid
	LOGFILE=${ORACLE_BASE}/ords/logs/console.log
	echo "Starting ORDS. See $LOGFILE for details."
	cd ${ORACLE_HOME}/ords
	# set config directory in ords.war, e.g. after creating a new container
	java -jar ords.war configdir ${ORACLE_BASE}/ords/conf
	# start ORDS as background process, increase default content size (was 200000).
	nohup java -Dorg.eclipse.jetty.server.Request.maxFormContentSize=1000000 -jar ords.war \
		standalone --parameterFile ${ORACLE_BASE}/ords/params/ords_params.properties --port 8081 >> $LOGFILE 2>&1 &
	# save PID for for kill in stop_ords.sh
	echo $! > /tmp/ords.pid
fi
