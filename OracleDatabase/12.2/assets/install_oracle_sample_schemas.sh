#!/bin/bash

# ensure ORACLE_HOME does not contain soft links to avoid "ORA-22288: file or LOB operation FILEOPEN failed" (for APEX images)
ORACLE_HOME_OLD=${ORACLE_HOME}
ORACLE_HOME=`readlink -f ${ORACLE_HOME}`
gosu oracle bash -c "mkdir /tmp/log && cd ${ORACLE_HOME}/demo/schema && echo "EXIT" | sqlplus -s -l system/${PASS}@${CONNECT_STRING} @mksample ${PASS} ${PASS} hr oe pm ix sh bi users temp /tmp/log/ ${CONNECT_STRING}"
# reset ORACLE_HOME
ORACLE_HOME=${ORACLE_HOME_OLD}
