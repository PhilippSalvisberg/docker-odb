#!/bin/bash

mkdirs(){
    mkdir -p ${ORACLE_BASE}/ords/params
    mkdir -p ${ORACLE_BASE}/ords/conf
    mkdir -p ${ORACLE_BASE}/ords/logs
}

set_params(){
	if [ $MULTITENANT == "true" ]; then
		THE_SERVICE_NAME=$PDB_SERVICE_NAME
	else
		THE_SERVICE_NAME=$SERVICE_NAME
	fi
	cat >${ORACLE_BASE}/ords/params/ords_params.properties <<EOF
config.dir=${ORACLE_BASE}/ords/conf
db.hostname=${HOSTNAME}
db.port=1521
db.servicename=${THE_SERVICE_NAME}
db.username=APEX_PUBLIC_USER
db.password=${PASS}
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=APEX
schema.tablespace.temp=TEMP
standalone.mode=false
standalone.use.https=false
standalone.http.port=8081
standalone.access.log=${ORACLE_BASE}/ords/logs
standalone.context.path=/ords
standalone.doc.root=${ORACLE_HOME}/ords/docs/javadoc
standalone.scheme.do.not.prompt=true
standalone.static.context.path=/i
standalone.static.do.not.prompt=true
# path to images must not contain symbolic links
standalone.static.images=${ORACLE_HOME}/apex/images
user.apex.listener.password=${PASS}
user.apex.restpublic.password=${PASS}
user.public.password=${PASS}
user.tablespace.default=APEX
user.tablespace.temp=TEMP
sys.user=SYS
sys.password=${PASS}
# to enable SQL Developer Web
restEnabledSql.active=true
feature.sdw=true
security.verifySSL=false
EOF
}

install(){
	cd ${ORACLE_HOME}/ords
	java -jar ords.war configdir ${ORACLE_BASE}/ords/conf
	java -jar ords.war install \
		--parameterFile ${ORACLE_BASE}/ords/params/ords_params.properties \
		--logDir ${ORACLE_BASE}/ords/logs \
		--silent
}

create_user_admin(){
	sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
		BEGIN
		   EXECUTE IMMEDIATE 'DROP USER admin CASCADE';
		EXCEPTION
		   WHEN OTHERS THEN
		      NULL;
		END;
		/
		CREATE USER admin IDENTIFIED BY ${PASS}
		   DEFAULT TABLESPACE users
		   TEMPORARY TABLESPACE temp
		   QUOTA UNLIMITED ON users;
		-- all these roles are required to gain full access to all SQL Developer Web components
		-- see https://docs.oracle.com/en/database/oracle/sql-developer-web/19.4/sdweb/user-management-page.html#GUID-75E439E8-A25B-4E26-821A-2F0F4558AFC4
		GRANT CONNECT, RESOURCE, PDB_DBA, DBA, ORDS_ADMINISTRATOR_ROLE to admin;
EOF
	sqlplus -s -l admin/${PASS}@${CONNECT_STRING} <<EOF
		BEGIN
		   ords.drop_rest_for_schema('ADMIN');
		   ords.enable_schema(
			   p_enabled             => true,
			   p_schema              => 'ADMIN',
			   p_url_mapping_type    => 'BASE_PATH',
			   p_url_mapping_pattern => 'admin',
			   p_auto_rest_auth      => false
		   );
		   COMMIT;
		END;
		/
EOF
}

# main
mkdirs
set_params
install
create_user_admin
