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
	echo "Optimizing EPG performance"
	echo "ALTER SYSTEM SET SHARED_SERVERS=15 SCOPE=BOTH;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
	echo -e "ALTER SYSTEM SET DISPATCHERS='(PROTOCOL=TCP) (SERVICE=${ORACLE_SID}XDB) (DISPATCHERS=3)' SCOPE=BOTH;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
}

apex_create_tablespace(){
	cd ${ORACLE_HOME}/apex
	echo "Creating APEX tablespace."
	${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA <<EOF
		CREATE TABLESPACE apex DATAFILE '${ORACLE_BASE}/oradata/${ORACLE_SID}/apex01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M;
EOF
}

apex_install(){
	cd $ORACLE_HOME/apex
	echo "Installing APEX."
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA @apexins APEX APEX TEMP /i/
	echo "Setting APEX ADMIN password."
    echo -e "\n\n${APEX_PASS}" | /opt/sqlcl/bin/sql -s -l sys/${PASS}@${ORACLE_SID} AS sysdba @apxchpwd.sql
}

apex_load_images() {
	echo "Load APEX images."
	# do not load images from path containing soft links to avoid "ORA-22288: file or LOB operation FILEOPEN failed"
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA @apxldimg.sql `readlink -f ${ORACLE_HOME}`
}

apex_rest_config() {
	echo "Getting ready for ORDS. Creating user APEX_LISTENER and APEX_REST_PUBLIC_USER."
	echo -e "${PASS}\n${PASS}" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS sysdba @apex_rest_config.sql
	echo "ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
	echo "ALTER USER APEX_PUBLIC_USER IDENTIFIED BY ${PASS};" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
}

disable_http
apex_create_tablespace
apex_install
apex_load_images
apex_rest_config
apex_epg_config
enable_http
cd /
