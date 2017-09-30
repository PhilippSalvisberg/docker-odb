#!/bin/bash

cd /opt/ftldb*
/bin/bash dba_install.sh ${CONNECT_STRING} sys ${PASS} ftldb ftldb
/bin/bash dba_switch_java_permissions.sh ${CONNECT_STRING} sys ${PASS} grant public
/bin/bash dba_switch_plsql_privileges.sh ${CONNECT_STRING} sys ${PASS} ftldb grant public
