#!/bin/bash

# Exit script on non-zero command exit status
set -e

# Prevent owner issues on mounted folders
chown -R oracle:dba /u01/app/oracle
rm -f /u01/app/oracle/product
ln -s /u01/app/oracle-product /u01/app/oracle/product

# Run Oracle root scripts
/u01/app/oraInventory/orainstRoot.sh > /dev/null 2>&1
echo | /u01/app/oracle/product/12.1.0/xe/root.sh > /dev/null 2>&1 || true

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
if [ "$(ls -A /u01/app/oracle/oradata)" ]; then
	echo "found files in /u01/app/oracle/oradata Using them instead of initial database"
	echo "XE:$ORACLE_HOME:N" >> /etc/oratab
	chown oracle:dba /etc/oratab
	chown 664 /etc/oratab
	rm -rf /u01/app/oracle-product/12.1.0/xe/dbs
	ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0/xe/dbs
	#Startup Database
	su oracle -c "${ORACLE_HOME}/bin/tnslsnr &"
	su oracle -c 'echo startup\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
else
	echo "Database not initialized. Initializing database."
	mv /u01/app/oracle-product/12.1.0/xe/dbs /u01/app/oracle/dbs
	ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0/xe/dbs
	chown oracle:dba ${ORACLE_HOME}/network/admin/tnsnames.ora
	chown 664 ${ORACLE_HOME}/network/admin/tnsnames.ora		
	echo "Starting tnslsnr"
	su oracle -c "${ORACLE_HOME}/bin/tnslsnr &"
	su oracle -c "${ORACLE_HOME}/bin/dbca -silent -createDatabase -templateName Data_Warehouse.dbc \
	   -gdbname ${SERVICE_NAME} -sid ${ORACLE_SID} -responseFile NO_VALUE -characterSet AL32UTF8 \
	   -totalMemory $DBCA_TOTAL_MEMORY -emConfiguration LOCAL -pdbAdminPassword ${PASS} \
	   -sysPassword ${PASS} -systemPassword ${PASS}"
	echo "Configuring Apex console"
	cd ${ORACLE_HOME}/apex
	su oracle -c 'echo -e "${APEX_PASS}\n8082" | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba @apxconf > /dev/null'
	su oracle -c 'echo -e "${ORACLE_HOME}\n\n" | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba @apex_epg_config_core.sql > /dev/null'
	su oracle -c 'echo -e "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba > /dev/null'
	echo "Database initialized."
	echo "Installing Oracle sample schemas."
	. /install_oracle_sample_schemas.sh
	echo "Installing FTLDB."
	. /install_ftldb.sh
	echo "Installing tePLSQL."
	. /install_teplsql.sh
	echo "Installing oddgen examples/tutorials"
	. /install_oddgen.sh
	if [ $WEB_CONSOLE == "true" ]; then
		echo "Upgrading APEX installation."
		. /upgrade_apex.sh
	else 
		echo "web management console and APEX is disabled, no need to upgrade APEX."
	fi			
fi

if [ $WEB_CONSOLE == "true" ]; then
	echo 'Starting web management console'
	su oracle -c 'echo EXEC DBMS_XDB.sethttpport\(8082\)\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
	echo "Web management console initialized. Please visit"
	echo "   - http://localhost:8082/em"
	echo "   - http://localhost:8082/apex"
else
	echo 'Disabling web management console'
	su oracle -c 'echo EXEC DBMS_XDB.sethttpport\(0\)\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
fi

# Successful installation/startup
echo ""
echo "Database ready to use. Enjoy! ;)"

# Infinite wait loop, trap interrupt/terminate signal for graceful termination
trap "su oracle -c 'echo shutdown immediate\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba'" INT TERM
while true; do sleep 1; done
