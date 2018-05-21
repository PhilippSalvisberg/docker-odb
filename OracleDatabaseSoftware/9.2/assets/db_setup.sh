#!/bin/bash

# ignore secure linux
setenforce Permissive

# create oracle groups
groupadd oinstall
groupadd dba
groupadd oper
groupadd apache

# create oracle user
useradd -g oinstall -G oinstall,dba oracle
useradd -g oinstall -G oinstall,dba apache

# install required OS components (without java-1.4.2-gcj-compat)
yum install -y compat-libstdc++-33-3* \
               xorg-x11-deprecated-libs-6* \
               make-3* \
               compat-db* \
               gcc-3* \
               gcc-c++-3* \
               gnome-libs-1* \
               freetype-devel* \
               fontconfig-devel* \
               xorg-x11-devel* \
               xorg-x11-deprecated-libs-devel-6* \
               compat-gcc-32-3* \
               compat-gcc-32-c++-3* \
               compat-libgcc-296-2* \
               compat-libstdc++-296-2* \
               gnome-libs-devel-1* \
               libaio-0* \
               libaio-devel-0* \
               openmotif21-2* \
               perl \
               tar \
               unzip \
               wget \
               libXp \
               libXt \
               libXtst \
               cpp \
               gcc-c++ \
               gcc \
               glibc-devel \
               glibc-headers \
               ksh \
               setarch \
               sysstat

# set download location for Oracle software which are not available for unattended downloads
ORACLE_ASSETS=https://www.salvis.com/oracle-assets

# environment variables (not configurable when creating a container)
echo "export ORACLE_BASE=/u01/app/oracle" > /.oracle_env
echo "export ORACLE_HOME=\$ORACLE_BASE/product/9.2.0/dbhome" >> /.oracle_env
echo "export PATH=/usr/sbin:\$PATH:/opt/sqlcl/bin" >> /.oracle_env
echo "export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH" >> /.oracle_env
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib" >> /.oracle_env
echo "export CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib" >> /.oracle_env
echo "export TMP=/tmp" >> /.oracle_env
echo "export TMPDIR=\$TMP" >> /.oracle_env
echo "export DISPLAY=localhost:0.0" >> /.oracle_env
chmod +x /.oracle_env

# set environment
. /.oracle_env
cat /.oracle_env >> /home/oracle/.bash_profile
cat /.oracle_env >> /root/.bashrc # .bash_profile not executed by docker

# create directories
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oraInventory
mkdir -p /tmp/oracle/Disk1
mkdir -p /tmp/oracle/Disk2
mkdir -p /tmp/oracle/Disk3
mkdir -p /tmp/oracle/patchset5
mkdir -p /tmp/oracle/patchset7

# change ownership of directories used by oracle user
chown -R oracle:oinstall /u01
chown -R oracle:oinstall /tmp/oracle
chown -R oracle:oinstall /assets

# download and extract Oracle database software including patchset 5 and patchset 7
echo "downloading Oracle database software..."
wget -q --no-check-certificate ${ORACLE_ASSETS}/oracle92/linux-x86_64/9.2.0.4-linux-amd64-Disk1.tar.gz -O /tmp/oracle/db1.tar.gz
wget -q --no-check-certificate ${ORACLE_ASSETS}/oracle92/linux-x86_64/9.2.0.4-linux-amd64-Disk2.tar.gz -O /tmp/oracle/db2.tar.gz
wget -q --no-check-certificate ${ORACLE_ASSETS}/oracle92/linux-x86_64/9.2.0.4-linux-amd64-Disk3.tar.gz -O /tmp/oracle/db3.tar.gz
wget -q --no-check-certificate ${ORACLE_ASSETS}/oracle92/linux-x86_64/p3948480_9206_Linux-x86-64.zip -O /tmp/oracle/ps5.zip
wget -q --no-check-certificate ${ORACLE_ASSETS}/oracle92/linux-x86_64/9.2.0.8-linux-amd64-Disk1.tar.gz -O /tmp/oracle/ps7.tar.gz
echo "extracting Oracle database software..."
tar xvpfz /tmp/oracle/db1.tar.gz -C /tmp/oracle/Disk1 > /dev/null
tar xvpfz /tmp/oracle/db2.tar.gz -C /tmp/oracle/Disk2 > /dev/null
tar xvpfz /tmp/oracle/db3.tar.gz -C /tmp/oracle/Disk3 > /dev/null
unzip -o /tmp/oracle/ps5.zip -d /tmp/oracle/patchset5 > /dev/null
tar xvpfz /tmp/oracle/ps7.tar.gz -C /tmp/oracle/patchset7 > /dev/null
chown oracle:oinstall -R /tmp/oracle
rm -f /tmp/oracle/db1.tar.gz
rm -f /tmp/oracle/db2.tar.gz
rm -f /tmp/oracle/db3.tar.gz
rm -f /tmp/oracle/ps5.zip
rm -f /tmp/oracle/ps7.tar.gz

# install Oracle Universion Installer from patchset 5 (9.2.0.6)
echo "running Oracle installer to install itself..."
su oracle -l -c "/tmp/oracle/patchset5/Disk1/runInstaller -waitforcompletion -ignoreSysPrereqs -silent -force -responseFile /assets/oui_install.rsp"
/u01/app/oracle/oraInventory/orainstRoot.sh
echo done

# install Oracle software into ${ORACLE_BASE} using previously installed Oracle installer
echo "running Oracle installer to install database software only..."
su oracle -l -c "${ORACLE_HOME}/oui/bin/runInstaller -waitforcompletion -ignoreSysPrereqs -silent -force -responsefile /assets/db_install.rsp"
echo -e "\n" | /u01/app/oracle/product/9.2.0/dbhome/root.sh

# install patchset 7 (9.2.0.8)
echo "running Oracle installer to install patchset 7 (9.2.0.8)..."
su oracle -l -c "/tmp/oracle/patchset7/Disk1/runInstaller -waitforcompletion -ignoreSysPrereqs -silent -force -responseFile /assets/ps8_install.rsp"
echo -e "\ny\ny\ny\n" | /u01/app/oracle/product/9.2.0/dbhome/root.sh

# cleanup
rm -r -f /tmp/*
rm -r -f /var/tmp/*
