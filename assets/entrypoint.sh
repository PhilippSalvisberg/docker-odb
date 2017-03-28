#!/bin/bash

# set environment 
. /assets/setenv.sh

# Exit script on non-zero command exit status
set -e

case "$1" in
	'')
		# default behaviour when no parameters are passed to the container

		# Startup database if oradata directory is found otherwise create a database
		if [ -d ${ORACLE_BASE}/oradata ]; then
			echo "Reuse existing database."
			echo "odb:$ORACLE_HOME:N" >> /etc/oratab
			chown oracle:dba /etc/oratab
			chmod 664 /etc/oratab
			rm -rf /u01/app/oracle-product/12.2.0.1/dbhome/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.2.0.1/dbhome/dbs
			gosu oracle bash -c "${ORACLE_HOME}/bin/lsnrctl start"
			gosu oracle bash -c 'echo startup\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
		else
			echo "Creating database."
			mv /u01/app/oracle-product/12.2.0.1/dbhome/dbs /u01/app/oracle/dbs
			ln -s /u01/app/oracle/dbs /u01/app/oracle-product/12.2.0.1/dbhome/dbs
			gosu oracle bash -c "${ORACLE_HOME}/bin/lsnrctl start"
			gosu oracle bash -c "${ORACLE_HOME}/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc \
			   -gdbname ${SERVICE_NAME} -sid ${ORACLE_SID} -responseFile NO_VALUE -characterSet AL32UTF8 \
			   -totalMemory $DBCA_TOTAL_MEMORY -emConfiguration DBEXPRESS -sysPassword ${PASS} -systemPassword ${PASS}"
			echo "Configure listener."
			gosu oracle bash -c 'echo -e "ALTER SYSTEM SET LOCAL_LISTENER='"'"'(ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))'"'"' SCOPE=BOTH;\n ALTER SYSTEM REGISTER;\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
			if [ $WEB_CONSOLE == "true" ]; then
				. /assets/install_apex.sh
			else
				gosu oracle bash -c 'echo EXEC DBMS_XDB.sethttpport\(0\)\; | ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba'
			fi
			echo "Installing schema SCOTT."
			export TWO_TASK=odb
			${ORACLE_HOME}/bin/sqlplus sys/${PASS}@odb as sysdba @${ORACLE_HOME}/rdbms/admin/utlsampl.sql
			unset TWO_TASK
			echo "Installing Oracle sample schemas."
			. /assets/install_oracle_sample_schemas.sh
			echo "Installing FTLDB."
			. /assets/install_ftldb.sh
			echo "Installing tePLSQL."
			. /assets/install_teplsql.sh
			echo "Installing oddgen examples/tutorials"
			. /assets/install_oddgen.sh
		fi

		# Successful installation/startup
		echo ""
		echo "Database ready to use. Enjoy! ;-)"

		# Infinite wait loop, trap interrupt/terminate signal for graceful termination
		trap "gosu oracle bash -c 'echo shutdown immediate\; | ${ORACLE_HOME}/bin/sqlplus -S / as sysdba'" INT TERM
		while true; do sleep 1; done
		;;

	*)
		# use parameters passed to the container
		
		echo ""
		echo "Overridden default behaviour. Run /assets/entrypoint.sh when ready."	
		$@
		;;
esac
