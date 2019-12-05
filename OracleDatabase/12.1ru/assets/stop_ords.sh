#!/bin/bash

if [ $ORDS == "true" ]; then
    echo "Stopping ORDS."
	if [ -f /tmp/ords.pid ]; then
		kill -9 `cat /tmp/ords.pid`
		rm /tmp/ords.pid
	else
		kill `ps -ef | grep "ords.war" | awk '{print $2}'`
	fi
fi
