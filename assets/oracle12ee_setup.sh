#!/bin/bash

# ignore secure linux
setenforce Permissive

# create oracle groups
groupadd --gid 54321 oinstall
groupadd --gid 54322 dba
groupadd --gid 54323 oper

# create oracle user
useradd --create-home --gid oinstall --groups oinstall,dba --uid 54321 oracle

# install required OS components
yum install -y oracle-database-server-12cR2-preinstall.x86_64 \
               perl \
               tar \
               unzip \
               wget

# download and extract JDK (required by sqlcl)
echo "downloading JDK..."
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/jdk-8u121-linux-x64.rpm -O /tmp/jdk.rpm
echo "installing JDK..."
rpm -i /tmp/jdk.rpm
rm /tmp/jdk.rpm              

# environment variables (not configurable when creating a container)
echo "export JAVA_HOME=\$(readlink -f /usr/bin/javac | sed \"s:/bin/javac::\")" > /.oracle_env 
echo "export ORACLE_HOME=/u01/app/oracle/product/12.2.0.1/dbhome" >> /.oracle_env
echo "export ORACLE_BASE=/u01/app/oracle" >> /.oracle_env
echo "export PATH=/usr/sbin:\$PATH:/opt/sqlcl/bin" >> /.oracle_env
echo "export PATH=\$ORACLE_HOME/bin:\$PATH" >> /.oracle_env
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib" >> /.oracle_env
echo "export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib" >> /.oracle_env
echo "export TMP=/tmp" >> /.oracle_env
echo "export TMPDIR=\$TMP" >> /.oracle_env
echo "export TERM=linux" >> /.oracle_env # avoid in sqlcl: "tput: No value for $TERM and no -T specified"
chmod +x /.oracle_env

# set environment
. /.oracle_env
cat /.oracle_env >> /home/oracle/.bash_profile
cat /.oracle_env >> /root/.bashrc # .bash_profile not executed by docker

# create directories and separate /u01/app/oracle/product to mount ${ORACLE_BASE} as volume
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle-product 
mkdir -p /u01/app/oraInventory
mkdir -p /tmp/oracle
chown -R oracle:oinstall /u01
chown -R oracle:oinstall /tmp/oracle
ln -s /u01/app/oracle-product /u01/app/oracle/product

# install gosu as workaround for su problems (see http://grokbase.com/t/gg/docker-user/162h4pekwa/docker-su-oracle-su-cannot-open-session-permission-denied)
wget -q --no-check-certificate "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64"  -O /usr/local/bin/gosu
chmod +x /usr/local/bin/gosu

# download and extract Oracle database software
cd /tmp/oracle
echo "downloading Oracle database software..."
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/linuxx64_12201_database.zip -O /tmp/oracle/db1.zip
chown oracle:oinstall /tmp/oracle/db1.zip
echo "extracting Oracle database software..."
gosu oracle bash -c "unzip -o /tmp/oracle/db1.zip -d /tmp/oracle/" > /dev/null
rm -f /tmp/oracle/db1.zip

# install Oracle software into ${ORACLE_BASE}
chown oracle:oinstall /assets/db_install.rsp
echo "running Oracle installer to install database software only..."
gosu oracle bash -c "/tmp/oracle/database/runInstaller -silent -force -waitforcompletion -responsefile /assets/db_install.rsp -ignoresysprereqs -ignoreprereq"

# Run Oracle root scripts
echo "running Oracle root scripts..."
#/u01/app/oraInventory/orainstRoot.sh > /dev/null 2>&1
echo | ${ORACLE_HOME}/root.sh > /dev/null 2>&1 || true

# download and extract Oracle sample schemas
echo "downloading Oracle sample schemas..."
wget -q --no-check-certificate https://github.com/oracle/db-sample-schemas/archive/master.zip -O /tmp/db-sample-schemas-master.zip
rm -r -f ${ORACLE_HOME}/demo/schema
echo "extracting Oracle sample schemas..."
unzip /tmp/db-sample-schemas-master.zip -d ${ORACLE_HOME}/demo/ > /dev/null
mv ${ORACLE_HOME}/demo/db-sample-schemas-master ${ORACLE_HOME}/demo/schema
# ensure ORACLE_HOME does not contain soft links to avoid "ORA-22288: file or LOB operation FILEOPEN failed"  (for Oracle sample schemas)
ORACLE_HOME=`readlink -f ${ORACLE_HOME}`
cd ${ORACLE_HOME}/demo/schema
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat > /dev/null
# reset environment (ORACLE_HOME)
. /.oracle_env
chown oracle:oinstall ${ORACLE_HOME}/demo/schema
rm -f /tmp/db-sample-schemas-master.zip

# download and extract SQL Developer CLI as workaround for SQL*Plus issues with "SET TERMOUT OFF/ON"
echo "downloading SQL Developer CLI..."
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/sqlcl-4.2.0.17.073.1038-no-jre.zip -O /tmp/sqlcl.zip
echo "extracting SQL Developer CLI..."
unzip /tmp/sqlcl.zip -d /opt > /dev/null
chown -R oracle:oinstall /opt/sqlcl
rm -f /tmp/sqlcl.zip

# rename original APEX folder
mv ${ORACLE_HOME}/apex ${ORACLE_HOME}/apex.old

# download and extract APEX software
echo "downloading APEX..."
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/apex_5.1.1_en.zip -O /tmp/apex.zip
rm -r -f ${ORACLE_HOME}/demo/apex
echo "extracting APEX..."
unzip -o /tmp/apex.zip -d ${ORACLE_HOME} > /dev/null
chown -R oracle:oinstall ${ORACLE_HOME}/apex
rm -f /tmp/apex.zip

# cleanup
rm -r -f /tmp/* 
rm -r -f /var/tmp/* \
