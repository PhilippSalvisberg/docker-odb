#!/bin/bash

apex_epg_config(){
	if [ $ORDS == "false" ]; then
		cd ${ORACLE_HOME}/apex
		echo "Setting up EPG for APEX by running: @apex_epg_config ${ORACLE_HOME}"
		echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA @apex_epg_config ${ORACLE_HOME}
		echo "Unlock anonymous account"
		echo "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
		echo "Unlock anonymous account on CDB"
		echo "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
		echo "Enable on DBMS_XDB HTTP port for EPG on pluggable database"
		echo "EXEC DBMS_XDB.SETHTTPPORT(8081);" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${ORACLE_SID} AS SYSDBA
		echo "Optimizing EPG performance"
		echo "ALTER SYSTEM SET SHARED_SERVERS=15 SCOPE=BOTH;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
		echo -e "ALTER SYSTEM SET DISPATCHERS='(PROTOCOL=TCP) (SERVICE=${ORACLE_SID}XDB) (DISPATCHERS=3)' SCOPE=BOTH;" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA
	fi
}

apex_create_tablespace(){
	echo "Creating APEX tablespace."
	DATAFILE=${ORACLE_BASE}/oradata/${ORACLE_SID}/${PDB_NAME}/apex01.dbf
	${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
		CREATE TABLESPACE apex DATAFILE '${DATAFILE}' SIZE 100M AUTOEXTEND ON NEXT 10M;
EOF
}

apex_install(){
	cd $ORACLE_HOME/apex
	echo "Installing APEX."
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA @apexins APEX APEX TEMP /i/
	echo "Setting APEX ADMIN password."
	${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
declare
   l_user_id INTEGER;
begin
   apex_util.set_security_group_id(10);
   l_user_id := apex_util.get_user_id('ADMIN');
   if l_user_id is null then
      apex_util.create_user(
         p_user_name                    => 'ADMIN',
         p_email_address                => 'ADMIN',
         p_web_password                 => '${APEX_PASS}',
         p_developer_privs              => 'ADMIN',
         p_change_password_on_first_use => 'N'
      );
   else 
      apex_util.edit_user(
         p_user_id                      => l_user_id,
         p_user_name                    => 'ADMIN',
         p_email_address                => 'ADMIN',
         p_web_password                 => '${APEX_PASS}',
         p_new_password                 => '${APEX_PASS}',
         p_change_password_on_first_use => 'N',
         p_account_locked               => 'N'
      );
   end if;
   apex_util.set_security_group_id(null);
   commit;
end;
/
EOF
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

apex_update() {
	cd $ORACLE_HOME/apex_patch
	echo "Installing APEX patch."
	echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA @catpatch.sql
	/bin/cp -rfv images/* $ORACLE_HOME/apex/images
	if [ $ORDS == "false" ]; then
		echo "EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA @epg_install_images.sql $ORACLE_HOME/apex_patch
	fi
}

apex_create_tablespace
apex_install
apex_update
apex_epg_config
apex_rest_config
cd /
