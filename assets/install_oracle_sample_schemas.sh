#!/bin/bash

cd ${ORACLE_HOME}/demo/schema
mkdir /tmp/log
echo "EXIT" | sqlplus -s -l system/${PASS}@${ORACLE_SID} @mksample ${PASS} ${PASS} hr oe pm ix sh bi users temp /tmp/log/ ${ORACLE_SID}
cd /
