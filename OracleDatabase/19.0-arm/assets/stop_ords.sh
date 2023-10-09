#!/bin/bash

if [ $ORDS == "true" ]; then
    echo "Stopping ORDS."
	kill `ps -ef | grep "ords -D" | awk '{print $2}'`
fi
