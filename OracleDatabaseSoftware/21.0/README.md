# Oracle Database 21c Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 7.9
* Oracle Database 19c Enterprise Edition Release 21.0.0.0.0 Version 21.3.0.0.0 software installation, including
  * OPatch 12.2.0.1.34 for DB 21.0.0.0.0 (Nov 2022)
  * Database Release Update 21.8.0.0.221018
  * JDK Bundle Patch 21.0.0.0.221018
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 22.2.0
* Oracle REST Data Services 22.3.3.r3111929

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 21.0](https://github.com/PhilippSalvisberg/docker-odb/blob/main/OracleDatabase/21.0).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/21.0.0/dbhome```
