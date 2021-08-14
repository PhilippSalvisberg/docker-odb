# Oracle Database 21c Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 7.9
* Oracle Database 19c Enterprise Edition Release 21.0.0.0.0 Version 21.3.0.0.0 software installation
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 21.1.0 
  * Bug 32598392 - PSE BUNDLE FOR APEX 21.1 (PSES ON TOP OF 21.1.0) (Patch Version 2)
* Oracle REST Data Services 21.2.0

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
