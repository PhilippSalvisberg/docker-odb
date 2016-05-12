#!/bin/bash

SQLPLUS=$ORACLE_HOME/bin/sqlplus
SQLPLUS_ARGS="sys/${PASS}@${ORACLE_SID} AS SYSDBA"

verify(){
	echo "exit" | ${SQLPLUS} -L $SQLPLUS_ARGS | grep Connected > /dev/null
	if [ $? -eq 0 ];
	then
	   echo "Database Connetion is OK"
	else
	   echo -e "Database Connection Failed. Connection failed with:\n ${SQLPLUS} -s -l ${SQLPLUS_ARGS}\n `${SQLPLUS} -s -l ${SQLPLUS_ARGS}` < /dev/null"
	   exit 1
	fi

	if [ "$(ls -A $ORACLE_HOME)" ]; then
		echo "Check Database files folder: OK"
	else
		echo -e "Failed to find database files"
		exit 1
	fi
}

disable_http(){
	echo "Turning off DBMS_XDB HTTP port"
	echo "EXEC DBMS_XDB.SETHTTPPORT(0);" | $SQLPLUS -S $SQLPLUS_ARGS
}

enable_http(){
	echo "Turning on DBMS_XDB HTTP port"
	echo "EXEC DBMS_XDB.SETHTTPPORT(8082);" | $SQLPLUS -S $SQLPLUS_ARGS
}

apex_epg_config(){
	cd $ORACLE_HOME/apex
	echo "Setting up EPG for Apex by running: @apex_epg_config $ORACLE_HOME"
	$SQLPLUS -S $SQLPLUS_ARGS @apex_epg_config $ORACLE_HOME < /dev/null
}

apex_upgrade(){
	cd $ORACLE_HOME/apex
	echo "Upgrading apex..."
	$SQLPLUS -S $SQLPLUS_ARGS @apexins SYSAUX SYSAUX TEMP /i/ < /dev/null
	echo "Updating apex images"
	$SQLPLUS -S $SQLPLUS_ARGS @apxldimg.sql $ORACLE_HOME < /dev/null
}

verify
disable_http
apex_upgrade
apex_epg_config
enable_http
cd /
