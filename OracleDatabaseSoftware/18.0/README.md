# Oracle Database 18.0 Enterprise Edition Software

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 7.4
* Oracle Database 18.0.0.0.0 Enterprise Edition software installation
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 5.1.4
* Oracle REST Data Services 18.1.1

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 18.0](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase/18.0).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/18.0.0/dbhome```
