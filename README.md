# Docker Base Image for Oracle Database 12.2.0.1 Enterprise Edition

## Content

Dockerfile including scripts to build a base image containing the following:

* Oracle Linux 7.4-1.0.4.el7.x86_64
* Oracle Database 12.2.0.1 Enterprise Edition software installation, including
  * OPatch 12.2.0.1.9 (patch 6880880)
  * Database Release Update 12.2.0.1.170814 (patch 21483023)
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 5.1.3
* Oracle REST Data Services 3.0.12

The purpose of this Docker image is provide all software components to fully automate the creation of additional Docker images.

This Docker image is not designed to create working Docker containers.

The intended use is for other Docker images such as

   * [PhilippSalvisberg/docker-oddgendemo](https://github.com/PhilippSalvisberg/docker-oddgendemo)
   * [PhilippSalvisberg/docker-oddgendemo-cdb](https://github.com/PhilippSalvisberg/docker-oddgendemo-cdb)

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make this image available on a public Docker registry.

## Environment Variable

The following environment variable values have been used for this image:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/12.2.0.1/dbhome```

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/PhilippSalvisberg/docker-oracle12ee/issues)
* [submit new issue](https://github.com/PhilippSalvisberg/docker-oracle12ee/issues/new)

## License

docker-oracle12ee is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.

See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4) regarding Oracle Database licenses.
