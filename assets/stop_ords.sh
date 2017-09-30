#!/bin/bash

if [ $ORDS == "true" ]; then
	if [ -f /tmp/ords.pid ]; then
		kill -9 `cat /tmp/ords.pid`
		rm /tmp/ords.pid
	else
		kill `ps -ef | grep "/opt/ords/ords.war" | awk '{print $2}'`
	fi
fi
