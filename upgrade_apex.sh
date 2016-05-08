#!/bin/bash

SQLPLUS=$ORACLE_HOME/bin/sqlplus
SQLPLUS_ARGS="sys/${PASS}@XE AS SYSDBA"

verify(){
	echo "exit" | ${SQLPLUS} -L $SQLPLUS_ARGS | grep Connected > /dev/null
	if [ $? -eq 0 ];
	then
	   echo "Database Connetion is OK"
	else
	   echo -e "Database Connection Failed. Connection failed with:\n $SQLPLUS -S $SQLPLUS_ARGS\n `$SQLPLUS -S $SQLPLUS_ARGS` < /dev/null"
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
	echo "EXEC DBMS_XDB.SETHTTPPORT($HTTP_PORT);" | $SQLPLUS -S $SQLPLUS_ARGS
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

unzip_apex(){
	echo "Unzipping and moving Apex-${APEX_VERSION} to target directory"
	rm -rf $ORACLE_HOME/apex
	$ORACLE_HOME/bin/unzip /tmp/apex.zip -d $ORACLE_HOME
	chown oracle:dba $ORACLE_HOME/apex
}


case $1 in
	'install')
		verify
		unzip_apex
		disable_http
		apex_upgrade
		apex_epg_config
		enable_http
		cd /
		;;
	*)
		$1
		;;
esac
