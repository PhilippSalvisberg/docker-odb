#!/bin/bash

gosu oracle bash -c "mkdir /tmp/log && cd ${ORACLE_HOME}/demo/schema && echo "EXIT" | sqlplus -s -l system/${PASS}@${CONNECT_STRING} @mksample ${PASS} ${PASS} hr oe pm ix sh bi users temp /tmp/log/ ${CONNECT_STRING}"
