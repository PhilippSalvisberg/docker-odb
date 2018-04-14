#!/bin/bash

apex_epg_config(){
	if [ $ORDS == "false" ]; then
		cd ${ORACLE_HOME}/apex
		echo "Setting up EPG for APEX by running: @apex_epg_config ${ORACLE_HOME}"
		# ensure ORACLE_HOME does not contain soft links to avoid "ORA-22288: file or LOB operation FILEOPEN failed" (for APEX images)
		ORACLE_HOME_OLD=${ORACLE_HOME}
		ORACLE_HOME=`readlink -f ${ORACLE_HOME}`
		echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA @apex_epg_config ${ORACLE_HOME}
		# reset ORACLE_HOME
		ORACLE_HOME=${ORACLE_HOME_OLD}
		echo "Unlock anonymous account"
		echo "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
		if [ $MULTITENANT == "true" ]; then
			echo "Unlock anonymous account on CDB"
			echo "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
			echo "Enable on DBMS_XDB HTTP port for EPG on pluggable database"
			echo "EXEC DBMS_XDB.SETHTTPPORT(8081);" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
		fi
		echo "Optimizing EPG performance"
		echo "ALTER SYSTEM SET SHARED_SERVERS=15 SCOPE=BOTH;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
		echo -e "ALTER SYSTEM SET DISPATCHERS='(PROTOCOL=TCP) (SERVICE=${ORACLE_SID}XDB) (DISPATCHERS=3)' SCOPE=BOTH;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
	fi
}

apex_create_tablespace(){
	echo "Creating APEX tablespace."
	if [ $MULTITENANT == "true" ]; then
		DATAFILE=${ORACLE_BASE}/oradata/${ORACLE_SID}/${PDB_NAME}/apex01.dbf
	else
		DATAFILE=${ORACLE_BASE}/oradata/${ORACLE_SID}/apex01.dbf
	fi
	${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
		CREATE TABLESPACE apex DATAFILE '${DATAFILE}' SIZE 100M AUTOEXTEND ON NEXT 10M;
EOF
}

apex_install(){
	cd $ORACLE_HOME/apex
	echo "Installing APEX."
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA @apexins APEX APEX TEMP /i/
	echo "Setting APEX ADMIN password."
	chmod +x ${ORACLE_HOME}/sqldeveloper/sqldeveloper/bin/sql
	sync
 	echo -e "\n\n${APEX_PASS}" | ${ORACLE_HOME}/sqldeveloper/sqldeveloper/bin/sql -s -l sys/${PASS}@${CONNECT_STRING} AS sysdba @apxchpwd.sql
}

apex_rest_config() {
	if [ $ORDS == "true" ]; then
	    cd $ORACLE_HOME/apex
		echo "Getting ready for ORDS. Creating user APEX_LISTENER and APEX_REST_PUBLIC_USER."
		echo -e "${PASS}\n${PASS}" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS sysdba @apex_rest_config.sql
		echo "ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
		echo "ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS};" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
	fi
}

apex_create_tablespace
apex_install
apex_epg_config
apex_rest_config
cd /
