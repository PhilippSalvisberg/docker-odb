#!/bin/bash
set -e

# Prevent owner issues on mounted folders
chown -R oracle:dba /u01/app/oracle
rm -f /u01/app/oracle/product
ln -s /u01/app/oracle-product /u01/app/oracle/product

#Run Oracle root scripts
/u01/app/oraInventory/orainstRoot.sh > /dev/null 2>&1
echo | /u01/app/oracle/product/12.1.0/xe/root.sh > /dev/null 2>&1 || true

case "$1" in
	'')
		#Check for mounted database files
		if [ "$(ls -A /u01/app/oracle/oradata)" ]; then
			echo "found files in /u01/app/oracle/oradata Using them instead of initial database"
			echo "XE:$ORACLE_HOME:N" >> /etc/oratab
			chown oracle:dba /etc/oratab
			chown 664 /etc/oratab
			rm -rf /u01/app/oracle-product/12.1.0/xe/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0/xe/dbs
			#Startup Database
			su oracle -c "/u01/app/oracle/product/12.1.0/xe/bin/tnslsnr &"
			su oracle -c 'echo startup\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba'
		else
			echo "Database not initialized. Initializing database."
			mv /u01/app/oracle-product/12.1.0/xe/dbs /u01/app/oracle/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.1.0/xe/dbs
			echo "Copying sample schemas"
			rm -rf $ORACLE_HOME/demo/schema
			$ORACLE_HOME/bin/unzip /tmp/db-sample-schemas-master.zip -d $ORACLE_HOME/demo/
			mv $ORACLE_HOME/demo/db-sample-schemas-master $ORACLE_HOME/demo/schema
			cd $ORACLE_HOME/demo/schema
			perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat
			chown oracle:dba $ORACLE_HOME/demo/schema
			echo "Starting tnslsnr"
			su oracle -c "/u01/app/oracle/product/12.1.0/xe/bin/tnslsnr &"
			#create DB for SID: xe (sample schemas HR, OC, PM, IX not installed, reason nyk)
			su oracle -c "$ORACLE_HOME/bin/dbca -silent -createDatabase -templateName Data_Warehouse.dbc -gdbname xe.oracle.docker -sid xe -responseFile NO_VALUE -characterSet AL32UTF8 -totalMemory $DBCA_TOTAL_MEMORY -emConfiguration LOCAL -pdbAdminPassword oracle -sysPassword ${PASS} -systemPassword ${PASS}"
			echo "Configuring Apex console"
			cd $ORACLE_HOME/apex
			su oracle -c 'echo -e "${APEX_PASS}\n${HTTP_PORT}" | $ORACLE_HOME/bin/sqlplus -S / as sysdba @apxconf > /dev/null'
			su oracle -c 'echo -e "${ORACLE_HOME}\n\n" | $ORACLE_HOME/bin/sqlplus -S / as sysdba @apex_epg_config_core.sql > /dev/null'
			su oracle -c 'echo -e "ALTER USER ANONYMOUS ACCOUNT UNLOCK;" | $ORACLE_HOME/bin/sqlplus -S / as sysdba > /dev/null'
			echo "Database initialized."
			echo "Installing oddgen schemas."
			. /install_oddgen.sh
			if [ $WEB_CONSOLE == "true" ]; then
				echo "Upgrading APEX installation to version ${APEX_VERSION}"
				. /upgrade_apex.sh install
			else 
				echo "web management console and APEX is disabled, no need to upgrade APEX."
			fi			
		fi

		if [ $WEB_CONSOLE == "true" ]; then
			echo 'Starting web management console'
			su oracle -c 'echo EXEC DBMS_XDB.sethttpport\(${HTTP_PORT}\)\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba'
			echo "Web management console initialized. Please visit"
			echo "   - http://localhost:${HTTP_PORT}/em"
			echo "   - http://localhost:${HTTP_PORT}/apex"
		else
			echo 'Disabling web management console'
			su oracle -c 'echo EXEC DBMS_XDB.sethttpport\(0\)\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba'
		fi
		
		echo ""
		echo "Database ready to use. Enjoy! ;)"

		##
		## Workaround for graceful shutdown.
		##
		while [ "$END" == '' ]; do
			sleep 1
			trap "su oracle -c 'echo shutdown immediate\; | $ORACLE_HOME/bin/sqlplus -S / as sysdba'" INT TERM
		done
		;;

	*)
		echo "Database is not configured. Please run '/entrypoint.sh' if needed."
		$@
		;;
esac
