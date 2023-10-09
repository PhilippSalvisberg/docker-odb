# Oracle Database 19c Enterprise Edition Software (ARM)

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux Server 8.8
* Oracle Database 19c Enterprise Edition Release 19.19.0.0.0 software installation
* Sample schemas HR, OE, PM, IX, SH, BI (old examples as of 2023-04-03, before 23c update)
* APEX 23.1.0 including Patch Set Bundle 5
* Oracle REST Data Services 23.2.3.242.1937

The purpose of this Docker image is to provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such [Oracle Database 19.0-arm](https://github.com/PhilippSalvisberg/docker-odb/blob/main/OracleDatabase/19.0-arm).

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/19.0.0/dbhome```
