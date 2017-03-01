#!/bin/bash

disable_http(){
	echo "Turning off DBMS_XDB HTTP port"
	echo "EXEC DBMS_XDB.SETHTTPPORT(0);" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
}

enable_http(){
	echo "Turning on DBMS_XDB HTTP port"
	echo "EXEC DBMS_XDB.SETHTTPPORT(8082);" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
}

apex_epg_config(){
	cd ${ORACLE_HOME}/apex
	echo "Setting up EPG for APEX by running: @apex_epg_config ${ORACLE_HOME}"
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA @apex_epg_config ${ORACLE_HOME}
	echo "Unlock anonymous account"
	echo "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
}

apex_upgrade(){
	cd $ORACLE_HOME/apex
	echo "Upgrading APEX."
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA @apexins SYSAUX SYSAUX TEMP /i/
	echo "Updating APEX images"
	# do not load images from path containing soft links to avoid "ORA-22288: file or LOB operation FILEOPEN failed"
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA @apxldimg.sql `readlink -f ${ORACLE_HOME}`
	echo "Setting APEX ADMIN password."
    echo -e "\n\n${APEX_PASS}" | /opt/sqlcl/bin/sql -s -l sys/${PASS}@${ORACLE_SID} AS sysdba @apxchpwd.sql
}

disable_http
apex_upgrade
apex_epg_config
enable_http
cd /
