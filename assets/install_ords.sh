#!/bin/bash

set_params(){
	if [ $MULTITENANT == "true" ]; then
		THE_SERVICE_NAME=$PDB_SERVICE_NAME
	else
		THE_SERVICE_NAME=$SERVICE_NAME
	fi
	cat >${ORACLE_HOME}/ords/params/ords_params.properties <<EOF
config.dir=${ORACLE_HOME}/ords/conf
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
standalone.access.log=${ORACLE_HOME}/ords/logs/access_log
standalone.context.path=/ords
standalone.doc.root=${ORACLE_HOME}/ords/docs/javadoc
standalone.scheme.do.not.prompt=true
standalone.static.context.path=/i
standalone.static.do.not.prompt=true
# path to images must not contain symbolic links
standalone.static.images=/u01/app/oracle-product/12.2.0.1/dbhome/apex/images
user.apex.listener.password=${PASS}
user.apex.restpublic.password=${PASS}
user.public.password=${PASS}
user.tablespace.default=APEX
user.tablespace.temp=TEMP
sys.user=SYS
sys.password=${PASS}
EOF
}

install(){
	cd ${ORACLE_HOME}/ords
	java -jar ords.war configdir conf
	java -jar ords.war
}

# main
set_params
install
