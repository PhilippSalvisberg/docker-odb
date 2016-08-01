#!/bin/bash

cd /opt/ftldb*
/bin/bash dba_install.sh ${ORACLE_SID} sys ${PASS} ftldb ftldb
/bin/bash dba_switch_java_permissions.sh ${ORACLE_SID} sys ${PASS} grant public
/bin/bash dba_switch_plsql_privileges.sh ${ORACLE_SID} sys ${PASS} ftldb grant public
