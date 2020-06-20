# Oracle Database 9.2 Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* CentOS 5.11
* Oracle Database 9.2.0.4.0 Enterprise Edition software installation, including
  * Oracle 9i Release 2 (9.2.0.8) Patch Set 7 for Linux x86-64

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 9.2](https://github.com/PhilippSalvisberg/docker-odb/blob/main/OracleDatabase/9.2).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/9.2.0/dbhome```
