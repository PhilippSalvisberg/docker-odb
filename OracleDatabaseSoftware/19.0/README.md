# Oracle Database 19c Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 7.7
* Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 software installation, including
  * OPatch 12.2.0.1.18
  * Database Release Update 19.5.0.0.191015
  * OJVM Component Release Update 19.5.0.0.191015
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 19.2.0 
  * Patch 30392181: PSE BUNDLE FOR APEX 19.2 (PSES ON TOP OF 19.2.0.00.18)
* Oracle REST Data Services 19.4.0

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 19.0](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase/19.0).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/19.0.0/dbhome```
