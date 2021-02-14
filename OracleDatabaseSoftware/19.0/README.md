# Oracle Database 19c Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 7.9
* Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 software installation, including
  * OPatch 12.2.0.1.23
  * Database Release Update 19.10.0.0.210119
  * OJVM Component Release Update 19.10.0.0.210119
  * Patch for Bug# 32431413 (regarding Blockchain Tables)
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 20.2.0 
  * Patch Set Exception: Bug 32006852 - PSE BUNDLE FOR APEX 20.2 (Patch Version 2021.02.05)
* Oracle REST Data Services 20.4.1

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 19.0](https://github.com/PhilippSalvisberg/docker-odb/blob/main/OracleDatabase/19.0).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/19.0.0/dbhome```
