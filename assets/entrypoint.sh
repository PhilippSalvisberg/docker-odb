#!/bin/bash

# ignore secure linux
setenforce Permissive

# environment variables (not configurable when creating a container)
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome
export ORACLE_BASE=/u01/app/oracle
export TERM=linux

# Exit script on non-zero command exit status
set -e

# Prevent owner issues on mounted folders
chown -R oracle:dba /u01/app/oracle
rm -f /u01/app/oracle/product
ln -s /u01/app/oracle-product /u01/app/oracle/product

case "$1" in
	'')
		# default behaviour when no parameters are passed

		# Create tnsnames.ora
		if [ -f "${ORACLE_HOME}/network/admin/tnsnames.ora" ]
		then
			echo "tnsnames.ora found."
		else
			echo "Creating tnsnames.ora" 
			printf "${ORACLE_SID} =\n\
			(DESCRIPTION =\n\
			 (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))\n\
			 (CONNECT_DATA = (SERVICE_NAME = ${SERVICE_NAME})))\n" > ${ORACLE_HOME}/network/admin/tnsnames.ora
		fi

		# Add Oracle to path
		export PATH=${ORACLE_HOME}/bin:$PATH
		if grep -q "PATH" ~/.bashrc
		then
			echo "Found PATH definition in ~/.bashrc"
		else
			echo "Extending PATH in in ~/.bashrc"
			printf "\nPATH=${PATH}\n" >> ~/.bashrc
		fi

		#Check for mounted database files
		if [ "$(ls -A ${ORACLE_BASE}/oradata)" ]; then
			echo "Found data files in ${ORACLE_BASE}/oradata, initial database does not need to be created."
			echo "odb:$ORACLE_HOME:N" >> /etc/oratab
			chown oracle:dba /etc/oratab
			chown 664 /etc/oratab
			rm -rf /u01/app/oracle-product/12.1.0.2/dbhome/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0.2/dbhome/dbs
			#Startup Database
			gosu oracle bash -c "${ORACLE_HOME}/bin/tnslsnr &"
			gosu oracle bash -c 'echo startup\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
		else
			echo "No data files found in ${ORACLE_BASE}/oradata, initializing database."
			mv /u01/app/oracle-product/12.1.0.2/dbhome/dbs /u01/app/oracle/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0.2/dbhome/dbs
			chown oracle:dba ${ORACLE_HOME}/network/admin/tnsnames.ora
			chown 664 ${ORACLE_HOME}/network/admin/tnsnames.ora		
			echo "Starting tnslsnr"
			gosu oracle bash -c "${ORACLE_HOME}/bin/tnslsnr &"
			gosu oracle bash -c "${ORACLE_HOME}/bin/dbca -silent -createDatabase -templateName Data_Warehouse.dbc \
			   -gdbname ${SERVICE_NAME} -sid ${ORACLE_SID} -responseFile NO_VALUE -characterSet AL32UTF8 \
			   -totalMemory $DBCA_TOTAL_MEMORY -emConfiguration LOCAL -pdbAdminPassword ${PASS} \
			   -sysPassword ${PASS} -systemPassword ${PASS}"
			if [ $WEB_CONSOLE == "true" ]; then
				echo "Upgrading APEX installation."
				. /assets/upgrade_apex.sh
				echo "Configuring APEX and APEX EM Database Express 12c"
				gosu oracle bash -c 'echo EXEC DBMS_XDB.sethttpport\(8082\)\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
				cd ${ORACLE_HOME}/apex
				gosu oracle bash -c 'echo -e "\n\n${APEX_PASS}" | /opt/sqlcl/bin/sql -s -l / as sysdba @apxchpwd.sql > /dev/null'
				gosu oracle bash -c 'echo -e "${ORACLE_HOME}\n\n" | /opt/sqlcl/bin/sql -s -l / as sysdba @apex_epg_config_core.sql > /dev/null'
				gosu oracle bash -c 'echo -e "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba > /dev/null'
			else 
				echo "APEX and EM Database Express 12c are disabled, no need to upgrade APEX."
			fi			
			echo "Database initialized."
			echo "Installing Oracle sample schemas."
			. /assets/install_oracle_sample_schemas.sh
			echo "Installing FTLDB."
			. /assets/install_ftldb.sh
			echo "Installing tePLSQL."
			. /assets/install_teplsql.sh
			echo "Installing oddgen examples/tutorials"
			. /assets/install_oddgen.sh
		fi
		
		if [ $WEB_CONSOLE == "true" ]; then
			gosu oracle bash -c 'echo EXEC DBMS_XDB.sethttpport\(8082\)\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
			echo "APEX and EM Database Express 12c initialized. Please visit"
			echo "   - http://localhost:8082/em"
			echo "   - http://localhost:8082/apex"
		else
			echo 'Disabling APEX and EM Database Express 12c'
			gosu oracle bash -c 'echo EXEC DBMS_XDB.sethttpport\(0\)\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
		fi

		# Successful installation/startup
		echo ""
		echo "Database ready to use. Enjoy! ;-)"

		# Infinite wait loop, trap interrupt/terminate signal for graceful termination
		trap "gosu oracle bash -c 'echo shutdown immediate\; | ${ORACLE_HOME}/bin/sqlplus -S / as sysdba'" INT TERM
		while true; do sleep 1; done
		;;

	*)
		# use parameters 
		
		echo ""
		echo "Overridden default behaviour. Run /assets/entrypoint.sh when ready."	
		$@
		;;
esac
