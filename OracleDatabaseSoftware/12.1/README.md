# Oracle Database 12.1 Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 7.6
* Oracle Database 12.1.0.2.0 Enterprise Edition software installation, including
  * OPatch 12.2.0.1.16 (patch 6880880)
  * Database Release Update 12.1.0.2.190115 (patch 28980115)
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 18.2.0
* Oracle REST Data Services 18.4.0

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 12.1](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase/12.1).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/12.1.0/dbhome```
